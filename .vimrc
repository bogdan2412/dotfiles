set nocompatible
set backspace=indent,eol,start
set autoindent                          " Smart indentation
set copyindent
set hlsearch incsearch                  " Incremental search, highlight all matches as you type
set gdefault                            " Do substitutions globally by default
set showmatch                           " Highlight matching brackets
set autoread                            " Automatically reload open files when they've been edited.
set nowrap                              " No wrapping
set expandtab tabstop=4 softtabstop=4   " Spaces for tabs, indentation of 4
set shiftwidth=4 shiftround
set wildmode=longest,list               " Mimic normal <TAB> completion for vim autocomplete
set ruler                               " Show line and column number
set scrolloff=3                         " Keep 3 lines visible above and below cursor

" Color scheme
colorscheme evening
set background=dark
syntax on

" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

" Enable filetype plugins and indent features
filetype plugin on
filetype indent on

" Automatically line break when line gets longer than 79 for code and scripting
" languages. Also highlight existing longer lines in the file.
autocmd FileType c,cpp,python,php,sh,matlab setlocal textwidth=79
autocmd FileType c,cpp,python,php,sh,matlab let w:lengtherror=matchadd('ErrorMsg', '\%>79v.\+', -1)
autocmd FileType matlab setlocal filetype=octave

" Command-T plugin configuration: Make <CR> open file in new tab as default
let g:CommandTAcceptSelectionTabMap = "<CR>"
let g:CommandTAcceptSelectionMap = "<C-T>"

" snipMate constants
let g:snips_author = "Bogdan-Cristian Tataroiu <b.tataroiu@gmail.com>"

" Activating omni-completion
set omnifunc=syntaxcomplete#Complete
set completeopt=longest,menuone

" Omni-completion menu colors
highlight Pmenu ctermbg=7 ctermfg=0
highlight Pmenusel ctermbg=4 ctermfg=7

" Omni-completion keyboard mappings
function CheckForAutocomplete(...)
    let curLin = line('.')
    let curCol = col('.')
    " An optional parameter can be specified to add a certain character at the
    " current position if it is not already there.
    if a:0 && strlen(a:1) == 1
        if strpart(getline(curLin), curCol - 2, 1) != a:1
            call setline(curLin, strpart(getline(curLin), 0, curCol - 1) . a:1 . strpart(getline(curLin), curCol - 1))
            let curCol += 1
            call cursor(curLin, curCol)
        endif
    endif

    if (strpart(getline(curLin), curCol - 2, 1) == ".")
        let syntaxName = synIDattr(synID(curLin, curCol - 1, 1), "name")
        " If the . is inside a comment or a string, do not initiate autocompletion
        if match(tolower(syntaxName), "string") != -1 || match(tolower(syntaxName), "comment") != -1
            return ""
        endif
        return "\<C-X>\<C-O>\<C-R>=PostAutocompleteInit()\<CR>"
    endif
    return ""
endfunction

function PostAutocompleteInit()
    if pumvisible()
        " If a popup menu is shown, manually revert automatically inserted
        " text and highlight first option in the menu.
        let curLin = line('.')
        let curCol = col('.')

        while strpart(getline(curLin), curCol - 2, 1) != '.'
            call setline(curLin, strpart(getline(curLin), 0, curCol - 2) . strpart(getline(curLin), curCol - 1))
            let curCol -= 1
            call cursor(curLin, curCol)
        endwhile

        return "\<Down>"
    endif
    return ""
endfunction

inoremap <expr> <silent>  <CR> pumvisible() ? '<C-Y><C-R>=CheckForAutocomplete()<CR>' : '<CR>'
inoremap <expr> <silent> <TAB> pumvisible() ? '<C-Y><C-R>=CheckForAutocomplete()<CR>' : '<TAB>'
inoremap <expr> <silent>     ( pumvisible() ? '<C-Y><C-R>=CheckForAutocomplete("(")<CR>' : '('
inoremap <expr> <silent>     . pumvisible() ? '<C-Y><C-R>=CheckForAutocomplete(".")<CR>' : '.<C-R>=CheckForAutocomplete()<CR>'

" Common keyboard mappings
map <F2> :w<CR>
map <F4> :wq<CR>
map! <F2> <ESC>:w<CR>
map! <F4> <ESC>:wq<CR>

map <F5> :tabprev<CR>
map <F6> :tabnext<CR>
map! <F5> <ESC>:tabprev<CR>
map! <F6> <ESC>:tabnext<CR>

" C/C++ compilation options
autocmd filetype c setlocal makeprg=gcc\ -DDEBUG\ -Wall\ -O2\ -o\ '%<'\ '%'\ -lm
autocmd filetype cpp setlocal makeprg=g++\ -DDEBUG\ -Wall\ -O2\ -o\ '%<'\ '%'\ -lm
" C/C++ keyboard mappings
autocmd filetype c,cpp map <buffer> <F8> :make<CR>:!time './%<'<CR>|
map <buffer> <F9> :make<CR>|
map <buffer> <F10> :!time './%<'<CR>|

map! <buffer> <F8> <ESC>:make<CR>:!time './%<'<CR>|
map! <buffer> <F9> <ESC>:make<CR>|
map! <buffer> <F10> <ESC>:!time './%<'<CR>

" Python keyboard mappings
autocmd filetype python map <buffer> <F8> :!python '%'<CR>|
map! <buffer> <F8> <ESC>:!python '%'<CR>|

" PHP keyboard mappings
autocmd filetype php map <buffer> <F8> :!php '%'<CR>|
map! <buffer> <F8> <ESC>:!php '%'<CR>

" Bash keyboard mappings
autocmd filetype sh map <buffer> <F8> :!bash '%'<CR>|
map! <buffer> <F8> <ESC>:!bash '%'<CR>

" Toggle Wrap shortcut
noremap <silent> <Leader>w :call ToggleWrap()<CR>
function ToggleWrap()
    if &wrap
        echo "Wrap OFF"
        setlocal nowrap
        silent! nunmap <buffer> <Up>
        silent! nunmap <buffer> <Down>
        silent! nunmap <buffer> <Home>
        silent! nunmap <buffer> <End>
        silent! iunmap <buffer> <Up>
        silent! iunmap <buffer> <Down>
        silent! iunmap <buffer> <Home>
        silent! iunmap <buffer> <End>
    else
        echo "Wrap ON"
        setlocal wrap linebreak nolist
        setlocal display+=lastline
        noremap  <buffer> <silent> <Up>   gk
        noremap  <buffer> <silent> <Down> gj
        noremap  <buffer> <silent> <Home> g<Home>
        noremap  <buffer> <silent> <End>  g<End>
        inoremap <buffer> <silent> <Up>   <C-o>gk
        inoremap <buffer> <silent> <Down> <C-o>gj
        inoremap <buffer> <silent> <Home> <C-o>g<Home>
        inoremap <buffer> <silent> <End>  <C-o>g<End>
    endif
endfunction
