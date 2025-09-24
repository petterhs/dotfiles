self: super: {
  # Extend python packages with missing deps used by custom HA integrations
  python3Packages = super.python3Packages // {
    json_timeseries = super.python3Packages.buildPythonPackage rec {
      pname = "json_timeseries";
      version = "0.1.7";
      src = super.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Eq3esU2KN0/O96sFaYucxDiA5wfCm8gxA9gEFOKbYCw=";
      };
      format = "pyproject";
      nativeBuildInputs = with super.python3Packages; [
        setuptools
        wheel
        setuptools-scm
      ];
      propagatedBuildInputs = with super.python3Packages; [ python-dateutil ];
      meta = with super.lib; {
        description = "Simple JSON time series helpers";
        homepage = "https://pypi.org/project/json-timeseries/";
        license = licenses.mit;
      };
    };

    openplantbook_sdk = super.python3Packages.buildPythonPackage rec {
      pname = "openplantbook_sdk";
      version = "0.4.7";
      src = super.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Pp0lfGnPfy6QZOScU39j/YACLumNJyeHKdbpdFHhdm0=";
      };
      format = "pyproject";
      nativeBuildInputs = with self.python3Packages; [
        setuptools
        wheel
        setuptools-scm
      ];
      propagatedBuildInputs = with self.python3Packages; [
        requests
        aiohttp
        json_timeseries
      ];
      meta = with super.lib; {
        description = "SDK for OpenPlantBook API";
        homepage = "https://pypi.org/project/openplantbook-sdk/";
        license = licenses.mit;
      };
    };
  };

  home-assistant-custom-components = (super.home-assistant-custom-components or { }) // {
    plant = super.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent rec {
        owner = "Olen";
        domain = "plant";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "homeassistant-plant";
          rev = "master";
          hash = "sha256-jpmfmflS2w7WoiPcIG8HR/cUisNiJwG+LBwRCAbQsZc=";
        };
        # manifest requires async-timeout>=4.0.2
        dependencies = [
          python3Packages."async-timeout"
        ];
        meta = {
          description = "Custom Plant integration for Home Assistant (Olen fork)";
          homepage = "https://github.com/Olen/homeassistant-plant";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ ];
        };
      }
    ) { };

    openplantbook = super.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent rec {
        owner = "Olen";
        domain = "openplantbook";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "home-assistant-openplantbook";
          rev = "master";
          hash = "sha256-PSax6WFUSEouJL1jes9T+nWdVh8ix5Ue5NE8TeScNfM";
        };
        # Provide Python deps required by manifest.json
        dependencies = [
          python3Packages.json_timeseries
          python3Packages.openplantbook_sdk
        ];
        meta = {
          description = "OpenPlantBook custom integration for Home Assistant";
          homepage = "https://github.com/Olen/home-assistant-openplantbook";
          license = lib.licenses.gpl3Only;
          maintainers = with lib.maintainers; [ ];
        };
      }
    ) { };
  };

  home-assistant-custom-lovelace-modules = (super.home-assistant-custom-lovelace-modules or { }) // {
    "flower-card" = super.callPackage (
      {
        lib,
        stdenvNoCC,
        fetchFromGitHub,
      }:
      stdenvNoCC.mkDerivation rec {
        pname = "flower-card";
        version = "2025-09-22";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "lovelace-flower-card";
          rev = "master";
          sha256 = "sha256-IwhhORWpKjR9APyeuWwvJ8H9pLhMelqXrnJRfQQQz8I=";
        };
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

    "navbar-card" = super.callPackage ./navbar-card-package.nix { };
  };
}
