local map = vim.keymap.set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- exit terminal mode in neovim
map("t", "<C-space>", "<C-\\><C-n><C-w>h",{silent = true})

-- Find and replace in current file with confirmation for each match
map('n', '<leader>fc', ':%s///gc<Left><Left><Left><Left>', { desc = "Find and replace with confirmation" })

-- Find and replace current word under cursor with confirmation
map('n', '<leader>fwc', ':%s/<C-r><C-w>//gc<Left><Left><Left>', { desc = "Find and replace current word with confirmation" })

map('n', '<leader>cM', ':ClearAllMacros<CR>', { desc = "Clear all macros" })

-- Auto-pair just for parentheses
map('i', '(', '()<Left>', { noremap = true })

-- Handle Enter key inside parentheses
map('i', '<CR>', function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local cursor_col = cursor_pos[2]
  -- Check if cursor is between parentheses
  if cursor_col > 0 and cursor_col < #line then
    local char_before = line:sub(cursor_col, cursor_col)
    local char_after = line:sub(cursor_col + 1, cursor_col + 1)
    if char_before == '(' and char_after == ')' then
      return '<CR><CR><Up><Tab>'
    end
  end
  -- Normal Enter key behavior
  return '<CR>'
end, { expr = true, noremap = true })

-- Smart indent if in visual mode and press space {
map('v', '<leader>{', '>gv<Esc>\'>o}<Esc>\'<O{<Esc>O', {
  noremap = true,
  silent = true,
  desc = "Add braces around selection and indent content"
})

-- Make Enter key place cursor between parentheses
map('i', '{', '{}<Left>', {
  noremap = true,
  desc = "Auto-pair parentheses"
})


map("n", "<C-a>", "ggVG", {desc = "Highlight everything within the file"})
