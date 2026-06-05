-- Autocmd設定

-- 挿入モード時はカーソル行をハイライト、通常モード時はハイライトを解除
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.opt.cursorline = true
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.opt.cursorline = false
	end,
})

-- ===== 外部変更の自動反映 =====
-- 別セッション (agent/CLI/他エディタ) のファイル変更を再起動なしで取り込む
local reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

-- フォーカス取得時・バッファ移動時・アイドル時に checktime を実行
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
	group = reload_group,
	callback = function()
		-- コマンドラインや cmdwin 中は触らない (UI が壊れるため)
		if vim.fn.mode() == "c" or vim.fn.getcmdwintype() ~= "" then
			return
		end
		vim.cmd("silent! checktime")
	end,
})

-- 再読込されたタイミングで知らせる
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = reload_group,
	callback = function()
		vim.notify("外部の変更を検出 → バッファを再読み込みしました", vim.log.levels.INFO)
	end,
})

-- libuv fs_event によるリアルタイム監視 (フォーカス無関係)
-- 注: Oil バッファは Oil 起動シーケンスと干渉するため監視対象外。
--     Oil 上でのディレクトリ変更反映が必要なときは <C-l> で手動 refresh する。
require("core.file-watch")
