{ config, pkgs, lib, ... }:
let
  sway_start = pkgs.writeShellScriptBin "sway-start" ''
    source /etc/profile 
    source /home/vesim/.nix-profile/etc/profile.d/hm-session-vars.sh
    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway
  '';
in {
  imports = [ ./hardware-configuration.nix ];

  # move to hardware-configuration.nix
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  hardware.sensor.iio.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  time.timeZone = "Europe/Warsaw";

  networking.hostName = "storm";

  # explicitly disable dhcpcd
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # enable systemd-networkd and iwd
  networking.useNetworkd = true;
  networking.wireless.iwd.enable = true;

  # INFO: networking.interfaces sucks
  # networking.interfaces.enp0s20f0u1.useDHCP = true;
  # networking.interfaces.wlan0.useDHCP = true;
  # so use systemd.network directly
  systemd.network.networks = {
    "99-en-dhcp" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
      routes = [{ routeConfig = { Metric = 1024; }; }];
    };
    "99-wl-dhcp" = {
      matchConfig.Name = "wl*";
      networkConfig.DHCP = "yes";
      routes = [{ routeConfig = { Metric = 1000; }; }];
    };
  };
  programs.dconf.enable = true;
  #services.dbus.packages = with pkgs; [ gnome3.dconf ];

  services.resolved.extraConfig = ''
    MulticastDNS=resolve
  '';

  networking.extraHosts = ''
    10.0.0.10 jellyfin.htpc.ves.im
    10.0.0.10 sonarr.htpc.ves.im
    10.0.0.10 qbittorrent.htpc.ves.im
    10.0.0.10 radarr.htpc.ves.im
    10.0.0.10 ombi.htpc.ves.im
  '';

  virtualisation = {
    waydroid.enable = true;
    docker.enable = true;
    lxc.enable = true;
    lxd.enable = true;
    # libvirtd = { enable = true; };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users = {
    defaultUserShell = pkgs.zsh;
    users.vesim = {
      isNormalUser = true;
      extraGroups = [ "wheel" "adbusers" "docker" ];
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "enpass"
      "vista-fonts"
      "symbola"
      "corefonts"
      "spotify-unwrapped"
      "spotify"
      "unrar"
    ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts
      proggyfonts
      dejavu_fonts
      dina-font
      proggyfonts
      terminus_font
      vistafonts
      font-awesome-ttf
      symbola
      meslo-lgs-nf
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
    ];
  };

  environment.systemPackages = with pkgs;
    [
      # TODO: add more utils
      htop
      bash
      findutils
      moreutils
      unzip
      tmux
      neovim-nightly
      killall
      wget
      nixfmt
      nix-index
      pciutils

      docker-compose
      lxc
      lxd

      # networking stuff
      dnsutils
      inetutils
      bridge-utils
      iw
      wirelesstools

      usbutils

      foot # for terminfo

      # TODO: ???
      vulkan-tools
      vulkan-loader
      mesa-demos

      # TODO: dont use python39Full
      (python3.withPackages (p:
        with p; [
          autopep8
          black
          flake8
          ipython
          mypy
          numpy
          pep8
          requests
          scipy
          setuptools
          virtualenv

          pulsectl
          #pwntools

          i3ipc
          appdirs
        ]))

      # security tools
      #python3.pkgs.pwntools
      #pwndbg

      # dev stuff
      cmake
      gdb
      meson
      ninja
      cppcheck

      # embedded
      picocom
      openocd
      stm32flash
      dfu-util

      unrar

      # yubikey
      yubikey-manager

      # gnu stuff
      gcc
      # pkgs.pkgsCross.aarch64-multiplatform.gcc
      gcc-arm-embedded
      gnumake
      automake
      autoconf

      # ???
      polkit
      polkit_gnome
    ] ++ (with llvmPackages_13; [ clang-unwrapped lld llvm ]);

  # TODO: make this working
  systemd.services.sway = {
    wantedBy = [ "graphical.target" ];
    after = [ "systemd-user-sessions.service" ];
    #aliases = ["display-manager.service"];
    description = "Start sway";
    serviceConfig = {
      Type = "simple";
      User = "vesim";
      WorkingDirectory = "/home/vesim";
      TTYPath = "/dev/tty1";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      PAMName = "login";
      StandardInput = "tty";
      StandardError = "journal";
      StandardOutput = "journal";
      ExecStart = "${sway_start}/bin/sway-start";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  hardware.bumblebee = {
    enable = true;
    driver = "nouveau";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.usbguard = {
    enable = true;
    IPCAllowedUsers = [ "vesim" "root" ];
  };
  systemd.services.usbguard-dbus = {
    enable = true;
    description = "USBGuard D-Bus Service";
    requires = [ "usbguard.service" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.usbguard1";
      ExecStart = "${pkgs.usbguard}/bin/usbguard-dbus";
    };
    wantedBy = [ "multi-user.target" ];
    aliases = [ "dbus-org.usbguard.service" ];
  };

  services.avahi = { enable = true; };

  programs.light.enable = true;
  security.wrappers.light = {
    source = "${pkgs.light}/bin/light";
    owner = "root";
    group = "video";
    setgid = true;
  };

  # enable pipewire as sound server
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  # disable pulseaudio which is enabled by sound.enable
  hardware.pulseaudio.enable = false;

  hardware.bluetooth = {
    enable = true;
    hsphfpd.enable = true;
  };

  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf --experimental"
  ];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver vaapiVdpau libvdpau-va-gl ];
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
      gtkUsePortal = true;
    };
  };

  security.pam.services.swaylock = { };

  # power saving stuff
  powerManagement.powertop.enable = true;
  # TODO: config
  services.throttled.enable = true;
  # TODO: config
  services.tlp.enable = true;
  services.upower.enable = true;
  services.acpid.enable = true;

  # thunderbolt stuff
  services.hardware.bolt.enable = true;

  services.locate.enable = true;

  # udev rules for yubikeys
  services.udev.packages = [ pkgs.yubikey-personalization ];
  # smartcard support for yubikey
  services.pcscd.enable = true;

  # udev rules for blackmagic probe
  services.udev.extraRules = ''
    # for some reasons setting the env below doesn't work
    SUBSYSTEMS=="usb", ENV{ID_USB_INTERFACE_NUM}="$attr{bInterfaceNumber}"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6018", GROUP="plugdev", MODE="0666", ENV{ID_USB_VENDOR}="$attr{idProduct}"

    # ATTR{bInterfaceNumber} is not available in tty subsystem so the ENV hack is required
    SUBSYSTEM=="tty", ENV{ID_USB_VENDOR}=="1d50", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="ttyGdb"
    SUBSYSTEM=="tty", ENV{ID_USB_VENDOR}=="1d50", ENV{ID_USB_INTERFACE_NUM}=="02", SYMLINK+="ttySerial"
  '';

  services.sshd.enable = true; # TODO: remove
  programs.adb.enable = true;

  nix = {
    binaryCaches =
      [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    allowedUsers = [ "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "weekly";
    };

    optimise = {
      automatic = true;
      dates = [ "07:00" "22:00" ];
    };
  };

  networking.firewall.allowedTCPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 1714;
    to = 1764;
  }];

  system.stateVersion = "21.05";
}

