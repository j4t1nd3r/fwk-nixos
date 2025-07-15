# ./home/symlink.nix

{ config, ... }:

{
  home.file = {
    ".config/warp-terminal/user_preferences.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/warp-terminal.json";

    ".config/Code/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/vscode-settings.json";

    ".config/kscreenlockerrc" = {
      force = true;
      text = ''
        [Greeter]
        WallpaperPlugin=org.kde.image
        [Greeter][Wallpaper][org.kde.image][General]
        Image=file://${builtins.toString ../assets/gorod-siluet-art-kiberpank.jpeg}
      '';
    };
  };
}