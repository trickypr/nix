{ pkgs, ... }:
{
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
        "gccarch-znver4"
      ];
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.brlaser ];
    services.flatpak.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    security.polkit.enable = true;

    programs.java = {
      enable = true;
      package = (pkgs.jdk17.override { enableJavaFX = true; });
    };

    services.safeeyes.enable = true;

    environment.sessionVariables = {
      PATH_TO_FX = "${pkgs.jdk17.override { enableJavaFX = true; }}/lib/openjdk/lib";
      JAVA_ROOM = "${pkgs.jdk17.override { enableJavaFX = true; }}";
    };

    environment.systemPackages = with pkgs; [
      wget
      kitty
      kdePackages.okular
      kdePackages.qtwayland
      networkmanagerapplet
      zathura
      system-config-printer
      waypipe
      opusfile

      fira-code-nerdfont
      fira-code
      usbutils
      pciutils

      jetbrains-toolbox
      javaPackages.openjfx17

      man-pages
      man-pages-posix
    ];
    fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark;
    documentation.dev.enable = true;

    programs.firefox.enable = true;
    programs.firefox.package = pkgs.firefox-bin;

    # Enable sound with pipewire.
    # sound.enable = false; # https://github.com/NixOS/nixpkgs/issues/319809
    # hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      # alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Electron wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.nix-ld.enable = true;
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
