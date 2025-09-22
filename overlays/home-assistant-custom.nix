self: super: {
  home-assistant-custom-components = (super.home-assistant-custom-components or {}) // {
    plant = super.callPackage (
      { lib, buildHomeAssistantComponent, fetchFromGitHub }:
      buildHomeAssistantComponent rec {
        owner = "Olen";
        domain = "plant";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "homeassistant-plant";
          # Pin as needed (master for now)
          rev = "master";
          hash = "sha256-jpmfmflS2w7WoiPcIG8HR/cUisNiJwG+LBwRCAbQsZc=";
        };
        meta = {
          description = "Custom Plant integration for Home Assistant (Olen fork)";
          homepage = "https://github.com/Olen/homeassistant-plant";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ ];
        };
      }
    ) { };

    openplantbook = super.callPackage (
      { lib, buildHomeAssistantComponent, fetchFromGitHub }:
      buildHomeAssistantComponent rec {
        owner = "Olen";
        domain = "openplantbook";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "home-assistant-openplantbook";
          rev = "master";
          hash = "sha256-PSax6WFUSEouJL1jes9T+nWdVh8ix5Ue5NE8TeScNfM=";
        };
        meta = {
          description = "OpenPlantBook custom integration for Home Assistant";
          homepage = "https://github.com/Olen/home-assistant-openplantbook";
          license = lib.licenses.gpl3Only;
          maintainers = with lib.maintainers; [ ];
        };
      }
    ) { };
  };

  home-assistant-custom-lovelace-modules = (super.home-assistant-custom-lovelace-modules or {}) // {
    "flower-card" = super.callPackage (
      { lib, buildNpmPackage, fetchFromGitHub }:
      buildNpmPackage rec {
        pname = "flower-card";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "lovelace-flower-card";
          rev = "master";
          hash = "sha256-IwhhORWpKjR9APyeuWwvJ8H9pLhMelqXrnJRfQQQz8I";
        };
        # TODO: compute the correct npmDepsHash with `nix run nixpkgs#nix-prefetch-github` / `nix-prefetch` flows
        npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

        # If the repo ships a prebuilt JS in dist/, install it
        installPhase = ''
          runHook preInstall

          mkdir -p $out
          if [ -f dist/flower-card.js ]; then
            install -m0644 dist/flower-card.js $out
          elif [ -f flower-card.js ]; then
            install -m0644 flower-card.js $out
          elif [ -f src/flower-card.js ]; then
            install -m0644 src/flower-card.js $out
          fi

          runHook postInstall
        '';

        meta = with lib; {
          description = "Lovelace Flower Card";
          homepage = "https://github.com/Olen/lovelace-flower-card";
          license = licenses.mit;
          platforms = platforms.all;
        };
      }
    ) { };
  };
}
