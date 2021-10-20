{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in {
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
    ./home/default.nix
  ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/neovim-nightly-overlay/archive/987450d4b0b6943d7fb20d5d798725d1d3988ebb.tar.gz";
    }))
    (self: super: {
      zig = super.zig.overrideAttrs (old: {
        version = "0.9.0";
        src = super.fetchFromGitHub {
          owner = "ziglang";
          repo = "zig";
          rev = "cde3dd365e1fed806294eddc91700558d2135a64";
          # TODO: create githuh actions for zig stuff
          sha256 = "1qv9s2bv0r5pyc9cwlns8zyrycai7cdjcbx1nf76ddldr3v6hz6b";
        };
        nativeBuildInputs = [ pkgs.cmake pkgs.llvmPackages_13.llvm.dev ];
        buildInputs = [ pkgs.libxml2 pkgs.zlib ]
          ++ (with pkgs.llvmPackages_13; [ libclang lld llvm ]);
        doCheck = false;
      });
      zls = super.zls.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "zigtools";
          repo = "zls";
          rev = "44fb88b85b2a5a6d74e9c40ac868f824c46c4174";
          # TODO: create githuh actions for zig stuff
          sha256 = "0jhj7b0klbvlrrkigmm44dyxf5bgpcqhiin879psr1402w9wcml5";
          fetchSubmodules = true;
        };
      });
      gdb11 = super.gdb.overrideAttrs (old: {
        version = "11.1";
        src = super.fetchurl {
          url = "mirror://gnu/gdb/gdb-11.1.tar.xz";
          sha256 = "151z6d0265hv9cgx9zqqa4bd6vbp20hrljhd6bxl7lr0gd0crkyc";
        };
      });
    })
  ];

  # move to hardware-configuration.nix
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  hardware.sensor.iio.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

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

  i18n.defaultLocale = "en_US.UTF-8";

  users = {
    defaultUserShell = pkgs.zsh;
    users.vesim = {
      isNormalUser = true;
      extraGroups = [ "wheel" "adbusers" ];
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
      "nvidia-x11"
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

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

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

      libva
      intel-media-driver

      # TODO: dont use python39Full
      (python3.withPackages (p:
        with p; [
          autopep8
          black
          flake8
          ipykernel
          ipython
          ipywidgets
          mypy
          numpy
          pep8
          pyls-mypy
          requests
          scipy
          setuptools
          virtualenv

          pulsectl
          pwntools

          i3ipc
          appdirs
        ]))

      # security tools
      #python3.pkgs.pwntools
      pwndbg

      # dev stuff
      cmake
      gdb11
      meson
      ninja
      cppcheck

      unrar

      qemu_full

      # yubikey
      yubikey-manager

      # TODO: remove me
      #linuxPackages_latest.nvidia_x11
      # linuxPackages_latest.bbswitch

      # gnu stuff
      gcc
      # pkgs.pkgsCross.aarch64-multiplatform.gcc
      gcc-arm-embedded
      gnumake
      automake
      autoconf
    ] ++ (with llvmPackages_13; [ clang clang-unwrapped lld llvm ]);

  hardware.bumblebee = { enable = true; };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.light.enable = true;
  security.wrappers.light = {
    source = "${pkgs.light}/bin/light";
    owner = "root";
    setuid = true;
  };

  # enable pipewire as sound server
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # disable pulseaudio which is enabled by sound.enable
  hardware.pulseaudio.enable = false;

  hardware.bluetooth = {
    enable = true;
    hsphfpd.enable = true;
  };

  hardware.opengl.enable = true;

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
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6018", GROUP="plugdev", MODE="0666"

    # ATTR{bInterfaceNumber} is not available in tty subsystem so the ENV hack is required
    SUBSYSTEM=="tty", ATTRS{serial}=="E2C5ACC0", ENV{ID_USB_INTERFACE_NUM}=="00", SYMLINK+="ttyGdb"
    SUBSYSTEM=="tty", ATTRS{serial}=="E2C5ACC0", ENV{ID_USB_INTERFACE_NUM}=="02", SYMLINK+="ttySerial"
  '';

  services.sshd.enable = true; # TODO: remove
  programs.adb.enable = true;

  nix = {
    allowedUsers = [ "@wheel" ];

    gc = {
      automatic = true;
      dates = "weekly";
    };
    optimise = {
      automatic = true;
      dates = [ "07:00" "13:00" "22:00" ];
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

