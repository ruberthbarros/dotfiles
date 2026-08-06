return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- markdown/markdown_inline parsers ship with Neovim 0.12, which also enables
    -- treesitter highlighting by default, so nvim-treesitter is not needed here.
    dependencies = {
      'nvim-tree/nvim-web-devicons',       -- code-block language icons (uses your Nerd Font)
    },
    ft = { 'markdown' },                   -- load only when opening a markdown file
    opts = {},                             -- defaults render headers, tables, checkboxes, code blocks
  },
}
