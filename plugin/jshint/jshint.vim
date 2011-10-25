" File:         jshint.vim
" Author:       Steffen Leistner (sleistner@gmail.com)
" Version:      0.1
" Description:  jshint.vim allows the JavaScript Hint from
"               http://www.jshint.com to be tightly integrated with vim.
"               The contents of a javascript file will be passed through the jshint program
"               after the file's buffer is saved.  Any lint warnings will be placed in
"               the quickfix window.  If you're not on a mac SpiderMonkey must be installed on your system
"               for this plugin to work properly.
" Last Modified: October 24, 2011
" Credits: heavily borrowed from Joe Stelmach's javascriptLint.vim

if exists("g:loaded_jshint")
    finish
endif
let g:loaded_jshint = 1

command JSHint call <SID>JSHint()
command JSHintReloadConfiguration call <SID>JSHintLoadConfiguration()
autocmd BufWritePost,FileWritePost *.js call s:JSHint()
autocmd BufWinLeave * call s:MaybeClearCursorLineColor()

if !exists('jshint_plugin_path')
    let runtimepaths = &runtimepath . ','
    while strlen(runtimepaths) != 0
        let filepath = substitute(runtimepaths, ',.*', '', '') . '/plugin/jshint'
        if filereadable(filepath . '/parser.js')
            let jshint_plugin_path = filepath
            break
        endif
        let runtimepaths = substitute(runtimepaths, '[^,]*,', '', '')
    endwhile
endif

if !exists("jshint_parser")
    let jshint_parser = jshint_plugin_path . '/parser.js'
endif

if !exists("jshint")
    let jshint = jshint_plugin_path . '/jshint.js'
endif

if !exists("jshint_command")
    let jsc = '/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc'
    if executable(jsc)
        let js_interpreter = jsc
        let sep = ' -- '
    elseif executable('js')
        let js_interpreter = 'js'
        let sep = ' '
    endif
    let jshint_command = js_interpreter . ' ' . jshint_parser . sep . jshint
endif

if !exists("jshint_highlight_color")
    let jshint_highlight_color = 'DarkMagenta'
endif

function! jshint#readConfiguration(path)
    let jshintrc_file = expand(a:path . '/.jshintrc')
    if filereadable(jshintrc_file)
        return readfile(jshintrc_file)
    end
    return []
endfunction

function! s:JSHintLoadConfiguration()
    let global_jshintrc = jshint#readConfiguration($HOME)
    let local_jshintrc = jshint#readConfiguration(getcwd())
    let g:jshintrc = [join(global_jshintrc + local_jshintrc)]
endfunction

if !exists("g:jshintrc")
    call s:JSHintLoadConfiguration()
endif

" Runs the current file through javascript hint and
" opens a quickfix window with any warnings
function! s:JSHint()
    let current_file = shellescape(expand('%:p'))
    let cmd_output = system(g:jshint_command . ' ' . current_file, join(g:jshintrc + getline(1, line("$")), "\n") . "\n")
    let &errorformat='%f(%l): %m'
    " if some warnings were found, we process them
    if strlen(cmd_output) > 0

        " write quickfix errors to a temp file
        let quickfix_tmpfile_name = tempname()
        exe "redir! > " . quickfix_tmpfile_name
        silent echon cmd_output
        redir END
        " read in the errors temp file
        execute "silent! cfile " . quickfix_tmpfile_name

        " change the cursor line to something hard to miss
        call s:SetCursorLineColor()

        " open the quicfix window
        botright copen
        let s:qfix_win = bufnr("$")

        " delete the temp file
        call delete(quickfix_tmpfile_name)

        " if no javascript warnings are found, we revert the cursorline color
        " and close the quick fix window
    else
        call s:ClearCursorLineColor()
        cclose
    endif
endfunction

" sets the cursor line highlight color to the error highlight color
function s:SetCursorLineColor()
    call s:ClearCursorLineColor()
    let s:highlight_on = 1

    " find the current cursor line highlight info
    redir => l:highlight_info
    silent highlight CursorLine
    redir END

    " find the guibg property within the highlight info (if it exists)
    let l:start_index = match(l:highlight_info, "guibg")
    if(l:start_index > 0)
        let s:previous_cursor_guibg = strpart(l:highlight_info, l:start_index)

    elseif(exists("s:previous_cursor_guibg"))
        unlet s:previous_cursor_guibg
    endif

    execute "highlight CursorLine guibg=" . g:jshint_highlight_color
endfunction

" Conditionally reverts the cursor line color based on the presence
" of the quickfix window
function s:MaybeClearCursorLineColor()
    if(exists("s:qfix_win") && s:qfix_win == bufnr("%"))
        call s:ClearCursorLineColor()
    endif
endfunction

" Reverts the cursor line color
function s:ClearCursorLineColor()
    " only revert if our highlight is currently enabled
    if(exists("s:highlight_on") && s:highlight_on)
        let s:highlight_on = 0

        " if a previous cursor guibg color was recorded, we use it
        if(exists("s:previous_cursor_guibg"))
            execute "highlight CursorLine " . s:previous_cursor_guibg
            unlet s:previous_cursor_guibg
        else
            highlight clear CursorLine
        endif
    endif
endfunction

