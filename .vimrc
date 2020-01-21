"Marks Used
" `y - Used for cursor placement after yank

"Registries Used
" "x - Used for environment completion command for .tex files

"Function Keys Used
" F2 - Toggle Whitespace
" F3 - Toggle Filetree
" F5 - Save file and call 'make' in command line
" F6 - Like F5 but clears console beforehand
" F8 - Used to toggle colorcolumn

"Key Bindings
" ^B - Autocomplete LaTeX begin-end statement
" ^C - Clear searched text
" ^H - Move 1 window left
" ^J - Move 1 window down
" ^K - Move 1 window up
" ^L - Move 1 window right
" ^X - Close current tab
" ^? - Comment/Uncomment text
" H  - Move 1 tab left
" L  - Move 1 tab right
" KK - Exit insert mode

" Great Practical Ideas for Computer Scientists
" Sample .vimrc file


" Ensure that we are in modern vim mode, not backwards-compatible vi mode
set nocompatible
set backspace=indent,eol,start

"Viminfo Settings
set viminfo='50,<1000,s1000

" Helpful information: cursor position in bottom right, line numbers on
" left
set ruler
set number

"Enable filetype detection and syntax hilighting
syntax on
filetype on
filetype indent on
filetype plugin on

" Show multicharacter commands as they are being typed
set showcmd

"Disable modelines
set nomodeline

"Highlight current line
set cursorline

"No Wrapped Lines and Smooth Horizontal Scrolling
set nowrap
set sidescroll=1

"Disable auto-wrapping of lines for SML
autocmd FileType sml setlocal textwidth=0
autocmd FileType sml setlocal wrapmargin=0

"Indentation
set smartindent
autocmd FileType sml setlocal noexpandtab tabstop=2 softtabstop=2 shiftwidth=2
autocmd FileType python setlocal noexpandtab tabstop=4 softtabstop=4 shiftwidth=4
set tabstop=4
set noexpandtab
set softtabstop=0
set shiftwidth=4

"Shift Tab for Spaces
inoremap <S-Tab> <Space><Space><Space><Space>
autocmd FileType sml inoremap <S-Tab> <Space><Space>

"Searching
set incsearch "Search as you type
set hlsearch "Highlight matches
"Remove search highlight with Esc
nnoremap <C-c> :nohlsearch<CR>

set encoding=utf-8
scriptencoding utf-8
"Whitespace characters
set list lcs=tab:⸽\ 

"SML Whitespace
autocmd Filetype sml setlocal lcs=tab:-—
if has('patch-7.4.710')
	autocmd Filetype sml setlocal lcs=tab:-—,space:·
endif

"Toggle show whitespace
noremap <expr> <F2> &lcs == 'tab:-—' ? ':set lcs=tab:⸽\ <CR>' : ':set lcs=tab:-—<CR>'
if has('patch-7.4.710')
	noremap <expr> <F2> &lcs == 'tab:-—,space:·' ? ':set lcs=tab:⸽\ <CR>' : ':set lcs=tab:-—,space:·<CR>'
endif

"Move cursor past line end
set virtualedit=onemore

"Colorscheme
set background=dark
set t_Co=256
colorscheme monokai

"Filetree
let g:netrw_banner=0
let g:netrw_liststyle=3
let g:netrw_browse_split=3
let g:netrw_winsize = 20

noremap <F3> :tabdo silent! Lexplore<CR>

autocmd VimEnter * :Lexplore | wincmd p
autocmd TabNew * :Lexplore | wincmd p


"Compile with F5
autocmd Filetype c noremap <F5> :w<CR>:!make<CR>
autocmd Filetype cpp noremap <F5> :w<CR>:!./run %<CR>
if has('terminal')
	autocmd Filetype cpp noremap <F5> :w<CR>:below term bash ./run %<CR>
endif
autocmd Filetype html noremap <F5> :w<CR>:exe ':silent !google-chrome % &'<CR>:redraw!<CR>
"Clear and compile with F6
autocmd Filetype c noremap <F6> :w<CR>:!clear;make<CR>

"Remap window navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

"Terminal Window
if has('terminal')
	tnoremap <C-h> <C-w>h
	tnoremap <C-j> <C-w>j
	tnoremap <C-k> <C-w>k
	tnoremap <C-l> <C-w>l
endif
tnoremap <S-J><S-J> <C-w>N

"below terminal
"resize 10

"Remap tab navigation
noremap <S-H> gT
noremap <S-L> gt
noremap <C-X> :tabclose<CR>

"Tabline Customization

