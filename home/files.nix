# /etc/nixos/home/files.nix
{ lib, isDarwin, ... }:
{
  home.file = {
    ".gitconfig".source = ../.gitconfig;
    ".p10k.zsh".source = ../.p10k.zsh;
    ".codex/config.toml".source = ../codex/config.toml;
    ".codex/AGENTS.md".source = ../codex/AGENTS.md;
    ".codex/github-mcp.sh" = {
      source = ../codex/github-mcp.sh;
      executable = true;
    };
    "yubikey-setup.sh" = {
      source = ../yubikey-setup.sh;
      executable = true;
    };
    ".config/opencode/opencode.jsonc".source = ../opencode/opencode.jsonc;
    ".config/opencode/oh-my-opencode.jsonc".source = ../opencode/oh-my-opencode.jsonc;
    ".config/opencode/AGENTS.md".source = ../opencode/AGENTS.md;
    ".config/opencode/themes/tokyonight-transparent.json".source =
      ../opencode/themes/tokyonight-transparent.json;
  }
  // lib.optionalAttrs (!isDarwin) {
    ".config/opencode/opencode-notifier.json".source = ../opencode/opencode-notifier.json;
    ".local/bin/opencode-wsl-notify" = {
      source = ../opencode/opencode-wsl-notify;
      executable = true;
    };
  };
}
