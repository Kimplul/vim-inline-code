function! OriginalOnError(original, replacement)
        " remove starting newline, execute() likes to add them
        if a:replacement[0] == "\n"
                let l:replacement = a:replacement[1:]
        else
                let l:replacement = a:replacement
        endif

        " remove trailing newline, again, execute()
        if a:replacement[strlen(a:replacement) - 1] == "\n"
                let l:replacement = l:replacement[0:-2]
        endif
        " note: the reason why I chose not to use trim() is that if the user
        " wants to generate newlines, this way only the ones appended by
        " execute() will be removed

        " pretty ugly check but it's the best I've come up with
        if l:replacement =~ "^Error"
                return a:original
        else
                return l:replacement
        endif
endfunction

function! EvalVolatile(line1, line2)
        " quite a mouthful, here's a breakdown of what's happening:
        "
        " a:line1 . "," . a:line2 - this is the range of the command
        "
        " s/<!\(\_.\{-}\)!> - capture pattern, look for volatile tags <! and !>
        "       and capture everything inside. The typical .* wouldn't work, as .
        "       doesn't match newlines and * is greedy. See :help /multi
        "
        " /\= - substitute replace expression, essentially run the following
        "       commands on the found pattern matches. See :help
        "       sub-replace-expression
        " OriginalOnError() - function that tries to figure out if the
        "       expression succeeded, if it didn't it returns the original
        "       expression so the user can try to quickly fix their mistake
        "
        " submatch(0) - the whole match
        "
        " execute(split(submatch(1),"\\n")) - split turns the expression found
        "       by :substitute into a list, so that we can write comments. Otherwise
        "       execute() would just ignore everything after the comments.
        "       expression() just runs the specified command.
        "
        " /ge - search globally(g), if a line has more than one code block, and
        "       don't report errors(e) if there are no matches
        "
        " silent - the exeuction doesn't stop if an error is found, but the user
        "       is informed of the error. Also prepends a "Error ..." line to the
        "       output
        call execute(a:line1 . "," . a:line2 . 's/<!\(\_.\{-}\)!>/\=OriginalOnError(submatch(0),execute(split(submatch(1),"\\n")))/ge', "silent")
endfunction

function! EvalInvolatile(line1, line2)
        " largely equivalent to EvalVolatile, but in this case we don't want to
        " replace any text, so we can do it outside of the buffer
        let l:scan = getline(a:line1, a:line2)
        let l:scan = join(l:scan, "\n")
        call substitute(l:scan, '<@\(\_.\{-}\)@>', '\=execute(split(submatch(1),"\\n"))', "ge")
endfunction

function! Eval(line1, line2)
        " call involatile first, since it is guaranteed to not decrease the
        " linecount of the file, avoiding "Incorrect range" errors
        call EvalInvolatile(a:line1, a:line2)
        call EvalVolatile(a:line1, a:line2)
endfunction

function! Modify(name)
        " tabbing through functions leaves us with func_name(, and we just want
        " the base name of the function
        let l:argname = substitute(a:name, '()\?', '', '')
        " get the definition of the function
        " note: I'm not sure if the format of the output is the same across
        " different vim versions, the code below works with NVIM v0.4.4
        let l:def = execute('verbose function ' . l:argname, 'silent!')

        if strlen(l:def) == 0
                echoerr 'Failed fetching function ' . l:argname . '! Make sure it's not a built-in function.'
                return
        endif

        " append() for some reason changes all newlines to null characters, so
        " we need to pass it a list
        let l:def = split(l:def, '\n')

        " remove second line, as it is not part of the function definition
        call remove(l:def, 1)

        " remove leading line numbers
        for l:i in range(len(l:def))
                let l:def[l:i] = substitute(trim(l:def[l:i]), "^[0-9]\\+", "", "")
        endfor

        call add(l:def, "!>")
        call insert(l:def, "<!")

        " insert function definition one line after current line
        call append(line("."), l:def)
endfunction

command! -range=% Eval call Eval(<line1>, <line2>)
command! -nargs=1 -complete=expression Modify call Modify("<args>")
