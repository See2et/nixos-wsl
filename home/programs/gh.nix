# /etc/nixos/home/programs/gh.nix
{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-notify ];
  };
}
