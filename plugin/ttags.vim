" ttags.vim -- Tag list browser (List, filter, preview, jump to tags)
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-09.
" @Last Change: 2007-09-29.
" @Revision:    0.3.87
" GetLatestVimScripts: 2018 1 ttags.vim
"
" TODO:
" - Open in new window (split, vsplit, tab)
" - Fix preview

if &cp || exists("loaded_ttags")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 14
    echoerr 'tlib >= 0.14 is required'
    finish
endif
let loaded_ttags = 3

let s:save_cpo = &cpo
set cpo&vim

TLet g:ttags_kinds   = ''
TLet g:ttags_tags_rx = ''
TLet g:ttags_file_rx = ''

" :nodefault:
" This variable can be buffer local.
"
" Filetype specfic highlighting can be defined as 
" g:ttags_highlighting_{&filetype}.
TLet g:ttags_highlighting = {
            \ 'a': 'Type',
            \ 'c': 'Special',
            \ 'f': 'Identifier',
            \ 'F': 'Constant',
            \ 'v': 'Statement',
            \ 'm': 'PreProc',
            \ }

" :nodefault:
TLet g:ttags_world = {
            \ 'type': 'si',
            \ 'query': 'Select tags',
            \ 'pick_last_item': 0,
            \ 'scratch': '__tags__',
            \ 'return_agent': 'ttags#GotoTag',
            \ 'scratch_vertical': 1,
            \ 'key_handlers': [
                \ {'key': 16, 'agent': 'ttags#PreviewTag',  'key_name': '<c-p>', 'help': 'Preview'},
                \ {'key':  7, 'agent': 'ttags#GotoTag',     'key_name': '<c-g>', 'help': 'Jump (don''t close the list)'},
                \ {'key': 60, 'agent': 'ttags#GotoTag',     'key_name': '<',     'help': 'Jump (don''t close the list)'},
                \ {'key': 20, 'agent': 'ttags#InsertTemplate',  'key_name': '<c-t>', 'help': 'Insert template'},
            \ ],
            \ }


" :display: TTags[!] [KIND] [TAGS_RX] [FILE_RX]
" See also |ttags#List()|.
command! -nargs=* -bang TTags call ttags#List(0, <f-args>)

" With !, rebuild the tags list.
" command! -nargs=* -bang TTags call ttags#List(empty('<bang>'), <f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo

finish

:TTags [KIND] [TAGS_RX] [FILE_RX]
In order to match any kind/rx, use *.
E.g. TTags * * _foo.vim$

Features:
    - List tags
    - Filter tags matching a pattern
    - Jump/Preview tags
    - Insert tags (and a template for the argument list if supported by 
      tSkeleton, which has to be installed for this)

Suggested key maps: >

    noremap <Leader>g. :TTags<cr>
    noremap <Leader>g# :TTags * <c-r><c-w><cr>
    for c in split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')
        exec 'noremap <Leader>g'. c .' :TTags '. c .'<cr>'
    endfor

You can use :echo keys(ttags#Kinds())<cr> to find out which kinds are defined.


CHANGES
0.1
Initial release

0.2
- The kind argument was introduced (i.e. the argument list has changed)
- * was defined as "match any".

0.3
- Configuration via [wbg]:ttags_kinds, [wbg]:ttags_tags_rx, 
[wbg]:ttags_file_rx variables
- The list includes the kind identifier and the entries are highlighted 
(see g:ttags_highlighting)
- If tSkeleton (vimscript #1160) is installed and if g:tskelTypes 
contains "tags", <c-t> will insert the tag in the buffer including (if 
supported by tSkeleton for the current filetype) a template for the 
argument list.
- g:ttags_world can be a normal dictionary (use tlib#input#ListD instead
of #ListW)
- Require tlib 0.14

