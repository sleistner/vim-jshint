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

if exists("g:jshint_loaded")
    finish
endif
let g:jshint_loaded = 1
let g:jshint_enabled = 1

command JSHint call <SID>JSHint()
command JSHintReload call <SID>JSHintLoad()
command JSHintToggle call <SID>JSHintToggle()
autocmd BufWritePost,FileWritePost *.js call s:JSHint()
autocmd BufWinLeave * call s:MaybeClearCursorLineColor()

if !exists('s:jshint_plugin_path')
    let s:runtimepaths = &runtimepath . ','
    while strlen(s:runtimepaths) != 0
        let s:filepath = substitute(s:runtimepaths, ',.*', '', '') . '/plugin/jshint'
        if filereadable(s:filepath . '/parser.js')
            let s:jshint_plugin_path = s:filepath
            break
        endif
        let s:runtimepaths = substitute(s:runtimepaths, '[^,]*,', '', '')
    endwhile
endif

if !exists("s:jshint_parser")
    let s:jshint_parser = s:jshint_plugin_path . '/parser.js'
endif

if !exists("s:jshint")
    let s:jshint = s:jshint_plugin_path . '/jshint.js'
endif

if !exists("s:jshint_command")
    let s:jsc = '/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc'
    if executable(s:jsc)
        let s:js_interpreter = s:jsc
        let s:sep = ' -- '
    elseif executable('js')
        let s:js_interpreter = 'js'
        let s:sep = ' '
    endif
    let s:jshint_command = s:js_interpreter . ' "' .  s:jshint . '" "' . s:jshint_parser . '"' . s:sep
endif

if !exists("g:jshint_highlight_color")
    let g:jshint_highlight_color = 'DarkMagenta'
endif

function! s:ReadOptions(path)
    let l:jshintrc_file = expand(a:path . '/.jshintrc')
    if filereadable(l:jshintrc_file)
        return system('cat ' . l:jshintrc_file . ' | sed -e "s|//.*||g" | sed -e "s|\"|\\\\\"|g"')
    end
    return ''
endfunction

function! s:JSHintLoad()
    let s:global_jshintrc = s:ReadOptions($HOME)
    let s:local_jshintrc = s:ReadOptions(getcwd())
endfunction

function! s:JSHintToggle()
   let g:jshint_enabled = !g:jshint_enabled
endfunction

if !exists("s:jshintrc")
    call s:JSHintLoad()
endif

" Runs the current file through javascript hint and
" opens a quickfix window with any warnings
function! s:JSHint()
    if g:jshint_enabled != 1
        return
    endif

    let l:content = join(getline(1, line("$")), "\n")
    if strlen(l:content) < 1
        return
    endif

    let l:current_file = shellescape(expand('%:p'))
    let l:cmd_output = system(s:jshint_command . ' ' . l:current_file . ' "' . s:global_jshintrc . '" "' . s:local_jshintrc . '"', l:content)
    let &errorformat='%f(%l): %m'
    " if some warnings were found, we process them
    if strlen(l:cmd_output) > 0

        " write quickfix errors to a temp file
        let l:quickfix_tmpfile_name = tempname()
        exe "redir! > " . l:quickfix_tmpfile_name
        silent echon l:cmd_output
        redir END
        " read in the errors temp file
        execute "silent! cfile " . l:quickfix_tmpfile_name

        " change the cursor line to something hard to miss
        call s:SetCursorLineColor()

        " open the quicfix window
        botright copen
        let s:qfix_win = bufnr("$")

        " delete the temp file
        call delete(l:quickfix_tmpfile_name)

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

