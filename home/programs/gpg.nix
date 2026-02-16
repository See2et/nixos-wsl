# /etc/nixos/home/programs/gpg.nix
{ ... }:
{
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
    };
  };
}
