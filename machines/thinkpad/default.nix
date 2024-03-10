{ ... }:

{
  imports = [
    ./services

    ../../modules
    ../../hardware/thinkpad.nix
  ];

  services.serial-reader.enable = true;
  services.f0runald.enable = true;

  services.logind.lidSwitch = "ignore";

  virtualisation.docker.enable = true;

  networking.firewall.allowedTCPPorts = [
    22 # ssh
    2053 # shadowsocks control panel
    8388 # shadowsocks
    42777 # telegram-bot

    # gameservers:
    # 	minecraft
    25565 # minecraft
    8200 # bluemap
    4326 # web rcon
    4327 # web rcon ws
    19132 # minecraft bedrock
  ];
  networking.firewall.allowedUDPPorts = [
    19132 # minecraft bedrock
  ];

  networking = { hostName = "thinkpad"; };
}
