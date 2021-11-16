-------------------- HELPERS -------------------------------
cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
fn = vim.fn -- to call Vim functions e.g. fn.bufnr()

g_meta = {}
function g_meta:__newindex(index, value) vim.g[index] = value end

function g_meta:__index(index) return vim.g[index] end
g = setmetatable({}, g_meta)
o = vim.o

function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- make vim pure
g.loaded_python3_provider = 0
g.loaded_python_provide = 0
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-------------------- PLUGINS -------------------------------
cmd "packadd! packer.nvim" -- load the package manager

require("packer").startup(function()
    use {"wbthomason/packer.nvim", opt = true}
    use {
        "neovim/nvim-lspconfig",
        ft = {"zig", "c", "cpp", "python", "nix", "javascript"},
        requires = {"ray-x/lsp_signature.nvim"},
        config = function()
            local lsp = require("lspconfig")

            function on_attach()
                require"lsp_signature".on_attach()
                -- require'completion'.on_attach()
            end

            lsp.pyright.setup {on_attach = on_attach}
            lsp.zls.setup {on_attach = on_attach}
            lsp.sumneko_lua.setup {on_attach = on_attach} -- , cmd = "lua-language-server"}
            lsp.ccls.setup {on_attach = on_attach}
            lsp.rnix.setup {on_attach = on_attach}
            lsp.tsserver.setup {on_attach = on_attach}
        end
    }
    use {"cpiger/NeoDebug"}
    --use {
    --  "rmagatti/session-lens",
    --  requires = {"nvim-telescope/telescope.nvim", 
    --    {
    --      "rmagatti/auto-session",
    --      config = function()
    --        require('auto-session').setup {
    --          auto_session_allowed_dirs = {'~/pro'},
    --          auto_save_enabled = true,
    --        }
    --        vim.o.sessionoptions="blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos,terminal"
    --      end
    --    }
    --  },
    --  config = function()
    --    require('session-lens').setup({--[[your custom config--]]})
    --    require("telescope").load_extension("session-lens")
    --  end
    --}
    use {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require "cmp"

            cmp.setup {
                mapping = {
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<c-y>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true
                    },
                    ["<c-space>"] = cmp.mapping.complete()
                },
                sources = {
                    {name = "nvim_lsp"}, {name = "cmp_luasnip"}, {name = "path"},
                    {name = "buffer", keyword_length = 3}
                },
                formatting = {
                    format = require"lspkind".cmp_format {
                        with_text = true,
                        menu = {
                            buffer = "[buf]",
                            nvim_lsp = "[LSP]",
                            path = "[path]",
                            luasnip = "[snip]",
                        }
                    }
                },
                experimental = {native_menu = false, ghost_text = true}
            }

            vim.o.completeopt = "menuone,noselect"
        end,
        requires = {
            {
                "onsails/lspkind-nvim",
                config = function() require"lspkind".init() end
            }, {"hrsh7th/cmp-nvim-lsp"}, {"hrsh7th/cmp-buffer"},
            {"hrsh7th/cmp-path"},
            {"saadparwaiz1/cmp_luasnip", requires = {{"L3MON4D3/LuaSnip"}}}
        }
    }

    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            {"nvim-lua/popup.nvim"}, {"nvim-lua/plenary.nvim"},
            {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}
        },
        config = function()
            require("telescope").setup {
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = "smart_case" -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    }
                }
            }

            require("telescope").load_extension("fzf")
            map("n", "<C-p>", "<cmd>Telescope find_files<cr>")
            map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
            map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")

            map("n", "<leader>d", "<cmd>:Telescope lsp_definitions<CR>")
            map("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>")
            map("n", "<leader>h", "<cmd>lua vim.lsp.buf.hover()<CR>")
            map("n", "<leader>m", ":Lspsaga rename<CR>")
            map("n", "<leader>r", "<cmd>Telecope lsp_references<CR>")
            map("n", "<leader>s", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")

        end
    }


    use {
        "nvim-treesitter/playground",
        requires = {
            {
                "nvim-treesitter/nvim-treesitter",
                config = function()
                    require"nvim-treesitter.configs".setup {
                        ensure_installed = {
                            "c", "cpp", "python", "zig", "lua", "nix", "javascript"
                        },
                        highlight = {enable = true, use_lanugagetree = true}
                    }
                end
            }
        }
    }
    use {
        "marko-cerovac/material.nvim",
        config = function()
            require("material.functions").change_style("deep ocean")
            require("material").setup({italics = {comments = true}})
            cmd [[colorscheme material]]
        end
    }

    use {"andymass/vim-matchup", event = "VimEnter *"}

    -- git stuff
    use {"tpope/vim-fugitive"}
    use {"tpope/vim-rhubarb"}
    use {"airblade/vim-gitgutter"}

    use {
        "liuchengxu/vista.vim",
        config = function() g.vista_default_executive = "nvim_lsp" end
    }

    use {"luochen1990/rainbow", config = function() g.rainbow_active = 1 end}

    use {"terminalnode/sway-vim-syntax"}

    use {"ziglang/zig.vim", config = function() g.zig_fmt_autosave = 1 end}

    use {
        "tpope/vim-dispatch",
        config = function() map("n", "<leader>z", ":Make<CR>") end
    }

    use {"tpope/vim-commentary"}

    use {
        "editorconfig/editorconfig-vim",
        config = function()
            g.EditorConfig_exclude_patterns = {"fugitive://.*", "scp://.*"}
        end
    }

    use {"kyazdani42/nvim-web-devicons"}
    use {
        "kyazdani42/nvim-tree.lua",
        config = function()
            cmd("nnoremap <C-n> :NvimTreeToggle<CR>")
            cmd("nnoremap <leader>r :NvimTreeRefresh<CR>")
            cmd("nnoremap <leader>n :NvimTreeFindFile<CR>")
        end
    }

    use {
        "akinsho/nvim-bufferline.lua",
        config = function()
            require("bufferline").setup {
                options = {
                    custom_areas = {
                        right = function()
                            local result = {}
                            local error =
                                vim.lsp.diagnostic.get_count(0, [[Error]])
                            local warning =
                                vim.lsp.diagnostic.get_count(0, [[Warning]])
                            local info =
                                vim.lsp.diagnostic.get_count(0, [[Information]])
                            local hint =
                                vim.lsp.diagnostic.get_count(0, [[Hint]])

                            if error ~= 0 then
                                result[1] = {
                                    text = "  " .. error,
                                    guifg = "#EC5241"
                                }
                            end

                            if warning ~= 0 then
                                result[2] = {
                                    text = "  " .. warning,
                                    guifg = "#EFB839"
                                }
                            end

                            if hint ~= 0 then
                                result[3] = {
                                    text = "  " .. hint,
                                    guifg = "#A3BA5E"
                                }
                            end

                            if info ~= 0 then
                                result[4] = {
                                    text = "  " .. info,
                                    guifg = "#7EA9A7"
                                }
                            end
                            return result
                        end
                    }
                }
            }
        end
    }

    -- use {
    --  'hoob3rt/lualine.nvim',
    --  requires = {'kyazdani42/nvim-web-devicons'},
    --  config = function()
    --  local lualine = require('lualine')
    --  lualine.theme = 'gruvbox'
    --  lualine.separator = '|'
    --  lualine.sections = {
    --    lualine_a = { 'mode' },
    --    lualine_b = { 'branch' },
    --    lualine_c = { 'filename' },
    --    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    --    lualine_y = { 'progress' },
    --    lualine_z = { 'location'  },
    --  }
    --  lualine.inactive_sections = {
    --    lualine_a = {  },
    --    lualine_b = {  },
    --    lualine_c = { 'filename' },
    --    lualine_x = { 'location' },
    --    lualine_y = {  },
    --    lualine_z = {   }
    --  }
    --  lualine.extensions = { 'fzf' }
    --  lualine.status()
    --  end
    -- }
