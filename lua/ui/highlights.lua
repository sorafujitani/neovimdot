local M = {}

-- グローバルハイライト設定
-- パレット: 白 (本文) + 水色/シアン (キーワード・関数・型) のミニマル配色
local palette = {
	fg = "#e6edf3", -- 本文 (off-white)
	muted = "#8b949e", -- 区切り・括弧
	comment = "#7d8590", -- コメント
	line_nr = "#6e7681",
	keyword = "#79c0ff", -- func / return / if / for / import など
	func = "#7ed8e8", -- 関数名 (cyan)
	type = "#a5d6ff", -- 型 (薄水色)
	string = "#a5d6ff", -- 文字列 (薄水色)
	number = "#79c0ff",
	accent = "#56d4dc", -- アクセント (シアン)
	magenta = "#d2a8ff", -- 特殊
}

local function setup_global_highlights()
	-- 基本UI
	vim.api.nvim_set_hl(0, "Normal", { fg = palette.fg, bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalNC", { fg = palette.fg, bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "LineNr", { fg = palette.line_nr, bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = palette.fg, bg = "NONE", bold = true })

	-- 検索
	vim.api.nvim_set_hl(0, "Search", { fg = "#000000", bg = palette.keyword })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = palette.type })

	-- ===== シンタックス (白 + 水色基調) =====
	-- キーワード系 → 水色
	vim.api.nvim_set_hl(0, "Keyword", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Statement", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Conditional", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Repeat", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Label", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Exception", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Include", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Define", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Macro", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "PreProc", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "StorageClass", { fg = palette.keyword })

	-- 関数 → シアン
	vim.api.nvim_set_hl(0, "Function", { fg = palette.func })

	-- 型 → 薄い水色
	vim.api.nvim_set_hl(0, "Type", { fg = palette.type })
	vim.api.nvim_set_hl(0, "Structure", { fg = palette.type })
	vim.api.nvim_set_hl(0, "Typedef", { fg = palette.type })

	-- 識別子・変数 → 白
	vim.api.nvim_set_hl(0, "Identifier", { fg = palette.fg })
	vim.api.nvim_set_hl(0, "Variable", { fg = palette.fg })

	-- リテラル
	vim.api.nvim_set_hl(0, "String", { fg = palette.string })
	vim.api.nvim_set_hl(0, "Character", { fg = palette.string })
	vim.api.nvim_set_hl(0, "Number", { fg = palette.number })
	vim.api.nvim_set_hl(0, "Float", { fg = palette.number })
	vim.api.nvim_set_hl(0, "Boolean", { fg = palette.number })
	vim.api.nvim_set_hl(0, "Constant", { fg = palette.number })

	-- コメント・区切り
	vim.api.nvim_set_hl(0, "Comment", { fg = palette.comment, italic = true })
	vim.api.nvim_set_hl(0, "Operator", { fg = palette.fg })
	vim.api.nvim_set_hl(0, "Delimiter", { fg = palette.muted })
	vim.api.nvim_set_hl(0, "Special", { fg = palette.accent })
	vim.api.nvim_set_hl(0, "SpecialChar", { fg = palette.accent })
	vim.api.nvim_set_hl(0, "Tag", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "Symbol", { fg = palette.fg })

	vim.api.nvim_set_hl(0, "Directory", { fg = palette.func })
	vim.api.nvim_set_hl(0, "Title", { fg = palette.fg, bold = true })

	-- ===== treesitter キャプチャを統一 (treesitter は @xxx を最優先) =====
	local ts_links = {
		-- キーワード
		["@keyword"] = "Keyword",
		["@keyword.function"] = "Keyword",
		["@keyword.return"] = "Keyword",
		["@keyword.operator"] = "Keyword",
		["@keyword.conditional"] = "Keyword",
		["@keyword.repeat"] = "Keyword",
		["@keyword.import"] = "Keyword",
		["@keyword.storage"] = "Keyword",
		["@keyword.modifier"] = "Keyword",
		["@keyword.coroutine"] = "Keyword",
		["@keyword.exception"] = "Keyword",
		["@keyword.directive"] = "Keyword",
		["@conditional"] = "Conditional",
		["@repeat"] = "Repeat",
		["@include"] = "Include",
		["@exception"] = "Exception",

		-- 関数
		["@function"] = "Function",
		["@function.call"] = "Function",
		["@function.method"] = "Function",
		["@function.method.call"] = "Function",
		["@function.builtin"] = "Function",
		["@function.macro"] = "Function",
		["@method"] = "Function",
		["@method.call"] = "Function",
		["@constructor"] = "Function",

		-- 型
		["@type"] = "Type",
		["@type.builtin"] = "Type",
		["@type.definition"] = "Type",
		["@type.qualifier"] = "Keyword",
		["@module"] = "Type",
		["@namespace"] = "Type",

		-- 変数・プロパティ
		["@variable"] = "Identifier",
		["@variable.member"] = "Identifier",
		["@variable.parameter"] = "Identifier",
		["@variable.builtin"] = "Identifier",
		["@property"] = "Identifier",
		["@field"] = "Identifier",
		["@parameter"] = "Identifier",
		["@attribute"] = "Identifier",

		-- リテラル
		["@string"] = "String",
		["@string.escape"] = "SpecialChar",
		["@string.special"] = "SpecialChar",
		["@number"] = "Number",
		["@boolean"] = "Boolean",
		["@float"] = "Float",
		["@constant"] = "Constant",
		["@constant.builtin"] = "Constant",
		["@constant.macro"] = "Constant",

		-- コメント・区切り
		["@comment"] = "Comment",
		["@operator"] = "Operator",
		["@punctuation"] = "Delimiter",
		["@punctuation.bracket"] = "Delimiter",
		["@punctuation.delimiter"] = "Delimiter",
		["@punctuation.special"] = "Special",

		-- タグ (HTML/JSX)
		["@tag"] = "Keyword",
		["@tag.attribute"] = "Identifier",
		["@tag.delimiter"] = "Delimiter",

		-- markdown コードブロック fallback (injection 失敗時に白で見えるように)
		["@markup.raw"] = "Normal",
		["@markup.raw.block"] = "Normal",
		["@markup.raw.markdown"] = "Normal",
		["@text.literal"] = "Normal",
		["@text.literal.block"] = "Normal",
	}
	for from, to in pairs(ts_links) do
		vim.api.nvim_set_hl(0, from, { link = to })
	end

	-- インラインコード (`code`) はアクセント色で
	vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { fg = palette.accent })
	vim.api.nvim_set_hl(0, "@text.literal.markdown_inline", { fg = palette.accent })

	-- Telescope
	vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#1f2937" })
