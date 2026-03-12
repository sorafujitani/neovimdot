---@type vim.lsp.Config
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
      cargo = {
        allFeatures = true,
      },
      completion = {
        callable = {
          snippets = 'none',
        },
      },
    },
  },
}
