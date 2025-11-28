{ pkgs, config, lib, ... }:

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
    theme = lib.mkForce {
      name = "Catppuccin-Mocha-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        variant = "mocha";
        size = "compact";
      };
    };
    # iconTheme is handled by catppuccin module automatically
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # dconf settings for GNOME apps (like file-roller)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Catppuccin-Mocha-Compact-Pink-Dark";
    };
  };

  # Configure qt5ct and qt6ct for dark theme
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=Papirus-Dark
    color_scheme_path=
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    style=adwaita-dark
    icon_theme=Papirus-Dark
    color_scheme_path=
  '';
}
