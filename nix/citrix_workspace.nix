{ lib, pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.citrix_workspace.override {
      libvorbis = pkgs.libvorbis.override {
        libogg = pkgs.libogg.overrideAttrs (prevAttrs: {
          cmakeFlags = (prevAttrs.cmakeFlags or [ ]) ++ [
            (lib.cmakeBool "BUILD_SHARED_LIBS" true)
          ];
        });
      };
    })
  ];
}
