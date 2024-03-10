let
  user-keys = import ./ssh-keys.nix;

  users = user-keys.cofob ++ user-keys.dettlaff ++ user-keys.tar-xzf
    ++ user-keys.mike;

  thinkpad =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUC3bR6lz0DpgzaiAE0SUL2UYlbtHwT7NLsHU53ySUH";
  systems = [ thinkpad ];

  all = users ++ systems;
in {
  # User passwords
  "secrets/passwords/cofob.age".publicKeys = all;
  "secrets/passwords/def.age".publicKeys = all;
  "secrets/passwords/tar.age".publicKeys = all;
  "secrets/passwords/mike.age".publicKeys = all;

  # Services
  "secrets/credentials/botka-v0.age".publicKeys = users ++ [ thinkpad ];
  "secrets/credentials/botka-v1.age".publicKeys = users ++ [ thinkpad ];
  "secrets/credentials/f0runald.age".publicKeys = users ++ [ thinkpad ];
}
