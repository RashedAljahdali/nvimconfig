return {
	"xiyaowong/transparent.nvim",
	lazy = false,
	config = function()
		require("transparent").setup({
			extra_groups = {
				"NormalFloat",
				"NvimTreeNormal",
				"TelescopeNormal",
				"Pmenu",
				"LspInlayHint",
				"LspInlayHintText",
				"LspInlayHintPrefix",
			},
			exclude_groups = {},
		})
		vim.cmd("TransparentEnable")
	end,
}
