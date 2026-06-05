-- 基本キーマップ設定

-- モード切替
vim.keymap.set("n", ";", ":", { desc = "Enter command mode" })
vim.keymap.set("i", "<C-j>", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("v", "<C-j>", "<Esc>", { desc = "Exit visual mode" })
vim.keymap.set("t", "<A-Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ウィンドウ操作
vim.keymap.set("n", "<CR>", "<C-w>w", { desc = "Next window" })

-- バッファ操作
vim.keymap.set("n", "<C-j>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>e", "<Cmd>bdelete<CR>", { desc = "Close buffer" })

-- 検索
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- リロード
vim.keymap.set("n", "<leader>s", "<cmd>source %<CR>", { desc = "Source current file" })

-- 相対パス確認
vim.keymap.set("n", "<leader>fp", function() print(vim.fn.expand("%")) end, { desc = "Print relative path" })

-- キーマップヘルプ
vim.keymap.set("n", "<leader>?", function()
	require("snacks").picker.keymaps()
end, { desc = "Show keymaps" })

-- try-catch wrap (TypeScript/JavaScript)
vim.keymap.set("n", "<Leader>try", [[:normal! Vito try {\r} catch (err) {\r    console.error(err);\r}<Esc>]], { desc = "Wrap in try-catch" })

-- サブモジュール読み込み
require("keymaps.lsp")
require("keymaps.picker")
require("keymaps.git")
require("keymaps.file-explorer")
require("keymaps.terminal")
