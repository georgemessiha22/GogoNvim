
-- {{{
return {
  "ibhagwan/fzf-lua",
  config = function(_)
     require("fzf-lua").setup({"telescope"})
     require("config").load_mapping("fzflua")
  end
}
-- }}}
