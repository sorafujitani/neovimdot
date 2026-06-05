-- libuv fs_event によるバッファ単位のリアルタイム監視
-- 別セッション (agent / シェル / 他エディタ) からのファイル書き換えを
-- FocusGained を待たずに即座にバッファへ反映する
--
-- 対象: 通常のファイルバッファのみ (buftype == "")
--   * oil:// など特殊バッファは扱わない (Oil 内部の write 処理と衝突して
--     編集状態が壊れるため。Oil 上のリフレッシュは <C-l> で手動)
--
-- macOS では FSEvents、Linux では inotify が利用される

local M = {}

local watchers = {}

local function unwatch(bufnr)
	local w = watchers[bufnr]
	if w then
		pcall(function()
			w:stop()
			w:close()
		end)
		watchers[bufnr] = nil
	end
end

local function target_file(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end
	if vim.bo[bufnr].buftype ~= "" then
		return nil
	end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" or name:match("^%w+://") then
		return nil
	end
	if vim.fn.filereadable(name) == 0 then
		return nil
	end
	return name
end

local watch -- 前方宣言

watch = function(bufnr)
	if watchers[bufnr] then
		return
	end
	local path = target_file(bufnr)
	if not path then
		return
	end

	local w = vim.uv.new_fs_event()
	if not w then
		return
	end

	local ok = pcall(function()
		w:start(
			path,
			{},
			vim.schedule_wrap(function(err, _, events)
				if err or not vim.api.nvim_buf_is_valid(bufnr) then
					unwatch(bufnr)
					return
				end
				vim.cmd(("silent! checktime %d"):format(bufnr))
				-- atomic save (一部エディタの mv 上書き) では inode が変わり
				-- 監視対象が消失するため、rename 検知時は張り直す
				if events and events.rename then
					unwatch(bufnr)
					vim.defer_fn(function()
						watch(bufnr)
					end, 100)
				end
			end)
		)
	end)

	if not ok then
		pcall(function()
			w:close()
		end)
		return
	end
	watchers[bufnr] = w
end

local group = vim.api.nvim_create_augroup("FileWatchFS", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost", "BufFilePost" }, {
	group = group,
	callback = function(args)
		watch(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	group = group,
	callback = function(args)
		unwatch(args.buf)
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		for buf in pairs(watchers) do
			unwatch(buf)
		end
	end,
})

return M
