{ stdenv, lib, fetchzip, autoPatchelfHook, xorg, gtk2, gnome2, gtk3, nss, alsa-lib, udev, unzip, wrapGAppsHook, mesa }:

stdenv.mkDerivation rec {
  pname = "cypress";
  version = "7.6.0";

  src = fetchzip {
    url = "https://cdn.cypress.io/desktop/${version}/linux-x64/cypress.zip";
    sha256 = "1wc38nz8y13q7ypim8ch1w44fvjmni99nwbliq7lcz1f9h9fsi4n";
  };

  passthru.updateScript = ./update.sh;

  # don't remove runtime deps
  dontPatchELF = true;

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook unzip ];

  buildInputs = with xorg; [
    libXScrnSaver libXdamage libXtst libxshmfence
  ] ++ [
    nss gtk2 alsa-lib gnome2.GConf gtk3
    mesa # for libgbm
  ];

  runtimeDependencies = [ (lib.getLib udev) ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/cypress
    cp -vr * $out/opt/cypress/
    # Let's create the file binary_state ourselves to make the npm package happy on initial verification.
    # Cypress now verifies version by reading bin/resources/app/package.json
    mkdir -p $out/bin/resources/app
    printf '{"version":"%b"}' $version > $out/bin/resources/app/package.json
    # Cypress now looks for binary_state.json in bin
    echo '{"verified": true}' > $out/binary_state.json
    ln -s $out/opt/cypress/Cypress $out/bin/Cypress

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fast, easy and reliable testing for anything that runs in a browser";
    homepage = "https://www.cypress.io";
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [ tweber mmahut ];
  };
}
