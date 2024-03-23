{ lib, pkg-config, openssl, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "notif";
  version = "0.1.0";

  src = ./.;

  cargoHash = "sha256-qinimo5C/T60R9cSpjn7Cz4XQCQMCbg4olSKkOwzr2Q=";
}
