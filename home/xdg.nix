# /etc/nixos/home/xdg.nix
{ ... }:
{
  xdg.configFile = {
    "nvim".source = ../nvim;
    "zellij".source = ../zellij;
  };

  xdg.enable = true;
}
