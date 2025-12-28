" Description: ty as linter for python files
call ale#Set('python_ty_executable', 'ty')
call ale#Set('python_ty_use_global', get(g:, 'ale_use_global_executables', 1))
call ale#Set('python_ty_change_directory', 1)
call ale#Set('python_ty_auto_pipenv', 0)
call ale#Set('python_ty_auto_poetry', 0)
call ale#Set('python_ty_auto_uv', 0)

function! ale_linters#python#ty#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_ty_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif
    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_ty_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif
    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_ty_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif
    return ale#python#FindExecutable(a:buffer, 'python_ty', ['ty'])
endfunction

function! ale_linters#python#ty#GetCwd(buffer) abort
    if ale#Var(a:buffer, 'python_ty_change_directory')
        let l:project_root = ale#python#FindProjectRoot(a:buffer)
        return !empty(l:project_root) ? l:project_root : '%s:h'
    endif
    return ''
endfunction

" LSP server command
function! ale_linters#python#ty#GetCommand(buffer) abort
    let l:executable = ale_linters#python#ty#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? '\(pipenv\|poetry\|uv\)$' ? ' run ty' : ''
    return ale#Escape(l:executable) . l:exec_args . ' server'
endfunction

call ale#linter#Define('python', {
\   'name': 'ty',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#python#ty#GetExecutable'),
\   'command': function('ale_linters#python#ty#GetCommand'),
\   'project_root': function('ale#python#FindProjectRoot'),
\})
