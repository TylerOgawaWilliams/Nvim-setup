return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip", -- Snippet engine
    "rafamadriz/friendly-snippets", -- Predefined snippets
    "hrsh7th/cmp-nvim-lsp", -- LSP completions
    "hrsh7th/cmp-buffer", -- Buffer completions
    "hrsh7th/cmp-path", -- Path completions
    "saadparwaiz1/cmp_luasnip", -- Snippet completions for LuaSnip
  },
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body) -- Use LuaSnip for snippet expansion
      end,
    }
    opts.sources = opts.sources or {}
    table.insert(opts.sources, { name = "nvim_lsp" })
    table.insert(opts.sources, { name = "buffer" })
    table.insert(opts.sources, { name = "path" })
    table.insert(opts.sources, { name = "luasnip" })
    opts.mapping = {
      -- Map <Tab> and <C-n> to select next item (down in the list)
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif require("luasnip").expand_or_jumpable() then
          require("luasnip").expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      -- Map <S-Tab> and <C-p> to select previous item (up in the list)
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item() -- Moves "up" to the previous item
        elseif require("luasnip").jumpable(-1) then
          require("luasnip").jump(-1) -- Jump backward in snippets
        else
          fallback() -- Insert Shift+Tab if no menu or snippet
        end
      end, { "i", "s" }),
      ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item() -- Moves "up" to the previous item
        else
          fallback()
        end
      end, { "i", "s" }),
      -- Map <CR> to confirm selection
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }
  end,
}
