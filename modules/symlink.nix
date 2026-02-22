# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/symlink.nix

{ config, ... }:

{
  home.file = {
    ".config/warp-terminal/user_preferences.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/warp-terminal.json";

    ".config/Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/vscode-settings.json";
  };
}