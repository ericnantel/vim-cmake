
" TODO: Add bear support, use a global variable
" TODO: Find Cmake projects, perhaps list available projects
" TODO: Add set project, target, preset
" TODO: Add error paths to quickfix list
" TODO: Create a small buffer to output nicely
" TODO: Is using system better than opening a terminal (if tmux is available?)
" TODO: Make a callback when done building, so that we can restart lsp
" perhaps with nvim we can do it internally ..
" TODO: Add preset cached variable to a dictionary
" Will be useful to know output path for bin and lib
" However we need to know what target name and type we are dealing with
" Steps to find binary output path
" First see if CMAKE_RUNTIME_OUTPUT_DIRECTORY is set
" Otherwise parse CMakePresets.json binaryDir in the preset configure
" Otherwise assume binaryDir is build/
" TODO: We need a run command or at least give the binary path
" And also make a callback to attach a debugger or something.
" EX: function! run_executable_preset & run_googletest_preset
" NOTE: test_preset is running ctests and googletests however you can run
" googletests build to output results properly..

" Credits: https://github.com/mattn/vim-findroot/blob/master/autoload/findroot.vim
function! s:find_project_up(path, patterns) abort
	let l:path = a:path
	while 1
		for l:pattern in a:patterns
			let l:current = l:path . '/' . l:pattern
			if stridx(l:pattern, '*') !=# -1 && !empty(glob(l:current, 1))
				return l:path
			elseif l:pattern =~# '/$'
				if isdirectory(l:current)
					return l:path
				endif
			elseif filereadable(l:current)
				return l:path
			endif
		endfor
		let l:next = fnamemodify(l:path, ':h')
		if l:next ==# l:path || (has('win32') && l:next =~# '^//[^/]\+$')
			break
		endif
		let l:path = l:next
	endwhile
	return ''
endfunction

function! cmake#clean() abort
	" Use cmake to find preset output build dir
	" find project path then rm -rf build
	" or perhaps we should instead find actual output bin/lib path
	" for the specified preset (if provided)
	echo "cmake clean"
endfunction

function! cmake#list_presets() abort
	let command = 'cmake --list-presets'
	silent! cclose

	let output = system(command)
	echo output
endfunction

function! cmake#list_preset_variables(preset, ...) abort
	" NOTE: Use -LA for advanced cached variables
	let l:command = 'cmake -L --preset ' .. a:preset
	silent! cclose

	let l:cwd = get(a:, 1, getcwd())
	let l:patterns = ['CMakePresets.json']
	let l:pwd = s:find_project_up(l:cwd, l:patterns)
	if l:pwd != l:cwd
		let l:command = 'cd ' . l:pwd . ' && ' . l:command . ' && cd ' . l:cwd
	endif
	let l:output = system(l:command)
	let l:result = v:shell_error
	echo output
endfunction

function! cmake#preset(preset, ...) abort
	let l:command = 'cmake --preset ' .. a:preset
	silent! cclose

	" let output = system(command)
	" let result = v:shell_error
	" if result == 0
	" 	echo "success"
	" else
	" 	echo "failed"
	" endif
	" echo output

	" Testing
	" NOTE: There are several ways to launch a command
	" exec 'terminal ' . command
	let l:cwd = get(a:, 1, getcwd())
	" echo string(cwd)
	" echon !empty(findfile('CMakePresets.json', l:cwd.';'))
	" echon findfile('CMakePresets.json', l:cwd.';')
	" echo findfile('CMakePresets.json', '.;')
	let l:patterns = ['CMakePresets.json']
	let l:pwd = s:find_project_up(l:cwd, l:patterns)
	if l:pwd != l:cwd
		let l:command = 'cd ' . l:pwd . ' && ' . l:command . ' && cd ' . l:cwd
		" echo "test " .. l:command
	endif
	" exec 'terminal ' . l:command
	let l:output = system(l:command)
	let l:result = v:shell_error
	echo output
endfunction

function! cmake#build_preset(preset, ...) abort
	let l:command = 'cmake --build --preset ' .. a:preset
	silent! cclose

	" Testing
	" NOTE: There are several ways to launch a command
	" exec 'terminal ' . command
	let l:cwd = get(a:, 1, getcwd())
	" echo string(cwd)
	" echon !empty(findfile('CMakePresets.json', l:cwd.';'))
	" echon findfile('CMakePresets.json', l:cwd.';')
	" echo findfile('CMakePresets.json', '.;')
	let l:patterns = ['CMakePresets.json']
	let l:pwd = s:find_project_up(l:cwd, l:patterns)
	if l:pwd != l:cwd
		let l:command = 'cd ' . l:pwd . ' && ' . l:command . ' && cd ' . l:cwd
		" echo "test " .. l:command
	endif
	" exec 'terminal ' . l:command
	let l:output = system(l:command)
	let l:result = v:shell_error
	echo output
endfunction

function! cmake#rebuild_preset(preset, ...) abort
	let l:fresh_preset_command = 'cmake --fresh --preset ' .. a:preset
	let l:build_preset_command = 'cmake --build --preset ' .. a:preset
	let l:command = l:fresh_preset_command . ' && ' . l:build_preset_command
	silent! cclose

	" Testing
	" NOTE: There are several ways to launch a command
	" exec 'terminal ' . command
	let l:cwd = get(a:, 1, getcwd())
	" echo string(cwd)
	" echon !empty(findfile('CMakePresets.json', l:cwd.';'))
	" echon findfile('CMakePresets.json', l:cwd.';')
	" echo findfile('CMakePresets.json', '.;')
	let l:patterns = ['CMakePresets.json']
	let l:pwd = s:find_project_up(l:cwd, l:patterns)
	if l:pwd != l:cwd
		let l:command = 'cd ' . l:pwd . ' && ' . l:command . ' && cd ' . l:cwd
		" echo "test " .. l:command
	endif
	" exec 'terminal ' . l:command
	let l:output = system(l:command)
	let l:result = v:shell_error
	echo output
endfunction

function! cmake#test_preset(preset, ...) abort
	let l:command = 'ctest --preset ' .. a:preset
	silent! cclose

	" Testing
	" NOTE: There are several ways to launch a command
	" exec 'terminal ' . command
	let l:cwd = get(a:, 1, getcwd())
	" echo string(cwd)
	" echon !empty(findfile('CMakePresets.json', l:cwd.';'))
	" echon findfile('CMakePresets.json', l:cwd.';')
	" echo findfile('CMakePresets.json', '.;')
	let l:patterns = ['CMakePresets.json']
	let l:pwd = s:find_project_up(l:cwd, l:patterns)
	if l:pwd != l:cwd
		let l:command = 'cd ' . l:pwd . ' && ' . l:command . ' && cd ' . l:cwd
		" echo "test " .. l:command
	endif
	" exec 'terminal ' . l:command
	let l:output = system(l:command)
	let l:result = v:shell_error
	echo output
endfunction

