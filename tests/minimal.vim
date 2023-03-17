set rtp +=.
set rtp +=../plenary.nvim/
set rtp +=../nvim-treesitter
set rtp +=../playground/


runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.vim
runtime! plugin/playground.vim
runtime! plugin/nvim-treesitter-rescript


set noswapfile
set nobackup

filetype indent off
set nowritebackup
set noautoindent
set nocindent
set nosmartindent
set indentexpr=
set foldlevel=9999


lua << EOF
_G.__is_log=true
_G.test_rename = true
_G.test_close = true
_G.ts_filetypes = {
  'html', 'javascript', 'typescript', 'svelte', 'vue', 'tsx', 'php', 'glimmer', 'rescript'
}
require("plenary/busted")
vim.cmd[[luafile ./tests/test-utils.lua]]
require("nvim-ts-autotag").setup()
EOF

