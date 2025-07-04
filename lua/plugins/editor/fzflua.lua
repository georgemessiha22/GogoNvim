
-- {{{
return {
  "ibhagwan/fzf-lua",
  config = function(_)
     require("fzf-lua").setup({"telescope"})
     GogoVIM.load_mapping("fzflua")
  end
}
-- }}}
