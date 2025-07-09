local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.ai", enabled = false},
    -- import/override with your plugins
    { import = "plugins" },
    { "zbirenbaum/copilot.lua", enabled = false},
    { "blink.cmp", enabled=false},
    { "nvim-cmp", enabled=true},
    { "copilot-cmp", enabled=false},
    { "blink-cmp-copilot", enabled=false},
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = true, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "Neotree",
      },
    },
  },
})

-- Custom Function to Permanently Clear Messages
local function clear_messages()
  -- Clear the command-line area
  vim.api.nvim_echo({}, false, {}) -- Clears normal command-line messages

  -- Clear errors (if any are currently displayed)
  vim.api.nvim_set_vvar("errmsg", "") -- Clears the 'v:errmsg' variable
end

-- Keybinding to Clear Messages
vim.api.nvim_set_keymap("n", "<leader>cL", ":lua clear_messages()<CR>", { noremap = true, silent = true })

-- Command to Clear Messages
vim.api.nvim_create_user_command("ClearMessages", clear_messages, {})
