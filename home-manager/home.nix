{ config, pkgs, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  home = {
    username = "jat";
    homeDirectory = "/home/jat";
    stateVersion = "23.11";

    packages = with pkgs; [
      starship
      git
      warp-terminal
      jq
      xclip
      flameshot
      neofetch
      vscode
      google-chrome
      firefox
      discord
      spotify
      signal-desktop
    ];

    file = {
      ".config/warp-terminal/user_preferences.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-fwk-system//configs/warp-terminal.json"; # warp terminal
      ".config/Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-fwk-system/configs/vscode-settings.json"; # vscode settings.json
       
    };

    sessionVariables = {
      EDITOR = "code";
    };
  };

  # set allowunFree
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs = {
    home-manager.enable = true;
    plasma = {
      enable = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
      };
    };
    bash.enable = true;
    git = {
      enable = true;
      userName  = "Jatinder Randhawa";
      userEmail = "j4t1nd3r@gmail.com";
    };
    starship = {
      enable = true;
      enableBashIntegration = true; 
    };
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        jdinhlife.gruvbox
        bbenoist.nix
        github.vscode-pull-request-github
      ];
    };
  };
}