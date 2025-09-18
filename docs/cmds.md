## CMDs

### ver checks

```
home-manager --version
plasmashell --version
```

### Kernal check

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

### Clear old generations but last one

```
nix-env --list-generations
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake ./#fwk-nixos
```

### Update system

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

### List package versions

```
find /run/current-system/sw/bin/ -type l -exec readlink {} \; | sed -E 's|[^-]+-([^/]+)/.*|\1|g' | sort -u
```

### nix prefetch git

To get the hash key:

```
nix-prefetch-git https://github.com/Keyitdev/sddm-astronaut-theme 
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

### useful framework / nixos links

https://wiki.nixos.org/wiki/Hardware/Framework/Laptop_16

### nix repl

refs: 
https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-repl
https://aldoborrero.com/posts/2022/12/02/learn-how-to-use-the-nix-repl-effectively/

to quit out of nix repl `:q`

### boot journal

check errors:

```
journalctl -b -0 -p err..alert
```

clear boot journal

```
sudo journalctl --rotate --vacuum-time=1s
```
