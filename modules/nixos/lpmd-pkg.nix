{
  stdenv,
  fetchgit,
  lib,
  automake,
  autoconf,
  autoconf-archive,
  gcc,
  glib,
  dbus-glib,
  gtk-doc,
  pkg-config,
  libxml2,
  libnl,
  systemdLibs,
  tree,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "lpmd";
  version = "branch";

  src = fetchgit {
    url = "https://github.com/endgame/intel-lpmd";
    rev = "b2832748aead9f0c4dbbaecc8d13a2e7147a82a2";
    sha256 = "bDzqbroO11ZQi4TfhW0KbzYtYwM4WYNFkPE52fKpa9Q=";
  };

  doCheck = true;

  buildInputs = [
    automake
    autoconf
    autoconf-archive
    gcc
    glib
    dbus-glib
    gtk-doc
    pkg-config
    libxml2
    libnl
    systemdLibs
    tree
  ];

  nativeBuildInputs = [ autoreconfHook ];
  configureFlags = [
    "--localstatedir=/var"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-dbus-sys-dir=${placeholder "out"}/etc/dbus-1/system.d"
  ];
  outputs = [ "out" ];

  # We wil handle systemd services within the module, but we want all of the dbus
  # stuff to get setup
  postInstall = ''
    rm -rf ${placeholder "out"}/lib/systemd/system
  '';

  meta = with lib; {
    description = "Intel's power management daemon";
    homepage = "https://github.com/intel/intel-lpmd";
    platforms = platforms.all;
  };
}
