{ lib, pkgs, ... }:

let
  run-rcon =
    "${pkgs.docker}/bin/docker run --network papermc_default --rm --interactive itzg/rcon-cli --host papermc --password f0rthsp4ce";
in {
  users.users.gameserver = {
    isSystemUser = true;
    group = "gameserver";
  };
  users.groups.gameserver = { };

  services.borgbackup.jobs.minecraft = rec {
    paths = "/home/gameserver/gameservers/minecraft/papermc/server";
    exclude = [ "${paths}/bluemap/web/maps" ];
    encryption.mode = "none";
    repo = "/backups/minecraft";
    doInit = true;
    compression = "auto,zstd";
    startAt = "0/4:00:00 UTC"; # Every 4 hours
    preHook = ''echo -e "save-off\nsave-all" | ${run-rcon} '';
    postHook = ''echo "save-on" | ${run-rcon} '';
  };

  virtualisation.docker.enable = lib.mkDefault true;
}
