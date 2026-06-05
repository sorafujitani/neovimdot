---@type vim.lsp.Config
return {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'default.nix', 'shell.nix', '.git' },
  settings = {
    ['nil'] = {
      nix = {
        flake = {
          autoArchive = true,
          autoEvalInputs = false,
        },
      },
    },
  },
}
