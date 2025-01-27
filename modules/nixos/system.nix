{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.t;
in
{
  options = {
    t.isGraphical = lib.mkEnableOption "if the system should have graphical utils";
  };

  config = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      system-features = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];

      # Enable my cachix caches to reduce the number of builds that I need to
      # trigger
      substituters = [
        "https://trickypr.cachix.org"
      ];
      trusted-public-keys = [
        "trickypr.cachix.org-1:NpJS0QWDDEUeFYlr2cvjrTB/zEvd5erIIZjQt+wDsNY="
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    security.polkit.enable = true;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    environment.systemPackages = with pkgs; [
      wget

      nerd-fonts.fira-code
      usbutils
      pciutils

      man-pages
      man-pages-posix
      nix-tree
    ];
    fonts.packages = with pkgs; [
      # If shit is brokey do "fc-cache -r"
      nerd-fonts.fira-code
    ];
    documentation.dev.enable = true;

    programs.firefox.enable = cfg.isGraphical;
    programs.firefox.package = pkgs.firefox-bin;

    # Enable sound with pipewire.
    # sound.enable = false; # https://github.com/NixOS/nixpkgs/issues/319809
    # hardware.pulseaudio.enable = false;
    security.rtkit.enable = cfg.isGraphical;
    services.pipewire = {
      enable = cfg.isGraphical;
      alsa.enable = cfg.isGraphical;
      # alsa.support32Bit = true;
      pulse.enable = cfg.isGraphical;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Electron wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # resolved is required for mullvad
    # for some reason, this also fixes my home internet, because the netadmin
    # has broken a couple of things
    services.resolved = {
      enable = true;
      # dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
      # dnsovertls = "true";
    };

    programs.nix-ld.enable = cfg.isGraphical;
    programs.nix-ld.libraries = with pkgs; [
      gtk3
      alsa-lib
      xorg.libX11
      xorg.libxcb
      xorg.libXcomposite
      xorg.libXext
      xorg.libXtst
      xorg.libXdamage
      xorg.libXrandr
      xorg.libXfixes
      xorg.libXcursor
      xorg.libXrender
      xorg.libXi
      xorg.libXxf86vm
      freetype
      pango
      cairo
      fontconfig
      gtk3
      atk
      gdk-pixbuf
      gtk3
      glib
      dbus
      pciutils
      libGL
      libxkbcommon
      glibc

      vulkan-loader
      glfw
      wayland
    ];
  };
}
