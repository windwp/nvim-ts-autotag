set rtp +=.
set rtp +=../plenary.nvim/
set rtp +=../nvim-treesitter/
set rtp +=../playground/
set rtp +=../nvim-treesitter-rescript/



runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter.lua
runtime! plugin/nvim-treesitter-playground.lua
runtime! plugin/nvim-treesitter-rescript.vim


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
_G.ts_filetypes = {
  'html', 'javascript', 'typescript', 'svelte', 'vue', 'tsx', 'php', 'glimmer', 'rescript', 'embedded_template'
}
require("nvim-treesitter.configs").setup({
    ensure_installed = _G.ts_filetypes,
    highlight = { enable = true },
    sync_install = true
})
vim.treesitter.language.register('tsx', 'typescriptreact')
vim.treesitter.language.register('embedded_template', 'eruby')
require("plenary/busted")
vim.cmd[[luafile ./tests/test-utils.lua]]
require("nvim-ts-autotag").setup({
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
})
EOF

