{ config, pkgs, lib, ... }:
let dell = "Dell Inc. DELL U2414H 292K46A515ML";
in {
  services.kanshi = {
    enable = true;
    profiles = {
      alone = {
        outputs = [{
          criteria = "eDP-1";
          scale = 2.0;
          position = "0,0";
          transform = "normal";
        }];
        exec = [ "/home/vesim/audio_switcher.py eDP-1" ];
      };
      dell = {
        outputs = [
          {
            criteria = "eDP-1";
            scale = 2.0;
            position = "240,1080";
            transform = "normal";
          }
          {
            criteria = "${dell}";
            scale = 1.0;
            position = "0,0";
            transform = "normal";
          }
        ];
        exec = [ "/home/vesim/audio_switcher.py '${dell}'" ];
      };
    };
  };
}
