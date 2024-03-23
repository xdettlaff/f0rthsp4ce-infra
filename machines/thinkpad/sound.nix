{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # mpg123
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

}
