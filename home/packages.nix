# /etc/nixos/home/packages.nix
{
  pkgs,
  rustToolchain,
  inputs,
  ...
}:
{
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
      nixd
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
      libnotify
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
}
