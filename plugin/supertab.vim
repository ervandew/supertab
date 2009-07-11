" Author:
"   Original: Gergely Kontra <kgergely@mcl.hu>
"   Current:  Eric Van Dewoestine <ervandew@gmail.com> (as of version 0.4)
"   Please direct all correspondence to Eric.
" Version: 0.51
"
" Description: {{{
"   Use your tab key to do all your completion in insert mode!
"   You can cycle forward and backward with the <Tab> and <S-Tab> keys
"   Note: you must press <Tab> once to be able to cycle back
"
"   http://www.vim.org/scripts/script.php?script_id=1643
" }}}
"
" License: {{{
"   Software License Agreement (BSD License)
"
"   Copyright (c) 2002 - 2009
"   All rights reserved.
"
"   Redistribution and use of this software in source and binary forms, with
"   or without modification, are permitted provided that the following
"   conditions are met:
"
"   * Redistributions of source code must retain the above
"     copyright notice, this list of conditions and the
"     following disclaimer.
"
"   * Redistributions in binary form must reproduce the above
"     copyright notice, this list of conditions and the
"     following disclaimer in the documentation and/or other
"     materials provided with the distribution.
"
"   * Neither the name of Gergely Kontra or Eric Van Dewoestine nor the names
"   of its contributors may be used to endorse or promote products derived
"   from this software without specific prior written permission of Gergely
"   Kontra or Eric Van Dewoestine.
"
"   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
"   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
"   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
"   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
"   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
"   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
"   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
"   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
"   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
"   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
"   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
" }}}
"
" Testing Info: {{{
"   Running vim + supertab with the absolute bar minimum settings:
"     $ vim -u NONE -U NONE -c "set nocp | runtime plugin/supertab.vim"
" }}}

if v:version < 700
  finish
endif

if exists('complType') " Integration with other completion functions.
  finish
endif

" Global Variables {{{

  " Used to set the default completion type.
  " There is no need to escape this value as that will be done for you when
  " the type is set.
  " Ex.  let g:SuperTabDefaultCompletionType = "<c-x><c-u>"
  "
  " Note that a special value of 'context' is supported which will result in
  " super tab attempting to use the text preceding the cursor to decide which
  " type of completion to attempt.  Currently super tab can recognize method
  " calls or attribute references via '.', '::' or '->', and file path
  " references containing '/'.
  " Ex. let g:SuperTabDefaultCompletionType = 'context'
  " /usr/l<tab>  # will use filename completion
  " myvar.t  # will use user completion if completefunc set, or omni
  "          # completion if omnifunc set.
  " myvar->  # same as above
  "
  " When using context completion, super tab will fall back to a secondary
  " default completion type set by g:SuperTabContextDefaultCompletionType.
  if !exists("g:SuperTabDefaultCompletionType")
    let g:SuperTabDefaultCompletionType = "<c-p>"
  endif

  " Sets the default completion type used when g:SuperTabDefaultCompletionType
  " is set to 'context' and the text preceding the cursor does not match any
  " patterns mapped to other specific completion types.
  if !exists("g:SuperTabContextDefaultCompletionType")
    let g:SuperTabContextDefaultCompletionType = "<c-p>"
  endif

  " When 'context' completion is enabled, this setting can be used to fallback
  " to g:SuperTabContextDefaultCompletionType as the default for files whose
  " file type occurs in this configured list.  This allows you to provide an
  " exclusion for which 'context' completion is not activated.
  if !exists("g:SuperTabContextFileTypeExclusions")
    let g:SuperTabContextFileTypeExclusions = []
  endif

  " Used to set a list of variable, completion type pairs used to determine
  " the default completion type to use for the current buffer.  If the
  " variable is non-zero and non-empty then the associated completion type
  " will be used.
  " Ex. To use omni or user completion when available, but fall back to the
  " global default otherwise:
  "   let g:SuperTabDefaultCompletionTypeDiscovery = [
  "       \ "&completefunc:<c-x><c-u>",
  "       \ "&omnifunc:<c-x><c-o>",
  "     \ ]
  if !exists("g:SuperTabDefaultCompletionTypeDiscovery")
    let g:SuperTabDefaultCompletionTypeDiscovery = []
  endif

  " Determines if, and for how long, the current completion type is retained.
  " The possible values include:
  " 0 - The current completion type is only retained for the current completion.
  "     Once you have chosen a completion result or exited the completion
  "     mode, the default completion type is restored.
  " 1 - The current completion type is saved for the duration of your vim
  "     session or until you enter a different completion mode.
  "     (SuperTab default).
  " 2 - The current completion type is saved until you exit insert mode (via
  "     ESC).  Once you exit insert mode the default completion type is
  "     restored.
  if !exists("g:SuperTabRetainCompletionType")
    let g:SuperTabRetainCompletionType = 1
  endif

  " Sets whether or not mid word completion is enabled.
  " When enabled, <tab> will kick off completion when ever a word character is
  " to the left of the cursor.  When disabled, completion will only occur if
  " the char to the left is a word char and the char to the right is not (you
  " are at the end of the word).
  if !exists("g:SuperTabMidWordCompletion")
    let g:SuperTabMidWordCompletion = 1
  endif

  " The following two variables allow you to set the key mapping used to kick
  " off the current completion.  By default this is <tab> and <s-tab>.  To
  " change to something like <c-space> and <s-c-space>, you can add the
  " following to your vimrc.
  "
  "   let g:SuperTabMappingForward = '<c-space>'
  "   let g:SuperTabMappingBackward = '<s-c-space>'
  "
  " Note: if the above does not have the desired effect (which may happen in
  " console version of vim), you can try the following mappings.  Although the
  " backwards mapping still doesn't seem to work in the console for me, your
  " milage may vary.
  "
  "   let g:SuperTabMappingForward = '<nul>'
  "   let g:SuperTabMappingBackward = '<s-nul>'
  "
  if !exists("g:SuperTabMappingForward")
    let g:SuperTabMappingForward = '<tab>'
  endif
  if !exists("g:SuperTabMappingBackward")
    let g:SuperTabMappingBackward = '<s-tab>'
  endif

  " Sets the key mapping used to insert a literal tab where supertab would
  " otherwise attempt to kick off insert completion.
  " The default is '<c-tab>' (ctrl-tab) which unfortunately might not work at
  " the console.  So if you are using a console vim and want this
  " functionality, you'll have to change it to something that is supported.
  if !exists("g:SuperTabMappingTabLiteral")
    let g:SuperTabMappingTabLiteral = '<c-tab>'
  endif

  " Sets whether or not to pre-highlight first match when completeopt has
  " the popup menu enabled and the 'longest' option as well.
  " When enabled, <tab> will kick off completion and pre-select the first
  " entry in the popup menu, allowing you to simply hit <enter> to use it.
  if !exists("g:SuperTabLongestHighlight")
    let g:SuperTabLongestHighlight = 0
  endif

