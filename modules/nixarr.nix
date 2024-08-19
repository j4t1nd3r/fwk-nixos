{ config, pkgs, ... }:

{
  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    vpn = {
      enable = false;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = "/data/.secret/wg.conf";
    };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      expose.https = {
        enable = false;
        domainName = "your.domain.com";
        acmeMail = "your@email.com"; # Required for ACME-bot
      };
    };

    transmission = {
      enable = false;
      vpn.enable = true;
      peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = false;
    lidarr.enable = false;
    readarr.enable = false;
  };
}