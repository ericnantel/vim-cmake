# Vim/Neovim Plugin for Presets/Workflow CMake Projects
*Written by Eric Nantel*

![vim-cmake-gif](screenshots/vim-cmake.gif "")

## From the author
I wrote this plugin (first one) using Vimscript so that I could run cmake commands within Vim/Neovim ecosystem.
I have not found another plugin that supported the 'New' way of creating cmake projects with presets and workflows.
So I make this. I am hoping you will find this useful in your workflow for building apps and frameworks with cmake.
One important aspect I wanted to focus on, was to be as less intruisive as possible, and that we can integrate it fast.

## Prerequisites

* cmake installed
* Projects must include both CMakePresets.json and CMakeFiles.txt files

## Installation

In Vim using vim-plug, place this repository within vim-plug begin/end calls:
```vim
call plug#begin('~/.vim/plugged')
   Plug 'ericnantel/vim-cmake'
call plug#end()
```

In Neovim using lazy.nvim, place this repository along with other plugins:
```lua
require("lazy").setup({
  spec = {
    {
      "ericnantel/vim-cmake",
    },
  },
})
```

## Features

* Supports CMake presets
* Supports CTest & GoogleTest presets
* Supports CMake Workflow presets
* (Coming soon) Supports [Bear](https://github.com/rizsotto/Bear) if available
* (Coming soon) Supports Ease integration with LSP and DAP
* (Coming soon) Supports Switching presets or workflow presets
* (Coming soon) Supports Command Log Window customization

## Useful links

* [CMake Examples](https://github.com/ericnantel/cmake_examples)

## Known issues


## Commands and Global Variables
Please read the documentation (coming soon) for an exaustive list of available commands and global variables.

## Thank you
You made it this far ! Thank you !


We stronly encourage you to give this repository a GitHub :star: to boost organic growth. 