" }}}

" Script Variables {{{

  " construct the help text.
  let s:tabHelp =
    \ "Hit <CR> or CTRL-] on the completion type you wish to switch to.\n" .
    \ "Use :help ins-completion for more information.\n" .
    \ "\n" .
    \ "|<c-n>|      - Keywords in 'complete' searching down.\n" .
    \ "|<c-p>|      - Keywords in 'complete' searching up (SuperTab default).\n" .
    \ "|<c-x><c-l>| - Whole lines.\n" .
    \ "|<c-x><c-n>| - Keywords in current file.\n" .
    \ "|<c-x><c-k>| - Keywords in 'dictionary'.\n" .
    \ "|<c-x><c-t>| - Keywords in 'thesaurus', thesaurus-style.\n" .
    \ "|<c-x><c-i>| - Keywords in the current and included files.\n" .
    \ "|<c-x><c-]>| - Tags.\n" .
    \ "|<c-x><c-f>| - File names.\n" .
    \ "|<c-x><c-d>| - Definitions or macros.\n" .
    \ "|<c-x><c-v>| - Vim command-line.\n" .
    \ "|<c-x><c-u>| - User defined completion.\n" .
    \ "|<c-x><c-o>| - Omni completion.\n" .
    \ "|<c-x>s|     - Spelling suggestions."

  " set the available completion types and modes.
  let s:types =
    \ "\<c-e>\<c-y>\<c-l>\<c-n>\<c-k>\<c-t>\<c-i>\<c-]>" .
    \ "\<c-f>\<c-d>\<c-v>\<c-n>\<c-p>\<c-u>\<c-o>\<c-n>\<c-p>s"
  let s:modes = '/^E/^Y/^L/^N/^K/^T/^I/^]/^F/^D/^V/^P/^U/^O/s'
  let s:types = s:types . "np"
  let s:modes = s:modes . '/n/p'

" }}}

" CtrlXPP() {{{
" Handles entrance into completion mode.
function! CtrlXPP()
  if &smd
    echo '' | echo '-- ^X++ mode (' . s:modes . ')'
  endif
  let complType = nr2char(getchar())
  if stridx(s:types, complType) != -1
    if stridx("\<c-e>\<c-y>", complType) != -1 " no memory, just scroll...
      return "\<c-x>" . complType
    elseif stridx('np', complType) != -1
      let complType = nr2char(char2nr(complType) - 96)
    else
      let complType = "\<c-x>" . complType
    endif

    if g:SuperTabRetainCompletionType
      let b:complType = complType
    endif

    " Hack to workaround appent bug when invoking command line completion via
    " <c-r>=
    if complType == "\<c-x>\<c-v>"
      return s:CommandLineCompletion()
    endif

    return complType
  endif

  echohl "Unknown mode"
  return complType
