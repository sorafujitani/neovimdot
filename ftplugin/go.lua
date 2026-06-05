-- Go ファイル専用設定

-- インデント／タブ（go は tab が標準）
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 0

-- 保存時に conform で gofumpt + goimports（lua/plugins/formatter.lua 設定済み）
vim.api.nvim_create_autocmd("BufWritePre", {
	buffer = 0,
	callback = function()
		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format({ bufnr = 0, async = false, lsp_format = "fallback", timeout_ms = 2000 })
		end
	end,
})

-- `:` を打ったら blink.cmp の補完を起動する。
-- カスタムソース (lsp/sources/go_walrus) が `:=` を候補として返す。
-- 自動 trigger に頼らず、明示的に show() を呼ぶことで確実に発火させる。
vim.keymap.set("i", ":", function()
	vim.schedule(function()
		pcall(function()
			require("blink.cmp").show()
		end)
	end)
	return ":"
end, { buffer = true, expr = true, desc = "Show completion after `:`" })
