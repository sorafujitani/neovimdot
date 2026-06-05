-- blink.cmp custom source: Goファイルで `:` 入力時に `:=` をサジェスト
--
-- 動作:
--   `name:` まで打つと補完候補に `:=` (Operator) が現れる。
--   確定するとカーソル位置の `:` が ` := ` に置換され、`name := ` になる。
-- 抑制条件:
--   - 直前が word(identifier) でない
--   - 行頭が `case `（switch case のラベル）
--   - 既に行内に `:=` がある（重複防止）

local M = {}
M.__index = M

function M.new()
	return setmetatable({}, M)
end

function M:enabled()
	return vim.bo.filetype == "go"
end

function M:get_trigger_characters()
	return { ":" }
end

function M:get_completions(ctx, callback)
	local row = ctx.cursor[1]
	local col = ctx.cursor[2]
	local bufnr = ctx.bufnr or vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

	local function done(items)
		callback({
			items = items or {},
			is_incomplete_forward = false,
			is_incomplete_backward = false,
		})
	end

	-- カーソル位置から `:` の文字位置を特定（直後 or 直前）
	local at_char = line:sub(col, col)
	local just_before = line:sub(col - 1, col - 1)
	local colon_pos
	if at_char == ":" then
		colon_pos = col - 1
	elseif just_before == ":" then
		colon_pos = col - 2
	else
		done({})
		return function() end
	end

	-- 抑制条件チェック
	local before_colon = line:sub(1, colon_pos)
	if not before_colon:match("[%w_]$") then
		done({})
		return function() end
	end
	if before_colon:match("^%s*case%s") then
		done({})
		return function() end
	end
	if line:find(":=", 1, true) then
		done({})
		return function() end
	end

	done({
		{
			label = ":=",
			kind = vim.lsp.protocol.CompletionItemKind.Operator,
			detail = "short variable declaration",
			textEdit = {
				range = {
					start = { line = row - 1, character = colon_pos },
					["end"] = { line = row - 1, character = colon_pos + 1 },
				},
				newText = " := ",
			},
			sortText = "0",
			documentation = {
				kind = "markdown",
				value = "`name := value` — short variable declaration",
			},
		},
	})
	return function() end
end

return M
