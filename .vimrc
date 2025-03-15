let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
"
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
" Using a non-default branch
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
" Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf.vim'

" Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'
Plug 'junegunn/goyo.vim'
" Plug 'rizzatti/dash.vim'
" Plug 'plasticboy/vim-markdown'
" Plug 'preservim/tagbar'
Plug 'tpope/vim-surround'
 "Plug 'itchyny/lightline.vim'
" Plug 'frazrepo/vim-rainbow'
" Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
" Plug 'vim-ruby/vim-ruby'
" Plug 'tpope/vim-rails'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'


" Initialize plugin system
call plug#end()

let g:rainbow_active = 1

" Change Cursor in 'INSERT MODE' into a line
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

set ttimeout
set ttimeoutlen=1
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.
set ttyfast

" Show Line Number
:set number   

set laststatus=2
set showmode
set showcmd

" Display 5 lines above/below the cursor when scrolling with a mouse.
set scrolloff=5

" LightLine Color Scheme
" let g:lightline = {
"       \ 'colorscheme': 'Tomorrow_Night_Blue',
"       \ }

:set autochdir

" Disable Folding
" let g:vim_markdown_folding_disabled = 1

" Syntax extensions

let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2

let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_override_foldtext = 0
map ge <Plug>Markdown_EditUrlUnderCursor

let g:markdown_minlines = 100

" Enable fenced code block syntaxes
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'javascript']

" Disable markdown syntax concealing
" let g:markdown_syntax_conceal = 1
" let g:vim_markdown_conceal = 1
set conceallevel=2
" Dont require .md extensions for Markdown links
let g:vim_markdown_no_extensions_in_markdown = 1
"Auto-write when following link

" Indentation with only spaces
set expandtab
set shiftwidth=2
set softtabstop=2

" Concealing Characters in Javascript
let g:javascript_conceal_function             = "ƒ"
let g:javascript_conceal_null                 = "ø"
let g:javascript_conceal_this                 = "@"
let g:javascript_conceal_return               = "⇚"
let g:javascript_conceal_undefined            = "¿"
let g:javascript_conceal_NaN                  = "ℕ"
let g:javascript_conceal_prototype            = "¶"
let g:javascript_conceal_static               = "•"
let g:javascript_conceal_super                = "Ω"
let g:javascript_conceal_arrow_function       = "⇒"
let g:javascript_conceal_noarg_arrow_function = "🞅"
let g:javascript_conceal_underscore_arrow_function = "🞅"

" Set the color of the Line Number to grey
:highlight LineNr ctermfg=grey

" Change the vertical separator
" set fillchars+=vert:│

" Invert color of separator and its bg
hi VertSplit term=NONE ctermfg=NONE ctermbg=NONE guibg=NONE

" Tagbar
nmap <F8> :TagbarToggle<CR>
nmap <C-p> :NERDTreeToggle<CR>

noremap <S-j> gT
noremap <S-k> gt

noremap <silent> <C-j> 4j
noremap <silent> <C-k> 4k

noremap <silent> <C-h> 4h
noremap <silent> <C-l> 4l

" Netrw hierarchy lines
" let g:netrw_liststyle = 2
nmap <D-e> :NERDTreeToggle<CR>

" FZF and ripgrep
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>

" set fzf to use ripgrep by default
set rtp+=/opt/homebrew/opt/fzf

" Highlight trailing whitespaces
" set lcs+=space:·
" match ExtraWhitespace /\s\+$/
" highlight ExtraWhitespace ctermbg=red guibg=red


" Highlight matching search patterns
set hlsearch

" Insert current date/time
:inoremap <F5> <C-R>=strftime("%a, %d %b %Y %H:%M:%S")<CR>

" let macvim_skip_colorscheme=1

" Goyo config
" get g:goyo_width 120
" get g:goyo_height 85%

