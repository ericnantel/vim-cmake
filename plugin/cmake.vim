
function CMakeClean()
	echom "cmake clean"
endfunction

function CMakeListPresets()
	echom "cmake --list-presets"
endfunction

function CMakePreset(...)
	echom "cmake --preset " .. string(a:1)
endfunction

function CMakeBuildPreset(...)
	echom "cmake --build --preset " .. string(a:1)
endfunction

function CMakeTestPreset(...)
	echom "ctest --preset " .. string(a:1)
endfunction

command! -nargs=0 CMakeClean call CMakeClean()
command! -nargs=0 CMakeListPresets call CMakeListPresets()
command! -nargs=1 CMakePresets call CMakePreset(<f-args>)
command! -nargs=1 CMakeBuildPreset call CMakeBuildPreset(<f-args>)
command! -nargs=1 CMakeTestPreset call CMakeTestPreset(<f-args>)

