# ./home-manager/home.nix

{ 
  config, 
  pkgs, 
  inputs,
  nix-vscode-extensions,
  ...
}:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
    ../modules/symlink.nix
  ];

  nixpkgs = {
    overlays = [ nix-vscode-extensions.overlays.default ];
    config = {
      allowUnfree = true;
    };
  };

  programs = {
    home-manager.enable = true;

    bash.enable = true;

    git = {
      enable    = true;
      userName  = "Jatinder Randhawa";
      userEmail = "j4t1nd3r@gmail.com";
    };

    starship = {
      enable                = true;
      enableBashIntegration = true;
    };

    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-marketplace; [
        bbenoist.nix
        jdinhlife.gruvbox
        eamodio.gitlens
        # # cloud
        # hashicorp.terraform
        # ms-vscode.powershell
        # dev
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        ms-dotnettools.csdevkit
        ms-dotnettools.vscodeintellicode-csharp
      ];
    };
  };

  home = {
    packages = with pkgs; [

      # kde / plasma helpers
      kdePackages.kio-admin
      # libsForQt5.polonium

      # cli
      git 
      starship 
      jq 
      xclip 
      neofetch 

      # gui
      flameshot 
      warp-terminal 
      vscode
      bitwarden-desktop
      protonvpn-gui
      google-chrome 
      discord 
      spotify
      signal-desktop 
      vlc 

      # cloud
      terraform
      azure-cli
      powershell
      # awscli2
      minikube
      docker

      # dev
      dotnet-sdk_9
    ];

    sessionVariables = {
      EDITOR = "code";
    };

    username      = "jat";
    homeDirectory = "/home/jat";
    stateVersion  = "23.11"; # don't change
  };
}
