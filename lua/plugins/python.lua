return {
  -- Add Python LSP
  {
    "neovim/nvim-lspconfig",
    ft = "python",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
  -- Ensure Python tools are installed through Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",           -- Microsoft's Python LSP
        "black",             -- Python formatter
        "isort",             -- Import sorter
        "debugpy",           -- Python debugger
        "ruff-lsp",          -- Fast Python linter
      })
    end,
  },
}
