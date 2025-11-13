
" TODO: Add bear support, use a global variable
" TODO: Add window height, use a global variable
" TODO: Use vim-dispatch if available because system() is blocking vim
" TODO: Find Cmake projects, perhaps list available projects
" TODO: Add set project, target, preset
" TODO: Add error paths to quickfix list
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
" TODO: Add package preset support ..

let s:cmake_command_log_window_name = "CMakeCommandLogWindow"
let s:cmake_previous_window_number = -1

function! s:goto_previous_window() abort
	" Switch to previous window if set
	if s:cmake_previous_window_number > -1
		exec s:cmake_previous_window_number . 'wincmd w'
	endif
endfunction

function! s:goto_command_log_window() abort
	" Reset previous window number
	let s:cmake_previous_window_number = -1

	" Check if not currently in command log window
	if bufname('%') == s:cmake_command_log_window_name
		return
	endif

	" Update previous window number
	let s:cmake_previous_window_number = winnr()

	" Find or create command log window
	let l:command_log_window_number = bufwinnr(s:cmake_command_log_window_name)
	if l:command_log_window_number == -1
		let l:wcmd = s:cmake_command_log_window_name
		silent execute printf('botright 5 sp %s', l:wcmd)
		let l:command_log_window_number = bufwinnr(s:cmake_command_log_window_name)
	endif

	" Switch to command log window
	exec l:command_log_window_number . 'wincmd w'

	" Added buffer keybind to close command log window
	nnoremap <silent> <buffer> q <cmd>close<CR>
endfunction

function! s:close_command_log_window() abort
	" Check if command log window exists
	let l:command_log_window_number = bufwinnr(s:cmake_command_log_window_name)
	if l:command_log_window_number == -1
		return
	endif

	" Switch to command log window
	if bufname('%') != s:cmake_command_log_window_name
		exec l:command_log_window_number . 'wincmd w'
		" Reset previous window number (just in case ..)
		let s:cmake_previous_window_number = -1
	endif

	" Close command log window using buffer keybind
	q
endfunction

" Credits: https://github.com/mattn/vim-findroot/blob/master/autoload/findroot.vim
function! s:find_dir_upward(path, patterns) abort
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

function! s:find_project_dir(path) abort
	let l:patterns = ['CMakePresets.json']
	let l:project_dir = s:find_dir_upward(a:path, l:patterns)
	return l:project_dir
endfunction

function! s:prepare_command(cwd, project_dir, command) abort
	let l:command = ''
	if a:project_dir != a:cwd
		silent echomsg "Prepending Project Dir to Command CMakePreset.."
		let l:command = 'cd ' . a:project_dir . ' && '
	endif
	let l:command = l:command . a:command
	return l:command
endfunction

function! s:run_command(command) abort
	" Close quickfix list
	silent! cclose
	
	call s:goto_command_log_window()

	setlocal nobuflisted
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal norelativenumber
	setlocal modifiable

	normal!ggdG
	let l:output = systemlist(a:command)
	call append(line('$'), l:output)
	normal! G$o

	setlocal nomodifiable

	call s:goto_previous_window()

	" Print result message
	let l:timestamp = strftime("%H:%M:%S")

	let l:result = v:shell_error
	if l:result == 0
		echomsg l:timestamp . " - Command CMakePreset Succeed."
	else
		echomsg l:timestamp . " - Command CMakePreset Failed."
	endif
endfunction

function! cmake#close_command_log_window() abort
	call s:close_command_log_window()
endfunction

function! cmake#list_presets() abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeListPresets Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --list-presets'
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#list_preset_variables(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeListPresetVariables Cannot Be Executed."
		return
	endif
	
	" NOTE: Use -LA for advanced cached variables
	let l:command = 'cmake -L --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakePreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#fresh_preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeFreshPreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --fresh --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#build_preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeBuildPreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --build --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#test_preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeTestPreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'ctest --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#workflow_list_presets() abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeWorkflowListPresets Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --workflow --list-presets'
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#workflow_preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeWorkflowPreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --workflow --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

function! cmake#workflow_fresh_preset(preset, ...) abort
	let l:cwd = get(a:, 1, getcwd())

	let l:project_dir = s:find_project_dir(l:cwd)
	if empty(l:project_dir)
		echomsg "Command CMakeWorkflowFreshPreset Cannot Be Executed."
		return
	endif
	
	let l:command = 'cmake --workflow --fresh --preset ' .. a:preset
	let l:final_command = s:prepare_command(l:cwd, l:project_dir, l:command)

	call s:run_command(l:final_command)
endfunction

