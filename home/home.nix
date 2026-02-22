# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./home/home.nix

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
    bash = {
      enable       = true;
      shellAliases = {
        ls  = "eza --icons";
        ll  = "eza -lah --icons --git";
        lt  = "eza --tree --icons";
        cat = "bat";
      };
    };

    fzf = {
      enable                = true;
      enableBashIntegration = true;
      defaultCommand        = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      defaultOptions        = [ "--height 40%" "--border" "--preview 'bat --color=always --line-range :200 {}'" ];
    };

    zoxide = {
      enable                = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable            = true;
      nix-direnv.enable = true;
    };

    atuin = {
      enable                = true;
      enableBashIntegration = true;
    };

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
      font.size = 12;
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

      # system
      btop              # process / resource monitor
      wl-clipboard      # wayland clipboard

      # kde / plasma
      kdePackages.kio-admin
      kdePackages.ark
      kdePackages.filelight
      kdePackages.isoimagewriter
      kdePackages.partitionmanager
      # libsForQt5.polonium

      # shell
      bat        # cat
      eza        # ls
      fd         # find
      jq         # json
      ripgrep    # grep

      # dev
      gh
      opencode

      # security
      protonvpn-gui
      bitwarden-desktop

      # productivity
      google-chrome
      obsidian

      # messaging
      discord
      signal-desktop

      # media
      spotify
      vlc

      # cloud
      # terraform
      # azure-cli
      # powershell
      # awscli2

      # containers
      # minikube
      # docker

    ];

    sessionVariables = {
      EDITOR = "code";
    };

    stateVersion = "23.11"; # don't change
  };
}
