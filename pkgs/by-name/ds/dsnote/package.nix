{ stdenv, lib, fetchFromGitHub, fetchzip, fetchurl, cmake, ninja, pkg-config, python3
, fmt, openblas, mbrola, espeak, boost, stt, onnxruntime
, piper-phonemize, spdlog, piper, python312Packages, rnnoise, rhvoice
, qt5, perl, opencl-headers, intel-ocl, amdvlk, cudaPackages
}:

let
  ssplitcpp = stdenv.mkDerivation rec {
    pname = "ssplitcpp";
    version = "unstable-2022-04-12"; # The package has no releases or tags

    src = fetchFromGitHub {
      owner = "ugermann";
      repo = "ssplit-cpp";
      rev = "49a8e12f11945fac82581cf056560965dcb641e6";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };

    nativeBuildInputs = [ cmake ninja ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DSSPLIT_COMPILE_LIBRARY_ONLY=ON"
      "-DSSPLIT_PREFER_STATIC_COMPILE=ON"
      "-DBUILD_SHARED_LIBS=OFF"
    ];

    meta = with lib; {
      description = "C++ library for sentence splitting";
      homepage = "https://github.com/ugermann/ssplit-cpp";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
  vosk = stdenv.mkDerivation rec {
    pname = "vosk";
    version = "0.3.45"; # Not the latest version, but the one from the flatpack builder manifest

    src = fetchzip {
      url = if stdenv.hostPlatform.system == "x86_64-linux" then
        "https://github.com/alphacep/vosk-api/releases/download/v${version}/vosk-linux-x86_64-${version}.zip"
      else if stdenv.hostPlatform.system == "aarch64-linux" then
        "https://github.com/alphacep/vosk-api/releases/download/v${version}/vosk-linux-aarch64-${version}.zip"
        else
        throw "Unsupported system: ${stdenv.hostPlatform.system}";
      sha256 = if stdenv.hostPlatform.system == "x86_64-linux" then
        "chpFXLiG+Y4YVErqVRrPGpBk7tH16EVkw727rlbTgdM="
        else
        "45e95d37755deb07568e79497d7feba8c03aee5a9e071df29961aa023fd94541";
      stripRoot = false;
    };

    installPhase = ''
      mkdir -p $out/lib $out/include
      cp libvosk.so $out/lib
      cp vosk_api.h $out/include
    '';

    meta = with lib; {
      description = "Offline speech recognition API";
      homepage = "https://github.com/alphacep/vosk-api";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  };
  webrtcvad = stdenv.mkDerivation rec {
    pname = "webrtcvad";
    version = "unstable-2024-09-29";

    src = fetchFromGitHub {
      owner = "webrtc-mirror";
      repo = "webrtc";
      rev = "ac87c8df2780cb12c74942ec8a473718c76cb5b7";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };

    nativeBuildInputs = [ cmake ninja ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    ];

    patches = [
      (fetchurl {
        url = "https://github.com/mkiol/dsnote/raw/48050943e090028b9cffe592643ed21e756a2858/patches/webrtcvad.patch";
        sha256 = "4V5M9PpKTpwKESPRKh5gtFEFjMv5AdUJfk+P/6Q7XjY=";
      })
    ];

    meta = with lib; {
      description = "WebRTC Voice Activity Detector";
      homepage = "https://github.com/webrtc-mirror/webrtc";
      platforms = platforms.linux;
    };
  };

in
stdenv.mkDerivation rec {
  pname = "dsnote";
  version = "4.6.1";

  src = fetchFromGitHub {
    owner = "mkiol";
    repo = "dsnote";
    rev = "v${version}";
    sha256 = "kQNy8Lz+inkYN1wFjJ9p7s6sFcktV3OXE1I202E6xXg=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    fmt
    openblas
    mbrola
    espeak
    boost
    webrtcvad
    stt
    vosk
    onnxruntime
    piper-phonemize
    spdlog
    piper
    ssplitcpp
    python312Packages.pybind11
    rnnoise
    rhvoice
    qt5.qtbase
    qt5.qtdeclarative
    perl
    opencl-headers
    intel-ocl
    amdvlk
    cudaPackages.nvidia_driver
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
  ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp $src/net.mkiol.SpeechNote.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp $src/net.mkiol.SpeechNote.svg $out/share/icons/hicolor/scalable/apps/
  '';

  meta = with lib; {
    description = "Speech recognition and text-to-speech application";
    homepage = "https://github.com/mkiol/SpeechNote";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}

