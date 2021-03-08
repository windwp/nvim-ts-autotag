set rtp +=.
set rtp +=~/.vim/autoload/plenary.nvim/
set rtp +=~/.vim/autoload/nvim-treesitter/

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.vim

set noswapfile
set nobackup

filetype indent off
set nowritebackup
set noautoindent
set nocindent
set nosmartindent
set indentexpr=

lua << EOF
local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.T=ts_utils
require("plenary/busted")
require("nvim-ts-autotag").setup()

EOF
