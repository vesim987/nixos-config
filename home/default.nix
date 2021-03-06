{ config, pkgs, lib, inputs, ... }: {
  imports = (import ./programs) ++ (import ./services)
    ++ [ ./packages.nix ./sway.nix ];

  home.sessionVariables = {
    # environment variables
    BROWSER = "chromium";
    EDITOR = "nvim";

    # wayland
    XDG_SESSION_TYPE = "wayland";
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
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    # TODO: font theme and other crap
  };

  qt = {
    enable = true;
    # TODO: font theme and other crap
  };

  xdg = { enable = true; };

  #systemd.user.services.xdg-desktop-portal.enable = true;
  #systemd.user.services.xdg-desktop-portal-wlr.enable = true;

  # TODO: create service for albert
  xdg.configFile."albert/albert.conf".source = ./configs/albert.conf;
  systemd.user.services.albert = {
    Unit = {
      Description = "Albert Launcher";
      PartOf = "sway-session.target";
      Requires = "sway-session.target";
      After = "sway-session.target";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.albert}/bin/albert";
      Restart = "always";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };
}
