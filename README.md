# vim-inline-code
Example project for writing inline VimScript

No real installation instructions as there are probably better implemented plugins that do similar things, I mainly wrote this out of curiosity.

# Usage
Source `commands.vim`: `:so commands.vim`

This will add two new commands, `Eval` and `Modify`, described below.

## `:Eval`
`:Eval` takes a range, and evaluates any code inside blocks in the range. For example, if you only want to evaluate on block, simply select it with `v`or `Ctrl-V`
or what have you and call `:Eval` with the block completely selected. This will only evaluate whatever you have selected. All standard vim ways to specify a range
will work, `:1,31Eval`, etc.

If an error occurs during the evaluation, the block will be reset and no expansion will occur. The error will still be shown to the user, so as to hopefully
make debugging easier.

## `:Modify`
`:Modify` takes the name of one function, and inserts the definition of the function into the current buffer. Important if you define a function inside
a volatile block, but realize that you made a mistake and want to correct it.

# Important concepts
## Code blocks
Code blocks can be specified with `<! ... !>` or `<@ ... @>`. These are what I call volatile and involatile blocks.

### Volatile blocks
Volatile code blocks can be specified with `<! ... !>`. Any code inside them is evaluated and the block is replaced with the output of the code inside it.

For example: 
```hello = {<! echo 'hi' !>} -> :Eval -> hello = {hi}```

### Involatile blocks
Involatile code blocks can be specified with `<@ ... @>`. Any code inside them is evaluated, but any output is discarded and the block is not replaced.
These blocks can be used to set up common functions or global variables, what have you.

For example:
```
<@                                      <@
function Hello()                        function Hello()
  echo 'Hello!'             ->:Eval->     echo 'Hello!'
endfunction                             endfunction
@>                                      @>

hi = {<! echo Hello() !>}               hi = {Hello!}
```

# Sort of neat features
For a scratchpad-like experience, just run `:new`, which will open up a new empty buffer and write 
whatever code you want, `:Eval` it and close the temporay buffer.

Blocks can even be used to execute code in an arbitrary language, sort of. Vim provides `system()`, which essentially just runs the command given to it. So you 
could do something like 

`tested with python version <! call system("python3 --version | awk '{print $2}'") !>`. 

Note however that `system()` uses the default
shell, which may or may not be the same that you use daily.

# Examples
See `examples.vim`
