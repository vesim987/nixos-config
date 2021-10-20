{ config, pkgs, lib, home-manager, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    users.vesim = {
      imports = (import ./programs) ++ (import ./services)
        ++ [ ./packages.nix ./sway.nix ];

      home.sessionVariables = {
        # environment variables
        BROWSER = "chromium";
        EDITOR = "nvim";

        # wayland
        XDG_CURRENT_DESKTOP = "sway";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ECORE_EVAS_ENGINE = "wayland_egl";
        ELM_ENGINE = "wayland_egl";
        RTC_USE_PIPEWIRE = "true";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      gtk = {
        enable = true;
        # TODO: font theme and other crap
      };

      qt = {
        enable = true;
        # TODO: font theme and other crap
      };

      xdg = { enable = true; };
    };
  };
}
