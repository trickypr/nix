{ pkgs, ... }:
{
  imports = [
  ];

  networking = {
    hostName = "akropolis";
    networkmanager.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services = {
  };

  # VM config for testing
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
      graphics = false;
    };
  };

  system.stateVersion = "24.11";
}
