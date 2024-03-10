{ ... }:

{
  services.nginx.enable = true;
  services.nginx.virtualHosts."mc.f0rth.space" = {
    forceSSL = true;
    enableACME = true;

    extraConfig = ''
      access_log off;
    '';

    locations."/".proxyPass = "http://localhost:8100";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
