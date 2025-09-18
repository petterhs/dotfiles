# Teams customization and background configuration
{
  services.caddy = {
    enable = true;
    virtualHosts."localhost".extraConfig = ''
      root * /var/www/
      file_server browse
      tls internal
    '';
  };
}
