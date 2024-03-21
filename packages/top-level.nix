{ callPackage }:

{
  nginx = (callPackage ./nginx.nix { });
}
