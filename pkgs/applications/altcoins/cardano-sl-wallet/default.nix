{lib, pkgs, stdenv, config, ...}:

let
  pname = "cardano-sl-wallet";
  version = "1.0.3";
  gitrev = "v${version}";
  source = pkgs.srcOnly {
    stdenv = stdenv;
    name = "${pname}-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "input-output-hk";
      repo = pname;
      rev = gitrev;
      sha256 = "1z2yjkm0qwhf588qnxcbz2d5mxvhqdxawwl8dczfnl47rb48jm52";
    };
  };
in (
  (import "${source}/default.nix") {
    inherit pkgs config gitrev;
  }
).cardano-sl-wallet
