{ config, pkgs, lib, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Consolas:size=14";
        letter-spacing = 0;
        horizontal-letter-offset = 0;
        vertical-letter-offset = 0;
        pad = "2x2";
      };
    };
  };

}
