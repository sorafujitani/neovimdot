local vim = vim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- colorSchema (即時読み込み)
  { "fcpg/vim-orbital", lazy = false },

  -- treesitter (即時読み込み / main branch API)
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "javascript", "typescript", "tsx", "rust", "go", "ruby",
          "html", "css", "json", "yaml", "toml", "markdown", "bash", "vim", "vimdoc", "python",
        },
        auto_install = true,
      })
    end,
  },

  -- markview (マークダウン時のみ)
  { "OXY2DEV/markview.nvim", ft = { "markdown", "md" } },

  -- snippets
  "rafamadriz/friendly-snippets",

  -- snacks (即時読み込み)
  { "folke/snacks.nvim", lazy = false },

  -- mini
  { "echasnovski/mini.icons", lazy = false },
  { "nvim-mini/mini.test", cmd = "MiniTest" },

  -- lazydev (Lua開発支援)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- blink
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = { "rafamadriz/friendly-snippets", "folke/lazydev.nvim" },
    version = '1.*',
  },

  -- dap (デバッグ時のみ)
  {
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle",
  },
  { "mfussenegger/nvim-dap", cmd = { "DapToggleBreakpoint", "DapContinue" } },
  { "rcarriga/nvim-dap-ui", lazy = true },
  { "nvim-neotest/nvim-nio", lazy = true },
  {
    "mxsdev/nvim-dap-vscode-js",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap" },
  },
  { "leoluz/nvim-dap-go", ft = "go" },

  -- lualine (即時読み込み)
  { "nvim-lualine/lualine.nvim", lazy = false },

  -- autosave (バッファ読み込み時)
  {
    "Pocco81/auto-save.nvim",
    event = "BufReadPost",
    config = function()
      require("auto-save").setup({
        condition = function(buf)
          -- バッファが有効かチェック
          if not vim.api.nvim_buf_is_valid(buf) then
            return false
          end

          local fn = vim.fn
          -- 除外するファイルタイプ
          local excluded_filetypes = { "oil", "gitcommit", "gitrebase", "hgcommit", "snacks_input" }
          local ok, filetype = pcall(fn.getbufvar, buf, "&filetype")
          if not ok or vim.tbl_contains(excluded_filetypes, filetype) then
            return false
          end
          -- 除外するバッファタイプ
          local ok2, buftype = pcall(fn.getbufvar, buf, "&buftype")
          if not ok2 or buftype ~= "" then
            return false
          end
          -- 大きすぎるファイルは除外 (1MB以上)
          if fn.getfsize(fn.expand("%")) > 1000000 then
            return false
          end
          return true
        end,
      })
    end,
  },

  -- search/replace
  { "duane9/nvim-rg", cmd = "Rg" },

  -- git
  { "lewis6991/gitsigns.nvim", event = "BufReadPre" },
  { "dinhhuy258/git.nvim", cmd = { "Git", "GitBlame" } },
  { "kdheepak/lazygit.nvim", cmd = "LazyGit" },
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    cmd = "Neogit",
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true,
        },
      })
    end,
  },
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },
  { "FabijanZulj/blame.nvim", cmd = "BlameToggle" },

  -- flash (モーション強化)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- comment (mini.comment)
  {
    "echasnovski/mini.comment",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle" },
    },
    config = function()
      require("mini.comment").setup({})
    end,
  },


  -- atac (コマンド時のみ)
  {
    "NachoNievaG/atac.nvim",
    cmd = "Atac",
    config = function()
      require("atac").setup({
        dir = "~/my/work/directory",
      })
    end,
  },

  -- denops (必要時に読み込み)
  { "vim-denops/denops.vim", event = "VeryLazy" },


  -- rayso (コマンド時のみ)
  { "ryoppippi/ray-so.vim", cmd = "RaySo" },

  -- filer (キー入力時)
  { "lambdalisue/nerdfont.vim", event = "VeryLazy" },
  {
    "stevearc/oil.nvim",
    keys = { { "<S-e>", "<cmd>Oil<CR>", desc = "Open Oil file explorer" } },
    cmd = "Oil",
  },
  {
    "A7Lavinraj/fyler.nvim",
    cmd = "Fyler",
    config = function()
      require("fyler").setup({})
    end,
  },

  -- formatter (保存時に読み込み)
  { "stevearc/conform.nvim", event = "BufWritePre" },

  -- snippets (mini.snippets)
  {
    "echasnovski/mini.snippets",
    event = "InsertEnter",
    config = function()
      require("mini.snippets").setup({
        mappings = {
          expand = '',  -- タブキーを無効化
          jump_next = '<C-l>',
          jump_prev = '<C-h>',
        }
      })
    end,
  },

  -- neotest (コマンド時のみ)
  { "nvim-neotest/neotest", cmd = "Neotest" },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "antoinemadec/FixCursorHold.nvim", lazy = true },
  { "marilari88/neotest-vitest", lazy = true },
  { "MisanthropicBit/neotest-busted", lazy = true },

  -- autopairs (mini.pairs)
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup({})
    end,
  },

  -- surround (mini.surround)
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup({})
    end,
  },

  -- yank (テキスト操作時)
  { "svermeulen/vim-yoink", event = "TextYankPost" },


  -- copilot (入力時)
  { "github/copilot.vim", event = "InsertEnter" },

  -- path copy (denops依存)
  {
    "fs0414/path-yank.nvim",
    dependencies = { "vim-denops/denops.vim" },
    event = "VeryLazy",
    config = function()
      require("copy-path").setup({
        register = "*",
        notify = true,
        lineFormat = {
          single = "#L%d",
          range = "#L%d-L%d",
        },
      })
    end,
  },
}, {
  -- Lazy.nvim configuration options
  defaults = {
    lazy = true, -- デフォルトで遅延読み込み
  },
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
