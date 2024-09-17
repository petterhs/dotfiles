{
  fonts.fontconfig.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
    pointerCursor = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
    };
  };

  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
      icon = {
        enable = true;
        accent = "lavender";
      };
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
