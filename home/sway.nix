{ config, pkgs, lib, ... }:
let
  terminal_wrapper = pkgs.writeShellScriptBin "sway-terminal" ''
    WINDOW_PID="$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -e 'recurse(.nodes[]?) | select((.focused==true) and (.app_id=="foot")).pid')"
    if [ "a$?" = "a0" ]; then
        SHELL_PID="$(${pkgs.procps}/bin/ps --no-headers --ppid "''${WINDOW_PID}" | ${pkgs.gawk}/bin/awk '{print $1; exit}')"
        if [ "a$?" = "a0" ]; then
            WORKING_DIRECTORY="$(${pkgs.coreutils}/bin/readlink "/proc/''${SHELL_PID}/cwd")"
        fi
    fi

    if [ "a''${WORKING_DIRECTORY}" = "a" ]; then
        WORKING_DIRECTORY="''${HOME}"
    fi

    exec ${pkgs.foot}/bin/foot --working-directory "''${WORKING_DIRECTORY}"
  '';
  sway_lock = pkgs.writeShellScriptBin "swaylock" ''
    exec ${pkgs.swaylock-effects}/bin/swaylock \
             -S \
             --effect-blur 7x4 \
             --effect-greyscale \
             --clock \
             --hide-keyboard-layout
      '';
in {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      menu = "${pkgs.albert}/bin/albert show";
      terminal = "${terminal_wrapper}/bin/sway-terminal";

      input = {
        "*" = {
          xkb_options = "caps:escape";
          xkb_layout = "pl,us";
        };
        "1739:6572:SYNA2393:00_06CB:19AC" = { map_to_output = "eDP-1"; };
        "1739:52552:SYNA1D31:00_06CB:CD48_Touchpad" = {
          dwt = "enable"; # disable-while-typing
          tap = "enable";
          middle_emulation = "enable";
        };
      };
      # TODO: for_window stuff

      modifier = "Mod4";
      focus = { followMouse = false; };
      window.border = 0;
      gaps = {
        smartGaps = true;
        inner = 2;
        outer = 5;
      };
      workspaceAutoBackAndForth = true;
      bars = [ ]; # bars are handled by waybar

      seat = { "*" = { hide_cursor = "5000"; }; };

      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
        inherit (config.wayland.windowManager.sway.config)
          left down up right menu terminal;
      in {
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+Shift+q" = "kill";
        "Mod1+Space" = "exec ${menu}";
        "${mod}+Ctrl+L" = "exec ${sway_lock}/bin/swaylock";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

        # TODO: use avizo for volume and brightness
        "XF86AudioRaiseVolume" = ''
          exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume "@DEFAULT_SINK@" "+5%"'';
        "XF86AudioLowerVolume" = ''
          exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume "@DEFAULT_SINK@" "-5%"'';
        "XF86AudioMute" = ''
          exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute "@DEFAULT_SINK@" toggle'';
        "XF86AudioMicMute" = ''
          exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-source-mute "@DEFAULT_SOURCE@" toggle'';

        # TODO: somehow use wrappers in a better way
        "XF86MonBrightnessUp" = "exec /run/wrappers/bin/light -A 10";
        "XF86MonBrightnessDown" = "exec /run/wrappers/bin/light -U 10";

        "${mod}+Tab" = "workspace next_on_output";
        "${mod}+Shift+Tab" = "workspace prev_on_output";

        # the rest is kinda standard
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";

        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        "${mod}+f" = "fullscreen";

        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        "${mod}+a" = "focus parent";

        "${mod}+r" = "mode resize";
      };
      modes = {
        resize = {
          Left = "resize shrink width";
          Right = "resize grow width";
          Down = "resize shrink height";
          Up = "resize grow height";
          h = "resize shrink width";
          l = "resize grow width";
          j = "resize shrink height";
          k = "resize grow height";
          Return = "mode default";
          Escape = "mode default";
        };
      };
    };
  };
}
