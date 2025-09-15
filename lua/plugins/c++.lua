return {
  -- Add the clangd LSP configuration
  {
    "neovim/nvim-lspconfig",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = function()
      return {
        servers = {
          clangd = {
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
              "--cross-file-rename",
              "--log=verbose",
              "--ranking-model=decision_forest",
              "--enable-config",
              "--offset-encoding=utf-16",
              "--all-scopes-completion",
              "--completion-parse=auto",
              "--completion-style=bundled",
              "--header-insertion-decorators",
              "--import-insertions",
              "--pch-storage=memory",
              "--malloc-trim",
            },
            init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
              semanticHighlighting = true,
            },
            keys = {
              { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C++)" },
              { "<leader>th", "<cmd>ClangdTypeHierarchy<cr>", desc = "Type Hierarchy (C++)" },
              { "<leader>sh", "<cmd>ClangdSymbolInfo<cr>", desc = "Symbol Info (C++)" },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      
      -- Enhanced capabilities
      local capabilities = cmp_nvim_lsp.default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
      
      -- Setup clangd
      lspconfig.clangd.setup(vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Enable inlay hints if supported
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_dir = lspconfig.util.root_pattern(
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git'
        ),
        single_file_support = true,
      }, opts.servers.clangd or {}))
    end,
  },
  
  -- Ensure C++ tools are installed through Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "clangd",
        "clang-format",
        "codelldb", -- C++ debugger
      })
    end,
  },
  
  -- Enhanced completion for C++
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      
      -- C++ specific completion settings
      cmp.setup.filetype({ "c", "cpp", "objc", "objcpp", "cuda" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
        }, {
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Add icons and source info
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },
  
  -- Snacks integration for notifications and UI
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Configure snacks for LSP notifications
      opts.notifier = opts.notifier or {}
      opts.notifier.enabled = true
      
      -- LSP progress notifications
      opts.lsp = opts.lsp or {}
      opts.lsp.progress = {
        enabled = true,
        throttle = 1000 / 30, -- 30fps
      }
      
      return opts
    end,
    config = function(_, opts)
      local snacks = require("snacks")
      snacks.setup(opts)
      
      -- Integrate with LSP for better notifications
      vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            snacks.notifier.notify(
              string.format("[%s] %s", client.name, args.data.params.value.message or ""),
              "info",
              { title = "LSP Progress", timeout = 1000 }
            )
          end
        end,
      })
    end,
  },
  
  -- Optional: Enhanced diagnostics display
  {
    "folke/trouble.nvim",
    optional = true,
    keys = {
      { "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>tD", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>tl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/..." },
    },
  },
  
  -- Auto-configure C++ file settings
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "cmake",
        "make",
      })
    end,
  },
}