endfunction " }}}

" SuperTabSetCompletionType(type) {{{
" Globally available function that user's can use to create mappings to
" quickly switch completion modes.  Useful when a user wants to restore the
" default or switch to another mode without having to kick off a completion
" of that type or use SuperTabHelp.
" Example mapping to restore SuperTab default:
"   nmap <F6> :call SetSuperTabCompletionType("<c-p>")<cr>
function! SuperTabSetCompletionType(type)
  exec "let b:complType = \"" . escape(a:type, '<') . "\""
endfunction " }}}

" s:Init {{{
" Global initilization when supertab is loaded.
function! s:Init()
  augroup supertab_init
    autocmd!
    autocmd BufEnter * call <SID>InitBuffer()
  augroup END

  " ensure InitBuffer gets called for the first buffer, after the ftplugins
  " have been called.
  augroup supertab_init_first
    autocmd!
    autocmd FileType <buffer> call <SID>InitBuffer()
  augroup END

  " Setup mechanism to restore orignial completion type upon leaving insert
  " mode if g:SuperTabRetainCompletionType == 2
  if g:SuperTabRetainCompletionType == 2
    augroup supertab_retain
      autocmd!
      autocmd InsertLeave * call s:SetDefaultCompletionType()
    augroup END
  endif
endfunction " }}}

" s:InitBuffer {{{
" Per buffer initilization.
function! s:InitBuffer()
  if exists("b:complType")
    return
  endif

  " init hack for <c-x><c-v> workaround.
  let b:complCommandLine = 0

  if !exists("b:SuperTabDefaultCompletionType")
    " loop through discovery list to find the default
    if !empty(g:SuperTabDefaultCompletionTypeDiscovery)
      " backward compatiability with old string value.
      if type(g:SuperTabDefaultCompletionTypeDiscovery) == 1
        let dlist = split(g:SuperTabDefaultCompletionTypeDiscovery, ',')
      else
        let dlist = g:SuperTabDefaultCompletionTypeDiscovery
      endif
      for pair in dlist
        let var = substitute(pair, '\(.*\):.*', '\1', '')
        let type = substitute(pair, '.*:\(.*\)', '\1', '')
        exec 'let value = ' . var
        if value !~ '^\s*$' && value != '0'
          let b:SuperTabDefaultCompletionType = type
          break
        endif
      endfor
    endif

    " fallback to configured default.
    if !exists("b:SuperTabDefaultCompletionType")
      let b:SuperTabDefaultCompletionType = g:SuperTabDefaultCompletionType
    endif
  endif

  " set the default completion type.
  call SuperTabSetCompletionType(b:SuperTabDefaultCompletionType)
endfunction " }}}

" s:SetCompletionType() {{{
" Sets the completion type based on what the user has chosen from the help
" buffer.
function! s:SetCompletionType()
  let chosen = substitute(getline('.'), '.*|\(.*\)|.*', '\1', '')
  if chosen != getline('.')
    let winnr = b:winnr
    close
    exec winnr . 'winc w'
    call SuperTabSetCompletionType(chosen)
  endif
endfunction " }}}

" s:SetDefaultCompletionType() {{{
function! s:SetDefaultCompletionType()
  if exists('b:SuperTabDefaultCompletionType') && !b:complCommandLine
    call SuperTabSetCompletionType(b:SuperTabDefaultCompletionType)
  endif
endfunction " }}}

