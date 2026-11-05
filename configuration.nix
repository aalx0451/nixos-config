# System configuration file

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host name.
  networking.hostName = "laurel";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  system.stateVersion = "26.11";
}
