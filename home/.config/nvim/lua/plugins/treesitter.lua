return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',                        -- stable API; 'main' is the unfinished rewrite
    build = ':TSUpdate',                      -- compile parsers after install/update
    main = 'nvim-treesitter.configs',         -- the module lazy.nvim calls setup() on
    opts = {
      ensure_installed = { 'markdown', 'markdown_inline' },  -- parsers render-markdown needs
      highlight = { enable = true },
    },
  },
}
