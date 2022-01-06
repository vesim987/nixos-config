{ config, pkgs, lib, ... }:
let
  dsl = import ./nix2vim/lib/dsl.nix { lib = pkgs; };
  luaConfigBuilder = import ./nix2vim/lib/lua-config-builder.nix {
    pkgs = pkgs;
    lib = pkgs.lib;
  };

  luaConfig = (luaConfigBuilder { config = config; }).lua;

  config = with dsl; {
    vim.g = {
      mapleader = " ";
      nofoldenable = true;
      noshowmode = true;
      completeopt = "menu,menuone,noselect";
    };

    use."nvim-treesitter.configs".setup = callWith {
      ensure_installed =
        [ "c" "lua" "cpp" "bash" "cmake" "python" "devicetree" "nix" "zig" ];
      highlight = { enable = true; };
      rainbow = { enable = true; };
    };

    use.lspconfig.zls.setup = callWith { cmd = [ "${pkgs.zls}/bin/zls" ]; };

    use.lspconfig.ccls.setup = callWith { cmd = [ "${pkgs.ccls}/bin/ccls" ]; };

    use.lspconfig.rnix.setup =
      callWith { cmd = [ "${pkgs.rnix-lsp}/bin/rnix" ]; };

    use.cmp.setup = callWith {
      mapping = [
        {
          "['<C-n>']" = rawLua
            "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Insert })";
        }
        {
          "['<C-p>']" = rawLua
            "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Insert })";
        }
        {
          "['<Down>']" = rawLua
            "require('cmp').mapping.select_next_item({ behavior = require('cmp').SelectBehavior.Select })";
        }
        {
          "['<Up>']" = rawLua
            "require('cmp').mapping.select_prev_item({ behavior = require('cmp').SelectBehavior.Select })";
        }
        { "['<C-d>']" = rawLua "require('cmp').mapping.scroll_docs(-4)"; }
        { "['<C-f>']" = rawLua "require('cmp').mapping.scroll_docs(4)"; }
        { "['<C-Space>']" = rawLua "require('cmp').mapping.complete()"; }
        { "['<C-e>']" = rawLua "require('cmp').mapping.close()"; }
        {
          "['<CR>']" = rawLua
            "require('cmp').mapping.confirm({ behavior = require('cmp').ConfirmBehavior.Replace, select = true, })";
        }
      ];
      sources = [ { name = "nvim_lsp"; } { name = "buffer"; } ];
    };

  };
in {

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    extraConfig = ''
      lua << EOF
      ${builtins.readFile ../configs/nvim-init.lua}
      EOF
    '';

    extraPackages = with pkgs; [ tree-sitter ];

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      lspsaga-nvim

      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      lspkind-nvim

      lush-nvim
      gruvbox-nvim

      telescope-nvim
      popup-nvim
      plenary-nvim
      telescope-fzf-native-nvim
      (nvim-treesitter.withPlugins (plugins:
        with plugins; [
          tree-sitter-c
          tree-sitter-lua
          tree-sitter-cpp
          tree-sitter-bash
          tree-sitter-cmake
          tree-sitter-python
          tree-sitter-devicetree
          tree-sitter-nix
          tree-sitter-zig
        ]))

      zig-vim
      bufferline-nvim
    ];
  };
}
