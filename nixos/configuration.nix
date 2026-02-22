# ./nixos/configuration.nix

# nixos-help
{ inputs, pkgs, lib, ... }:

{
  # --- changes frequently ---

  # switch over to testing channel:
  # boot.kernelPackages = pkgs.linuxPackages_testing; # 04/09/25
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    nvd
    nix-prefetch-git
    tree
    usbutils
    hplipWithPlugin
    pciutils
    util-linux
  ];

  fonts.packages = with pkgs; [ nerd-fonts.meslo-lg ];

  home-manager = {
    useGlobalPkgs    = true;
    useUserPackages  = true;
    users.jat        = import ../home/home.nix;
    sharedModules    = [ inputs.plasma-manager.homeModules.plasma-manager ];
    extraSpecialArgs = { inherit inputs; };
  };

  # Workaround: AMDGPU DCN 3.1.4 loses precision when Plasma 6.6+ programs
  # the display shaper LUT, causing intermittent graphical artifacts.
  # Disabling hardware color management forces the pipeline through software.
  environment.sessionVariables.KWIN_DRM_NO_AMS = "1";

  # --- set once ---

  users.users.jat = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "lp" "scanner" ];
  };

  networking = {
    hostName              = "jat-fwk-nix";
    networkmanager.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  hardware = {
    bluetooth.enable                = true;
    bluetooth.powerOnBoot           = true;
    enableRedistributableFirmware   = true; # enables AMD CPU microcode updates
  };

  services.printing = {
    enable  = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  systemd.services.cups.wantedBy = lib.mkForce [ ]; # service not required on boot

  security.rtkit.enable = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
  };

  services.libinput.touchpad.disableWhileTyping = true;

  time.timeZone               = "Europe/London";
  services.xserver.xkb.layout = "gb";
  console.keyMap              = "uk";
  i18n.defaultLocale          = "en_GB.UTF-8";

  swapDevices = [{ device = "/swapfile"; size = 32 * 1024; }];

  services.power-profiles-daemon.enable = true;
  services.fwupd.enable                 = true;

  nixpkgs.config.allowUnfree = true;

  # --- static (set at install) ---

  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ../modules/default.nix
  ];

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "23.11"; # do not bump
}