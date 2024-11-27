## CMDs

### Clear old generations but last one

```
nix-env --list-generations
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d
```

### Update system

pwd: $home

```
nix flake update --flake ./nix-fwk-system/
sudo nixos-rebuild switch --flake nix-fwk-system/#fwk-nixos
```

pwd: /home/jat/nix-fwk-system

```
nix flake update --flake ./
sudo nixos-rebuild switch --flake ./#fwk-nixos
```

### List package versions

```
find /run/current-system/sw/bin/ -type l -exec readlink {} \; | sed -E 's|[^-]+-([^/]+)/.*|\1|g' | sort -u
```

### fwupdmgr

```
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update
```

### useful framework / nixos links

https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_16