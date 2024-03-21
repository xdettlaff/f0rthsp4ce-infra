{ lib, pkg-config, openssl, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "notif";
  version = "0.1.0";

  src = ./.;

  cargoHash = "sha256-VaParZzPusHAe3BSlGwNsAOa/8XzwnP0v3nPUYdW+rI=";
}