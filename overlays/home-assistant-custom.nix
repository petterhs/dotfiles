self: super: {
  # Extra Python libs for custom components must live in home-assistant.python3Packages (same
  # interpreter as HA), not in top-level python3Packages, which is often a different version.
  home-assistant = super.home-assistant.override {
    packageOverrides = ps: pysuper: {
      json_timeseries = ps.buildPythonPackage rec {
        pname = "json_timeseries";
        version = "0.1.7";
        src = self.fetchPypi {
          inherit pname version;
          sha256 = "sha256-Eq3esU2KN0/O96sFaYucxDiA5wfCm8gxA9gEFOKbYCw=";
        };
        format = "pyproject";
        nativeBuildInputs = with ps; [
          setuptools
          wheel
          setuptools-scm
        ];
        propagatedBuildInputs = with ps; [ python-dateutil ];
        meta = with self.lib; {
          description = "Simple JSON time series helpers";
          homepage = "https://pypi.org/project/json-timeseries/";
          license = licenses.mit;
        };
      };

      openplantbook_sdk = ps.buildPythonPackage rec {
        pname = "openplantbook_sdk";
        version = "0.6.1";
        src = self.fetchPypi {
          inherit pname version;
          sha256 = "sha256-OI8Y91SA3kIOJnqdRi7tKUgC0TnW4WUQGSAjL9JkBt4=";
        };
        format = "pyproject";
        nativeBuildInputs = with ps; [
          setuptools
          wheel
          setuptools-scm
        ];
        propagatedBuildInputs = with ps; [
          requests
          aiohttp
          json_timeseries
        ];
        meta = with self.lib; {
          description = "SDK for OpenPlantBook API";
          homepage = "https://pypi.org/project/openplantbook-sdk/";
          license = licenses.mit;
        };
      };
    };
  };

  home-assistant-custom-components = (super.home-assistant-custom-components or { }) // {
    plant = self.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent {
        owner = "Olen";
        domain = "plant";
        version = "v2026.9.0";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "homeassistant-plant";
          rev = "v2026.9.0";
          hash = "sha256-8V+90Onh3MLN8G4CjenzZWznwnGiWfhz17KZhGd1qYk=";
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
    ) { python3Packages = self.home-assistant.python3Packages; };

    openplantbook = self.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent {
        owner = "Olen";
        domain = "openplantbook";
        version = "v1.6.0";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "home-assistant-openplantbook";
          rev = "v1.6.0";
          hash = "sha256-Lk+dyrBwTqRil64fVm28bhN+q57bA5U9FpX2wFf/g8I=";
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
    ) { python3Packages = self.home-assistant.python3Packages; };

    pax_ble = self.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent {
        owner = "eriknn";
        domain = "pax_ble";
        version = "v1.1.31";
        src = fetchFromGitHub {
          owner = "eriknn";
          repo = "ha-pax_ble";
          rev = "v1.1.31";
          hash = "sha256-5u4a0GvIaV0m5E+qaZKMPQQ1DTupufmWec72z2XlXKI=";
        };
        dependencies = [
          python3Packages."bleak-retry-connector"
        ];
        meta = {
          description = "Home Assistant integration for Pax Calima and other Bluetooth-enabled fans";
          homepage = "https://github.com/eriknn/ha-pax_ble";
          license = lib.licenses.asl20;
        };
      }
    ) { python3Packages = self.home-assistant.python3Packages; };

    ha_washdata = self.callPackage (
      {
        lib,
        buildHomeAssistantComponent,
        fetchFromGitHub,
        python3Packages,
      }:
      buildHomeAssistantComponent {
        owner = "3dg1luk43";
        domain = "ha_washdata";
        version = "v0.5.8";
        src = fetchFromGitHub {
          owner = "3dg1luk43";
          repo = "ha_washdata";
          rev = "v0.5.8";
          hash = "sha256-j4FRBdvXZW3hni+OVGLSZ4yZnbgeyzmoxOLBEn89r0Q=";
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
    ) { python3Packages = self.home-assistant.python3Packages; };
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
        version = "v2026.8.0";
        src = fetchFromGitHub {
          owner = "Olen";
          repo = "lovelace-flower-card";
          rev = "v2026.8.0";
          sha256 = "sha256-9VnoImrKiPhxk5mtEw57TQfZdIphF7pUrLrgTi2Z7LY=";
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
        version = "2.3.1";
        src = fetchFromGitHub {
          owner = "AnthonMS";
          repo = "my-cards";
          rev = "v2.3.1";
          sha256 = "sha256-H67EA8zDGNZ9EK+w3Vgb/0NvTdqxmUL177ggS8D8Cz8=";
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
