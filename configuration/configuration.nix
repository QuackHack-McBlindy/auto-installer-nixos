{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/gdm-logo.nix
    ./modules/gnome-background.nix
    ./modules/plymouth-logo.nix
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "nixos-training";
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.extraModprobeConfig = "options kvm-intel nested=Y";

  hardware.cpu.intel.updateMicrocode = pkgs.stdenv.isx86_64;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { enable = true; domain = true; addresses = true; };
  };
  
  boot.tmp.cleanOnBoot = true;

  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  nix = {
    optimise.automatic = true;
    gc.automatic = true;
    package = pkgs.nixVersions.unstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    tmux
    unzip
    libvirt
    virt-manager
    gnome.gnome-boxes
  ];

  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    enable = true;
    libinput.enable = true;
  };

  boot.plymouth.enable = true;

  customization = {
    gdm-logo.enable = true;
    gnome-background.enable = true;
    plymouth-logo.enable = true;
  };

  hardware.opengl = {
    # this fixes the "glXChooseVisual failed" bug,
    # context: https://github.com/NixOS/nixpkgs/issues/47932
    enable = true;
    driSupport32Bit = true;
  };

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  users.mutableUsers = false;
  users.extraUsers.root.password = "nixos";

  users.users.pungkula = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
    ];
    initialPassword = "nixcademy";
  };


  virtualisation.libvirtd.enable = true;
  #virtualisation.docker.enable = true;
  
}
