
" Functions
function CMakeClean()
	echom "cmake clean"
endfunction

function CMakeListPresets()
	let output = system('cmake --list-presets')
	echo output
endfunction

function CMakePreset(...)
	let output = system('cmake --preset default')
	echo output
endfunction

function CMakeBuildPreset(...)
	let output = system('cmake --build --preset default')
	echo output
endfunction

function CMakeTestPreset(...)
	let output = system('ctest --preset default')
	echo output
endfunction

" Commands
command -nargs=0 CMakeClean call CMakeClean()
command -nargs=0 CMakeListPresets call CMakeListPresets()
command -nargs=? CMakePreset call CMakePreset(<f-args>)
command -nargs=? CMakeBuildPreset call CMakeBuildPreset(<f-args>)
command -nargs=? CMakeTestPreset call CMakeTestPreset(<f-args>)

" Mappings
nnoremap <silent> <Plug>(CMakeClean) :call CMakeClean()<CR>
nnoremap <silent> <Plug>(CMakeListPresets) :call CMakeListPresets()<CR>
nnoremap <silent> <Plug>(CMakePreset) :call CMakePreset(default)<CR>
nnoremap <silent> <Plug>(CMakeBuildPreset) :call CMakeBuildPreset(default)<CR>
nnoremap <silent> <Plug>(CMakeTestPreset) :call CMakeTestPreset(default)<CR>

