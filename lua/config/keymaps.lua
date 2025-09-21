local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-m>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<C-h>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-t>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-n>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-s>", function()
	harpoon:list():select(4)
end)

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP keymaps",
	callback = function(event)
		local opts = { buffer = event.buf }
		local map = vim.keymap.set

		map("n", "K", vim.lsp.buf.hover, opts)
		map("n", "gd", vim.lsp.buf.definition, opts)
		map("n", "gD", vim.lsp.buf.declaration, opts)
		map("n", "gi", vim.lsp.buf.implementation, opts)
		map("n", "gr", vim.lsp.buf.references, opts)
		map("n", "go", vim.lsp.buf.type_definition, opts)
		map("n", "gs", vim.lsp.buf.signature_help, opts)
		map("n", "<F2>", vim.lsp.buf.rename, opts)
		map({ "n", "x" }, "<F3>", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
		map("n", "<F4>", vim.lsp.buf.code_action, opts)
	end,
})
vim.api.nvim_set_keymap("n", "<leader>b", "<C-o>", { noremap = false, silent = true })
vim.keymap.set("n", "<leader>err", function()
	local row = vim.fn.line(".")
	local indent = vim.fn.indent(vim.fn.line("."))
	local indent_str = string.rep(" ", indent) -- spaces by default

	vim.fn.append(row, {
		indent_str .. "if err != nil {",
		indent_str .. "\t",
		indent_str .. "}",
	})

	-- Move cursor inside block
	vim.api.nvim_win_set_cursor(0, { row + 2, indent + 1 })
end, { noremap = true, silent = true })
