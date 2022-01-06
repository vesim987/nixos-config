{ config, pkgs, lib, home-manager, ... }: {
  home.packages = with pkgs;
    [
      (enpass.overrideAttrs (orgAttrs: {
        installPhase = builtins.replaceStrings [ "--unset QT_PLUGIN_PATH" ]
          [ "--unset QT_PLUGIN_PATH --unset QT_QPA_PLATFORM" ]
          orgAttrs.installPhase;
      }))

      zig
      zls

      albert
      pavucontrol
      tdesktop
      yubikey-manager-qt
      virt-manager

      spotify

      xdg-desktop-portal-wlr
      xdg-desktop-portal
      xdg-utils

      ripgrep

      # wine stuff
      wineWowPackages.staging
      winetricks

      # lsp servers
      rnix-lsp
      ccls
      sumneko-lua-language-server
      nodePackages.pyright # thats hurts

      #ghidra-bin
      ffmpeg
      sc-im

    ] ++ (with sway-contrib; [
      slurp
      wf-recorder
      wl-clipboard
      grimshot
      wdisplays
      swaylock
    ]);

}

