# git-rebase-auto-diff

Show diff automatically when git rebase.

https://user-images.githubusercontent.com/8683947/229416568-b50a6391-bd0b-4e61-88d8-2edeabcc1cd2.mp4

Inspired by [hotwatermorning/auto-git-diff](https://github.com/hotwatermorning/auto-git-diff)

## Installation

```lua
{
	"yutkat/git-rebase-auto-diff.nvim",
	ft = { "gitrebase" },
	config = function()
		require("git-rebase-auto-diff").setup()
	end,
}
```

## Usage

```
git rebase -i HEAD^^^
```
