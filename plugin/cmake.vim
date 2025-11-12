
if exists('g.loaded_cmake') && g.loaded_cmake
	finish
endif
let g:loaded_cmake = 1

if !executable('cmake')
	echo "Cannot find cmake.."
	finish
endif

if !executable('ctest')
	echo "Cannot find ctest.."
	finish
endif

if !executable('bear')
	echo "Cannot find bear"
	"finish
endif

" Commands
command! -nargs=0 CMakeClean call cmake#clean()
command! -nargs=0 CMakeListPresets call cmake#list_presets()
command! -nargs=+ CMakePreset call cmake#preset(<f-args>)
command! -nargs=+ CMakeBuildPreset call cmake#build_preset(<f-args>)
command! -nargs=+ CMakeRebuildPreset call cmake#rebuild_preset(<f-args>)
command! -nargs=+ CMakeTestPreset call cmake#test_preset(<f-args>)

" Mappings
nnoremap <silent> <Plug>(CMakeClean) :call cmake#clean()<CR>
nnoremap <silent> <Plug>(CMakeListPresets) :call cmake#list_presets()<CR>
nnoremap <silent> <Plug>(CMakePreset) :call cmake#preset(default)<CR>
nnoremap <silent> <Plug>(CMakeBuildPreset) :call cmake#build_preset(default)<CR>
nnoremap <silent> <Plug>(CMakeRebuildPreset) :call cmake#rebuild_preset(default)<CR>
nnoremap <silent> <Plug>(CMakeTestPreset) :call cmake#test_preset(default)<CR>

