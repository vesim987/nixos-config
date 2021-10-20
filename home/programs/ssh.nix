{ config, pkgs, lib, ... }: {
  programs.ssh = {
    enable = true;
    #startAgent = true;  not available in home-manager for some reasons
    matchBlocks = {
      "*" = { extraOptions = { "SetEnv" = "TERM=xterm-256color"; }; };
    };
  };
}
