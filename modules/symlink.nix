# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./modules/symlink.nix

{ config, ... }:

# Symlinks point to ~/dotfiles which is managed in a separate repo.
# This is intentional — dotfiles are excluded from this flake to avoid
# git noise. Ensure ~/dotfiles is cloned and populated before activating
# home-manager, otherwise these symlink targets will be missing.
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