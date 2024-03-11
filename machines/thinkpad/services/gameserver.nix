{ config, lib, pkgs, ... }:

let
  run-rcon = pkgs.writeScriptBin "run-rcon" ''
    #!${pkgs.bash}/bin/bash
    PASSWORD=$(cat $1)
    cat /dev/stdin | ${pkgs.docker}/bin/docker run --network papermc_default \
                     --rm --interactive itzg/rcon-cli --host papermc --password $PASSWORD
  '';
in {
  age.secrets.credentials-minecraft-rcon.file =
    ../../../secrets/credentials/minecraft-rcon.age;

  services.borgbackup.jobs.minecraft = rec {
    paths = "/root/gameservers/minecraft/papermc/server";
    exclude = [ "${paths}/bluemap/web/maps" ];
    encryption.mode = "none";
    repo = "/backups/minecraft";
    doInit = true;
    compression = "auto,zstd";
    startAt = "0/4:00:00 UTC"; # Every 4 hours
    preHook = ''
      echo -e "save-off\nsave-all" | ${run-rcon}/bin/run-rcon ${config.age.secrets.credentials-minecraft-rcon.path}'';
    postHook = ''
      echo "save-on" | ${run-rcon}/bin/run-rcon ${config.age.secrets.credentials-minecraft-rcon.path}'';
  };

  virtualisation.docker.enable = lib.mkDefault true;
}
