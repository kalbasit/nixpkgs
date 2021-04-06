{ autoPatchelfHook
, curl
, dpkg
, dbus_daemon
, fetchurl
, lib
, libnl
, libudev
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "twingate";
  version = "1.0.6.14247";

  src = fetchurl {
    url = "https://packages.twingate.com/apt/files/ver_JmSX4/twingate-amd64.deb";
    sha256 = "sha256-UaQo9jLgJHwudyHtHILRr15FPcBXGTgPOy2YVAGrezM=";
  };

  buildInputs = [ curl libnl libudev ];
  nativeBuildInputs = [ dbus_daemon.dev dpkg autoPatchelfHook ];

  unpackCmd = "mkdir root ; dpkg-deb -x $curSrc root";

  buildPhase = ''
    while read file; do
      substituteInPlace "$file" \
        --replace "/usr/bin" "$out/bin" \
        --replace "/usr/sbin" "$out/bin" \
        --replace "/etc/" "$out/etc/"
    done < <(find etc usr/lib usr/share -type f)
  '';

  installPhase = ''
    mkdir $out
    mv etc $out/
    mv usr/bin $out/bin
    mv usr/sbin/* $out/bin
    mv usr/lib $out/lib
    mv usr/share $out/share
  '';

  meta = with lib; {
    description = "<fill in description>";
    homepage = "<fill in website>";
    license = licenses.unfree;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
