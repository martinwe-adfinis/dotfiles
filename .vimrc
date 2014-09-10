" Vim configuration file
" Initially written by ayekat in a snowy day in january 2010

" ------------------------------------------------------------------------------
" GENERAL {{{

" No compatibility with vi for tasty features:
set nocompatible

" }}}
" ------------------------------------------------------------------------------
" BUNDLES {{{

" Initialise and bootstrap NeoBundle (here goes my thanks to flor):
if has('vim_starting')
	set runtimepath+=~/.vim/bundle/neobundle/
	if !isdirectory(glob('~/.vim/bundle/neobundle'))
		!mkdir -p ~/.vim/bundle/neobundle && git clone 'https://github.com/Shougo/neobundle.vim.git' ~/.vim/bundle/neobundle
	endif
endif
call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle handle itself:
NeoBundleFetch 'Shougo/neobundle.vim'

" Bundles I use:
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'spolu/dwm.vim'
NeoBundle 'ayekat/dwm_fix.vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'vim-scripts/glsl.vim'
NeoBundle 'Matt-Stevens/vim-systemd-syntax'
NeoBundle 'vim-scripts/bbcode'
NeoBundleCheck

" Disable scala and java syntax checkers, as they are slow as hell:
let g:syntastic_java_checkers = []
let g:syntastic_scala_checkers = []

" Disable LaTeX style warnings:
let g:syntastic_tex_chktex_args = '-m'

" Change Sytastic symbols:
let g:syntastic_warning_symbol = '!!'
let g:syntastic_error_symbol = 'XX'

" Don't make unite overwrite the statusline:
let g:unite_force_overwrite_statusline = 0

" Don't use default keybindings of DWM plugin:
let g:dwm_map_keys = 0

" Further settings are defined in the 'behaviour' part.

" }}}
" ------------------------------------------------------------------------------
" LOOK {{{

" Enable 256 colours mode (we handle the TTY case further below):
set t_Co=256

" Display and format line numbers:
set number
set numberwidth=5

" Enable UTF-8 (I wanna see Umlauts!):
set encoding=utf8

" SPLIT WINDOWS >
	
	if $TERM == 'linux'
		set fillchars=vert:.
	else
		set fillchars=vert:┃
	endif
	

" FOLDING >

	" Fill characters (space=don't fill up):
	set fillchars+=fold:\ 

	" Autofold (except in git commit message):
	set foldmethod=marker
	au FileType gitcommit set foldmethod=manual


