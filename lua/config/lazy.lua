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

  -- treesitter（ファイルを開いてから読み込み — 起動時コストを避ける）
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "javascript", "typescript", "tsx", "rust", "go", "ruby",
          "html", "css", "json", "yaml", "toml", "markdown", "markdown_inline", "bash", "vim", "vimdoc", "python", "nix",
        },
        auto_install = true,
      })
    end,
  },

  -- render-markdown (マークダウン時のみ)
  -- カーソル行でも描画を維持するため anti_conceal を無効化
  -- コードブロックの白帯を抑制するため width/border 調整
  -- (ハイライト色は ui/highlights.lua で orbital に合わせて設定)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      anti_conceal = { enabled = false },
      code = {
        -- "normal" でコードブロック bg のみ描画 (ラベル装飾なし)。
        -- 幅を block に絞り、サイン列のアイコンと上下罫線は省く。
        style = "normal",
        sign = false,
        width = "block",
        border = "none",
        left_pad = 1,
        right_pad = 1,
      },
      heading = {
        width = "block",
        left_pad = 0,
        right_pad = 1,
        border = false,
      },
    },
  },

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

  -- lualine（UI 準備後に読み込み）
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("plugins.statusline")
    end,
  },

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
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({})
    end,
  },
  {
    "dinhhuy258/git.nvim",
    cmd = { "Git", "GitBlame" },
    config = function()
      local ok, git = pcall(require, "git")
      if ok then
        git.setup({
          keymaps = {
            blame = "<Leader>gb",
            browse = "<Leader>go",
          },
        })
      end
    end,
  },
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
    config = function()
      require("plugins.oil")
    end,
  },
  {
    "A7Lavinraj/fyler.nvim",
    cmd = "Fyler",
    config = function()
      require("fyler").setup({})
    end,
  },

  -- formatter (保存時に読み込み + 設定はこのタイミングで適用)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("plugins.formatter")
    end,
  },

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
