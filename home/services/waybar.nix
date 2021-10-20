{ config, pkgs, lib, ... }: {
  # send pkill -USR2 using home.file.<name>.changed
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [{
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "custom/media" ];
      modules-right =
        [ "idle_inhibitor" "network" "pulseaudio" "tray" "clock" "battery" ];
      modules = {
        "custom/media" = {
          format = "{icon} {}";
          return-type = "json";
          max-length = 40;
          escape = true;
          exec = pkgs.writeShellScript "waybar-media" ''
            echo "foo"
          '';
        };
      };
    }];
  };

}
