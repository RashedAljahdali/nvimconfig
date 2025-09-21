return {
	"fatih/vim-go",
	run = ":GoUpdateBinaries",
	config = function()
		vim.g.go_fmt_command = "goimports"
		vim.g.go_auto_type_info = 1
		vim.g.go_fmt_autosave = 1
		vim.g.go_imports_autosave = 1
	end,
}
