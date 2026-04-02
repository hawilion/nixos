{ config, pkgs, ... }:

{
  services.tailscale.enable = true;

  # Open the firewall for Tailscale's UDP port
  networking.firewall.allowedUDPPorts = [ 41641 ];

  # Update Nextcloud to use the Tailscale name
  services.nextcloud = {
    # Replace the IP with your Tailscale machine name
    hostName = "nixos-server"; 
    settings.trusted_domains = [ "nixos-server" "nixos-server.your-tailnet.ts.net" ];
  };
}
