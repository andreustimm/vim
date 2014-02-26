set nocompatible        " Must be first line
set showmatch    "mostra caracteres ( { [ quando fechados
set textwidth=80 "largura do texto
set nowrap       "sem wrap (quebra de linha)
set mouse=a      "habilita todas as acoes do mouse
set nu           "numeracao de linhas
set ts=4         "Seta onde o tab para
set sw=4         "largura do tab
set et           "espacos em vez de tab
set expandtab                   " Tabs are spaces, not tabs
set softtabstop=4               " Let backspace delete indent
set ai           "auto incrementa
set ic           "ignore case
set hls          "marca selecao busca
set incsearch
set magic
set bs=indent,eol,start
set laststatus=1
syntax on        "syntax highlight
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
color elflord

" Sets CursorLine color to a smooth background, no underline
highlight CursorLine   cterm=NONE ctermfg=NONE ctermbg=235 guibg=Grey40
highlight CursorColumn cterm=NONE ctermfg=NONE ctermbg=235 guibg=Grey48
set cursorline cursorcolumn     " Show a 'cross' that pinpoints to the cursor position
set splitright                  " New window on rightside when vsplit
set splitbelow                  " New window on bottomside when hsplit

" NetRW - vim file-system manager
let g:netrw_liststyle=3         " Sets Tree view as default
let g:netrw_browse_split=2      " When \<CR> a file, do a vsplit first
let g:netrw_altv=&spr           " Uses the 'splitright' value
let g:netrw_winsize=80          " Relativa (%) size of new window when 'o' or 'v'

" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,go,php,javascript,python,twig,xml,yml autocmd BufWritePre <buffer> call StripTrailingWhitespace()
autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
if has ('x') && has ('gui') " On Linux use + register for copy-paste
    set clipboard=unnamedplus
elseif has ('gui')          " On mac and Windows, use * register for copy-paste
    set clipboard=unnamed
endif

if has('cmdline_info')
    set ruler                   " Show the ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
    set showcmd                 " Show partial commands in status line and
                                " Selected characters/lines in visual mode
endif

if has('statusline')
    set laststatus=2

    " Broken down into easily includeable segments
    set statusline=%<%f\                               " Filename
    set statusline+=%w%h%m%r%q                         " Options
    set statusline+=\ %{fugitive#statusline()}         " Git Hotness
    set statusline+=\ [%Y\|%{&ff}\|%{&fenc!=''?&fenc:&enc}] " Filetype & encoding
    set statusline+=\ [%{getcwd()}]                    " Current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%            " Right aligned file nav info
    set statusline+=\ Chr\ %b                          " Current char ASCII (Dec)
    set statusline+=\ %{strftime(\"\|\ %d-%m-%y\ %H:%M\")}  " Current date-time

    let g:airline_theme='powerlineish'                 " airline users use the powerline theme
    let g:airline_powerline_fonts=1                    " and the powerline fonts
endif

set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
set nu                          " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=4                " Lines to scroll when cursor leaves screen
set scrolloff=2                 " Minimum lines to keep above and below cursor
set foldenable                  " Auto fold code
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" Stupid shift key fixes
if has("user_commands")
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Fix home and end keybindings for screen, particularly on mac
" - for some reason this fixes the arrow keys too. huh.
map [F $
imap [F $
map [H g0
imap [H g0

    " Initialize directories {
    function! InitializeDirectories()
        let parent = $HOME
        let prefix = 'vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory' }

        if has('persistent_undo')
            let dir_list['undo'] = 'undodir'
        endif
    " Setting up the directories {
        set backup                  " Backups are nice ...
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    "set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)

        " To specify a different directory in which to place the vimbackup,
        " vimviews, vimundo, and vimswap files/directories, add the following to
        " your .vimrc.local file:
        "   let g:spf13_consolidated_directory = <full path to desired directory>
        "   eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
        if exists('g:spf13_consolidated_directory')
            let common_dir = g:spf13_consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        endif

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'
            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif
            if !isdirectory(directory)
                echo "Warning: Unable to create backup directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " To disable the stripping of whitespace, add the following to your
        " .vimrc.local file:
        "   let g:spf13_keep_trailing_whitespace = 1
        if !exists('g:spf13_keep_trailing_whitespace')
            " Preparation: save last search, and cursor position.
            let _s=@/
            let l = line(".")
            let c = col(".")
            " do the business:
            %s/\s\+$//e
            " clean up: restore previous search history, and cursor position
            let @/=_s
            call cursor(l, c)
        endif
    endfunction
    " }


    filetype plugin indent on   " Automatically detect file types.

    " Finish local initializations {
call InitializeDirectories()
    " }