" s:SuperTab(command) {{{
" Used to perform proper cycle navigation as the user requests the next or
" previous entry in a completion list, and determines whether or not to simply
" retain the normal usage of <tab> based on the cursor position.
function! s:SuperTab(command)
  if s:WillComplete()
    " rare case where no autocmds have fired for this buffer to initialize the
    " supertab vars.
    call s:InitBuffer()

    let key = ''
    " highlight first result if longest enabled
    if g:SuperTabLongestHighlight && !pumvisible() && &completeopt =~ 'longest'
      let key = (b:complType == "\<c-p>") ? "\<c-p>" : "\<c-n>"
    endif

    " exception: if in <c-p> mode, then <c-n> should move up the list, and
    " <c-p> down the list.
    if a:command == 'p' &&
      \ (b:complType == "\<c-p>" ||
      \   (b:complType == 'context' &&
      \    tolower(g:SuperTabContextDefaultCompletionType) == '<c-p>'))
      return "\<c-n>"
    endif

    if b:complType == 'context'
      if index(g:SuperTabContextFileTypeExclusions, &ft) == -1
        let curline = getline('.')
        let cnum = col('.')
        let synname = synIDattr(synID(line('.'), cnum - 1, 1), 'name')
        if curline =~ '.*/\w*\%' . cnum . 'c' ||
          \ ((has('win32') || has('win64')) && curline =~ '.*\\\w*\%' . cnum . 'c')
          return "\<c-x>\<c-f>" . key
        elseif curline =~ '.*\(\w\|[\])]\)\(\.\|::\|->\)\w*\%' . cnum . 'c' &&
          \ synname !~ '\(String\|Comment\)'
          if &completefunc != ''
            return "\<c-x>\<c-u>" . key
          elseif &omnifunc != ''
            return "\<c-x>\<c-o>" . key
          endif
        endif
      endif
      exec "let complType = \"" . escape(g:SuperTabContextDefaultCompletionType, '<') . "\""
      return complType . key
    endif

    " Hack to workaround appent bug when invoking command line completion via
    " <c-r>=
    if b:complType == "\<c-x>\<c-v>"
      return s:CommandLineCompletion()
    endif
    return b:complType . key
  endif

  return "\<tab>"
endfunction " }}}

" s:SuperTabHelp() {{{
" Opens a help window where the user can choose a completion type to enter.
function! s:SuperTabHelp()
  let winnr = winnr()
  if bufwinnr("SuperTabHelp") == -1
    botright split SuperTabHelp

    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete

    let saved = @"
    let @" = s:tabHelp
    silent put
    call cursor(1, 1)
    silent 1,delete
    call cursor(4, 1)
    let @" = saved
    exec "resize " . line('$')

    syntax match Special "|.\{-}|"

    setlocal readonly
    setlocal nomodifiable

    nmap <silent> <buffer> <cr> :call <SID>SetCompletionType()<cr>
    nmap <silent> <buffer> <c-]> :call <SID>SetCompletionType()<cr>
  else
    exec bufwinnr("SuperTabHelp") . "winc w"
  endif
  let b:winnr = winnr
endfunction " }}}

" s:WillComplete() {{{
" Determines if completion should be kicked off at the current location.
function! s:WillComplete()
  let line = getline('.')
  let cnum = col('.')

  " Start of line.
  let prev_char = strpart(line, cnum - 2, 1)
  if prev_char =~ '^\s*$'
    return 0
  endif

  " Within a word, but user does not have mid word completion enabled.
  let next_char = strpart(line, cnum - 1, 1)
  if !g:SuperTabMidWordCompletion && next_char =~ '\k'
    return 0
  endif

  " In keyword completion mode and no preceding word characters.
  "if (b:complType == "\<c-n>" || b:complType == "\<c-p>") && prev_char !~ '\k'
  "  return 0
  "endif

  return 1
endfunction " }}}

" s:CommandLineCompletion() {{{
" Hack needed to account for apparent bug in vim command line mode completion
" when invoked via <c-r>=
function! s:CommandLineCompletion()
  " This hack will trigger InsertLeave which will then invoke
  " s:SetDefaultCompletionType.  To prevent default completion from being
  " restored prematurely, set an internal flag for s:SetDefaultCompletionType
  " to check for.
  let b:complCommandLine = 1
  return "\<c-\>\<c-o>:call feedkeys('\<c-x>\<c-v>\<c-v>', 'n') | " .
    \ "let b:complCommandLine = 0\<cr>"
endfunction " }}}

" Key Mappings {{{
  " map a regular tab to ctrl-tab (note: doesn't work in console vim)
  exec 'inoremap ' . g:SuperTabMappingTabLiteral . ' <tab>'

  imap <c-x> <c-r>=CtrlXPP()<cr>

  " From the doc |insert.txt| improved
  exec 'imap ' . g:SuperTabMappingForward . ' <c-n>'
  exec 'imap ' . g:SuperTabMappingBackward . ' <c-p>'

  " After hitting <Tab>, hitting it once more will go to next match
  " (because in XIM mode <c-n> and <c-p> mappings are ignored)
  " and wont start a brand new completion
  " The side effect, that in the beginning of line <c-n> and <c-p> inserts a
  " <Tab>, but I hope it may not be a problem...
  inoremap <c-n> <c-r>=<SID>SuperTab('n')<cr>
  inoremap <c-p> <c-r>=<SID>SuperTab('p')<cr>
" }}}

" Command Mappings {{{
  if !exists(":SuperTabHelp")
    command SuperTabHelp :call <SID>SuperTabHelp()
  endif
" }}}

call s:Init()

" vim:ft=vim:fdm=marker
