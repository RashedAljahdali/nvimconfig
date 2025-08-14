return {
	"sontungexpt/better-diagnostic-virtual-text",
	config = function(_)
		require("better-diagnostic-virtual-text").setup({
			ui = { -- Display diagnostics above the line
			},
		})
	end,
}
