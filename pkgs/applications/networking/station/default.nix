{ appimageTools, fetchurl, lib }:

let
  pname = "station";
  version = "2.1.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/getstation/desktop-app/releases/download/v${version}/Station-x86_64.AppImage";
#    url = "https://github.com/getstation/desktop-app/releases/download/v2.1.0/Station-x86_64.AppImage";
    sha256 = "bvu63m/2wp8u187mLpUYszX+SRdoNeYyLaScVlBNUDQ=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };
in appimageTools.wrapType2 rec {
  inherit name src;

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  multiPkgs = null;
  extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
  extraInstallCommands = ''
    mv $out/bin/{${name},${pname}}
    install -m 444 -D ${appimageContents}/station-desktop-app.desktop $out/share/applications/station-desktop-app.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/station-desktop-app.png \
      $out/share/icons/hicolor/512x512/apps/station-desktop-app.png
    substituteInPlace $out/share/applications/station-desktop-app.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "A single place for all of your web applications";
    homepage = "https://getstation.com";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
