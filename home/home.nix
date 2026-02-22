# ./home/home.nix

{ 
  config, 
  pkgs, 
  inputs,
  ...
}:

{
  imports = [
    ../modules/symlink.nix
  ];

  programs = {
    bash.enable = true;

    git = {
      enable    = true;
      settings.user.name  = "Jatinder Randhawa";
      settings.user.email = "j4t1nd3r@gmail.com";
    };

    starship = {
      enable                = true;
      enableBashIntegration = true;
    };

    kitty = {
      enable    = true;
      font.name = "MesloLGS Nerd Font Mono";
      font.size = 13;
    };

    konsole = {
      enable         = true;
      defaultProfile = "Default";
      profiles = {
        Default = {
          colorScheme = "Breeze";
          font        = { name = "MesloLGS Nerd Font Mono"; size = 13; };
        };
      };
    };

    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-marketplace; [
        jnoortheen.nix-ide # replacing: bbenoist.nix
        jdinhlife.gruvbox
        eamodio.gitlens
        # # cloud
        # hashicorp.terraform
        # ms-vscode.powershell
        # dev
        # ms-dotnettools.csharp
        # ms-dotnettools.vscode-dotnet-runtime
        # ms-dotnettools.csdevkit
        # ms-dotnettools.vscodeintellicode-csharp
      ];
    };
  };

  home = {
    packages = with pkgs; [

      # kde / plasma helpers
      kdePackages.kio-admin
      # libsForQt5.polonium

      # cli
      gh
      jq 
      wl-clipboard
      
      # terminal / ide
      # zed-editor
      # warp-terminal 

      # gui
      google-chrome
      obsidian

      # messaging
      discord 
      signal-desktop 

      # media
      spotify
      vlc 
      gnome-disk-utility

      # security
      protonvpn-gui
      bitwarden-desktop

      # cloud
      # terraform
      # azure-cli
      # powershell
      # awscli2

      # containers
      # minikube
      # docker

      # dev
      opencode
      # dotnet-sdk_9
    ];

    sessionVariables = {
      EDITOR = "code";
    };

    stateVersion = "23.11"; # don't change
  };
}
