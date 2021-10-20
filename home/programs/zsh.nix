{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    shellAliases = {

    };
    initExtraFirst = builtins.readFile ../configs/zshrc;
  };

}
