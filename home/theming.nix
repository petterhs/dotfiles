{
  fonts.fontconfig.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
    cursors = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
    };
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