" PROGRAMMING >

	" Without any syntax highlighting, programming is a pain:
	syntax on

	" Fix unrecognised file types:
	au BufRead,BufNewFile *.md set filetype=markdown
	au BufRead,BufNewFile *.tex set filetype=tex
	au BufRead,BufNewFile *.xbm set filetype=c
	au BufRead,BufNewFile *.frag,*.vert,*.geom,*.glsl set filetype=glsl
	au BufRead,BufNewFile dunstrc,redshift.conf set filetype=cfg
	au BufRead,BufNewFile *.target set filetype=systemd
	au BufRead,BufNewFile */etc/iptables/*.rules set filetype=sh

	" Assembly:
	let asmsyntax='nasm'

	" C:
	let c_no_curly_error=1 " Allow {} inside [] and () (non-ANSI)
	let c_space_errors=1   " Highlight trailing spaces and spaces before tabs
	let c_syntax_for_h=1   " Treat .h as C header files (instead of C++)

	" Make:
	let make_no_commands=1 " Don't highlight commands

	" PHP:
	"let php_sql_query=1    " Highlight SQL syntax inside strings
	"let php_htmlInStrings=1         " HTML syntax inside strings

	" Shell:
	let g:is_posix=1       " /bin/sh is POSIX shell, not deprecated Bourne shell

	" Display a bar after a reasonable number of columns:
	if version >= 703
		set colorcolumn=81
		au FileType mail,gitcommit set colorcolumn=73
		au FileType java set colorcolumn=121
		au FileType asm set colorcolumn=41,81
	endif

	" I wanna see tabs and trailing whitespaces:
	set list
	set listchars=tab:→\ ,trail:·

	" Highlight matching parentheses:
	set showmatch

" }}}
" ------------------------------------------------------------------------------
" BEHAVIOUR {{{

" Leader key:
let mapleader='ö'

" Keep 3 lines 'padding' above/below the cursor:
set scrolloff=3

" Simplify window scrolling:
map K 3<C-y>
map J 3<C-e>

" Easier to access 'back to beginning of line':
map ä 0

" Modelines are evil!
set nomodeline

" Fix trailing whitespaces:
function! StripTrailingWhitespaces()
	let _s=@/
	let l=line('.')
	let c=col('.')
	%s/\s\+$//eg
	call cursor(l,c)
	let @/=_s
endfunction
au FileType c,java,php,sh,perl,sql,glsl,cpp au BufWritePre <buffer> :call StripTrailingWhitespaces()

" Save the undo tree between edit:
if v:version >= 703
	if ! isdirectory($HOME . "/.vim/undo")
		call mkdir($HOME . "/.vim/undo", "p")
		!chmod 700 -R ~/.vim/undo
	endif
	set undofile
	" Save it in ~/.vim/undo/ if possible, otherwise same dir as edited file
	set undodir=$HOME/.vim/undo,.
endif

" Make sure we don't generate undofiles for certain files:
if has("autocmd")
	autocmd BufWritePre /tmp/* setlocal noundofile
	autocmd BufWritePre /dev/shm/* setlocal noundofile
	autocmd BufWritePre /run/shm/* setlocal noundofile
endif


" INSERT MODE >

	" By default, use tabs instead of spaces, and 4 character wide tabs:
	set noexpandtab shiftwidth=4 tabstop=4
	au FileType c set tabstop=8 shiftwidth=8
	au FileType tex,scala set expandtab tabstop=2 shiftwidth=2
	au FileType java,ant,haskell,sql set expandtab

	" Auto-indent, and reuse the same combination of spaces/tabs:
	set autoindent
	set copyindent
	filetype plugin indent on

	" Visually wrap lines (except in Java), and break words:
	set wrap
	au FileType java set nowrap
	set linebreak      " wrap at words (does not work with list)

	" Physically wrap lines for certain file types:
	au FileType tex,html,php,markdown set textwidth=80
	au FileType gitcommit set textwidth=72

	" Remove delay for leaving insert mode:
	set noesckeys

" NORMAL MODE >

	" Display commands when typing:
	set showcmd

	" Highlight search results and display them immediately as they are typed:
	set hlsearch
	set incsearch

	" Ignore case when searching, except when explicitely using majuscules:
	set ignorecase
	set smartcase

	" Moving the cursor on visual lines is much more intuitive with 'g':
	map k gk
	map j gj

	" Word-breaking characters:
	set iskeyword-=[.]

" FANCY IDE-LIKE:

	" Show command history:
	nnoremap ; q:
	vnoremap ; q:

	" Show 10 last commands in the window
	set cmdwinheight=10

	" Unite window:
	map <leader>n :Unite file<CR>

	" Search for tags file recursively, up to root:
	set tags=./tags;/

" DWM:

	map <leader>j <C-w>w
	map <leader>k <C-w>W
	map <leader><Space> :call DWM_Focus()<CR>

" }}}
" ------------------------------------------------------------------------------
" COLOUR SCHEME {{{

" Make visual less penetrant:
hi Visual cterm=inverse ctermbg=0

" Non-printable characters (tabs, spaces, special keys):
hi SpecialKey cterm=bold ctermfg=238

" Matching parentheses:
hi MatchParen cterm=bold ctermfg=4 ctermbg=none

if $TERM != "linux"
	" Custom colour scheme for X vim {{{
	" Dropdown menu:
	hi Pmenu      ctermfg=244 ctermbg=234
	hi PmenuSel   ctermfg=45  ctermbg=23
	hi PmenuSbar              ctermbg=234
	hi PmenuThumb             ctermbg=31

	" Folding:
	hi Folded ctermfg=248 ctermbg=0 cterm=none

	" Separate normal text from non-file-text:
	"hi Normal                 ctermbg=234
	hi NonText    ctermfg=0   ctermbg=232 cterm=bold
	"
	" Window separator:
	hi VertSplit  ctermfg=0 ctermbg=0
	"
	" Line numbers and syntastic column:
	hi SignColumn ctermbg=none
	hi LineNr     ctermbg=0

	" 80 columns indicator:
	hi ColorColumn ctermbg=235

	" Search:
	hi Search             ctermfg=0  ctermbg=136

	" Diffs:
	hi DiffAdd            ctermfg=46  ctermbg=22
	hi DiffChange         ctermfg=45  ctermbg=24
	hi DiffDelete         ctermfg=52  ctermbg=232
	hi DiffText           ctermfg=226 ctermbg=94 cterm=none

	" Syntax:
	hi Comment            ctermfg=243
	hi Constant           ctermfg=34
		" any constant | string | 'c' '\n' | 234 0xff | TRUE false | 2.3e10
		"hi String         ctermfg=
		"hi Character      ctermfg=
		"hi Number         ctermfg=
		"hi Boolean        ctermfg=
		"hi Float          ctermfg=
	hi Identifier         ctermfg=169
		" any variable name | function name (also: methods for classes)
		"hi Function       ctermfg=
	hi Statement          ctermfg=172
		" any statement | if then else endif switch | for do while |
		" case default | sizeof + * | any other keyword | exception
		"hi Conditional
		"hi Repeat
		"hi Label
		"hi Operator
		"hi Keyword
		"hi Exception
	hi PreProc            ctermfg=169
		" any preprocessor | #include | #define | macro | #if #else #endif
		"hi Include
		"hi Define
		"hi Macro
		"hi PreCondit
	hi Type               ctermfg=38
		" int long char | static register volatile | struct union enum | typedef
		"hi StorageClass
		"hi Structure
		"hi Typedef
	hi Special            ctermfg=136
		"hi SpecialChar
		"hi Tag
		"hi Delimiter
		"hi SpecialComment
		"hi Debug
	" TODO
	hi Todo               ctermfg=148 ctermbg=22
	hi Error              ctermfg=88 ctermbg=9 cterm=bold
		"hi SyntasticErrorSign
	" }}}
else
	" Custom colour scheme for TTY vim {{{
	set background=light

	" Window separator:
	hi VertSplit ctermfg=4 ctermbg=4 cterm=none

	" Folding:
	hi Folded ctermfg=3 ctermbg=8 cterm=none

	" Line numbers:
	hi LineNr ctermfg=3 ctermbg=0

	" Search:
	hi Search             ctermfg=0  ctermbg=3

	" Syntax:
	hi Statement ctermfg=3
	hi Todo ctermbg=3
	" }}}
endif


" }}}
" ------------------------------------------------------------------------------
" STATUSLINE {{{
" Written by ayekat on a cold day in december 2012, updated in december 2013

" Always display the statusline:
set laststatus=2

" Don't display the mode in the ruler; we display it in the statusline:
set noshowmode

" Separators {{{
if $TERM == "linux"
	let sep="|"
	let lnum="LN"
	let branch="|'"
else
	let sep="┃"
	let lnum="␤"
	let branch="ᚴ"
endif " }}}

" Colours {{{
if $TERM == 'linux'
	hi StatusLine   ctermfg=0 ctermbg=7 cterm=none
	hi StatusLineNC ctermfg=7 ctermbg=4 cterm=none
else
	" normal statusline:
	hi N_mode           ctermfg=22  ctermbg=148
	hi N_git_branch     ctermfg=7   ctermbg=8
	hi N_git_sep        ctermfg=236 ctermbg=8
	hi N_file           ctermfg=247 ctermbg=8
	hi N_file_emphasise ctermfg=7   ctermbg=8
	hi N_file_modified  ctermfg=3   ctermbg=8
	hi N_middle         ctermfg=244 ctermbg=236
	hi N_middle_sep     ctermfg=8   ctermbg=236
	hi N_warning        ctermfg=1   ctermbg=236
	hi N_pos            ctermfg=11  ctermbg=8
	hi N_cursor         ctermfg=0   ctermbg=7
	hi N_cursor_line    ctermfg=236 ctermbg=7
	hi N_cursor_col     ctermfg=8   ctermbg=7

	hi V_mode           ctermfg=52  ctermbg=208

	hi I_mode           ctermfg=8   ctermbg=7
	hi I_git_branch     ctermfg=7   ctermbg=31
	hi I_git_sep        ctermfg=23  ctermbg=31
	hi I_file           ctermfg=249 ctermbg=31
	hi I_file_emphasise ctermfg=7   ctermbg=31
	hi I_file_modified  ctermfg=3   ctermbg=31
	hi I_middle         ctermfg=45  ctermbg=23
	hi I_middle_sep     ctermfg=31  ctermbg=23
	hi I_warning        ctermfg=1   ctermbg=23
	hi I_pos            ctermfg=11  ctermbg=31

	" command statusline:
	hi cmd_mode              ctermfg=15  ctermbg=64
	hi cmd_info              ctermfg=7   ctermbg=0

	" cursor:
	hi CursorLine                        ctermbg=235 cterm=none
	hi CursorLineNr          ctermfg=45  ctermbg=23

	" default statusline:
	hi StatusLine            ctermfg=0   ctermbg=236 cterm=none
	hi StatusLineNC          ctermfg=8   ctermbg=236 cterm=none
endif
" }}}

" Active Statusline {{{
function! StatuslineActive()
	let l:statusline = ''
	let l:mode = mode()
	let l:unite = unite#get_status_string()
	let l:git_branch = fugitive#head()

	" Mode {{{
	if l:mode ==? 'v' || l:mode == ''
		let l:statusline .= '%#V_mode#'
		if l:mode ==# 'v'
			let l:statusline .= ' VISUAL '
		elseif l:mode ==# 'V'
			let l:statusline .= ' V·LINE '
		else
			let l:statusline .= ' V·BLOCK '
		endif
	elseif l:mode == 'i'
		let l:statusline .= '%#I_mode# INSERT '
	else
		let l:statusline .= '%#N_mode# NORMAL '
	endif
	" }}}

	" Git {{{
	if l:git_branch != ''
		if l:mode == 'i'
			let l:statusline .= '%#I_git_branch#'
		else
			let l:statusline .= '%#N_git_branch#'
		endif
		let l:statusline .= ' %{branch} '.l:git_branch
		if l:mode == 'i'
			let l:statusline .= ' %#I_git_sep#%{sep}'
		else
			let l:statusline .= ' %#N_git_sep#%{sep}'
		endif
	endif " }}}

	" Filename {{{
	if l:mode == 'i'
		let l:statusline .= '%#I_file#'
	else
		let l:statusline .= '%#N_file#'
	endif
	let l:statusline.=' %<%{expand("%:p:h")}/'
	if l:mode == 'i'
		let l:statusline.='%#I_file_emphasise#'
	else
		let l:statusline.='%#N_file_emphasise#'
	endif
	let l:statusline.='%{expand("%:t")} '
	" }}}

	" Modified {{{
	if &modified
		if l:mode == 'i'
			let l:statusline .= '%#I_file_modified#'
		else
			let l:statusline .= '%#N_file_modified#'
		endif
		let l:statusline .= '* '
	endif
	" }}}

	if l:mode == 'i'
		let l:statusline .= '%#I_middle# '
	else
		let l:statusline .= '%#N_middle# '
	endif

	" Readonly {{{
	if &readonly
		if l:mode == 'i'
			let l:statusline .= ' %#I_warning#X%#I_middle#'
		else
			let l:statusline .= ' %#N_warning#X%#N_middle#'
		endif
	endif
	" }}}

	" Unite.vim {{{
	if l:unite != ''
		let l:statusline .= ' '.l:unite
	endif
	" }}}

	let l:statusline .= '%='

	" File format, encoding, type, line count {{{
	if l:unite == ''
		let l:ff = &fileformat
		let l:fe = &fileencoding
		let l:ft = &filetype
		if l:ff != 'unix' && l:ff != ''
			if l:mode == 'i'
				let l:statusline .= l:ff.' %#I_middle_sep#%{sep}%#I_middle#'
			else
				let l:statusline .= l:ff.' %#N_middle_sep#%{sep}%#N_middle#'
			endif
		endif
		if l:fe != 'utf-8' && l:fe != 'ascii' && l:fe != ''
			if l:mode == 'i'
				let l:statusline .= l:fe.' %#I_middle_sep#%{sep}%#I_middle#'
			else
				let l:statusline .= l:fe.' %#N_middle_sep#%{sep}%#N_middle#'
			endif
		endif
		if l:ft != ''
			if l:mode == 'i'
				let l:statusline .= l:ft.' %#I_middle_sep#%{sep}%#I_middle#'
			else
				let l:statusline .= l:ft.' %#N_middle_sep#%{sep}%#N_middle#'
			endif
		endif
		let l:statusline .= ' %{lnum} %L '
	endif
	" }}}

	" Buffer position {{{
	if l:mode == 'i'
		let l:statusline .= '%#I_pos#'
	else
		let l:statusline .= '%#N_pos#'
	endif
	let l:statusline .= ' %P '
	" }}}

	" Cursor position {{{
	let l:statusline .= '%#N_cursor_line# %3l'
	let l:statusline .= '%#N_cursor_col#:%02c %#N_middle#'
	" }}}

	return l:statusline
endfunction
" }}}

" Inactive Statusline {{{
function! StatuslineInactive()
	let l:statusline = ''
	let l:branch = fugitive#head()
	let l:unite = unite#get_status_string()

	" mode:
	let l:statusline .= '        %{sep}'

	" filename:
	let l:statusline.=' %<%t %{sep}'

	" change to the right side:
	let l:statusline.='%='

	" line count:
	let l:statusline .= ' %{lnum} %L '

	" buffer position:
	let l:statusline.='%{sep} %P '

	" cursor position:
	let l:statusline .= '%{sep} %3l:%02c '

	return l:statusline
endfunction " }}}

function! StatuslineCommand() " {{{
	return '%#cmd_mode# COMMAND %#cmd_mode_end#%{rfsep}'
endfunction " }}}

" define when which statusline is displayed:
au! BufEnter,WinEnter * setl statusline=%!StatuslineActive()
au! BufLeave,WinLeave * set  statusline=%!StatuslineInactive()
au! CmdwinEnter       * setl statusline=%!StatuslineCommand()

" }}}
" ------------------------------------------------------------------------------
" LINE NUMBERS {{{
" Make line number design change as a function of mode.

if $TERM != 'linux'
	function! SetLineNr(mode)
		if a:mode == 'v'
			hi LineNr ctermfg=172
		else
			hi LineNr ctermfg=242
		endif
	endfunction

	" insert mode:
	au! InsertEnter * set cursorline | call SetLineNr('i')
	au! InsertLeave * set nocursorline

	" visual mode (ugly, since there is no VisualEnter/VisualLeave):
	noremap <silent> v :call SetLineNr('v')<CR>v
	noremap <silent> V :call SetLineNr('v')<CR>V
	noremap <silent> <C-v> :call SetLineNr('v')<CR><C-v>
	set updatetime=0
	au! CursorHold * call SetLineNr('n')
endif

" }}}
" ------------------------------------------------------------------------------
" MISC {{{
" Rather temporary settings, but they remain for like half a year (often for
" EPFL courses).

au! BufEnter /home/ayekat/epfl/cg/{*.c,*.h,*.vert,*.geom,*.frag} set expandtab
au! BufEnter /home/ayekat/epfl/blitzview-report/*.tex set formatoptions+=l
" }}}
