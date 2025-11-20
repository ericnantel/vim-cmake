
if exists('g.loaded_cmake') && g.loaded_cmake
	finish
endif
let g:loaded_cmake = 1

if !executable('cmake')
	echomsg "Cannot find cmake.."
	finish
endif

if !executable('ctest')
	echomsg "Cannot find ctest.."
	finish
endif

if !executable('bear')
	echomsg "Cannot find bear.."
	"finish NOTE: Optional
endif

" Initializing Plugin
silent call cmake#init()

" Window Commands
command! -nargs=0 CMakeCloseCommandLogWindow call cmake#close_command_log_window()

" Path Commands (project, binary, library)
" TODO: ..

" Commands
command! -nargs=0 CMakeListPresets call cmake#list_presets()
command! -nargs=+ CMakeListPresetVariables call cmake#list_preset_variables(<f-args>)
command! -nargs=+ CMakePreset call cmake#preset(<f-args>)
command! -nargs=+ CMakeFreshPreset call cmake#fresh_preset(<f-args>)
command! -nargs=+ CMakeBuildPreset call cmake#build_preset(<f-args>)
command! -nargs=+ CMakeTestPreset call cmake#test_preset(<f-args>)

" Package Commands
" TODO: ..

" Workflow Commands
command! -nargs=0 CMakeWorkflowListPresets call cmake#workflow_list_presets()
command! -nargs=+ CMakeWorkflowPreset call cmake#workflow_preset(<f-args>)
command! -nargs=+ CMakeWorkflowFreshPreset call cmake#workflow_fresh_preset(<f-args>)

" Window Mappings
nnoremap <silent> <Plug>(CMakeCloseCommandLogWindow) :call cmake#close_command_log_window()<CR>

" Mappings
nnoremap <silent> <Plug>(CMakeListPresets) :call cmake#list_presets()<CR>
nnoremap <silent> <Plug>(CMakeListPresetVariables) :call cmake#list_preset_variables(default)<CR>
nnoremap <silent> <Plug>(CMakePreset) :call cmake#preset(default)<CR>
nnoremap <silent> <Plug>(CMakeFreshPreset) :call cmake#fresh_preset(default)<CR>
nnoremap <silent> <Plug>(CMakeBuildPreset) :call cmake#build_preset(default)<CR>
nnoremap <silent> <Plug>(CMakeTestPreset) :call cmake#test_preset(default)<CR>

" Package Mappings
" TODO: ..

" Workflow Mappings
nnoremap <silent> <Plug>(CMakeWorkflowListPresets) :call cmake#workflow_list_presets()<CR>
nnoremap <silent> <Plug>(CMakeWorkflowPreset) : call cmake#workflow_preset(default)<CR>
nnoremap <silent> <Plug>(CMakeWorkflowFreshPreset) : call cmake#workflow_fresh_preset(default)<CR>

