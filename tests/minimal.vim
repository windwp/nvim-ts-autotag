set rtp +=.
set rtp +=~/.vim/autoload/plenary.nvim/
set rtp +=~/.vim/autoload/nvim-treesitter
set rtp +=~/.vim/autoload/playground/

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.vim
runtime! plugin/playground.vim

set noswapfile
set nobackup

filetype indent off
set nowritebackup
set noautoindent
set nocindent
set nosmartindent
set indentexpr=

TSUpdate

lua << EOF

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.T=ts_utils
require("plenary/busted")
require("nvim-ts-autotag").setup()

EOF

