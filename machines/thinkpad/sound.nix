{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpg123
    # pipewire
    alsa-utils # Добавляем утилиты ALSA (включая aplay)
    pulseaudio
  ];

  sound.enable = true;
  # 
  #   security.rtkit.enable = true;

  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   pulse.enable = true;
  #   wireplumber.enable = true;
  # };

  # hardware.pulseaudio.enable = true;  # Включаем PulseAudio

  # sound.enable = true;  # Включаем поддержку звука в NixOS

  # Если вы используете звуковую карту или драйвер, которому нужны дополнительные настройки, укажите их здесь

  services.udev.packages =
    [ pkgs.alsa-utils ]; # Добавляем правила udev для ALSA

  services.jack = {
    jackd.enable = true;
    # support ALSA only programs via ALSA JACK PCM plugin
    alsa.enable = false;
    # support ALSA only programs via loopback device (supports programs like Steam)
    loopback = {
      enable = true;
      # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
      #dmixConfig = ''
      #  period_size 2048
      #'';
    };
  };

  users.extraUsers.def.extraGroups = [ "jackaudio" ];

}
