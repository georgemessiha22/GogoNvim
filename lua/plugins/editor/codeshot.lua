-- [[
-- Plugin: SergioRibera/codeshot.nvim
-- Description: CodeShot allows you to take screenshots of your code in a very nice format and integrated in neovim.
-- ]]

return {
  "SergioRibera/codeshot.nvim",
  config = function()
    require("codeshot").setup({
      bin_path = "sss_code", -- This may be required in case you have not added the binary to the $PATH
      -- %c = is a sss_code command generated
      -- Example to copy on wayland: "%c | wl-copy"
      copy = "%c", -- Format of custom command to run and copy output raw
      silent = true, -- Run command as Silent
      window_controls = false, --
      shadow = true, -- Enable Shadow
      shadow_image = true, -- Generate shadow from code theme
      show_line_numbers = true, -- Enable line numbers
      use_current_theme = true, -- Allows you to generate a screenshot taking the current neovim theme you have
      -- theme = "catppuccin", -- Theme file to use. May be a path, or an embedded theme
      -- extra_syntaxes = "", -- Additional folder to search for .sublime-syntax files in
      -- tab_width = vim.opt.shiftwidth,
      -- fonts = vim.opt.guifont:replace(":h", "="):replace(":", "="), -- Lists of fonts to use
      -- background = "#323232", -- Background of image
      -- radius = 15, -- Rounded radius of code
      -- author = "George Messiha", -- Leave your mark, add your name to the picture
      -- author_color = "#89CFF0",
      -- window_title = "", -- The title that the code will have at the top next to the window controls
      -- window_title_background = "", -- The color for the window controls bar, if you leave it empty it will take the background of the theme
      -- window_title_color = "#FFFFFF",
      -- window_controls_width = 120, -- The maximum width for window controls
      -- window_controls_height = 40, -- The maximum Height for window controls
      -- titlebar_padding = 10, -- Text separation with window controls
      -- padding_x = 80, -- The x padding of the code with the image border
      -- padding_y = 100, -- The y padding of the code with the image border
      -- shadow_color = "#707070", -- Color for the shadow
      -- shadow_blur = 90, -- The level of blurring to be applied to the shadow
      save_format = "png", -- The format in which the image will be saved [default: png]
      output = "CodeShot_${year}-${month}-${date}_${time}.png", -- Auto generate file name based on time (absolute or relative to cwd)
    })
  end,
}
