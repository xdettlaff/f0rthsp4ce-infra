{ config, lib, pkgs, ... }:

let pythonEnv = pkgs.python3.withPackages (ps: with ps; [ pyserial websocket-client ]);
in {
  options = {
    services.serial-reader = {
      enable = lib.mkEnableOption "Whether to enable serial reader";
    };
  };

  config = lib.mkIf (config.services.serial-reader.enable) {
    age.secrets.credentials-move-killer.file =
      ../../secrets/credentials/move-killer.age;

    systemd.services.serial-reader = {
      description = "Serial Reader Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.notif ];
      environment = {
        CONFIG_FILE = config.age.secrets.credentials-notif-config.path;
      };
      serviceConfig = {
        EnvironmentFile = config.age.secrets.credentials-move-killer.path;
        ExecStart = "${pythonEnv}/bin/python ${./move_killer.py}";
        Restart = "always";
        User = "root";
      };
    };
  };
}
