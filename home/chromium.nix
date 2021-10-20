{ config, pkgs, lib, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "kmcfomidfpdkfieipokbalgegidffkal" # enpass
    ];
  };

}
