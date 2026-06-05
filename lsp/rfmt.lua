---@type vim.lsp.Config
return {
	cmd = { 'rfmt-lsp' },
	filetypes = { 'ruby' },
	root_markers = { '.rfmt.yml', 'Gemfile', '.git' },
}
