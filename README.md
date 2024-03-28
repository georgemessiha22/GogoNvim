<!--toc:start-->
- [GoGo NeoVim](#gogo-neovim)
  - [Structure](#structure)
- [Lazy Plugins](#lazy-plugins)
<!--toc:end-->

# GoGo NeoVim
![image](https://user-images.githubusercontent.com/101672047/235722220-dbf567c4-4e8f-4bb1-8f9a-1d6a221cda33.png)

This repo is highly inspired by NvChad and LazyVIM, the only reason of creating my own repo, i didn't like the idea of learning curve; 
constrains/needs to setup things in their way, so i built this Repo that have everything directly connected and you can just edit it.
Installing new plugin is simple just use whatever mentioned in their github, and add the new plugin file to `plugins/init.lua` with required.

**NOTE** only plugins mentioned in `plugins/init.lua` will be included. This way i can play around with switching on and off some plugins.

Basic setup idea

* config
    - `init.lua` have functions to load.
    - `settings.lua`

* UI
    - To make it reusable, everything you think it might be reusable in different scenarios can be placed in `ui.lua`

* Plugins
    - all plugins are in `plugins/installer` but that does not auto install.
    - you must include the plugin file in `plugins/init.lua`.
    - all the plugin setup goes in attribute `conifg` as function.

## Structure

```bash
./
├── init.lua
├── LICENSE
├── lua/
│   ├── config/
│   │   ├── autocmds.lua
│   │   ├── init.lua
│   │   ├── keymaps.lua
│   │   └── loader.lua
│   ├── plugins/
│   │   ├── code/
│   │   │   ├── cmp.lua
│   │   │   ├── comment.lua
│   │   │   ├── iconpicker.lua
│   │   │   ├── indentscope.lua
│   │   │   ├── luasnip.lua
│   │   │   ├── miniai.lua
│   │   │   ├── minipairs.lua
│   │   │   ├── minisurround.lua
│   │   │   └── todo-comment.lua
│   │   ├── colors/
│   │   │   ├── colorizer.lua
│   │   │   ├── colorscheme.lua
│   │   │   └── illuminate.lua
│   │   ├── editor/
│   │   │   ├── blankline.lua
│   │   │   ├── bufferline.lua
│   │   │   ├── dashboard.lua
│   │   │   ├── dressing.lua
│   │   │   ├── flash.lua
│   │   │   ├── fzf.lua
│   │   │   ├── harpoon2.lua
│   │   │   ├── lualine.lua
│   │   │   ├── mini-animate.lua
│   │   │   ├── minibufremove.lua
│   │   │   ├── neotree.lua
│   │   │   ├── noice.lua
│   │   │   ├── notify.lua
│   │   │   ├── persistence.lua
│   │   │   ├── spectre.lua
│   │   │   ├── startuptime.lua
│   │   │   ├── telescope.lua
│   │   │   ├── trouble.lua
│   │   │   └── whichkey.lua
│   │   ├── git/
│   │   │   ├── gitsigns.lua
│   │   │   └── lazygit.lua
│   │   ├── init.lua
│   │   └── lsp/
│   │       ├── conform.lua
│   │       ├── init.lua
│   │       ├── lang/
│   │       ├── lsp_kind.lua
│   │       ├── lspconfig.lua
│   │       ├── mason.lua
│   │       ├── none-ls.lua
│   │       ├── nvim-lint.lua
│   │       └── treesitter.lua
│   ├── ui/
│   │   ├── icons.lua
│   │   └── init.lua
│   └── util/
│       ├── format.lua
│       ├── init.lua
│       ├── inject.lua
│       ├── lsp.lua
│       └── ui.lua
├── queries/
│   └── lua/
│       └── highlights.scm
├── README.md
├── spell/
│   ├── en.utf-8.add
│   └── en.utf-8.add.spl
└── stylua.toml
```

# Lazy Plugins

- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [onsails/lspkind-nvim](https://github.com/onsails/lspkind-nvim)
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
- [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [folke/trouble.nvim](https://github.com/folke/trouble.nvim)
- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)
- [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
- [ojroques/nvim-hardline](https://github.com/ojroques/nvim-hardline)
- [folke/which-key.nvim](https://github.com/folke/which-key.nvim)
- [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify)
- [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
- [junegunn/fzf](https://github.com/junegunn/fzf)

