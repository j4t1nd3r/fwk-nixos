# ./nixos/configuration.nix

# nixos-help

{ inputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      ../modules/default.nix
    ];

  # swap file
  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16Gb
  }];

  # power management
  services.power-profiles-daemon = {
    enable = true;
  };

  # enable bios updates, run "fwupdmgr update" to update
  services.fwupd.enable = true;

  # home-manager
  home-manager = {
    users.jat =  import ../home-manager/home.nix;

    extraSpecialArgs = { 
      inherit inputs;
      plasma-manager = inputs.plasma-manager;
      nix-vscode-extensions = inputs.nix-vscode-extensions; 
    };
  };  

  # last updated: 07/07/25
  boot.kernelPackages = pkgs.linuxPackages_6_15;
  # to check for latest:
  # nix eval --raw 'github:NixOS/nixpkgs/nixos-unstable#linuxPackages_latest.kernel.version'

  networking.hostName = "jat-fwk-nix";

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true; 
  hardware.bluetooth.powerOnBoot = true;

  # Set time zone.
  time.timeZone = "Europe/London";

  i18n = {
    # Select internationalisation properties.
    defaultLocale = "en_GB.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services.libinput.touchpad.disableWhileTyping = true;

  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;

    theme          = "sddm-astronaut-theme";
    extraPackages  = [ pkgs.sddm-astronaut ];

    settings = {
      Theme.CursorTheme   = "Breeze_Snow";
      General.HaltCommand = "systemctl poweroff";
      General.RebootCommand = "systemctl reboot";
    };
  };
  
  services.desktopManager.plasma6.enable = true;
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  ## 18/03/25 didnt work, need to fix / or print config is not correct for CUPS

  # # Enable CUPS to print documents.
  # services.printing.enable = true;

  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  # Audio
  security.rtkit.enable = true;
  # hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jat = {
    isNormalUser = true;
    description = "Jatinder";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    home-manager
    nix-prefetch-git
    usbutils
    tree
    sddm-astronaut
  ];
    
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11";
}