return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
	    	"lua_ls",		 -- Lua
	    	"pyright",		-- Python
	    	"ts_ls",	 -- JavaScript / TypeScript
	    	"clangd",		 -- C / C++
	    	"html",
	    	"cssls",
	    	"jsonls",
	        "texlab",
	        "marksman",
	        "yamlls",
	        "jsonls",
            "tinymist",
	        },
	    automatic_installation = true,
        },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
