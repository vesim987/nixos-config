-------------------- HELPERS -------------------------------
cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
fn = vim.fn -- to call Vim functions e.g. fn.bufnr()

g_meta = {}
function g_meta:__newindex(index, value)
    vim.g[index] = value
end

function g_meta:__index(index)
    return vim.g[index]
end
g = setmetatable({}, g_meta)
o = vim.o

function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
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

require("packer").startup(
    function()
        use {"wbthomason/packer.nvim", opt = true}
        use {
            "neovim/nvim-lspconfig",
            ft = {"zig", "c", "cpp", "python", "nix"},
            requires = {
                {
                    "hrsh7th/nvim-compe", -- TODO: migrate to nvim-cmp
                    config = function()
                        require "compe".setup {
                            enabled = true,
                            autocomplete = true,
                            debug = false,
                            min_length = 1,
                            preselect = "enable",
                            throttle_time = 80,
                            source_timeout = 200,
                            incomplete_delay = 400,
                            max_abbr_width = 100,
                            max_kind_width = 100,
                            max_menu_width = 100,
                            documentation = true,
                            source = {
                                path = true,
                                buffer = true,
                                calc = true,
                                nvim_lsp = true,
                                nvim_lua = true,
                                vsnip = true
                            }
                        }
                        vim.o.completeopt = "menuone,noselect"
                        map("i", "<C-Space>", "compe#complete()", {expr = true})
                        map("i", "<CR>", "compe#confirm('<CR>')", {expr = true})
                    end
                },
                {
                    "glepnir/lspsaga.nvim",
                    config = function()
                        require "lspsaga".init_lsp_saga()
                        -------------------- LSP -----------------------------------
                        map("n", "<silent><leader>N", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>")
                        map("n", "<silent><leader>n", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>")

                        map("n", "<silent><leader>ca", ":Lspsaga code_action<CR>")
                        map("v", "<silent><leader>ca", ":<C-U>Lspsaga range_code_action<CR>")

                        map("n", "<silent><leader>", ":Lspsaga code_action<CR>")

                        map("n", "K", ":Lspsaga code_action<CR>")

                        -- map("n", "<silent><leader>d", "<cmd>lua vim.lsp.buf.definition()<CR>")
                        -- map("n", "<silent><leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>")
                        -- map("n", "<silent><leader>h", "<cmd>lua vim.lsp.buf.hover()<CR>")
                        -- map("n", "<silent><leader>m", ":Lspsaga rename<CR>")
                        -- map("n", "<silent><leader>r", "<cmd>lua vim.lsp.buf.references()<CR>")
                        -- map("n", "<silent><leader>s", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
                    end
                },
                {
                    "nvim-telescope/telescope.nvim",
                    requires = {
                      {"nvim-lua/popup.nvim"}, 
                      {"nvim-lua/plenary.nvim"},
                      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
                    },
                    config = function()
                        require('telescope').setup {
                          extensions = {
                            fzf = {
                              fuzzy = true,                    -- false will only do exact matching
                              override_generic_sorter = true,  -- override the generic sorter
                              override_file_sorter = true,     -- override the file sorter
                              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                                              -- the default case_mode is "smart_case"
                            }
                          }
                        }

                        require('telescope').load_extension('fzf')
                        map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
                        map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
                        map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
                    end
                }
            },
            config = function()
                local lsp = require("lspconfig")

                function on_attach()
                    require "lsp_signature".on_attach()
                    --require'completion'.on_attach()
                end

                lsp.pyright.setup {on_attach = on_attach}
                lsp.zls.setup {on_attach = on_attach}
                lsp.sumneko_lua.setup {on_attach = on_attach} --, cmd = "lua-language-server"}
                lsp.ccls.setup {on_attach = on_attach}
                lsp.rnix.setup {on_attach = on_attach}
            end
        }
        use {
            "ray-x/lsp_signature.nvim"
        }

        use {
            "nvim-treesitter/nvim-treesitter",
            -- ft = {"c", "cpp", "python", "zig", "lua", "nix"},
            config = function()
                require "nvim-treesitter.configs".setup {
                    ensure_installed = {"c", "cpp", "python", "zig", "lua", "nix"},
                    highlight = {
                        enable = true,
                        use_lanugagetree = true
                    }
                }
            end
        }

        use {
            "nvim-treesitter/playground",
            requires = { {'nvim-treesitter', 
            config = function()
                require "nvim-treesitter.configs".setup {
                    ensure_installed = {"c", "cpp", "python", "zig", "lua", "nix"},
                    highlight = {
                        enable = true,
                        use_lanugagetree = true
                    }
                }
            end
          }

          }
          }
        use {
            "marko-cerovac/material.nvim",
            config = function()
                require("material.functions").change_style("deep ocean")
                require("material").setup(
                    {
                        italics = {
                            comments = true
                        }
                    }
                )
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
            config = function()
                g.vista_default_executive = "nvim_lsp"
            end
        }

        use {
            "luochen1990/rainbow",
            config = function()
                g.rainbow_active = 1
            end
        }

        use {"terminalnode/sway-vim-syntax"}

        use {
            "ziglang/zig.vim",
            config = function()
                g.zig_fmt_autosave = 0
            end
        }

        use {
            "tpope/vim-dispatch",
            config = function()
                map("n", "<leader>z", ":Make<CR>")
            end
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
                                local error = vim.lsp.diagnostic.get_count(0, [[Error]])
                                local warning = vim.lsp.diagnostic.get_count(0, [[Warning]])
                                local info = vim.lsp.diagnostic.get_count(0, [[Information]])
                                local hint = vim.lsp.diagnostic.get_count(0, [[Hint]])

                                if error ~= 0 then
                                    result[1] = {text = "  " .. error, guifg = "#EC5241"}
                                end

                                if warning ~= 0 then
                                    result[2] = {text = "  " .. warning, guifg = "#EFB839"}
                                end

                                if hint ~= 0 then
                                    result[3] = {text = "  " .. hint, guifg = "#A3BA5E"}
                                end

                                if info ~= 0 then
                                    result[4] = {text = "  " .. info, guifg = "#7EA9A7"}
                                end
                                return result
                            end
                        }
                    }
                }
            end
        }

        --use {
        --  'hoob3rt/lualine.nvim',
        --  requires = {'kyazdani42/nvim-web-devicons'},
        --  config = function()
        --    local lualine = require('lualine')
        --    lualine.theme = 'gruvbox'
        --    lualine.separator = '|'
        --    lualine.sections = {
        --      lualine_a = { 'mode' },
        --      lualine_b = { 'branch' },
        --      lualine_c = { 'filename' },
        --      lualine_x = { 'encoding', 'fileformat', 'filetype' },
        --      lualine_y = { 'progress' },
        --      lualine_z = { 'location'  },
        --    }
        --    lualine.inactive_sections = {
        --      lualine_a = {  },
        --      lualine_b = {  },
        --      lualine_c = { 'filename' },
        --      lualine_x = { 'location' },
        --      lualine_y = {  },
        --      lualine_z = {   }
        --    }
        --    lualine.extensions = { 'fzf' }
        --    lualine.status()
        --  end
        --}
    end
)

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

map("n", "<C-p>", ":Files<Cr>")

map("n", "<leader>", ":w<Cr>")

map("n", "<leader>gs", ":Gstatus<cr>")
map("n", "<leader>ge", ":Gedit<cr>")
map("n", "<leader>gr", ":Gread<cr>")
map("n", "<leader>gb", ":Gblame<cr>")

-------------------- COMMANDS ------------------------------
cmd "au TextYankPost * lua vim.highlight.on_yank {on_visual = false}" -- disabled in visual mode

cmd [[
  highlight ExtraWhitespace ctermbg=red guibg=red"
  match ExtraWhitespace /\\s\\+$/"
  au BufWinEnter * match ExtraWhitespace /\\s\\+$/"
  au InsertEnter * match ExtraWhitespace /\\s\\+\\%#\\@<!$/"
  au InsertLeave * match ExtraWhitespace /\\s\\+$/"
  au BufWinLeave * call clearmatches()"
]]

cmd "inoremap <silent><expr> <C-Space> compe#complete()"
cmd "inoremap <silent><expr> <CR>      compe#confirm('<CR>')"
cmd "inoremap <silent><expr> <C-e>     compe#close('<C-e>')"
cmd "inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })"
cmd "inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })"
