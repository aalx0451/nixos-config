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

  # Time zone.
  time.timeZone = "Europe/Moscow";

  # Internationalisation properties.
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "cyr-sun16";
    keyMap = "ru";
  };

  # Define user accounts.
  users.users.lina = {
    createHome = true;
    description = "Polina S.";
    enable = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    group = "users";
    hashedPassword = "$y$j9T$.bDyP0NucYQ5EJCvNFR9H1$JA1GE15yUPxevjEQNX2JOJuWp7mBtvWy9zXpPnRkiU8";
    home = "/home/lina";
    homeMode = "0700";
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # Disallow direct `useradd` using.
  users.mutableUsers = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  system.stateVersion = "26.11";
}
