# /etc/nixos/home/session.nix
{ config, ... }:
{
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
}
