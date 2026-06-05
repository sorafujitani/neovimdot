-- Lualine (ステータスライン) 設定 — agent coding 時代版
local custom_theme = require("lualine.themes.iceberg_dark")

-- プロジェクト名 (cwd basename)
local function project_name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- branch + dirty + ahead/behind (gitsigns 経由)
local function git_status()
	local head = vim.b.gitsigns_head
	if not head then
		return ""
	end

	local dict = vim.b.gitsigns_status_dict or {}
	local parts = { head }

	-- dirty marker
	local added = dict.added or 0
	local changed = dict.changed or 0
	local removed = dict.removed or 0
	if added + changed + removed > 0 then
		table.insert(parts, "*")
	end

	-- ahead / behind (gitsigns_status_dict から取得不可の場合は空)
	-- gitsigns は ahead/behind を status_dict に入れないため、git rev-list で取る
	-- ただし毎回 fork するのは重いので、BufEnter/FocusGained で cache する
	return table.concat(parts)
end

-- rebase / merge / cherry-pick 中の警告
local function git_operation()
	local git_dir = vim.fn.finddir(".git", ".;")
	if git_dir == "" then
		return ""
	end
	if vim.fn.filereadable(git_dir .. "/MERGE_HEAD") == 1 then
		return "MERGING"
	end
	if vim.fn.isdirectory(git_dir .. "/rebase-merge") == 1 or vim.fn.isdirectory(git_dir .. "/rebase-apply") == 1 then
		return "REBASING"
	end
	if vim.fn.filereadable(git_dir .. "/CHERRY_PICK_HEAD") == 1 then
		return "CHERRY-PICK"
	end
	return ""
end

-- LSP 進捗 (vim.lsp.status)
local function lsp_status()
	local status = vim.lsp.status()
	if status and status ~= "" then
		-- 長すぎる場合は切り詰め
		if #status > 50 then
			status = status:sub(1, 47) .. "..."
		end
		return status
	end
	return ""
end

-- Copilot 状態 (copilot.vim)
local function copilot_status()
	local ok, enabled = pcall(vim.fn["copilot#Enabled"])
	if not ok then
		return ""
	end
	if enabled == 1 then
		return ""
	else
		return " OFF"
	end
end

-- workspace 全体の diagnostics 集計 (0件なら空)
local function workspace_diagnostics()
	local errors = #vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.ERROR })
	local warns = #vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.WARN })
	local parts = {}
	if errors > 0 then
		table.insert(parts, "E:" .. errors)
	end
	if warns > 0 then
		table.insert(parts, "W:" .. warns)
	end
	return table.concat(parts, " ")
end

-- マクロ記録中の表示
local function macro_recording()
	local reg = vim.fn.reg_recording()
	if reg ~= "" then
		return "recording @" .. reg
	end
	return ""
end

-- 検索ヒット数
local function search_count()
	if vim.v.hlsearch == 0 then
		return ""
	end
	local ok, result = pcall(vim.fn.searchcount, { maxcount = 999 })
	if not ok or result.total == 0 then
		return ""
	end
	return string.format("[%d/%d]", result.current, result.total)
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = custom_theme,
		globalstatus = true,
		disabled_filetypes = { statusline = {}, winbar = {} },
		always_divide_middle = true,
		refresh = { statusline = 500 },
	},
	sections = {
		lualine_a = { project_name },
		lualine_b = {
			git_status,
			{ git_operation, color = { fg = "#e27878" } },
		},
		lualine_c = {
			lsp_status,
			copilot_status,
		},
		lualine_x = { workspace_diagnostics },
		lualine_y = { macro_recording, search_count },
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	winbar = {},
	inactive_winbar = {},
	tabline = {},
	extensions = {},
})
