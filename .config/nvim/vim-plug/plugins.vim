call plug#begin('~/.config/nvim/autoload/plugged')
    " Support for Language Server Protocol
    Plug 'neovim/nvim-lspconfig'

    " Support for Rust
    Plug 'simrat39/rust-tools.nvim'

    " Debugging
    Plug 'nvim-lua/plenary.nvim'
    Plug 'mfussenegger/nvim-dap'

    " Neat (maybe best) file tree for vim
    Plug 'preservim/nerdtree'
call plug#end()
