" ttags.vim -- A simple tags list
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-09.
" @Last Change: 2007-09-11.
" @Revision:    0.1.37
" GetLatestVimScripts: 0 1 ttags.vim

if &cp || exists("loaded_ttags")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 12
    echoerr 'tlib >= 0.12 is required'
    finish
endif
let loaded_ttags = 1

let s:save_cpo = &cpo
set cpo&vim


TLet g:ttags_world = tlib#World#New({
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
                \ ],
            \ })


" :display: TTags[!] [TAGS_RX] [FILE_RX]
" See also |ttags#List()|.
command! -nargs=* -bang TTags call ttags#List(0, <f-args>)

" With !, rebuild the tags list.
" command! -nargs=* -bang TTags call ttags#List(empty('<bang>'), <f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo

finish
:TTags [TAGS_RX] [FILE_RX]

Features:
    - List tags
    - Filter tags matching a pattern
    - Jump/Preview tags

Suggested key maps:
noremap <m-g>     :TTags<cr>
noremap <Leader>g :TTags<cr>
noremap <Leader>G :TTags <c-r><c-w><cr>


CHANGES
0.1
Initial release

