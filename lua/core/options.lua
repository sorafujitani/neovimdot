-- Neovim基本オプション設定

-- leader key (他の設定より先に設定)
vim.g.mapleader = " "

-- エンコーディング
vim.opt.fileencoding = "utf-8"

-- スワップファイルを使用しない
vim.opt.swapfile = false

-- ヘルプ言語を日本語に設定
vim.opt.helplang = "ja"

-- 非アクティブなバッファもバックグラウンドで開いておく
vim.opt.hidden = true

-- eob非表示
vim.opt.fillchars = { eob = " " }

-- マウス有効化
vim.o.mouse = "a"

-- クリップボードをunnamedplusに設定してシステムのクリップボードと連携
vim.opt.clipboard:append({ "unnamedplus" })

-- コマンドラインの補完機能を有効にする
vim.opt.wildmenu = true

-- statuslineをグローバルに固定
vim.opt.laststatus = 3

-- タイムアウト (キーマッピングの応答速度)
vim.opt.timeoutlen = 300

-- 検索
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.matchtime = 1

-- インデント
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- 行番号
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.showmatch = true

-- フォント
vim.opt.guifont = "Fira Code:h1:b"

-- サインカラムを常に表示
vim.opt.signcolumn = "yes"

-- アンビグ幅をsingleに設定
vim.opt.ambiwidth = "single"

-- 透過度
vim.opt.winblend = 0
vim.opt.pumblend = 0

vim.opt.pumborder = "rounded"

-- GUIカラーを使用
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- プラグイン設定
vim.g.yoinkAutoFormat = 1
vim.g.yoinkMaxItems = 10

-- colorscheme with safe loading
local colorscheme = "orbital"
local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	vim.cmd([[colorscheme default]])
end
