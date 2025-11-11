
" TODO: Add bear support, use a global variable
" TODO: Find Cmake projects, perhaps list available projects
" TODO: Add set project, target, preset
" TODO: Add error paths to quickfix list
" TODO: Create a small buffer to output nicely
" TODO: Is using system better than opening a terminal (if tmux is available?)

function! cmake#clean() abort
	" Use cmake to find preset output build dir
	echo "cmake clean"
endfunction

function! cmake#list_presets() abort
	let command = 'cmake --list-presets'
	let output = system(command)
	echo output
endfunction

function! cmake#preset(preset, ...) abort
	let command = 'cmake --preset ' .. a:preset
	let output = system(command)
	echo output
endfunction

function! cmake#build_preset(preset, ...) abort
	let command = 'cmake --build --preset ' .. a:preset
	let output = system(command)
	echo output
endfunction

function! cmake#test_preset(preset, ...) abort
	let command = 'ctest --preset ' .. a:preset
	let output = system(command)
	echo output
endfunction

