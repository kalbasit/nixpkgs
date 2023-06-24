{ lib
, stdenv
, fetchFromGitHub
, git
}:

stdenv.mkDerivation rec {
  pname = "rtl-wmbus";
  version = "dev";
  rev ="f2a89a0a1b90b7a804b536a83b6c45942c344f23";

  src = fetchFromGitHub {
    inherit rev;
    owner = "xaelsouth";
    repo = "rtl-wmbus";
    hash = "sha256-Q2rANqSQCuyzZOP1ds+F4p7snbncIcbTUkYNjHw7WTs=";
  };

  nativeBuildInputs = [ git ];

  makeFlags = [ "DESTDIR=$(out)" ];
  meta = with lib; {
    description = "rtl-wmbus: software defined receiver for Wireless-M-Bus with RTL-SDR";
    homepage = "https://github.com/xaelsouth/rtl-wmbus";
    # license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.linux;
  };
}
