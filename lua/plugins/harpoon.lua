return
{
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local keys = {
      {
        "<leader>H",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
    }
    for i = 1, 5 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
  config = function(_, opts)
    local harpoon = require("harpoon")
    harpoon:setup(opts)
    
    -- Hook into whatever tabline plugin you're using
    -- This example uses a common approach that should work with most setups
    local get_harpoon_index = function(file_path)
      local list = harpoon:list()
      local items = list:display()
      
      for idx, item in ipairs(items) do
        if item.value == file_path then
          return idx
        end
      end
      return nil
    end
    
    -- Check if nvim-web-devicons is available
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")
    if has_devicons then
      -- Store the original get_icon function
      local original_get_icon = devicons.get_icon
      
      -- Override the get_icon function
      devicons.get_icon = function(name, ext, opts)
        -- First get the standard icon
        local icon, icon_hl = original_get_icon(name, ext, opts)
        
        -- If we have a valid file path, check if it's in Harpoon
        local file_path = vim.fn.expand('%:p')
        local harpoon_idx = get_harpoon_index(file_path)
        
        -- If this is a harpooned file and we're getting icon for current buffer
        if harpoon_idx and name == vim.fn.expand('%:t') then
          -- Return the harpoon index instead of the icon
          -- Use the same highlight group as the original icon
          return tostring(harpoon_idx), icon_hl
        end
        
        -- For non-harpooned files, return the original icon
        return icon, icon_hl
      end
    end
  end,
}
