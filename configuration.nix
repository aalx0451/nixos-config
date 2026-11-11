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

  # Enable some secure bootargs
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_poison=1"
    "quiet"
    "slab_nomerge=1"
    "slab_debug=FZF"
  ];

  # Enable some secure sysctl settings.
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
  };

  # Show kernel errors and vconsole only.
  boot.consoleLogLevel = 3;

  # Load i915 kernel module in initrd to prevent defaulting tty font
  boot.initrd.kernelModules = [ "i915" ];

  # Host name.
  networking.hostName = "laurel";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager = {
    enable = true;
    ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

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

  # Define root account.
  users.users.root = {
    description = "System Administrator";
    enable = true;
    shell = pkgs.zsh;
  };

  # Disallow direct `useradd` using.
  users.mutableUsers = false;

  # Use tmpfs for /tmp.
  boot.tmp.useTmpfs = true;

  # Enable zRAM.
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 100;
  };

  # Make low-priority swap file on a disk.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
      priority = 1;
    }
  ];

  # Enable MAC subsystem (AppArmor)
  security.apparmor.enable = true;

  # Enable hardware graphics driver.
  hardware.graphics.enable = true;

  # Programs to enable.
  programs.dconf.enable = true;
  programs.sway.enable = true;
  programs.zsh.enable = true;

  # Fonts to enable.
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Services to enable.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;

    settings = {
      publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = true;
        publish-workstation = true;
      };
    };
  };
  services.openssh.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  services.printing.enable = true;
  services.tlp.enable = true;

  # XDG settings.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common.default = "*";
  };

  # First NixOS version installed.
  system.stateVersion = "26.11";

  # Enable Nix experemental features.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
