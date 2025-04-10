return {
  -- Add SML LSP
  {
    "neovim/nvim-lspconfig",
    ft = "sml",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('lspconfig').smlls.setup{}
    end,
  },
  -- Ensure SML tools are installed through Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "smlls",  -- SML language server
      })
    end,
  },
  -- Add SML filetype detection (optional)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "sml" })
    end,
  },
}
