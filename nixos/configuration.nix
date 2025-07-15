# ./nixos/configuration.nix

# nixos-help
{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ../modules/default.nix
  ];
  # to check for latest:
  # nix eval --raw 'github:NixOS/nixpkgs/nixos-unstable#linuxPackages_latest.kernel.version'
  boot.kernelPackages = pkgs.linuxPackages_6_15; # 07/07/25

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
    nvd
    nix-prefetch-git
    home-manager
    tree
    usbutils
  ];

  fonts.packages = with pkgs; [ nerd-fonts.meslo-lg ];

  services.libinput.touchpad.disableWhileTyping = true;

  time.timeZone               = "Europe/London";
  services.xserver.xkb.layout = "gb";
  console.keyMap              = "uk";

  i18n.defaultLocale = "en_GB.UTF-8";

  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  services.desktopManager.plasma6.enable = true;

  hardware.bluetooth = { enable = true; powerOnBoot = true; };

  networking = {
    hostName            = "jat-fwk-nix";
    networkmanager.enable = true;
  };

  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];

  services.power-profiles-daemon.enable = true;
  services.fwupd.enable                 = true;

  boot.loader.systemd-boot.enable       = true;
  boot.loader.efi.canTouchEfiVariables  = true;
  
  boot.blacklistedKernelModules = [ 
    "cros_usbpd_charger" # chromebook usbpd, not for framework
    "framework_leds" # led matrix not used
  ]; # 15/07/25 

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11";
}
