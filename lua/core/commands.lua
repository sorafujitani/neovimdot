-- カスタムコマンド定義

-- 置換コマンド
vim.api.nvim_create_user_command("Sed", function(opt)
	local args = opt.args
	local words = vim.split(args, " ")
	if #words >= 2 then
		local old = words[1]
		local new = words[2]
		vim.cmd(string.format("%%s/%s/%s/g", old, new))
	end
end, {
	nargs = "*",
	complete = "file",
})

-- パスコピーコマンド (path-yank.nvimへのエイリアス)
-- 短縮コマンド用のエイリアス (denops初期化後に有効)
vim.api.nvim_create_user_command("Cfp", function()
	require("copy-path").copy_full_path()
end, { range = true, desc = "Copy the full path of the current file to the clipboard" })

vim.api.nvim_create_user_command("Crp", function()
	require("copy-path").copy_relative_path()
end, { range = true, desc = "Copy the relative path of the current file to the clipboard" })

vim.api.nvim_create_user_command("Cfn", function()
	require("copy-path").copy_file_name()
end, { range = true, desc = "Copy the file name of the current file to the clipboard" })

-- LSP制御コマンド
vim.api.nvim_create_user_command("Nonts", function()
	for _, client in ipairs(vim.lsp.get_clients({ name = "ts_ls" })) do
		client:stop()
	end
end, { desc = "Stop TypeScript LSP server" })

vim.api.nvim_create_user_command("Nondeno", function()
	for _, client in ipairs(vim.lsp.get_clients({ name = "denols" })) do
		client:stop()
	end
end, { desc = "Stop Deno LSP server" })

-- Copilot制御コマンド
vim.api.nvim_create_user_command("Ghcd", function()
	vim.cmd("Copilot disable")
	vim.notify("Copilot disabled")
end, { desc = "Disable GitHub Copilot" })

vim.api.nvim_create_user_command("Ghcn", function()
	vim.cmd("Copilot enable")
	vim.notify("Copilot enabled")
end, { desc = "Enable GitHub Copilot" })

vim.api.nvim_create_user_command("CopilotToggle", function()
	local copilot_status = vim.fn["copilot#Enabled"]()
	if copilot_status == 1 then
		vim.cmd("Copilot disable")
		vim.notify("Copilot disabled")
	else
		vim.cmd("Copilot enable")
		vim.notify("Copilot enabled")
	end
end, { desc = "Toggle GitHub Copilot" })

-- フォーマットコマンド
vim.api.nvim_create_user_command("Fmt", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true, desc = "Format code" })

-- NotePush: git add, commit, push を一括実行
vim.api.nvim_create_user_command("NotePush", function()
	local Snacks = require("snacks")
	local buf_dir = vim.fn.expand("%:p:h")
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel")[1]

	if vim.v.shell_error ~= 0 or not git_root then
		vim.notify("Not a git repository", vim.log.levels.ERROR)
		return
	end

	Snacks.input({ prompt = "Type 'yes' to push: " }, function(value)
		if value == "yes" then
			-- auto-saveを一時的に無効化
			local auto_save_enabled = vim.g.auto_save
			vim.g.auto_save = 0
			
			local cmd = string.format(
				"cd %s && git add . && git commit -m 'note update' && git push",
				vim.fn.shellescape(git_root)
			)
			
			local output = {}
			vim.fn.jobstart(cmd, {
				on_stdout = function(_, data)
					if data then
						for _, line in ipairs(data) do
							if line ~= "" then
								table.insert(output, line)
							end
						end
					end
				end,
				on_stderr = function(_, data)
					if data then
						for _, line in ipairs(data) do
							if line ~= "" then
								table.insert(output, "ERROR: " .. line)
							end
						end
					end
				end,
				on_exit = function(_, code)
					-- auto-saveを元に戻す
					vim.defer_fn(function()
						vim.g.auto_save = auto_save_enabled
					end, 100)
					
					if code == 0 then
						vim.notify("Push complete: " .. git_root, vim.log.levels.INFO)
					else
						vim.notify("Push failed (code: " .. code .. ")", vim.log.levels.ERROR)
						-- エラー出力を表示
						if #output > 0 then
							vim.notify(table.concat(output, "\n"), vim.log.levels.ERROR)
						end
					end
				end,
			})
		else
			vim.notify("Cancelled", vim.log.levels.WARN)
		end
	end)
end, { desc = "git add, commit, push を一括実行" })
