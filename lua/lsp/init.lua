-- LSP設定 (Neovim 0.11+ 組み込み機能を使用)

-- Capabilities (blink.cmp連携 + 拡張)
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- folding range
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- code lens
capabilities.textDocument.codeLens = {
	dynamicRegistration = false,
}

-- グローバル設定
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- Linter LSP共通設定 (formatter無効化)
local linter_on_attach = function(client)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

vim.lsp.config("biome", { on_attach = linter_on_attach })

-- 有効化するサーバー一覧
-- Note: oxlintは削除 (biomeで十分)
-- Note: denolsはdeno.json存在時のみ起動 (root_markers設定済み)
vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"denols",
	"biome",
	"rust_analyzer",
	"ruby_lsp",
	"gopls",
	"ty",
})

-- LSP情報表示コマンド (詳細版)
vim.api.nvim_create_user_command("LspInfo", function()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		print("No LSP clients attached")
		return
	end
	print(string.format("=== %d LSP client(s) attached ===", #clients))
	for _, c in ipairs(clients) do
		local ft = table.concat(c.config.filetypes or {}, ", ")
		print(string.format("\n[%s] (id: %d)", c.name, c.id))
		print(string.format("  root: %s", c.root_dir or "N/A"))
		print(string.format("  filetypes: %s", ft ~= "" and ft or "N/A"))
	end
end, { desc = "Show attached LSP clients" })

-- LSP再起動コマンド (停止後にバッファ再読み込みでLSP再起動)
vim.api.nvim_create_user_command("LspRestart", function(opts)
	local name = opts.args ~= "" and opts.args or nil
	local clients = vim.lsp.get_clients({ name = name })
	local count = #clients

	if count == 0 then
		-- クライアントがない場合はバッファ再読み込みで起動を試みる
		vim.cmd("edit")
		vim.notify("Reloading buffer to start LSP")
		return
	end

	for _, client in ipairs(clients) do
		client:stop()
	end

	-- 停止後にバッファを再読み込みしてLSPを再起動
	vim.defer_fn(function()
		vim.cmd("edit")
		vim.notify(string.format("Restarted %d LSP client(s)", count))
	end, 100)
end, { nargs = "?", desc = "Restart LSP client(s)" })

-- LSP停止コマンド
vim.api.nvim_create_user_command("LspStop", function(opts)
	local name = opts.args ~= "" and opts.args or nil
	local clients = vim.lsp.get_clients({ name = name })
	for _, client in ipairs(clients) do
		client:stop()
	end
	vim.notify(string.format("Stopped %d client(s)", #clients))
end, { nargs = "?", desc = "Stop LSP client(s)" })

-- LSP起動コマンド (現在のバッファでLSPを起動)
vim.api.nvim_create_user_command("LspStart", function()
	vim.cmd("edit")
	vim.notify("Reloading buffer to start LSP")
end, { desc = "Start LSP for current buffer" })

-- Diagnostic設定
require("lsp.diagnostics")

-- Hover設定
require("lsp.hover")
