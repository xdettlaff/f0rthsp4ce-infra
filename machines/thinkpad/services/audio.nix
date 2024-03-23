{ ... }:

{
  services.pipewire = {
    enable = true;
    systemWide = true;
    audio.enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
  };
}
