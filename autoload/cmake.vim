
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
let s:cmake_command_job_id = "null"

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

function! s:on_job_stdout(channel, msg) abort

	call s:run_command_append(a:msg)

endfunction

function! s:on_job_stderr(channel, msg) abort

	call s:run_command_append('ERROR - ' . a:msg)

endfunction

function! s:on_job_exit(job, status) abort

	call s:run_command_exit(a:status)

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

function! s:run_command_enter() abort

	" Close quickfix list
	silent! cclose
	
	call s:goto_command_log_window()

	setlocal nobuflisted
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal norelativenumber
	setlocal autoread
	setlocal modifiable

	normal! gg"9dG

endfunction

function! s:run_command_append(msg) abort

	if bufname('%') == s:cmake_command_log_window_name
		call append(line('$'), a:msg)
		normal! G
	else
		let l:command_log_window_number = bufwinnr(s:cmake_command_log_window_name)
		if l:command_log_window_number > -1
			call appendbufline(l:command_log_window_number, '$', a:msg)
			" NOTE: This is optional..but this is how I refresh the buffer
			if s:cmake_previous_window_number > -1
				exec l:command_log_window_number . 'wincmd w'
				normal! G
				exec s:cmake_previous_window_number . 'wincmd w'
			endif
		endif
	endif

endfunction

function! s:run_command_exit(status) abort

	let s:cmake_command_job_id = "null"

	if bufname('%') == s:cmake_command_log_window_name
		setlocal nomodifiable
	endif

	call s:goto_previous_window()

	" Print result message
	" TODO: Add command_name to the message
	let l:timestamp = strftime("%H:%M:%S")
	if a:status == 0
		echomsg l:timestamp . ' - Command Succeed.'
	else
		echomsg l:timestamp . ' - Command Failed.'
	endif

endfunction

function! s:run_job_command(command) abort

	" Start a job when none is running
	if s:cmake_command_job_id == "null"
		call s:run_command_enter()
		let s:cmake_command_job_id = job_start(a:command, {
					\'out_cb': function('s:on_job_stdout'),
					\'err_cb': function('s:on_job_stderr'),
					\'exit_cb': function('s:on_job_exit')
					\})
		" DEBUG: echomsg 'job id ' . s:cmake_command_job_id
		" call s:run_command_exit is called on_job_exit
	else
		echomsg "Already running job."
	endif

endfunction

function! s:run_system_command(command) abort

	call s:run_command_enter()

	let l:output = systemlist(a:command)
	call s:run_command_append(l:output)

	let status = v:shell_error
	call s:run_command_exit(status)

endfunction

function! s:run_command(command) abort
	
	" TODO: Make sure user cannot change this once the command is running
	" If it becomes a global variable, otherwise we may ran into issues
	let l:run_job = 1

	if l:run_job == 1
		call s:run_job_command(a:command)
	else
		call s:run_system_command(a:command)
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

