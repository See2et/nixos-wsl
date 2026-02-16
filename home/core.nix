# /etc/nixos/home/core.nix
{ isDarwin, ... }:
{
  home.username = if isDarwin then "see2et" else "nixos";
  home.homeDirectory = if isDarwin then "/Users/see2et" else "/home/nixos";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
