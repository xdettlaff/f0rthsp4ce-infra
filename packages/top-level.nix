{ callPackage }:

{
  upgrade-system = callPackage ./upgrade-system.nix { };
  nginx = (callPackage ./nginx.nix { });
}
