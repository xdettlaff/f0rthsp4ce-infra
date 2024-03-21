{ config, lib, pkgs, ... }:

let
  lid = pkgs.writeScriptBin "lid" ''
    #!${pkgs.bash}/bin/bash
    while true; do
      if grep -q open /proc/acpi/button/lid/*/state; then
        CONFIG_FILE=${config.age.secrets.credentials-notif-config.path} ${pkgs.notif}/bin/ping admins "Смертный посмел открыть мою крышку"
        sleep 1
        # systemctl reboot
      fi
      sleep 0.5
    done
  '';
in {
  age.secrets.credentials-notif-config.file =
    ../../../secrets/credentials/notif-config.age;

  systemd.services.lid = {
    description = "Lid";

    wantedBy = [ "multi-user.target" ];
    wants = [ "acpid.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${lid}/bin/lid";
      Restart = "always";
    };
  };

  services.acpid.enable = true;
}
