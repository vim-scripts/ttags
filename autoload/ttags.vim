" ttags.vim
" @Author:      Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-09.
" @Last Change: 2007-09-29.
" @Revision:    144

if &cp || exists("loaded_ttags_autoload")
    finish
endif
let loaded_ttags_autoload = 1

let s:tags = {}


function! ttags#Kinds(...) "{{{3
    TVarArg ['tags', []]
    if empty(tags)
        let tags = taglist('.')
    end
    let kinds = {}
    for t in tags
        let k = t.kind
        if !empty(k)
            if has_key(kinds, k)
                let kinds[k].n += 1
            else
                let kinds[k] = {'n': 0, 'sample': t}
            endif
        else
            " TLogDBG 'Empty kind: '. string(t)
        endif
    endfor
    return kinds
endf


function! ttags#Highlight(tags) "{{{3
    let kinds = sort(keys(ttags#Kinds(a:tags)))
    let acc = []
    let hv = tlib#var#Get('ttags_highlighting_'. &filetype, 'bg', tlib#var#Get('ttags_highlighting', 'bg'))
    " TLogVAR hv
    for kind in kinds
        let hi = get(hv, kind)
        " TLogVAR hi
        if !empty(hi)
            if kind ==# toupper(kind)
                let kindg = kind.kind
            else
                let kindg = kind
            end
            call add(acc, 'syn match TTags_'. kindg .' /\C'. kind .': \zs\S\+/')
            call add(acc, 'hi def link TTags_'. kindg .' '. hi)
        endif
    endfor
    let acc += [
                \ 'syn match TTags_source / @\zs.*$/',
                \ 'hi def link TTags_source Directory'
                \ ]
    " TLogVAR acc
    return join(acc, ' | ')
endf


" :def: function! ttags#List(use_cache, ?kind='', ?rx='', ?file_rx='')
function! ttags#List(use_cache, ...) "{{{3
    TVarArg ['kind', tlib#var#Get('ttags_kinds', 'wbg')],
                \ ['rx', tlib#var#Get('ttags_tags_rx', 'wbg')],
                \ ['file_rx', tlib#var#Get('ttags_file_rx', 'wbg')]
    " TLogVAR rx, file_rx
    let world  = copy(g:ttags_world)
    let tagsid = string(tagfiles())
    if !a:use_cache || empty(get(s:tags, tagsid))
        let s:tags[tagsid] = taglist('.')
    else
        " TLogDBG 'Use cache for: '. tagsid
    endif
    let world.tags = s:tags[tagsid]
    if !empty(kind) && kind != '*'
        call filter(world.tags, 'v:val.kind =~ "['. kind .']"')
    endif
    if !empty(rx) && rx != '*'
        call filter(world.tags, 'v:val.name =~ rx')
    endif
    if !empty(file_rx) && file_rx != '*'
        call filter(world.tags, 'v:val.filename =~ file_rx')
    endif
    " TLogVAR world.tags
    if !empty(world.tags)
        let world.base = map(copy(world.tags), 'printf("%s: %-20s %s @%s", v:val.kind, v:val.name, fnamemodify(v:val.filename, ":t"), fnamemodify(v:val.filename, ":p:h"))')
        " TLogVAR world.base
        if tlib#cmd#UseVertical('TTags')
            let world.scratch_vertical = 1
        endif
        if get(world, 'scratch_vertical')
            let sizes = map(copy(world.base), 'len(matchstr(v:val, ''^.\{-}\ze@''))')
            let world.resize_vertical = max(sizes) + len(len(world.base)) + 2
        endif
        " if kind == '*'
            let world.tlib_UseInputListScratch = ttags#Highlight(world.tags)
        " endif
        call tlib#input#ListD(world)
    else
        echohl Error
        echom 'ttags: No tags'
        echohl NONE
    endif
endf


function! s:GetTag(world, id) "{{{3
    return a:world.tags[a:world.GetBaseIdx(a:id) - 1]
endf


function! s:ShowTag(world, tagline) "{{{3
    let tag = s:GetTag(a:world, a:tagline)
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


function! ttags#InsertTemplate(world, selected) "{{{3
    let back = a:world.SwitchWindow('win')
    for tagid in a:selected
        let tag = s:GetTag(a:world, tagid)
        if exists('g:loaded_tskeleton') && g:loaded_tskeleton > 301
            call tskeleton#ExpandBitUnderCursor('n', tag.name)
        else
            call tlib#buffer#InsertText(tag.name)
        endif
    endfor
    exec back
    let a:world.state = 'exit'
    return a:world
endf


