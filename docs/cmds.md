## update system

### kernal check

stable / testing channel comparison

```
nix flake update --flake ./
nix eval --raw 'github:NixOS/nixpkgs/nixos-unstable#legacyPackages.x86_64-linux' \
  --apply 'pkgs:
    builtins.concatStringsSep "\n" [
      ("lts: "     + pkgs.linux.version)
      ("latest: "  + pkgs.linux_latest.version)
      ("testing: " + pkgs.linux_testing.version)
    ]'
```

### rebuild

pwd: /home/jat/nix-fwk-system

```
nix flake update --flake ./
sudo nixos-rebuild build --flake ./#fwk-nixos
nvd diff /run/current-system ./result
rm -rf result
sudo nixos-rebuild switch --flake ./#fwk-nixos
```

```
nix flake update --flake ./
sudo nixos-rebuild switch --flake ./#fwk-nixos
```

### remmove old generations

```
# nix-env --list-generations
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake ./#fwk-nixos
```

### fwupdmgr

```
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```

switch to testing channel:

```
fwupdmgr enable-remote lvfs-testing
```

disable testing channel:

```
fwupdmgr disable-remote lvfs-testing
```

### boot journal

check errors:

```
journalctl -b -0 -p err..alert
```

clear boot journal (do after rebuild)

```
sudo journalctl --rotate --vacuum-time=1s
```

## other commands

### package version check

```
uname -r
home-manager --version
plasmashell --version
```

```
find /run/current-system/sw/bin/ -type l -exec readlink {} \; | sed -E 's|[^-]+-([^/]+)/.*|\1|g' | sort -u
```
