{ lib, config, pkgs, inputs, vars, ... }: 

let
  cfg = config.main-user;
in
{
  options = {
    main-user.enable = lib.mkEnableOption "enable user module";
   main-user.userName = lib.mkOption {
     default = "mainuser";
     description = "primary user's name";
   };
   main-user.sshKey = lib.mkOption {
     description = "your users ssh key";
   };
   main-user.homeManager = lib.mkOption {
     description = "primary user's name";
   };
  };

 config = lib.mkIf cfg.enable {
   users.users.${cfg.userName} = {
     isNormalUser = true;
     description = "main user";
     extraGroups = [ "networkmanager" "wheel" "docker" "storage" "uinput" "power" "wireshark" ];
     shell = pkgs.zsh;
     openssh.authorizedKeys.keys = [cfg.sshKey];
   };

   home-manager = {
     extraSpecialArgs = { inherit inputs; vars = vars; };
     users.${cfg.userName} = cfg.homeManager;
   };

   programs.zsh.enable = true;
 };
}
