## CMDs

### ver checks

```
home-manager --version
plasmashell --version
```

### Kernal check

```
uname -r
nix eval --raw 'github:NixOS/nixpkgs/nixos-unstable#linuxPackages_latest.kernel.version'
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

### boot errors

```
journalctl -b -0 -p err..alert
```

### clear boot journal
```
sudo journalctl --rotate --vacuum-time=1s
```

### printing

model: HP OfficeJet Pro x476dw

initial setup:

```
hp-setup <ip of hp printer>
```

loookup current print queues:

```
lpstat -p -d
```

print all pdfs in current directory:

```
lp -d 35-npv *.pdf *.PDF
```

#### print files in subdirectories

output of print & order:

```
find . -type f -iname '*.pdf' -print0   | \
  sort -z                                | \
  xargs -0 printf '%s\n'
```

redirect to print: 

```
find . -type f -iname '*.pdf' -print0 |
  sort -z |
  xargs -0 -n1 lp -d 35-npv
```