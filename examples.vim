<@
function! DiceGrid()
let l:ret = ""
for l:i in [1, 2, 3, 4, 5, 6]
        let l:line = ""
        for l:j in [1, 2, 3, 4, 5, 6]
                let l:line = l:line . "(" . l:i . "," . l:j . ")"
        endfor
        let l:ret = l:ret . l:line . "\n"
endfor

" spelling mistake!
return l:rt
endfunction

" arguably a good idea to call the function right after defining it, so that we
" get an error message now rather than later
call DiceGrid()
@>

" this command will throw an error, and as such it won't be replaced
grid1 ={<! echo DiceGrid() !>}

" this command will work just fine, and you should see a nice little grid
grid2 = 
<!
        let ret = ""
        for i in [1,2,3,4,5,6]
                let line = ""
                for j in [1,2,3,4,5,6]
                        let line = line . "(" . i . "," . j . ")"
                endfor
                " very silly
                let ret = ret . line . "\n"
        endfor
        echo ret
!>

" inline code blocks can also fairly easily be used to execute system commands
date = {<! echo system('date') !>}

" this format doesn't work as nicely, it inserts a bunch of extra crud around the
" part we're (probably) most interested in
lol = {<! !date !>} 

" try calling :Modify DiceGrid() here and fix the issue
