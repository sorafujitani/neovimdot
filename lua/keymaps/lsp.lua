-- LSP関連キーマップ

-- split and goto definition
local function split_and_goto_definition(split_cmd)
	vim.cmd(split_cmd)
	vim.lsp.buf.definition()
end

vim.keymap.set("n", "<C-h>gd", function()
	split_and_goto_definition("leftabove vsplit")
end, { desc = "Definition in left split" })
vim.keymap.set("n", "<C-k>gd", function()
	split_and_goto_definition("aboveleft split")
end, { desc = "Definition in top split" })
vim.keymap.set("n", "<C-l>gd", function()
	split_and_goto_definition("rightbelow vsplit")
end, { desc = "Definition in right split" })

-- rename
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "LSP rename" })

-- diagnostic設定
vim.keymap.set("n", "<leader>n", function()
	vim.diagnostic.config({ virtual_text = false })
end, { desc = "Disable virtual text" })

-- LspAttach時のキーマップ
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf }

		-- hover/signature
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

		vim.keymap.set("n", "<C-k>", function()
			vim.lsp.buf.signature_help({ border = "rounded" })
		end, vim.tbl_extend("force", opts, { desc = "Signature help" }))

		-- diagnostic float
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float({ border = "rounded" })
		end, vim.tbl_extend("force", opts, { desc = "Diagnostic float" }))

		-- diagnostic navigation
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = { border = "rounded" } })
		end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))

		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = { border = "rounded" } })
		end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

		vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostic list" }))

		-- code action
		vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))

		-- implementation / type definition (picker未対応のためnative使用)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
	end,
})
