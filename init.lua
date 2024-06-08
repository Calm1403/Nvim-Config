---@diagnostic disable: undefined-global
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")

vim.keymap.set("n", "<C-Up>", "ddkP", { ... })
vim.keymap.set("n", "<C-Down>", "ddp", { ... })
vim.opt.fillchars = { eob = " " }
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    "shaunsingh/nord.nvim"
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    }
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim"
    }
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = {
      ":TSUpdate"
    }
  },
  {
    "williamboman/mason.nvim",
    {
      "williamboman/mason-lspconfig.nvim",
      lazy = false,
      opts = {
        auto_install = true
      }
    },
    "neovim/nvim-lspconfig"
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    {
      "L3MON4D3/LuaSnip",
      dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets"
      }
    },
    "hrsh7th/nvim-cmp"
  },
  {
    "goolord/alpha-nvim"
  }
}

local opts = { ... }

require("lazy").setup(plugins, opts)
vim.keymap.set("n", "<leader>L", ":Lazy<CR>", { ... })

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
  [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
  [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
  [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
  [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
  [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}

dashboard.section.buttons.val = {
  dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
  dashboard.button("ff", "󰈞  Find file", ""),
  dashboard.button("fg", "󰈬  Find word", ""),
  dashboard.button("fh", "󰊄  Recently opened files", ""),
  dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>")
}

require("alpha").setup(dashboard.config)

vim.cmd("colorscheme nord")
require("lualine").setup({
  options = {
    theme = "nord"
  }
})

vim.keymap.set("n", "<leader>tt", ":ToggleTerm direction=float<CR>", { ... })

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { ... })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { ... })
vim.keymap.set("n", "<leader>fh", builtin.oldfiles, { ... })
vim.keymap.set("n", "<leader>gs", builtin.git_status, { ... })

local telescope = require("telescope")
telescope.setup({
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown()
    }
  }
})

telescope.load_extension("ui-select")

local configs = require("nvim-treesitter.configs")
configs.setup({
  ensure_installed = { "lua", "cpp", "vimdoc", "python", "markdown", "make" },
  highlight = { enable = true },
  indent = { enable = true }
})

vim.cmd("hi CursorLine guibg=NONE guifg=NONE") -- This is here because treesitter was having a massive giggle with the bloody highlight groups.

local border = "rounded"

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_uninstalled = "✗",
      package_pending = "➜"
    },
    border = border
  }
})
vim.keymap.set("n", "<leader>M", ":Mason<CR>", { ... })

require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pylsp" }
})

local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true })
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" }
  })
})


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = border }
)

vim.diagnostic.config {
  float = { border = border }
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")

require("lspconfig.ui.windows").default_options.border = border
vim.cmd("hi LspInfoBorder guifg=lightgrey")

vim.keymap.set("n", "<leader>li", ":LspInfo<CR>")
vim.keymap.set("n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", { ... })
vim.keymap.set("n", "<leader>D", vim.lsp.buf.definition, { ... })
vim.keymap.set("n", "<leader>C", vim.lsp.buf.hover, { ... })
vim.keymap.set("n", "<leader>A", vim.lsp.buf.code_action, { ... })
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { ... })

lspconfig.lua_ls.setup({
  capabilities = capabilities
})

lspconfig.pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "E501" } -- Fuck off.
        }
      }
    }
  },
  capabilities = capabilities
})
