{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  cacert,
  esbuild,
}:

let
  pname = "navbar-card";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "joseluis9595";
    repo = "lovelace-navbar-card";
    tag = "v${version}";
    hash = "sha256-uw90tm8KI7tqZwMNaRuxuIKVXhCLe0wVNisk91jLwwk=";
  };

  # Fixed-output derivation for node_modules
  node_modules = stdenv.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [
      nodejs
      cacert
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      # make npm use a writable directory
      export TMPDIR=$PWD/.tmp
      export NPM_CONFIG_CACHE=$PWD/.npm-cache
      mkdir -p $TMPDIR $NPM_CONFIG_CACHE

      npm install --ignore-scripts --omit=dev
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R node_modules $out/
      runHook postInstall
    '';

    dontFixup = true;

    # You need to fill in the correct hash after first build attempt
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-HwfcHF8apGRkW1CiXQgc28z7WfCSwheckX3CBcbFYzM=";
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    nodejs
    cacert
    esbuild
  ];

  configurePhase = ''
    runHook preConfigure
    cp -R ${node_modules}/node_modules .
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    esbuild src/navbar-card.ts \
      --outfile=dist/navbar-card.js \
      --bundle \
      --target=es2020
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp ./dist/navbar-card.js $out
    runHook postInstall
  '';

  passthru.entrypoint = "navbar-card.js";

  meta = {
    description = "Navbar Card for Home Assistant's Lovelace UI - easily navigate through dashboards";
    homepage = "https://github.com/joseluis9595/lovelace-navbar-card";
    changelog = "https://github.com/joseluis9595/lovelace-navbar-card/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
    platforms = lib.platforms.all;
  };
}
