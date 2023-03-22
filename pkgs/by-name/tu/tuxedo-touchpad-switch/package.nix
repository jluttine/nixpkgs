{ lib, stdenv, fetchFromGitHub, replaceVars, cmake, pkg-config, udev, glib }:

stdenv.mkDerivation rec {
  pname = "tuxedo-touchpad-switch";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "tuxedocomputers";
    repo = "tuxedo-touchpad-switch";
    # Use PR #11:
    # https://github.com/tuxedocomputers/tuxedo-touchpad-switch/pull/13
    rev = "851534c467fd0214b5dbda22c6f6a5cafcb11bc1";
    sha256 = "sha256-AMrsRzh3ILyXAxyhxN8c9f/BRxPFNI7ZGd9iEC4yUxo=";
    #rev = "v${version}";
    #sha256 = "sha256-LBYFOY0wR+Ktl5PKcZAofPexXNNsYNFiY08ij50f2q8=";
  };

  patches = with lib.versions; [
    # Fix version info because Tuxedo would otherwise read it from git describe
    (replaceVars ./version_info.patch {
      git_tag = "v${version}";
      semver = version;
      version = version;
      version_major = major version;
      version_minor = minor version;
      version_patch = patch version;
    })
    ./support-all-desktops.patch
  ];

  # Fix paths:
  #
  # - In installation, absolute paths are converted to relative paths so that
  #   the files are installed correctly in nixpkgs
  #
  # - In the app, the path to the lock file is set to point to the lock file in
  #   nix store
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/etc/" "etc/" \
      --replace "/usr/share/" "share/"
    substituteInPlace tuxedo-touchpad-switch.cpp \
      --replace "/etc/" "$out/etc/"
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ udev glib ];

  meta = with lib; {
    description = "";
    longDescription = ''
    '';
    homepage = "";
    #license = licenses.gpl3Plus;
    platforms = platforms.linux;
    #broken = stdenv.isAarch64;
    maintainers = [ maintainers.jluttine ];
  };
}
