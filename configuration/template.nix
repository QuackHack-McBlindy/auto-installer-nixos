{ lib, user ? "nix", host ? "nixos", ssid ? "", wifipass ? "", publickey ? "" }:
let
  enableWifi = ssid != "" && wifipass != "";
in
{
  
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = "";
    openssh.authorizedKeys.keys = [ publickey ];
  };

  networking = lib.mkMerge [
    {
      hostName = host;
    }

    (lib.mkIf enableWifi {
      networkmanager.wifi.backend = "iwd";
      wireless = {
        networks.${ssid}.psk = wifipass;
        iwd = {
          enable = true;
          settings = {
            Settings.AutoConnect = true;
          };
        };
      };
    })
  ];
}
