{ config, pkgs, lib, ... }: {
  # programs.neovim is generating init.vim which is causing issues
  xdg.configFile."nvim/init.lua".source = ../configs/nvim-init.lua;
}
