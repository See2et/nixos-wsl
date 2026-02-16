# /etc/nixos/home/programs/git.nix
{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
