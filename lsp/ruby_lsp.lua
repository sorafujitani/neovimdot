---@type vim.lsp.Config
return {
  cmd = { 'ruby-lsp' },
  filetypes = { 'ruby', 'eruby' },
  root_markers = { 'Gemfile', '.ruby-version', '.git' },
  init_options = {
    formatter = 'rfmt',
  },
}
