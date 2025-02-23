{ pkgs }:
pkgs.buildGoModule rec {
  pname = "rcon-cli";
  # current as of 2025-02-20
  version = "1.6.11";

  src = pkgs.fetchFromGitHub {
    owner = "itzg";
    repo = "rcon-cli";
    rev = "${version}";
    hash = "sha256-RfcmAF2lj/huQNxxQFS1GUsqCS1eVfF5jTpXVGvykFE=";
  };

  vendorHash = "sha256-b9mWhrsHyXPhUm/9v9Oj72O4VEnlYMnieJiahE/9k1k=";

  doCheck = false;
}
