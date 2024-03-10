{ config, lib, pkgs, ... }:

let
  lid = pkgs.writeScriptBin "lid" ''
    while true; do
      if grep -q open /proc/acpi/button/lid/*/state; then
        (cd /root/notif/ && ./ping admins "Смертный посмел открыть мою крышку")
        sleep 1
        # systemctl reboot
      fi
      sleep 0.5
    done
  '';
in {
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
