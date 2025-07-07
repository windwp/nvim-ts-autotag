clean:
	nvim --headless --clean -n -c "lua vim.fn.delete('./tests/.deps', 'rf')" +q
test:
	nvim --headless --clean -u tests/test.lua "$(FILE)"
lint:
	stylua --check lua/ tests/
	VIMRUNTIME="$$(nvim --clean --headless +'echo $$VIMRUNTIME' +q 2>&1)" lua-language-server --configpath=../.luarc.jsonc --check=./
	luacheck $$(git ls-files lua tests)
format:
	stylua lua/ tests/
