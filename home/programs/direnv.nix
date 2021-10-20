{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };
}
