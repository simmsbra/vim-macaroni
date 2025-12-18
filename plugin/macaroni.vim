" vim-macaroni: quick, no-nonsense macro editing
"
" Author: Brandon Simmons
" Version: 1.0.0

" :h write-plugin

if exists("g:loaded_macaroni")
  finish
endif
let g:loaded_macaroni = 1

let s:save_cpo = &cpo
set cpo&vim


" opens up the command-line-window and constructs a :let @a="" command for
" editing whichever macro register letter is given. just edit the macro text and
" then hit enter. note that you'll have to escape " characters; and if you want
" to insert a special character, you can use C-v
function! s:GetRegisterLetterThenOpenForEditing()
    echo "Enter the letter of the macro register that you want to edit: "
    let l:registerLetter = getchar()
    " make sure the result is a Number, and not something like a mouse click
    if type(l:registerLetter) != 0
        call s:EchoInvalidCharError()
        return
    endif
    let l:registerLetter = nr2char(l:registerLetter)
    if l:registerLetter !~# '[a-zA-Z]'
        call s:EchoInvalidCharError()
        return
    endif
    " to insert the macro register's literal text into the command, <C-r><C-o>
    " (:h i_CTRL-R_CTRL-O) is used. but that wouldn't escape any double quotes,
    " so instead of putting the macro's register letter right after <C-r><C-o>,
    " we use the expression register (:h @=) to insert the result of escaping
    " any double quotes within the macro register's contents
    call feedkeys(
        \ "q:"
        \ .. "i"
        \ .. ":let @" .. l:registerLetter .. "="
        \ .. '"'
        \ .. "\<C-r>\<C-o>=escape(@" .. l:registerLetter .. ", '\"')\<CR>"
        \ .. '"'
        \ .. ' "C-v to insert special characters; \ to escape double quotes'
        \ .. "\<Esc>"
        \ .. '0f"l'
    \ )
endfunction

function! s:EchoInvalidCharError()
    " could use "echoerr", but it makes it look like the error wasn't handled,
    " since it shows the function name and line number
    echohl ErrorMsg
    echo "ERROR: You must enter a valid macro register character (A-Z or a-z)"
    echohl None
endfunction


if !hasmapto('<Plug>MacaroniGetRegisterLetterThenOpenForEditing;')
    nmap <unique> <Leader>q <Plug>MacaroniGetRegisterLetterThenOpenForEditing;
endif

noremap <unique> <Plug>MacaroniGetRegisterLetterThenOpenForEditing;
    \ :call <SID>GetRegisterLetterThenOpenForEditing()<CR>


let &cpo = s:save_cpo
unlet s:save_cpo
