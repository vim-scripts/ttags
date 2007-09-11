" ttags.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-09.
" @Last Change: 2007-09-09.
" @Revision:    63

if &cp || exists("loaded_ttags_autoload")
    finish
endif
let loaded_ttags_autoload = 1

let s:tags = {}


" :def: function! ttags#List(use_cache, ?rx='', ?file_rx='')
function! ttags#List(use_cache, ...) "{{{3
    TVarArg 'rx', 'file_rx'
    " TLogVAR rx, file_rx
    let world  = copy(g:ttags_world)
    let tagsid = string(tagfiles())
    if !a:use_cache || empty(get(s:tags, tagsid))
        let s:tags[tagsid] = taglist('.')
    else
        " TLogDBG 'Use cache for: '. tagsid
    endif
    let world.tags = s:tags[tagsid]
    if !empty(rx)
        call filter(world.tags, 'v:val.name =~ rx')
    endif
    if !empty(file_rx)
        call filter(world.tags, 'v:val.filename =~ file_rx')
    endif
    " TLogVAR world.tags
    if !empty(world.tags)
        let world.base = map(copy(world.tags), 'printf("%-20s %s @%s", v:val.name, fnamemodify(v:val.filename, ":t"), fnamemodify(v:val.filename, ":p:h"))')
        " TLogVAR world.base
        if tlib#cmd#UseVertical('TTags')
            let world.scratch_vertical = 1
        endif
        if world.scratch_vertical
            let sizes = map(copy(world.base), 'len(matchstr(v:val, ''^.\{-}\ze@''))')
            let world.resize_vertical = max(sizes) + len(len(world.base)) + 2
        endif
        call tlib#input#ListW(world)
    else
        echohl Error
        echom 'ttags: No tags'
        echohl NONE
    endif
endf


function! s:ShowTag(world, tagline) "{{{3
    let tag = a:world.tags[a:world.GetBaseIdx(a:tagline) - 1]
    " TLogVAR tag.filename
    call tlib#file#With('edit', 'buffer', [tag.filename], a:world)
    " TLogVAR tag.cmd
    exec tag.cmd
    norm! zz
    redraw
    " call tlib#buffer#HighlightLine(line('.'))
endf


function! ttags#PreviewTag(world, selected) "{{{3
    let back = a:world.SwitchWindow('win')
    call s:ShowTag(a:world, a:selected[0])
    exec back
    let a:world.state = 'redisplay'
    return a:world
endf


function! ttags#GotoTag(world, selected) "{{{3
    if !empty(a:selected)
        if a:world.win_wnr != winnr()
            let world = tlib#agent#Suspend(a:world, a:selected)
            exec a:world.win_wnr .'wincmd w'
        endif
        call s:ShowTag(a:world, a:selected[0])
    endif
    return a:world
endf


