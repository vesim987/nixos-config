{ config, pkgs, lib, ... }: {
  programs.exa = {
    enable = true;
    enableAliases = true;
  };

}
