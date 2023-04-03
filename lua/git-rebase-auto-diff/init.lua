local M = {}
local config = {
	size = vim.fn.float2nr(vim.o.lines * 0.5),
}

local terminal = require("toggleterm.terminal").Terminal
local task_runner = terminal:new({ direction = "horizontal", count = 8 })

function M.run(cmd)
	task_runner:shutdown()
	task_runner = terminal:new({ cmd = cmd, direction = "horizontal", count = 8 })
	task_runner:open(config.size, "horizontal", true)
	require("toggleterm.ui").save_window_size()
	vim.g.toglleterm_win_num = vim.fn.winnr()
	vim.api.nvim_set_option_value("previewwindow", true, { scope = "local", win = vim.api.nvim_get_current_win() })
	vim.cmd([[stopinsert | wincmd p]])
end

function M.preview()
	local function get_git_hash()
		return vim.fn.matchstr(vim.fn.getline("."), [[^\(\w\+\>\)\=\(\s*\)\zs\x\{4,40\}\>\ze]])
	end
	local hash = get_git_hash()
	if hash == "" then
		return
	end
	require("git-rebase-auto-diff").run("git --no-pager diff " .. hash .. "^!")
end

local function create_autocmds()
	local group_name = "git-rebase-auto-diff"
	vim.api.nvim_create_augroup(group_name, { clear = true })
	vim.api.nvim_create_autocmd({ "TermClose" }, {
		group = group_name,
		pattern = "term://*#toggleterm#8*",
		callback = function()
			if vim.fn.winbufnr(vim.g.toglleterm_win_num) ~= -1 then
				vim.cmd(vim.g.toglleterm_win_num .. "wincmd w")
				vim.cmd("0")
				vim.cmd("wincmd p")
			end
		end,
		once = false,
		nested = false,
	})
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group_name,
		pattern = ".git/rebase-merge/git-rebase-todo",
		callback = function()
			require("git-rebase-auto-diff").preview()
		end,
		once = false,
		nested = false,
	})
	vim.api.nvim_create_autocmd({ "VimEnter" }, {
		group = group_name,
		pattern = ".git/rebase-merge/git-rebase-todo",
		callback = function()
			require("git-rebase-auto-diff").preview()
		end,
		once = true,
		nested = false,
	})
end

function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("keep", opts, config)
	create_autocmds()
end

return M
