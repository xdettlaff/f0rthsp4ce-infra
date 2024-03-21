{
  description = "f0rthsp4ce server configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    flake-utils.url = "github:numtide/flake-utils";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cofob-home = {
      url = "github:cofob/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    botka-v0 = {
      url = "github:f0rthsp4ce/botka/4ada593690610da9a7105913c9564b9f673c267e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    botka-v1 = {
      url = "github:f0rthsp4ce/botka";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, agenix, lanzaboote, botka-v0, botka-v1
    , ... }@attrs:
    {
      nixosConfigurations = builtins.mapAttrs (key: value:
        (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [ ./machines/${key} ];
        })) (builtins.readDir ./machines);

      overlays.default = final: prev: (import ./overlay.nix final attrs);
    } // flake-utils.lib.eachSystem
    (with flake-utils.lib.system; [ x86_64-linux i686-linux aarch64-linux ])
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ agenix.packages.${system}.default pkgs.nixfmt ];
        };

        packages = {
          ci-cache = pkgs.stdenv.mkDerivation {
            name = "ci-cache";
            version = "0.1.0";
            buildInputs = (
              [
                pkgs.zerotierone # zerotier is unfree and not built in nixpkgs cache
              ] ++
              builtins.attrValues (import ./overlay.nix pkgs attrs)
            );
            phases = [ "installPhase" ];
            installPhase = "echo 'ci-cache' > $out";
          };
        } // (import ./overlay.nix pkgs attrs);
      });
}
