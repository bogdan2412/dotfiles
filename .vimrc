set nocompatible
set backspace=indent,eol,start
set autoindent
set copyindent
set hlsearch incsearch
set showmatch
set autoread
set nowrap
set expandtab tabstop=4 softtabstop=4
set shiftwidth=4 shiftround
set wildmode=longest,list
set ruler

" Color scheme
colorscheme evening
set background=dark
syntax on

" Enable filetype plugins and indent features
filetype on
filetype plugin on
filetype indent on

" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()

" Command-T plugin configuration: Make <CR> open file in new tab as default
let g:CommandTAcceptSelectionTabMap = "<CR>"
let g:CommandTAcceptSelectionMap = "<C-T>"

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
autocmd filetype c set makeprg=gcc\ -DDEBUG\ -Wall\ -O2\ -o\ '%<'\ '%'\ -lm
autocmd filetype cpp set makeprg=g++\ -DDEBUG\ -Wall\ -O2\ -o\ '%<'\ '%'\ -lm
" C/C++ keyboard mappings
autocmd filetype c,cpp map <F8> :make<CR>:!time './%<'<CR>|
map <F9> :make<CR>|
map <F10> :!time './%<'<CR>|

map! <F8> <ESC>:make<CR>:!time './%<'<CR>|
map! <F9> <ESC>:make<CR>|
map! <F10> <ESC>:!time './%<'<CR>

" Python keyboard mappings
autocmd filetype python map <F8> :!python '%'<CR>|
map! <F8> <ESC>:!python '%'<CR>|
set ts=2 sts=2 sw=2

" PHP keyboard mappings
autocmd filetype php map <F8> :!php '%'<CR>|
map! <F8> <ESC>:!php '%'<CR>

" Bash keyboard mappings
autocmd filetype sh map <F8> :!bash '%'<CR>|
map! <F8> <ESC>:!bash '%'<CR>
