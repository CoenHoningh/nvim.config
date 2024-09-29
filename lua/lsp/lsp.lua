return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
          vim.defer_fn(function()
            vim.lsp.inlay_hint.enable(true)
          end, 5000)
        end
      end,
    })
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
    local lspconfig = require 'lspconfig'
    local servers = {
      clangd = { manual_install = true },
      gopls = true,
      basedpyright = true,
      -- rust_analyzer = {
      --   settings = {
      --     ['rust-analyzer'] = {
      --       cargo = {
      --         allFeatures = true,
      --       },
      --       imports = {
      --         group = {
      --           enable = false,
      --         },
      --       },
      --       completion = {
      --         postfix = {
      --           enable = true,
      --         },
      --       },
      --     },
      --   },
      -- },
      zls = true,
      ruff = {
        settings = {
          configuration = '~/AppData/Local/ruff/ruff.toml',
        },
      },
      hls = {
        manual_install = true,
        cmd = { 'C:/ghcup/bin/haskell-language-server-wrapper.exe', '--lsp' },
      },
      ts_ls = {
        { 'typescript-language-server.cmd', '--stdio' },
      },
      svelte = true,
      marksman = true,
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
              displayContext = 4,
            },
            diagnostics = { disable = { 'missing-fields' } },
            hint = {
              enable = true,
              setType = true,
            },
          },
        },
      },
      powershell_es = {
        manual_install = true,
        bundle_path = '~/Documents/spul/PowerShellEditorServices/module',
      },
      taplo = true,
      ocamllsp = {
        manual_install = true,
        cmd = { 'dune', 'exec', 'ocamllsp' },
      },
    }

    local servers_to_install = vim.tbl_filter(function(key)
      local t = servers[key]
      if type(t) == 'table' then
        return not t.manual_install
      else
        return t
      end
    end, vim.tbl_keys(servers))

    require('mason').setup()
    local ensure_installed = {
      'stylua',
    }
    vim.list_extend(ensure_installed, servers_to_install)
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    for name, config in pairs(servers) do
      if config == true then
        config = {}
      end
      config = vim.tbl_deep_extend('force', {}, {
        capabilities = capabilities,
      }, config)
      lspconfig[name].setup(config)
    end

    --require('mason-lspconfig').setup {
    --  handlers = {
    --    function(server_name)
    --      local server = servers[server_name] or {}
    --      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    --      require('lspconfig')[server_name].setup(server)
    --    end,
    --  },
    --}
  end,
}
