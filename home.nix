# /etc/nixos/home.nix
{
  imports = [
    ./home/core.nix
    ./home/packages.nix
    ./home/files.nix
    ./home/xdg.nix
    ./home/session.nix
    ./home/programs/git.nix
    ./home/programs/gh.nix
    ./home/programs/gpg.nix
    ./home/programs/zsh
  ];
}