end)

-------------------- OPTIONS -------------------------------
local indent = 2
o.autoread = true -- automatically realod file
o.expandtab = true -- Use spaces instead of tabs
o.shiftwidth = indent -- Size of an indent
o.wildmenu = true -- enable command line completition
o.smartindent = true -- Insert indents automatically
o.tabstop = indent -- Number of spaces tabs count for
o.hidden = true -- Enable modified buffers in background
g.mapleader = ","
o.clipboard = "unnamed,unnamedplus"

o.hlsearch = true -- Highlight all search matches
o.ignorecase = true -- Ignore case
o.smartcase = true -- case sensitive searching when patter cotains upper case letter
o.incsearch = true -- dynamic search

g.inccomand = "nosplit" -- ???

o.mouse = "a" -- enable mouse

o.updatetime = 100 -- used by CurserHold event, makes some plugin faster

o.autoindent = true

o.title = true -- show show fielname in window title

o.joinspaces = false -- No double spaces with join after a dot
o.scrolloff = 4 -- Lines of context
o.shiftround = true -- Round indent
o.sidescrolloff = 8 -- Columns of context
o.smartcase = true -- Don't ignore case with capitals
o.splitbelow = true -- Put new windows below current
o.splitright = true -- Put new windows right of current
o.termguicolors = true -- True color support
o.wildmode = "longest:full,full" -- Command-line completion mode
o.list = true -- Show some invisible characters (tabs etc.)
o.number = true -- Print line number
o.relativenumber = true -- Relative line numbers
o.signcolumn = "yes"
o.wrap = false -- Disable line wrap

------------------ MAPPINGS ------------------------------
map("i", "<C-u>", "<C-g>u<C-u>") -- Make <C-u> undoable
map("i", "<C-w>", "<C-g>u<C-w>") -- Make <C-w> undoable

map("n", "<C-l>", "<cmd>noh<CR>") -- Clear highlights

map("n", "<leader>", ":w<Cr>")

map("n", "<leader>gs", ":Git status<cr>")
map("n", "<leader>ge", ":Git edit<cr>")
map("n", "<leader>gr", ":Git read<cr>")
map("n", "<leader>gb", ":Git blame<cr>")