end

-- LSP関連ハイライト
local function setup_lsp_highlights()
	-- Float
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#808080", bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#e0e0e0", bg = "NONE" })
	vim.api.nvim_set_hl(0, "LspHoverNormal", { fg = "#ffffff", bg = "NONE" })
	vim.api.nvim_set_hl(0, "LspHoverBorder", { fg = "#808080", bg = "NONE" })

	-- Diagnostic
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = "#ff5555" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = true, sp = "#ffff55" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = true, sp = "#55ffff" })
	vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = true, sp = "#55ff55" })
end

-- 補完メニュー (blink.cmp) ハイライト
local function setup_completion_highlights()
	-- メニュー
	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#808080", bg = "NONE" })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#2a2a2a" })

	-- ドキュメント
	vim.api.nvim_set_hl(0, "BlinkCmpDoc", { fg = "#ffffff", bg = "NONE" })
	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = "#808080", bg = "NONE" })

	-- Kind icons
	vim.api.nvim_set_hl(0, "BlinkCmpKind", { fg = "#00ffff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#00ffff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#00ffff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindConstructor", { fg = "#ffaa00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindField", { fg = "#00ff00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#ff00ff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = "#ffaa00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = "#ffaa00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindModule", { fg = "#ffaa00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindProperty", { fg = "#00ff00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindUnit", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindValue", { fg = "#ff00ff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindEnum", { fg = "#ffaa00" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#ff00ff" })
	vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#00ffff" })

	-- Pmenu (ポップアップメニュー)
	vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2a2a2a" })
	vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#808080" })
end

-- Picker (snacks.picker) ハイライト
local function setup_picker_highlights()
	vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "White" })
	vim.api.nvim_set_hl(0, "SnacksPickerFile", { fg = "White" })
	vim.api.nvim_set_hl(0, "SnacksPickerMatch", { fg = "Cyan", bold = true })
	vim.api.nvim_set_hl(0, "SnacksPickerSelection", { bg = "#3a3a3a", fg = "White" })
	vim.api.nvim_set_hl(0, "SnacksPickerSpecial", { fg = "White" })
	vim.api.nvim_set_hl(0, "SnacksPickerVirtText", { fg = "Cyan" })
end

-- Diffview ハイライト（見やすい色に変更）
local function setup_diffview_highlights()
	-- 追加行（緑系）
	vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1a3a1a", fg = "NONE" })
	vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { bg = "#1a3a1a", fg = "NONE" })
	vim.api.nvim_set_hl(0, "DiffviewDiffAddText", { bg = "#2a5a2a", fg = "NONE" })

	-- 削除行（赤系）
	vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3a1a1a", fg = "#555555" })
	vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { bg = "#3a1a1a", fg = "#555555" })

	-- 変更行（青系）
	vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1a2a3a", fg = "NONE" })
	vim.api.nvim_set_hl(0, "DiffText", { bg = "#2a4a6a", fg = "NONE" })
	vim.api.nvim_set_hl(0, "DiffviewDiffChange", { bg = "#1a2a3a", fg = "NONE" })
	vim.api.nvim_set_hl(0, "DiffviewDiffText", { bg = "#2a4a6a", fg = "NONE" })

	-- ファイルパネル
	vim.api.nvim_set_hl(0, "DiffviewFilePanelTitle", { fg = "#66ccff", bold = true })
	vim.api.nvim_set_hl(0, "DiffviewFilePanelFileName", { fg = "#ffffff" })
	vim.api.nvim_set_hl(0, "DiffviewFilePanelPath", { fg = "#888888" })
