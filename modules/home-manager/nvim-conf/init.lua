vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

function keymap(mode, keybind, command)
  vim.api.nvim_set_keymap(mode, keybind, command, { noremap = true, silent = true })
end

local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

vim.o.smartindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.opt.clipboard = 'unnamedplus'

vim.wo.relativenumber = true

keymap("n", "<leader>|", ":vsplit<cr>")
vim.keymap.set("n", "[e", diagnostic_goto(true, "ERROR"))
vim.keymap.set("n", "]e", diagnostic_goto(false, "ERROR"))

vim.keymap.set("n", "[w", diagnostic_goto(true, "WARN"))
vim.keymap.set("n", "]w", diagnostic_goto(false, "WARN"))

require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        [" "] = { "<cmd>Telescope find_files<cr>", "Find Files (Root Dir)" },
        ["|"] = { "<cmd>vsplit<cr>", "Split right" },
        ["-"] = { "<cmd>split<cr>", "Split down" },

        ["ca"] = { function() vim.lsp.buf.code_action() end, "Code action" },
        ["[e"] = { diagnostic_goto(true, "ERROR"), "Go to last error" },
        ["]e"] = { diagnostic_goto(false, "ERROR"), "Go to next error" },

        e = { "<cmd>Explore<cr>", "Explore containing folder" }
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults, { prefix = "<leader>" })
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    opt = {
      manual_mode = true
    }
  },
  { "folke/neoconf.nvim", cmd = "Neoconf" },

  {
    'echasnovski/mini.pairs',
    version = false,
    config = true,
    name = "mini.pairs"
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = true,
    name = 'mini.surround'
  },

  -- UI changes
  { -- Tabline stuff
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      presets = { inc_rename = true }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  { -- Theme
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "latte"
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Library items can be absolute paths
        -- "~/projects/my-awesome-lib",
        -- Or relative, which means they will be resolved as a plugin
        -- "LazyVim",
        -- When relative, you can also provide a path to the library in the plugin dir
        -- "luvit-meta/library", -- see below
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "folke/which-key.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },

    opts = {
      sources = {
        { name = "nvim_lsp" },
        { name = "lazydev", group_index = 0 }
      }
    },

    config = function(_, opts)
      local cmp = require("cmp")
      local wk = require("which-key")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-j>'] = cmp.mapping.scroll_docs(-4),
          ['<C-k>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = opts.sources
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = {
      servers = {
        jsonls = {},
        lua_ls = {},
        elixirls = {},
        elmls = {},
        nil_ls = {}, -- Nixos
        rust_analyzer = {},
        gleam = {},
        gopls = {},
        tsserver = {},
        clangd = {},
        cssls = {},
        html = {},
        typst_lsp = {},
        templ = {},
        ltex = {
          filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc", "quarto", "rmd", "context", "html", "xhtml", "mail", "text", "typst" }
        },
      }
    },
    ---@param opts PluginLspOpts
    config = function(_, opts)
      local servers = opts.servers

      for server, server_opts in pairs(servers) do
        if server_opts then
          require("lspconfig")[server].setup(server_opts)
        end
      end
    end
  },
  {
    "smjonas/inc-rename.nvim",
    config = true,
    keys = {
      { "<leader>cr", function() return ":IncRename" .. vim.fn.expand("<cword>") end, desc = "Rename symbol" },
    },
  },
  {
    "elentok/format-on-save.nvim",
    event = "VeryLazy",

    config = function(_, _)
      local format_on_save = require("format-on-save")
      local formatters = require("format-on-save.formatters")

      format_on_save.setup({
        formatter_by_ft = {
          templ = formatters.shell({ cmd = {"templ", "fmt"} })
        }
      })
    end
  },


  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true,
    event = "VeryLazy",
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
    },
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = "VeryLazy",
    keys = {
      { "<leader>sw", "<cmd>lua require(\"spectre\").open_visual({select_word=true})<CR>", desc = "Find and replace (word)" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "gleam" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  }

})
