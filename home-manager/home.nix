{ config, pkgs, plasma-manager, nix-vscode-extensions, ... }:

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
      kdePackages.kio-admin
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
      # libsForQt5.polonium
      qbittorrent
      vlc
      awscli2
    ];

    file = {
      ".config/warp-terminal/user_preferences.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/warp-terminal.json"; # warp terminal
      ".config/Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/vscode-settings.json"; # vscode settings.json
    };

    sessionVariables = {
      EDITOR = "code";
    };
  };

  nixpkgs.config.allowUnfree = true;

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
      extensions = with nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        bbenoist.nix
        jdinhlife.gruvbox
        github.vscode-pull-request-github
        eamodio.gitlens
      ];
    };
  };

}