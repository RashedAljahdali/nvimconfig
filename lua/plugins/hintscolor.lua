return {
	"sontungexpt/better-diagnostic-virtual-text",
	config = function(_)
		require("better-diagnostic-virtual-text").setup({
			ui = {
   above = true,          -- show above the line
    wrap = false,          -- don't wrap long text
    max_width = 60,        -- truncate long messages
    format = function(diagnostic)
      return string.format("[%s] %s", diagnostic.source or "", diagnostic.message)
    end,
			},
		})
	end,
}
