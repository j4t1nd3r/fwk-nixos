{ config, pkgs, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  
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
    ];

    file = {
      # ".config/warp-terminal/user_preferences.json".source = ../configs/warp-terminal.json;
    };

    sessionVariables = {
      EDITOR = "code";
    };
  };
  
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };

  # set allowunFree
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.git = {
    enable = true;
    userName  = "Jatinder Randhawa";
    userEmail = "j4t1nd3r@gmail.com";
  };

  programs.bash.enable = true;
  
  programs.starship = {
  enable = true;
   enableBashIntegration = true; 
  # settings = pkgs.lib.importTOML ../starship.toml;
};

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jdinhlife.gruvbox
      bbenoist.nix
      github.vscode-pull-request-github
    ];
    # userSettings = {
    #   "extensions.autoCheckUpdates" = false;
    #   "git.enableSmartCommit" = true;
    #   "git.confirmSync" = false;
    #   "editor.tabSize" = 2;
    #   "editor.renderWhitespace" = "all";
    #   "editor.fontFamily" = "'MesloLGL Nerd Font', 'Droid Sans Mono', 'monospace'";
    #   "workbench.colorTheme" = "Gruvbox Dark Hard";
    # };
  };
}