" set up tab labels with tab number, buffer name, number of windows
set showtabline=2
function MyTabLine()
	let s = '' " complete tabline goes here
	" loop through each tab page
	for t in range(tabpagenr('$'))
		" select the highlighting for the buffer names
		if t + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif
		" empty space
		let s .= ' '
		" set the tab page number (for mouse clicks)
		let s .= '%' . (t + 1) . 'T'
		" set page number string
		let s .= t + 1 . ' '
		" get buffer names and statuses
		let n = ''	"temp string for buffer names while we loop and check buftype
		let m = 0 " &modified counter
		let bc = len(tabpagebuflist(t + 1))	"counter to avoid last ' '
		" loop through each buffer in a tab
		for b in tabpagebuflist(t + 1)
			" buffer types: quickfix gets a [Q], help gets [H]{base fname}
			" others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
			if getbufvar( b, "&buftype" ) == 'help'
				let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
			elseif getbufvar( b, "&buftype" ) == 'quickfix'
				let n .= '[Q]'
			else
				let n = pathshorten(bufname(b))
				let n = fnamemodify(n, ':p:t')
				"let n .= bufname(b)
			endif
			" check and ++ tab's &modified count
			if getbufvar( b, "&modified" )
				let m += 1
			endif
			" no final ' ' added...formatting looks better done later
			if bc > 1
				let n .= ' '
			endif
			let bc -= 1
		endfor
		" add modified label [n+] where n pages in tab are modified
		if m > 0
			"let s .= '[' . m . '+]'
			let s.= '*'
		endif
		" add buffer names
		if n == ''
			let s .= '[No Name]'
		else
			let s .= n
		endif
		" switch to no underlining and add final space to buffer list
		let s .= ' '
	endfor
	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'
	" right-align the label to close the current tab page
	if tabpagenr('$') > 1
		let s .= '%=%#TabLine#%999XX'
	endif
	return s
endfunction

set tabline=%!MyTabLine()

"Command and Undo History
set history=1000
set undolevels=1000

"Persistent Undo
set undofile
set undodir=~/.vim/undodir/

"Load bashrc for vim shell
:set shellcmdflag=-ic

"Autocomplete Menu
set wildmenu

"Colorcolumn
set colorcolumn=81
"Toggle Colorcolumn
noremap <expr> <F8> &cc == '' ? ':set cc=81<CR>' : ':set cc=<CR>'

"Folding
set foldenable
set foldlevelstart=10
set foldnestmax=5
set foldmethod=indent
nnoremap <Space> za

"Remember folds on exit
augroup remember_folds
	autocmd!
	autocmd BufWinLeave * mkview
	autocmd BufWinEnter * silent! loadview
augroup END

"Keep cursor in place for yank
vnoremap y myy`y
vnoremap Y myY`y

"Put cursor at end of pasted text
noremap p gp<BS><Right>
noremap P gP<BS><Right>
noremap gp p
noremap gP P

"Keep highlighted text for indent shifting
vnoremap < <gv
vnoremap > >gv

"Automatch Braces
inoremap {<CR> {<CR>}<Esc>ko

"Block Comment/Uncomment
nnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '0:<S-Left>exe "<S-Right>normal! ".b:unCommentCommand<CR>' :
			\ '0:<S-Left>exe "<S-Right>normal! ".b:commentCommand<CR>'

vnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '0:<S-Left>exe "<S-Right>normal! ".b:unCommentCommand<CR>gv' :
			\ '0:<S-Left>exe "<S-Right>normal! ".b:commentCommand<CR>gv'

autocmd Filetype c,cpp,java let b:commentCommand='i//'   "Comment for '//' filetypes
autocmd Filetype c,cpp,java let b:unCommentCommand='^xx' "un-Comment for '//' filetypes
autocmd Filetype python,make let b:commentCommand='i#'    "Comment for '#' filetypes
autocmd Filetype python,make let b:unCommentCommand='^x'  "un-Comment for '#' filetypes
autocmd Filetype vim let b:commentCommand='i"'    "Comment for vim filetypes
autocmd Filetype vim let b:unCommentCommand='^x'  "un-Comment for vim filetypes
autocmd Filetype tex let b:commentCommand='i%'    "Comment for '%' filetypes
autocmd Filetype tex let b:unCommentCommand='^x'  "un-Comment for '%' filetypes
autocmd Filetype sml nnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '0xx$hxx' :
			\ '0i(*<Esc>$a*)<Esc>'
autocmd Filetype sml vnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '<Esc>`<xx`>hxhxgv' :
			\ '<Esc>`<i(*<Esc>`>a*)<Esc>gv'
autocmd Filetype html nnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '0xxxx$hhxxx' :
			\ ':set paste<CR>0i<lt>!--<Esc>$a--><Esc>:set nopaste<CR>'
autocmd Filetype html vnoremap <expr> <C-_> (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ '<Esc>`<xxxx`>hxhxhxgv' :
			\ '<Esc>`<i<lt>!--<Esc>`>a--><Esc>gv'

"Keep Comment Designators when using cc
autocmd Filetype c,cpp,java nnoremap <expr> cc (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ 'cc// ': 
			\ 'cc'
autocmd Filetype python,make nnoremap <expr> cc (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ 'cc# ': 
			\ 'cc'
autocmd Filetype vim nnoremap <expr> cc (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ 'cc" ': 
			\ 'cc'
autocmd Filetype tex nnoremap <expr> cc (synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ?
			\ 'cc% ': 
			\ 'cc'

"Default Tex Flavor
let g:tex_flavor = "latex"

"Autocomplete \begin Latex
autocmd FileType tex inoremap <C-B> <esc>:let@x=@"<CR>YpkI\begin{<esc>A}<esc>jI\end{<esc>A}<esc>:let@"=@x<CR>ko

"Remap Escape
inoremap <S-j><S-j> <esc>
"Visual Mode Remap Escape
vnoremap <C-c> <esc>
