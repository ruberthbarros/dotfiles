return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',   -- parses the markdown (configured in treesitter.lua)
      'nvim-tree/nvim-web-devicons',       -- code-block language icons (uses your Nerd Font)
    },
    ft = { 'markdown' },                   -- load only when opening a markdown file
    opts = {},                             -- defaults render headers, tables, checkboxes, code blocks
  },
}
