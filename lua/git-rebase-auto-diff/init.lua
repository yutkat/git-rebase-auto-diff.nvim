local M = {}
local config = {
	size = vim.fn.float2nr(vim.o.lines * 0.5),
}
local buf = nil

local function terminal_cmd(cmd)
	vim.cmd(config.size .. "split")
	local win = vim.api.nvim_get_current_win()
	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_set_option_value("previewwindow", true, { scope = "local", win = vim.api.nvim_get_current_win() })
	vim.fn.termopen(cmd .. "\n")
end

local function is_visual_mode()
	local CTRL_V = vim.api.nvim_replace_termcodes("<C-v>", true, true, true)
	local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
	if mode == "v" or mode == "V" or mode == CTRL_V then
		return true
	end
	return false
end

function M.run(cmd)
	if buf ~= nil then
		vim.api.nvim_buf_delete(buf, { force = true })
	end
	terminal_cmd(cmd)

	vim.g.toglleterm_win_num = vim.fn.winnr()
	vim.cmd([[stopinsert | wincmd p]])
end

function M.preview()
	if is_visual_mode() then
		return
	end
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
