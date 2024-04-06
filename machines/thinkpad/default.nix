{ ... }:

{
  imports = [
    ./services

    ./audio.nix

    ../../modules
    ../../hardware/thinkpad.nix
    # ../../machines/thinkpad/sound.nix
  ];

  services.serial-reader.enable = true;

  services.logind.lidSwitch = "ignore";

  virtualisation.docker.enable = true;
  virtualisation.docker.logDriver = "json-file";

  nixpkgs.config.allowUnfree = true;
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "856127940c577285" ];
  };

  networking.firewall.allowedTCPPorts = [
    22 # ssh
    2053 # shadowsocks control panel
    8388 # shadowsocks
    42777 # telegram-bot
  ];

  networking = { hostName = "thinkpad"; };
}
