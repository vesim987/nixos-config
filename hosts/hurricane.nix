{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # move to hardware-configuration.nix
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/EFI";

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  time.timeZone = "Europe/Warsaw";

  networking.hostName = "hurricine";

  # explicitly disable dhcpcd
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # enable systemd-networkd and iwd
  networking.useNetworkd = true;

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
  #networking.bridges = { htpc0 = {}; };

  services.resolved.extraConfig = ''
    MulticastDNS=resolve
  '';

  containers = {
    jellyfin = {
      ephemeral = true;
      autoStart = true;
      bindMounts = {
        "/config" = {
          hostPath = "/opt/htpc/jellyfin";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.jellyfin = {
          enable = true;
          openFirewall = true;
          dataDir = "/config";
        };
      };
    };
    jackett = {
      ephemeral = true;
      autoStart = true;
      bindMounts = {
        "/config" = {
          hostPath = "/opt/htpc/jackett";
          isReadOnly = false;
          dataDir = "/config";
        };
      };
      config = { config, pkgs, ... }: {
        services.jackett = {
          enable = true;
          openFirewall = true;
          dataDir = "/config";
        };
      };
    };
    sonarr = {
      ephemeral = true;
      autoStart = true;
      bindMounts = {
        "/config" = {
          hostPath = "/opt/htpc/sonarr";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.sonarr = {
          enable = true;
          openFirewall = true;
        };
      };
    };
    radarr = {
      ephemeral = true;
      autoStart = true;
      bindMounts = {
        "/config" = {
          hostPath = "/opt/htpc/radarr";
          isReadOnly = false;
        };
      };
      config = { config, pkgs, ... }: {
        services.radarr = {
          enable = true;
          openFirewall = true;
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /opt/htpc/jellyfin 0755 vesim users"
    "d /opt/htpc/jackett 0755 vesim users"
    "d /opt/htpc/sonarr 0755 vesim users"
    "d /opt/htpc/radarr 0755 vesim users"
  ];

  #services = {
  #  sonarr = {
  #    enable = true;
  #    openFirewall = true;
  #  };
  #  radarr = {
  #    enable = true;
  #    openFirewall = true;
  #  };
  #  jackett = { enable = true; };
  #  ombi = { enable = true; };
  #};

  i18n.defaultLocale = "en_US.UTF-8";

  users = {
    defaultUserShell = pkgs.bash;
    users.vesim = {
      password = "foo";
      isNormalUser = true;
      extraGroups = [ "wheel" "adbusers" "docker" ];
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "unrar" ];

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

      usbutils

      foot # for terminfo

    ] ++ (with llvmPackages_13; [ clang-unwrapped lld llvm ]);

  services.avahi = { enable = true; };

  services.locate.enable = true;
  services.sshd.enable = true;

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

  #networking.firewall.allowedTCPPortRanges = [];
  #networking.firewall.allowedUDPPortRanges = [];

  system.stateVersion = "21.11";
}

