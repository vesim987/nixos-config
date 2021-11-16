{ config, pkgs, lib, ... }: {
  programs.git = {
    enable = true;
    userEmail = "vesim809@pm.me";
    userName = "Vesim";
    extraConfig = {
      color = { ui = true; };
      core = {
        pager =
          "${pkgs.gitAndTools.diff-so-fancy}/bin/diff-so-fancy fancy | less --tabs=4 -RFX";
      };
      merge = { tool = "vimdiff"; };
      mergeTool = { keepBackup = false; };
      "mergetool \"vimdiff\"" = {
        cmd =
          "${pkgs.neovim}/bin/nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      };
    };
    ignores = [
      "*.swp"
      "*~"
      ".#*"
      ".direnv"
      ".vagrant"
      "CMakeCache.txt"
      "CMakeFiles"
      ".gdb_history"
      "zig-out"
      "zig-cache"
    ];
  };
}
