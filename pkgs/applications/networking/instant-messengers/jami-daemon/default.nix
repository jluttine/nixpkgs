{ stdenv
, fetchurl
, which
, autoreconfHook
, pkgconfig
, automake
, libtool
, pjsip
, libyamlcpp
, alsaLib
, libpulseaudio
, libsamplerate
, libsndfile
, dbus
, dbus_cplusplus
, ffmpeg
, udev
, pcre
, gsm
, speex
, boost
, opendht
, msgpack
, gnutls
, zlib
, jsoncpp
, xorg
, libargon2
, cryptopp
, openssl
, perl
, python3
, libupnp
, speexdsp
, cmake
, asio
}:

# let
#   myPython = python3.withPackages (ps: with ps; [
#     pygobject3
#     dbus-python
#   ]);

#   src = fetchgit {
#     url = https://gitlab.savoirfairelinux.com/ring/ring-daemon.git;
#     rev = "006b8dc7be08fe9beb68709af71004e7bc1ceb5c";
#     sha256 = "0ih9g0rismrhx6nqcy3jqfbcs166grg0shnfmrnmykl9h0xy8z47";
#   };

#   patchdir = "${src}/contrib/src";

#   restbed = import ./restbed.nix {
#     inherit stdenv fetchFromGitHub cmake asio openssl;
#     patches = [
#     "${patchdir}/restbed/CMakeLists.patch"
#     "${patchdir}/restbed/strand.patch"
#     "${patchdir}/restbed/uri_cpp.patch"
#     "${patchdir}/restbed/dns-resolution-error.patch"
#     "${patchdir}/restbed/string.patch"
#     ];
#   };

#   pjsip' = stdenv.lib.overrideDerivation pjsip (old: {
#     patches = [
#       "${patchdir}/pjproject/gnutls.patch"
#       ./notestsapps.patch # this one had to be modified
#       "${patchdir}/pjproject/fix_base64.patch"
#       "${patchdir}/pjproject/ipv6.patch"
#       "${patchdir}/pjproject/ice_config.patch"
#       "${patchdir}/pjproject/multiple_listeners.patch"
#       "${patchdir}/pjproject/pj_ice_sess.patch"
#       "${patchdir}/pjproject/fix_turn_fallback.patch"
#       "${patchdir}/pjproject/fix_ioqueue_ipv6_sendto.patch"
#       "${patchdir}/pjproject/add_dtls_transport.patch"
#     ];
#     CFLAGS = "-g -DPJ_ICE_MAX_CAND=256 -DPJ_ICE_MAX_CHECKS=150 -DPJ_ICE_COMP_BITS=2 -DPJ_ICE_MAX_STUN=3 -DPJSIP_MAX_PKT_LEN=8000";
#   });
# in
stdenv.mkDerivation rec {
  pname = "jami-daemon";
  version = "unstable-2020-03-26";
  # version = "20200326.1";

  src = fetchurl {
    url = "https://git.jami.net/savoirfairelinux/ring-daemon/-/archive/6c58fb51842e14dbb38c0e1e87517c0020b08a33/ring-daemon-6c58fb51842e14dbb38c0e1e87517c0020b08a33.tar.gz";
    sha256 = "0hf4zgf8azkxv9i3nmck4i8704bypq26iacylkjdl1fr8y71dz3a";
  };

  # src = fetchurl {
  #   url = "https://dl.jami.net/ring-release/tarballs/jami_${version}.f8d3d10.tar.gz";
  #   sha256 = "05mi8axxfslbmqc0658zxnjyhgihh5mn97g8hdasd4ip96gyyv1p";
  # };

  nativeBuildInputs = [
    which
    autoreconfHook
    # automake
    # libtool
    pkgconfig
    cmake
  ];

  buildInputs = [
    pjsip
    libyamlcpp
    alsaLib
    libpulseaudio
    libsamplerate
    libsndfile
    dbus
    dbus_cplusplus
    ffmpeg
    udev
    pcre
    gsm
    speex
    boost
    opendht
    msgpack
    gnutls
    zlib
    jsoncpp
    #restbed
    xorg.libX11
    libargon2
    cryptopp
    openssl
    perl
    libupnp
    speexdsp
  ];

  preConfigure = ''
    sh autogen.sh
  '';

  # postInstall = ''
  #   mkdir $out/bin
  #   ln -s $out/lib/ring/dring $out/bin/dring
  #   cp -R ./tools/dringctrl/ $out/
  #   substitute ./tools/dringctrl/dringctrl.py $out/dringctrl/dringctrl.py \
  #     --replace '#!/usr/bin/env python3' "#!${myPython}/bin/python3"
  #   chmod +x $out/dringctrl/dringctrl.py
  #   ln -s $out/dringctrl/dringctrl.py $out/bin/dringctrl.py
  # '';

  meta = with stdenv.lib; {
    description = "A Voice-over-IP software phone";
    longDescription = ''
      As the SIP/audio daemon and the user interface are separate processes, it
      is easy to provide different user interfaces. GNU Ring comes with various
      graphical user interfaces and even scripts to control the daemon from the
      shell.
    '';
    homepage = https://ring.cx;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ taeer olynch jluttine ];
    platforms = platforms.linux;
    # pjsip' fails to compile with the supplied patch set, see: https://hydra.nixos.org/build/68667921/nixlog/4
  };
}
