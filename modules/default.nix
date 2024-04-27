{ agenix, home-manager, ... }:

{
  imports = [
    home-manager.nixosModule
    agenix.nixosModules.default

    ./acme.nix
    ./common.nix
    ./dns.nix
    ./move-killer
    ./nginx-defaults.nix
    ./overlays.nix
    ./ssh.nix
    ./telegram-backup.nix
    ./users.nix
    ./f0urnald
  ];
}
