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
      buildHomeAssistantComponent {
        owner = "Olen";
        domain = "plant";
        version = "v2026.2.1";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "homeassistant-plant";
          rev = "v2026.2.1";
          hash = "sha256-a3fcl4xhH4itVBmwCTIde/+8m/Q8eS8jSxeaEcDhHwQ=";
        };
        # manifest requires async-timeout>=4.0.2
        dependencies = [
          python3Packages."async-timeout"
        ];
        meta = {
          description = "Custom Plant integration for Home Assistant (Olen fork)";
          homepage = "https://github.com/Olen/homeassistant-plant";
          license = lib.licenses.mit;
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
      buildHomeAssistantComponent {
        owner = "Olen";
        domain = "openplantbook";
        version = "v1.3.2";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "home-assistant-openplantbook";
          rev = "v1.3.2";
          hash = "sha256-5AhVnn7umpJ7r68e7FCkaT6E9pG4bNOg1O32PWS5WrI=";
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
        };
      }
    ) { };

    ha_washdata = super.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent {
        owner = "3dg1luk43";
        domain = "ha_washdata";
        version = "v0.4.2";
        src = fetchFromGitHub {
          owner = "3dg1luk43";
          repo = "ha_washdata";
          rev = "v0.4.2";
          hash = "sha256-9THYWgTZFjCUOS2rliaBzvvPyyBq/Y22BLJUTWNR06k=";
        };
        # Provide Python deps required by manifest.json
        dependencies = [
          python3Packages.numpy
        ];
        meta = {
          description = "A Home Assistant custom component to monitor washing machines via smart sockets, learn power profiles, and estimate completion time using shape-correlation matching.";
          homepage = "https://github.com/3dg1luk43/ha_washdata";
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
      stdenvNoCC.mkDerivation {
        pname = "flower-card";
        version = "v2026.1.1";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "lovelace-flower-card";
          rev = "v2026.1.1";
          sha256 = "sha256-X3bdYkdm72ptix69gTmJ3TS4cwAU6HTEUM+m5OmHN/c=";
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

    "swipe-card" = super.callPackage (
      {
        lib,
        stdenvNoCC,
        fetchFromGitHub,
      }:
      stdenvNoCC.mkDerivation {
        pname = "swipe-card";
        version = "5.0.0";
        src = fetchFromGitHub {
          owner = "bramkragten";
          repo = "swipe-card";
          rev = "v5.0.0";
          sha256 = "sha256-UC4Oz+2pRdZsNSwjb21jNrTBa+txtXf0CAoJKi2SLXo=";
        };
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          if [ -f dist/swipe-card.js ]; then
            install -m0644 dist/swipe-card.js $out
          elif [ -f swipe-card.js ]; then
            install -m0644 swipe-card.js $out
          elif [ -f src/swipe-card.js ]; then
            install -m0644 src/swipe-card.js $out
          fi
          runHook postInstall
        '';
        meta = with lib; {
          description = "Lovelace swipe card";
          homepage = "https://gitub.com/bramkragten/swipe-card";
          platforms = platforms.all;
        };
      }
    ) { };

    "my-cards-bundle" = super.callPackage (
      {
        lib,
        stdenvNoCC,
        fetchFromGitHub,
      }:
      stdenvNoCC.mkDerivation {
        pname = "my-cards-bundle";
        version = "1.0.6";
        src = fetchFromGitHub {
          owner = "AnthonMS";
          repo = "my-cards";
          rev = "v1.0.6";
          sha256 = "sha256-x0vOq87P1uOq5ILB4CSAowaAtUo4Nu9m6DFRiqa/Sw4=";
        };
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          install -m0644 dist/my-slider-v2.js $out
          install -m0644 dist/my-slider.js $out
          install -m0644 dist/my-cards.js $out
          runHook postInstall
        '';
        meta = with lib; {
          description = "Bundle of custom Lovelace cards";
          homepage = "https://github.com/AnthonMS/my-cards";
          license = licenses.mit;
          platforms = platforms.all;
        };
      }
    ) { };
  };
}
