return {
  -- typescript-tools.nvim for TypeScript LSP
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Plugin-specific settings
      settings = {
        -- Enable inlay hints for better code readability
        tsserver_inlay_hints = {
          enable = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        -- Enable JSX/TSX closing tag support for React
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
        -- Disable tsserver formatting to use Prettier instead
        tsserver_format_options = {
          allowIncompleteCompletions = false,
          allowRenameOfImportPath = true,
        },
      },
      -- LSP on_attach function for custom keymaps
      on_attach = function(client, bufnr)
        -- Disable tsserver formatting (use Prettier via null-ls or conform.nvim)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- Custom keymaps
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "gD", "<cmd>TypescriptGoToSourceDefinition<cr>", opts)
        vim.keymap.set("n", "gR", "<cmd>TypescriptFindAllFileReferences<cr>", opts)
        vim.keymap.set("n", "<leader>co", "<cmd>TypescriptOrganizeImports<cr>", opts)
        vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<cr>", opts)
      end,
    },
    config = function(_, opts)
      require("typescript-tools").setup(opts)
    end,
  },

  -- Ensure Mason installs necessary tools (optional, for managing tsserver)
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "typescript-language-server", -- Still needed for tsserver binary
        "prettier", -- Optional: for formatting
      },
    },
  },

  -- Optional: Add nvim-cmp for autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      })
      opts.mapping = {
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
      }
    end,
  },

  -- Optional: Add Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "typescript", "tsx", "javascript", "json" },
      highlight = { enable = true },
      incremental_selection = { enable = true },
      indent = { enable = true },
    },
  },
}
