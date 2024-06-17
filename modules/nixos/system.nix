{ pkgs, ... }: {
  config = {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      system-features = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      wget
      kitty
      networkmanagerapplet

      fira-code-nerdfont
      fira-code
    ];
    fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];

    # Enable sound with pipewire.
    sound.enable = false; # https://github.com/NixOS/nixpkgs/issues/319809
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
