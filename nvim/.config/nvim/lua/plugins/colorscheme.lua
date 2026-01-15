return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    "Lazyvim/Lazyvim",
    opts = {
      colorscheme = "catppuccin",
      -- colorscheme = function() end, -- This will prevent any colorscheme from loading
    },
  },
}
