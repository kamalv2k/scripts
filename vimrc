"
" @(#)	This is vimrc for vim/gvim.
"		This vimrc file will automatically configure itself based on
"		the system it runs on (Windows/Unix).
"		This vimrc file has been tested on SPARC/Solaris, Intel/Linux
"		and Windows NT/ME
"
"		Config Notes:
"		Unix:
"			1. Create a directory: ~/vimtmp and move .viminfo there
"			2. Link: ln -s .vimrc .gvimrc	
"			3. If gvim is executed, .vimrc will be executed twice.
"			   First as .vimrc and then as .gvimrc. This is good!
"		Windows:
"			1. Create a directory: $HOME\vimtmp
"			2. Move .viminfo (if it exists) to $HOME\vimtmp	
"			3. Name .vimrc as _vimrc in $HOME 	
"
"			   Make sure there is no _gvimrc in $HOME. This creates a conflict.	
"			4. Optional. In the Windows Global settings below, change the preferences
"			   to suit your needs.
"
" @(#)	01/07/25-03/07/21 xaos@darksmile.net, "http://www.darksmile.net/vimindex.html"
"
" Windows Global Settings. Font and scheme preferences
"
let mywinfont="Lucida_Console:h12:cANSI"
let $myscheme=$VIMRUNTIME . '\colors\koehler.vim'
let $myxscheme=$VIMRUNTIME . '/colors/koehler.vim'
"
" If full gui has been reached then run these additional commands. Unix only!
"
let myfiletypefile = "$HOME/myvim/ftypes.vim"
let mysyntaxfile = "$HOME/myvim/lexcol.vim"
if has("gui_running") && &term == "builtin_gui"
	if &syntax == "" && isdirectory($VIMRUNTIME)
		syntax on
		set hlsearch
	endif
	map <F37> :set list!
	imap <F37> :set list!a
	highlight Normal guibg=white
	highlight Cursor guibg=green guifg=NONE
	set guifont=-schumacher-clean-medium-r-normal-*-*-160-*-*-c-*-iso646.1991-irv
	"
	" This is also nice. Run as :F2 to change font
	command! F2 set guifont=-dec-terminal-medium-r-wide-*-*-140-*-*-c-*-iso8859-1
	if filereadable( $myxscheme )
		source $myxscheme
	endif
else
	"
	" This needs to be set up front
	"
	set nocompatible
	"
	" Set up according to platform
	" 
	if has("win32") || has("win16")
		let osys="windows"
		behave mswin
		source $VIMRUNTIME/mswin.vim
	else
		let osys=system('uname -s')
		"
		" What was the name that we were called as?
		"
		let vinvoke=fnamemodify($_, ":p")
		let fullp=substitute(vinvoke, '^\(.*[/]\).*$', '\1', "")
		"
		" It's possible that $VIMRUNTIME does not exist.
		" Let's see if there is a dir vimshare below where we were started
		"
		if isdirectory($VIMRUNTIME) == 0
			let vimshare=fullp . "vimshare"
			if isdirectory(vimshare) == 1
				let $VIMRUNTIME=vimshare . "/vim" . substitute(v:version, "50", "5", "")
				let &helpfile=vimshare . "/vim" . substitute(v:version, "50", "5", "") . "/doc/help.txt"
			endif
		endif
	endif
	if &t_Co > 2
		set bg=dark
		syntax on
		set nohlsearch
		highlight Comment term=bold ctermfg=2
		highlight Constant term=underline ctermfg=7
	endif
	if osys == "windows" && has("gui_running")
		syntax on
		set hlsearch
		let &guifont=mywinfont
		if filereadable( $myscheme )
			source $myscheme
		endif
	endif
	if version >= 600
		filetype plugin indent on
		autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif 
		"
		" fold options
		"
		"set foldmethod=indent
		"set foldmethod=expr
		"set foldexpr=getline(v:lnum)[0]==\"\\t\"
	else
		autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif
	endif
	"
	" Find out where the backups and viminfo are kept
	" If term is blank at this point, this must be a windows system
	"
	if osys == "windows"
		let vimtdir=$HOME . '\vimtmp'
		if isdirectory(vimtdir) == 0
			let vimtdir=$HOME
		endif 
		let &viminfo="'20," . '%,n' . vimtdir . '\.viminfo'
	else
		let myuid=substitute(system('id'), '^uid=\([0-9]*\)(.*', '\1', "")
		let vimtdir=$HOME . '/vimtmp'
		if isdirectory(vimtdir) == 0
			let vimtdir=$HOME
		endif 
		if myuid == "0" && osys =~ "SunOS"
			let vimtdir='/var/vimtmp'
		endif
		let &viminfo="'20," . '%,n' . vimtdir . '/.viminfo'
		"
		" Setup a proper include file path
		"
		if $INCLUDE == ""
			if osys =~ "SunOS"
				let &path="/usr/include,/usr/openwin/include,/usr/dt/include,/usr/local/include"
			else
				let &path="/usr/include,/usr/X11R6/include,/usr/openwin/include,/usr/local/include"
			endif
		else
			let &path=substitute($INCLUDE, ':', ',', "g")
		endif
	endif
	set backup
	let &backupdir=vimtdir
	set history=100
	set number
	set nowrap
	set tabstop=4
	set shiftwidth=4
	set statusline=%<%F%h%m%r%=\[%B\]\ %l,%c%V\ %P
	set laststatus=2
	set showcmd
	set gcr=a:blinkon0
	set errorbells
	set visualbell
	set nowarn
	set ignorecase
	set smartcase
	"
	" The following function and maps allow for [[ and ]] to search for a
	" single char under the cursor.
	" 
	function Cchar()
		let c = getline(line("."))[col(".") - 1]
		let @/ = c
	endfunction
	map [[ :call Cchar()n
	map ]] :call Cchar()N
	"
	" Use F4 to switch between hex and ASCII editing
	"
	function Fxxd()
		let c=getline(".")
		if c =~ '^[0-9a-f]\{7}:'
			:%!xxd -r
		else
			:%!xxd -g4
		endif
	endfunction
	map <F4> :call Fxxd()
	map  gf
	if &term == "xterm"
		" Delete
		map  x
		" End
		map [26~ 100%
		" Home
		map [25~ :1
		" F2
		map [12~ :w
		imap [12~ :wi
		" F3
		map [13~ :q
		imap [13~ :q
		" F10
		map [21~ :wq!
		imap [21~ :wq!
		" F11
		map [24~ :set list!
		imap [24~ :set list!i
	else
		if osys != "windows" 
			map [3~ x	" Delete
			imap [3~  
			map [2~ i		" Insert
			imap [2~ 
			map [4~ 100%	" End
			map [1~ :1	" Home
			map [5~ 	" PgUp
			map [6~ 	" PgDn
			map [[A :h		" F1
			map [28~ :h 
		endif
	endif
	map <F2> :w
	imap <F2> :wa
	map <F3> :q
	imap <F3> :q
	map <F10> :wq!
	imap <F10> :wq!
endif
"
" Some commands which must be run twice!
" 
if version >= 600
	set cmdwinheight&
endif
set cmdheight&
