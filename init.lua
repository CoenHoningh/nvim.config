require 'config.options'
require 'config.autocmds'
require 'lazy.lazy'

require('lazy').setup({
  require 'lsp.lsp',
  require 'config.theme',
  {
    import = 'plugins',
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  rocks = {
    enabled = true,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
