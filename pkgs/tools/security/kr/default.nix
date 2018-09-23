{ stdenvNoCC
, fetchFromGitHub
, buildGoPackage
, buildRustCrate
}:

let
  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "kryptco";
    repo = "kr";
    rev = "2.4.12";
    sha256 = "1gxkhipd9skrbrx55mkmv03gfhg26nxs56g8rvhgwzm1x8fnzidc";
  };
in let
  sigchain = buildRustCrate rec {

  };

  kr = buildGoPackage rec {
    inherit src;

    name = "kr-kr";

    goPackagePath = "github.com/kryptco/kr";
  };

in stdenvNoCC.mkDerivation rec {
  name = "kr-${version}";
  version = src.rev;

  buildPhase = "true";

  installPhase = ''
    cp -r ${kr} $out
  '';
}
