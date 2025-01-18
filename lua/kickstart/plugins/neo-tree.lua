return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  opts = {
    close_if_last_window = true,
    -- A command is a function that we can assign to a mapping (below)
    commands = {
      system_open = function(state)
        require('base.utils').open_with_program(state.tree:get_node():get_id())
      end,
      parent_or_close = function(state)
        local node = state.tree:get_node()
        if (node.type == 'directory' or node:has_children()) and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
        end
      end,
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node.type == 'directory' or node:has_children() then
          if not node:is_expanded() then -- if unexpanded, expand
            state.commands.toggle_node(state)
          else -- if expanded and has children, seleect the next child
            require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
          end
        else -- if not a directory just open it
          state.commands.open(state)
        end
      end,
      copy_selector = function(state)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        local filename = node.name
        local modify = vim.fn.fnamemodify

        local results = {
          e = { val = modify(filename, ':e'), msg = 'Extension only' },
          f = { val = filename, msg = 'Filename' },
          F = {
            val = modify(filename, ':r'),
            msg = 'Filename w/o extension',
          },
          h = {
            val = modify(filepath, ':~'),
            msg = 'Path relative to Home',
          },
          p = {
            val = modify(filepath, ':.'),
            msg = 'Path relative to CWD',
          },
          P = { val = filepath, msg = 'Absolute path' },
        }

        local messages = {
          { '\nChoose to copy to clipboard:\n', 'Normal' },
        }
        for i, result in pairs(results) do
          if result.val and result.val ~= '' then
            vim.list_extend(messages, {
              { ('%s.'):format(i), 'Identifier' },
              { (' %s: '):format(result.msg) },
              { result.val, 'String' },
              { '\n' },
            })
          end
        end
        vim.api.nvim_echo(messages, false, {})
        local result = results[vim.fn.getcharstr()]
        if result and result.val and result.val ~= '' then
          vim.notify('Copied: ' .. result.val)
          vim.fn.setreg('+', result.val)
        end
      end,
      find_in_dir = function(state)
        local node = state.tree:get_node()
        local path = node:get_id()
        require('telescope.builtin').find_files {
          cwd = node.type == 'directory' and path or vim.fn.fnamemodify(path, ':h'),
        }
      end,
    },

    window = {
      width = 30,
      mappings = {
        ['<space>'] = false,
        ['<S-CR>'] = 'system_open',
        ['[b'] = 'prev_source',
        [']b'] = 'next_source',
        --        F = utils.is_available("telescope.nvim") and "find_in_dir" or nil,
        O = 'system_open',
        Y = 'copy_selector',
        h = 'parent_or_close',
        l = 'child_or_open',
      },
    },
  },
  keys = {
    { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Neotree' },
  },
}
