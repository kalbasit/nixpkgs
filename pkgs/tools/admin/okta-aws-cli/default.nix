{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "okta-aws-cli";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner  = "okta";
    repo   = "okta-aws-cli";
    rev    = "v${version}";
    sha256 = "1qlc04fydcqnifbhrzdw63wq3ndzsyzp4s1bdvfhvizbhdi03mpp";
  };

  vendorSha256 = "1gzaadpf9zrci7yv88f434mvc7gralb7dj6wl6r4vsv3qk291680";

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "A CLI for having Okta as the IdP for AWS CLI operations";
    homepage = "https://github.com/okta/okta-aws-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ daniyalsuri6 ];
  };
}
