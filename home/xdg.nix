# XDG stands for "Cross-Desktop Group", with X used to mean "cross".
# It's a bunch of specifications from freedesktop.org intended to standardize desktops and
# other GUI applications on various systems (primarily Unix-like) to be interoperable:
#   https://www.freedesktop.org/wiki/Specifications/
{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
    flatpak # needed for flatpak make-default command
  ];

  # Set Zen browser as default using Flatpak
  home.activation.setZenBrowserDefault = ''
    if command -v flatpak >/dev/null 2>&1; then
      if flatpak list --app | grep -q "app.zen_browser.zen"; then
        flatpak make-default app.zen_browser.zen 2>/dev/null || true
      fi
    fi
  '';

  xdg.configFile."mimeapps.list".force = true;
  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    # manage $XDG_CONFIG_HOME/mimeapps.list
    # xdg search all desktop entries from $XDG_DATA_DIRS, check it by command:
    #  echo $XDG_DATA_DIRS
    # the system-level desktop entries can be list by command:
    #   ls -l /run/current-system/sw/share/applications/
    # the user-level desktop entries can be list by command(user ryan):
    #  ls /etc/profiles/per-user/ryan/share/applications/
    desktopEntries = {
      "zen-browser" = {
        name = "Zen Browser";
        genericName = "Web Browser";
        exec = "flatpak run app.zen_browser.zen %u";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        mimeType = [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/ftp"
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/xml"
          "application/rdf+xml"
          "application/rss+xml"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
        ];
      };
      "nvim" = {
        name = "Neovim";
        genericName = "Text Editor";
        exec = "alacritty -e nvim %F";
        terminal = false;
        categories = [
          "TextEditor"
          "Utility"
        ];
        mimeType = [
          "text/plain"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-java"
          "text/x-dsrc"
          "text/x-pascal"
          "text/x-perl"
          "text/x-python"
          "text/x-rust"
          "text/x-markdown"
          "text/x-toml"
          "text/x-yaml"
          "text/x-json"
          "application/x-shellscript"
        ];
        startupNotify = true;
        icon = "nvim.png";
      };
    };

    mimeApps = {
      enable = true;
      # let `xdg-open` to open the url with the correct application.
      defaultApplications =
        let
          # Use Flatpak's desktop entry for Zen browser (preferred) or fallback to our wrapper
          # Flatpak desktop entries are typically: app.zen_browser.zen.desktop
          browser = [
            "app.zen_browser.zen.desktop"
            "zen-browser.desktop"
          ];
          editor = [ "nvim.desktop" ];
        in
        {
          # Web content and documents
          "application/json" = browser;
          "application/pdf" = browser; # TODO: pdf viewer
          "text/html" = browser;
          "text/xml" = browser;
          "application/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xhtml_xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/x-extension-xht" = browser;
          "application/x-extension-xhtml" = browser;

          # URL scheme handlers
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/ftp" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;

          # Text files
          "text/plain" = editor;
          "application/x-wine-extension-ini" = editor;

          "audio/*" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];
        };

      associations.removed = {
        # ......
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
