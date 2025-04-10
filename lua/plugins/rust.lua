return {
  -- Add Rust LSP
  {
    "neovim/nvim-lspconfig",
    ft = "rust",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "simrat39/rust-tools.nvim",  -- Optional: enhanced Rust LSP features
    },
  },
  -- Ensure Rust tools are installed through Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "rust-analyzer",     -- Rust language server
        "codelldb",          -- Debugging support
        "rustfmt",           -- Rust formatter
      })
    end,
  },
}
