-- Blink.cmp (補完) 設定
local blink = require("blink.cmp")

blink.setup({
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer", "go_walrus" },
		providers = {
			lsp = {
				name = "LSP",
				enabled = true,
				module = "blink.cmp.sources.lsp",
				fallbacks = {},
			},
			snippets = {
				name = "Snippets",
				module = "blink.cmp.sources.snippets",
				opts = {
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
					global_snippets = {},
				},
			},
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				fallbacks = { "lsp" },
			},
			go_walrus = {
				name = "Walrus",
				module = "lsp.sources.go_walrus",
				score_offset = 100,
			},
		},
	},

	keymap = {
		preset = "none",
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "cancel", "fallback" },
		["<Esc>"] = {
			function(cmp)
				if cmp.is_visible() then
					cmp.cancel()
				end
				vim.cmd("stopinsert")
			end,
		},
		["<CR>"] = {
			"accept",
			function()
				local col = vim.fn.col(".")
				local line = vim.api.nvim_get_current_line()
				local prev_char = line:sub(col - 1, col - 1)
				local next_char = line:sub(col, col)
				local pair_of = { ["{"] = "}", ["["] = "]", ["("] = ")" }
				if pair_of[prev_char] == next_char then
					local keys = vim.api.nvim_replace_termcodes("<CR><Esc>O", true, false, true)
					vim.api.nvim_feedkeys(keys, "n", false)
					return true
				end
				return false
			end,
			"fallback",
		},
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},

	completion = {
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		accept = {
			auto_brackets = {
				enabled = true,
			},
		},
		ghost_text = {
			enabled = false,
		},
		menu = {
			border = "single",
			winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
			draw = {
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = "single",
				winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder",
			},
		},
	},

	signature = {
		enabled = false,
	},
})

return {
	capabilities = blink.get_lsp_capabilities(),
}
