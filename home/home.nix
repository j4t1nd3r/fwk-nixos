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
        ls   = "eza --icons";
        ll   = "eza -lah --icons --git";
        lt   = "eza --tree --icons";
        cat  = "bat";
        copy = "wl-copy";
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
      settings.update_check = false;
    };

    git = {
      enable    = true;
      settings.user.name  = "Jatinder Randhawa";
      settings.user.email = "44571350+j4t1nd3r@users.noreply.github.com";
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
        jnoortheen.nix-ide
        jdinhlife.gruvbox
        eamodio.gitlens
        # # cloud
        # hashicorp.terraform
        # ms-vscode.powershell

      ];
    };
  };

  home = {
    packages = with pkgs; [

      # system
      btop  # process / resource monitor

      # kde / plasma
      kdePackages.kio-admin
      kdePackages.ark
      kdePackages.partitionmanager
      kdePackages.filelight
      kdePackages.isoimagewriter
      kdePackages.polonium

      # shell
      bat           # cat
      eza           # ls
      fd            # find
      jq            # json
      ripgrep       # grep
      wl-clipboard  # cli | copy

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
      EDITOR                       = "nano";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";  # forces electron apps (vscode, chrome, discord) to run native wayland, fixes ctrl modifier issues
    };

    stateVersion = "23.11"; # don't change
  };
}
