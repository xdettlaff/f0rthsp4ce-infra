{ config, lib, pkgs, ... }:

let pythonEnv = pkgs.python3.withPackages (ps: with ps; [ pyserial ]);
in {
  options = {
    services.serial-reader = {
      enable = lib.mkEnableOption "Whether to enable serial reader";
    };
  };

  config = lib.mkIf (config.services.serial-reader.enable) {
    systemd.services.serial-reader = {
      description = "Serial Reader Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/python ${./move_killer.py}";
        Restart = "always";
        User = "root";
      };
    };
  };
}