end

-- Flash ハイライト
local function setup_flash_highlights()
	vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#00FFFF", bg = "#003333", bold = true, italic = true })
	vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#88ccff", bg = "#333333" })
	vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#ffffff", bg = "#555555" })
end

-- render-markdown ハイライト (白 + 水色基調)
local function setup_render_markdown_highlights()
	-- ===== コードブロック =====
	-- 通常背景 (orbital の Normal=透明 = ターミナル背景) よりわずかに青寄りの
	-- ダークネイビーで識別性を確保しつつ目に優しい。
	local code_bg = "#0e1a2b"
	vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = code_bg })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = palette.accent, bg = code_bg })
	vim.api.nvim_set_hl(0, "RenderMarkdownLanguage", { fg = palette.func, bg = code_bg, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { fg = code_bg, bg = "NONE" })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeFallback", { bg = code_bg })
	vim.api.nvim_set_hl(0, "RenderMarkdownSign", { bg = "NONE" })

	-- ===== 見出し =====
	-- bg帯を段階的に明るくしてレベル識別性を確保、fg は全て高コントラスト + bold
	vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#ffffff", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = palette.type, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = palette.func, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = palette.keyword, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = palette.accent, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = palette.muted, bold = true })
	-- 帯背景: 暗い → やや明るい のステップで階層感を出す
	vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { fg = "#ffffff", bg = "#2b3d5c", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { fg = palette.type, bg = "#1f3550", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { fg = palette.func, bg = "#172b44", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { fg = palette.keyword, bg = "#13243a", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { fg = palette.accent, bg = "#101e30", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { fg = palette.muted, bg = "NONE", bold = true })

	-- 引用・リスト記号・区切り
	vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = palette.muted, italic = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = palette.keyword })
	vim.api.nvim_set_hl(0, "RenderMarkdownDash", { fg = palette.muted })

	-- チェックボックス
	vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = palette.func })
	vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = palette.muted })

	-- テーブル
	vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = palette.func, bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = palette.fg })

	-- リンク
	vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = palette.accent, underline = true })
end

-- 全ハイライトを適用
function M.setup()
	setup_global_highlights()
	setup_lsp_highlights()
	setup_completion_highlights()
	setup_picker_highlights()
	setup_diffview_highlights()
	setup_flash_highlights()
	setup_render_markdown_highlights()
end

-- 初回適用
M.setup()

-- ColorScheme変更時に再適用
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = M.setup,
})

return M
