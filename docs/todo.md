# todo

## security

- [ ] **full disk encryption (LUKS)**
  - laptop is a high theft-risk device, currently no FDE configured
  - use [disko](https://github.com/nix-community/disko) to declaratively manage partitions + LUKS setup
  - ref: reddit review suggestion (sectionme)

- [ ] **secure boot (lanzaboote)**
  - replaces `systemd-boot` with a signed bootloader chain
  - works alongside FDE for a hardened boot stack
  - https://github.com/nix-community/lanzaboote
  - ref: reddit review suggestion (sectionme)

- [ ] **declare user password via agenix**
  - `users.users.jat.password` or `hashedPasswordFile` should be managed declaratively
  - currently no secrets are defined in `secrets/secrets.nix` — agenix is wired up but unused
  - alternative: sops-nix (https://github.com/Mic92/sops-nix), though agenix is already present

- [ ] **SSH / GPG agent**
  - no `programs.gpg-agent` or `programs.ssh-agent` configured in home-manager
  - needed for signed git commits, key forwarding, password manager integration
  - ref: reddit review suggestion (sectionme)

---

## hardware / framework 16 specific

- [ ] **nixos-hardware framework module**
  - `nixos-hardware` is imported in the flake but check whether
    `nixos-hardware.nixosModules.framework-16-7040-amd` is being consumed in `configuration.nix`
  - the module bundles recommended kernel params, firmware quirks, and power tuning for the FW16

- [ ] **kernel pinning strategy**
  - currently using `linuxPackages_latest` which tracks the bleeding edge (e.g. today's 6.19.x regression)
  - consider switching to `linuxPackages` (latest LTS) for better stability on a daily driver
  - could leave `linuxPackages_latest` behind a comment as a quick toggle

- [ ] **zram swap**
  - currently using a 32GB swapfile on disk
  - zram (compressed in-memory swap) is faster and better suited to a laptop with NVMe
  - `zramSwap.enable = true;` + reduce or remove swapfile

- [ ] **lid / sleep / logind behaviour**
  - no `services.logind` configuration present
  - worth declaring: lid close action, suspend on idle, hibernate thresholds

- [ ] **powertop auto-tune with USB exclusions**
  - `powerManagement.powertop.enable` is disabled due to keyboard autosuspend bug (see bugs.md)
  - long term: configure udev rules to explicitly exclude `32ac:0018` and re-enable powertop
  - this would recover meaningful battery savings on the rest of the USB bus

---

## nix / config structure

- [ ] **modularise configuration.nix**
  - `configuration.nix` is a single file mixing hardware, desktop, audio, networking, etc.
  - consider splitting into e.g. `modules/audio.nix`, `modules/networking.nix`, `modules/printing.nix`
  - makes the config easier to reason about and reuse if a second machine is added later

- [ ] **modularise home.nix**
  - `home/home.nix` is growing — shell tools, GUI apps, KDE packages all in one file
  - consider splitting into `home/shell.nix`, `home/apps.nix`, `home/dev.nix`

- [ ] **consolidate dotfiles into flake**
  - `modules/symlink.nix` symlinks VSCode settings from `~/dotfiles` (external repo)
  - this breaks reproducibility — a fresh install requires manually cloning dotfiles first
  - consider either inlining the settings into home-manager or adding dotfiles as a flake input

- [ ] **polkit**
  - not explicitly enabled — Plasma likely pulls it in implicitly, but worth declaring
    `security.polkit.enable = true;` to make the dependency explicit
  - ref: reddit review suggestion (sectionme)

- [ ] **boot generation limit**
  - no `boot.loader.systemd-boot.configurationLimit` set
  - without a cap, every generation adds a boot entry; can clutter GRUB and fill `/boot` over time
  - `boot.loader.systemd-boot.configurationLimit = 10;` is a reasonable default

---

## applications / home

- [ ] **flatpak**
  - some apps (e.g. Obsidian, Discord) ship faster fixes via Flatpak than nixpkgs
  - `services.flatpak.enable = true;` gives an escape hatch without compromising the rest of the config

- [ ] **tailscale / VPN**
  - ProtonVPN GUI is installed but has no NixOS service declaration
  - `services.tailscale.enable` is worth considering for remote access to the machine

- [ ] **VSCode extensions — cloud/infra**
  - Terraform, PowerShell, AWS extensions are commented out in `home.nix`
  - when cloud work resumes, consider a separate `home/dev-cloud.nix` module that can be toggled
