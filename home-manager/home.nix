# ./home-manager/home.nix

{ config, pkgs, plasma-manager, nix-vscode-extensions, ... }:

{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  nixpkgs = {
    overlays = [ nix-vscode-extensions.overlays.default ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "jat";
    homeDirectory = "/home/jat";
    stateVersion = "23.11"; # don't change, reference to installed version

    packages = with pkgs; [
      kdePackages.kio-admin
      # libsForQt5.polonium
      git
      starship
      warp-terminal
      vscode
      jq
      xclip
      flameshot
      neofetch
      google-chrome
      discord
      spotify
      signal-desktop
      vlc
      awscli2
      bitwarden-desktop
      dotnet-sdk_9
    ];

    file = {
      ".config/warp-terminal/user_preferences.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/warp-terminal.json"; # warp terminal
      ".config/Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/vscode-settings.json"; # vscode settings.json
    };

    sessionVariables = {
      EDITOR = "code";
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
      profiles.default.extensions = with pkgs.vscode-marketplace; [
        bbenoist.nix
        jdinhlife.gruvbox
        github.vscode-pull-request-github
        eamodio.gitlens
        ms-dotnettools.csdevkit
        ms-dotnettools.vscodeintellicode-csharp
      ];
    };
  };
}