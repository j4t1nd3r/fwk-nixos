# ./nixos/configuration.nix

{ inputs, pkgs, ... }:

let
  sddmAstronautCp = pkgs.sddm-astronaut.override {
    embeddedTheme = "cyberpunk";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ../modules/default.nix
  ];

  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;

    theme          = "sddm-astronaut-theme";
    extraPackages  = [ sddmAstronautCp ];
  };

  services.desktopManager.plasma6.enable = true;

  home-manager = {
    users.jat = import ../home-manager/home.nix;
    extraSpecialArgs = {
      inherit inputs;
      plasma-manager        = inputs.plasma-manager;
      nix-vscode-extensions = inputs.nix-vscode-extensions;
    };
  };

  users.users.jat = {
    isNormalUser = true;
    extraGroups  = [ "networkmanager" "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    home-manager
    nix-prefetch-git
    usbutils
    tree
    sddmAstronautCp
  ];

  fonts.packages = with pkgs; [ nerd-fonts.meslo-lg ];

  services.libinput.touchpad.disableWhileTyping = true;

  time.timeZone               = "Europe/London";
  services.xserver.xkb.layout = "gb";
  console.keyMap              = "uk";

  i18n.defaultLocale = "en_GB.UTF-8";

  networking = {
    hostName = "jat-fwk-nix";
    networkmanager.enable = true;
  };

  hardware.bluetooth = { enable = true; powerOnBoot = true; };

  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  services.power-profiles-daemon.enable = true;
  services.fwupd.enable                 = true;

  boot.kernelPackages                   = pkgs.linuxPackages_6_15;
  boot.loader.systemd-boot.enable       = true;
  boot.loader.efi.canTouchEfiVariables  = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
