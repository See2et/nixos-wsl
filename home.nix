# /etc/nixos/home.nix  (統合後の正本)home
{
  config,
  pkgs,
  rustToolchain,
  lib,
  isDarwin,
  inputs,
  ...
}:
{
  home.username = if isDarwin then "see2et" else "nixos";
  home.homeDirectory = if isDarwin then "/Users/see2et" else "/home/nixos";

  home.stateVersion = "25.05";

  home.packages =
    (with pkgs; [
      neovim
      zsh
      gcc
      unzip
      rust-analyzer
      tre-command
      lsd
      nixfmt-rfc-style
      gh
      ghq
      lazygit
      zellij
      zenn-cli
      peco
      zoxide
      nodejs_24
      bun
      pnpm
      yarn
      deno
      uv
      fastfetch
      tree-sitter
      yt-dlp
      ripgrep
      wl-clipboard
      xclip
      ffmpeg
      fzf
      markdownlint-cli2
      yubikey-manager
      wget # for VSCode Server
    ])
    ++ [
      rustToolchain
      inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex-node
      inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    ];

  home.file = {
    ".gitconfig".source = ./.gitconfig;
    ".p10k.zsh".source = ./.p10k.zsh;
    ".codex/config.toml".source = ./codex/config.toml;
    ".codex/AGENTS.md".source = ./codex/AGENTS.md;
    ".codex/github-mcp.sh" = {
      source = ./codex/github-mcp.sh;
      executable = true;
    };
    "yubikey-setup.sh" = {
      source = ./yubikey-setup.sh;
      executable = true;
    };
    ".config/opencode/opencode.jsonc".source = ./opencode/opencode.jsonc;
    ".config/opencode/oh-my-opencode.jsonc".source = ./opencode/oh-my-opencode.jsonc;
    ".config/opencode/AGENTS.md".source = ./opencode/AGENTS.md;
    ".config/opencode/themes/tokyonight-transparent.json".source =
      ./opencode/themes/tokyonight-transparent.json;
  };

  xdg.configFile = {
    "nvim".source = ./nvim;
    "zellij".source = ./zellij;
  };

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    UV_TOOL_DIR = "${config.xdg.dataHome}/uv/tools";
    UV_TOOL_BIN_DIR = "${config.xdg.dataHome}/uv/tools/bin";
    PATH = ''
      $PATH:/mnt/c/Users/See2et/AppData/Local/Programs/Microsoft\ VS\ Code/bin
    '';
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "${config.xdg.dataHome}/uv/tools/bin"
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-notify ];
  };

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  programs.zsh = {
    enable = true;

    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi

          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
        zshConfig = lib.mkOrder 1000 ''
          export ABBR_QUIET=1
          ABBR_SET_EXPANSION_CURSOR=1

          typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

          eval "$(zoxide init zsh)"
          eval "$(${pkgs.uv}/bin/uv generate-shell-completion zsh)"

          function peco-ghq () {
            cd "$( ghq list --full-path | peco --prompt "REPO> " --layout=bottom-up)"
          }
          abbr -S gp='peco-ghq'

          function peco-git-switch() {
            local sel branch
            sel=$(
              git for-each-ref --format='%(refname:short)' refs/heads \
              | peco --prompt "BRANCH> " --query "$LBUFFER" --layout=bottom-up --print-query \
              | tail -n 1
            ) || return

            [[ -z "$sel" ]] && return
            branch="$sel"

            if git show-ref --verify --quiet "refs/heads/$branch"; then
              git switch "$branch"
            else
              git switch -c "$branch"
            fi
          }
          abbr -S gsp="peco-git-switch"

          function peco-history() {
            local selected_command=$(fc -l -n 1 | tail -300 | awk '!seen[$0]++ { lines[++count] = $0 } END { for (i = count; i >= 1; i--) print lines[i] }' | peco --prompt "HISTORY>" --layout=bottom-up)

            if [ -n "$selected_command" ]; then
              print -s "$selected_command"
              echo "Executing: $selected_command"
              eval "$selected_command"
            fi
          }
          abbr -S hp="peco-history"

          function peco-zoxide() {
            local dir
            dir=$(zoxide query -l | peco --prompt "DIR> " --layout=bottom-up)
            [[ -n "$dir" ]] && cd "$dir"
          }
          abbr -S zp="peco-zoxide"

          function fzf-git-worktree() {
            local git_common_dir main_repo ghq_root repo_path worktree_repo_root
            local branches branch branch_list wt_path result query key selected
            local remote_url

            git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return

            if [[ "$git_common_dir" == ".git" ]]; then
              main_repo=$(git rev-parse --show-toplevel 2>/dev/null) || return
            else
              main_repo="''${git_common_dir%/.git}"
            fi

            ghq_root=$(ghq root 2>/dev/null) || return
            if [[ "$main_repo" == "$ghq_root/"* ]]; then
              repo_path="''${main_repo#"$ghq_root/"}"
            else
              remote_url=$(git -C "$main_repo" remote get-url origin 2>/dev/null) || return
              repo_path=$(printf "%s" "$remote_url" | sed -E 's#(git@|https://)##; s#:#/#; s#\\.git$##')
            fi

            worktree_repo_root="$HOME/worktrees/$repo_path"
            mkdir -p "$worktree_repo_root"

            branches=$(git -C "$main_repo" for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin | sed 's#^origin/##' | sort -u)

            while IFS= read -r branch; do
              [[ -z "$branch" ]] && continue
              wt_path="$worktree_repo_root/''${branch//\//-}"
              if [[ -d "$wt_path" ]]; then
                branch_list+="''${branch}"$'\t'"[worktree: ''${wt_path}]"$'\n'
              else
                branch_list+="''${branch}"$'\n'
              fi
            done <<< "$branches"

            result=$(printf "%s" "$branch_list" | fzf --prompt "WORKTREE> " --layout=bottom-up --delimiter=$'\t' --with-nth=1 --expect=ctrl-n,ctrl-d --print-query --header "Enter: switch | Ctrl-n: new branch | Ctrl-d: delete") || return

            query=$(printf "%s\n" "$result" | sed -n '1p')
            key=$(printf "%s\n" "$result" | sed -n '2p')
            selected=$(printf "%s\n" "$result" | sed -n '3p' | awk -F $'\t' '{print $1}')

            case "$key" in
              ctrl-n)
                branch="$query"
                [[ -z "$branch" ]] && return
                ;;
              *)
                branch="$selected"
                [[ -z "$branch" ]] && return
                ;;
            esac

            wt_path="$worktree_repo_root/''${branch//\//-}"

            case "$key" in
              ctrl-d)
                [[ -d "$wt_path" ]] || return
                read -q "REPLY?Delete worktree at ''${wt_path}? [y/N] " || return
                echo
                [[ "$REPLY" =~ ^[Yy]$ ]] || return
                git -C "$main_repo" worktree remove "$wt_path"
                ;;
              *)
                if [[ -d "$wt_path" ]]; then
                  cd "$wt_path"
                else
                  if git -C "$main_repo" show-ref --verify --quiet "refs/heads/$branch"; then
                    git -C "$main_repo" worktree add "$wt_path" "$branch" || return
                  else
                    git -C "$main_repo" worktree add -b "$branch" "$wt_path" || return
                  fi
                  cd "$wt_path"
                fi
                ;;
            esac
          }
          abbr -S gw="fzf-git-worktree"

          function fzf-git-worktree-widget() {
            zle -I
            fzf-git-worktree
            zle reset-prompt
          }
          zle -N fzf-git-worktree-widget
          bindkey "^[b" fzf-git-worktree-widget
        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
      ];

    zsh-abbr = {
      enable = true;
      abbreviations = {
        v = "nvim";
        ll = "lsd -alF";
        ls = "lsd";
        la = "lsd -altr";
        lg = "lazygit";
        bat = "batcat";
        ze = "zellij --layout 1p2p";
        up = "cd ../";
        cl = "clear";

        re =
          if isDarwin then
            "home-manager switch --flake /etc/nixos#darwin"
          else
            "sudo nixos-rebuild switch --flake /etc/nixos#nixos";

        gcm = ''git commit -S -m "%"'';
      };
    };

    antidote = {
      enable = true;
      plugins = [
        "ohmyzsh/ohmyzsh"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "romkatv/powerlevel10k"
        "Tarrasch/zsh-bd"
      ];
    };
  };
}
