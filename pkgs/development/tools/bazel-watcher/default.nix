{ buildBazelPackage
, cacert
, fetchFromGitHub
, fetchpatch
, git
, go
, stdenv
}:

buildBazelPackage rec {
  name = "bazel-watcher-${version}";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "bazelbuild";
    repo = "bazel-watcher";
    rev = "v${version}";
    sha256 = "04b27lv3hbi475r51ya59b17djdzl6h3cf7934gyvjrdg49jicq6";
  };

  patches = [
    ./update-gazelle-fix-ssl.patch
  ];

  nativeBuildInputs = [ go git ];

  bazelTarget = "//ibazel";

  fetchAttrs = {
    preBuild = ''
      patchShebangs .

      # tell rules_go to use the Go binary found in the PATH
      sed -e 's:go_register_toolchains():go_register_toolchains(go_version = "host"):g' -i WORKSPACE

      # tell rules_go to invoke GIT with custom CAINFO path
      export GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt"
    '';

    preInstall = ''
      # Remove the go_sdk (it's just a copy of the go derivation) and all
      # references to it from the marker files. Bazel does not need to download
      # this sdk because we have patched the WORKSPACE file to point to the one
      # currently present in PATH. Without removing the go_sdk from the marker
      # file, the hash of it will change anytime the Go derivation changes and
      # that would lead to impurities in the marker files which would result in
      # a different sha256 for the fetch phase.
      rm -rf $bazelOut/external/{go_sdk,\@go_sdk.marker}
      sed -e '/^FILE:@go_sdk.*/d' -i $bazelOut/external/\@*.marker

      # Remove compiled binaries as they differ on Linux and Mac, they also do
      # not affect the build.
      rm -f $bazelOut/external/bazel_gazelle_go_repository_tools/bin/fetch_repo
      rm -f $bazelOut/external/bazel_gazelle_go_repository_tools/bin/gazelle
    '';

    sha256 = "12j8qxyd1cwzziv2fjjrg961rkqsmwm6kclnnlz6pm9m1s1d24f7";
  };

  buildAttrs = {
    preBuild = ''
      patchShebangs .

      # tell rules_go to use the Go binary found in the PATH
      sed -e 's:go_register_toolchains():go_register_toolchains(go_version = "host"):g' -i WORKSPACE
    '';

    installPhase = ''
      install -Dm755 bazel-bin/ibazel/*_pure_stripped/ibazel $out/bin/ibazel
    '';
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/bazelbuild/bazel-watcher;
    description = "Tools for building Bazel targets when source files change.";
    license = licenses.asl20;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.all;
  };
}
