" Author:
"   Original: Gergely Kontra <kgergely@mcl.hu>
"   Current:  Eric Van Dewoestine <ervandew@gmail.com> (as of version 0.4)
"   Please direct all correspondence to Eric.
" Version: 0.61
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
  " Note: a special value of 'context' is supported which will result in
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
  "
  " Note: once the buffer has been initialized, changing the value of this
  " setting will not change the default complete type used.  If you want to
  " change the default completion type for the current buffer after it has
  " been set, perhaps in an ftplugin, you'll need to call
  " SuperTabSetDefaultCompletionType like so, supplying the completion type
  " you wish to switch to:
  "   call SuperTabSetDefaultCompletionType("<c-x><c-u>")
  if !exists("g:SuperTabDefaultCompletionType")
    let g:SuperTabDefaultCompletionType = "<c-p>"
  endif

  " Sets the default completion type used when g:SuperTabDefaultCompletionType
  " is set to 'context' and no completion type is returned by any of the
  " configured contexts.
  if !exists("g:SuperTabContextDefaultCompletionType")
    let g:SuperTabContextDefaultCompletionType = "<c-p>"
  endif

  " Sets the list of contexts used for context completion.  This value should
  " be a list of function names which provide the context implementation.
  "
  " When super tab starts the default completion, each of these contexts will
  " be consulted in order to determine the completion type to use.  If a
  " context returns a completion type, that type will be used, otherwise the
  " next context in the list will be consulted.  If after executing all the
  " context functions, no completion type has been determined, then the value
  " of g:SuperTabContextDefaultCompletionType will be used.
  "
  " Built in completion contexts:
  "   s:ContextText - The text context will examine the text near the cursor
  "     to decide which type of completion to attempt.  Currently the text
  "     context can recognize method calls or attribute references via '.',
  "     '::' or '->', and file path references containing '/'.
  "     Ex.
  "     /usr/l<tab>  # will use filename completion
  "     myvar.t      # will use user completion if completefunc set, or omni
  "                  # completion if omnifunc set.
  "     myvar->      # same as above
  "
  "     Supported configuration attributes:
  "       g:SuperTabContextTextFileTypeExclusions
  "         List of file types for which the text context will be skipped.
  "       g:SuperTabContextTextOmniPrecedence
  "         List of omni completion option names in the order of precendence
  "         that they should be used if available. By default, user completion
  "         will be given precedence over omni completion, but you can use
  "         this variable to give omni completion higher precedence by placing
  "         it first in the list.
  "
  "  s:ContextDiscover - This context will use the
  "    'g:SuperTabContextDiscoverDiscovery' variable to determine the
  "    completion type to use.  It will evaluate each value in order until a
  "    variable evaluates to a non-zero or non-empty value, then the
  "    associated completion type is used.
  "
  "     Supported configuration properties:
  "       g:SuperTabContextDiscoverDiscovery:
  "         List of variable:completionType mappings.
  "
  "  Example context configuration:
  "    let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
  "    let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
  "    let g:SuperTabContextDiscoverDiscovery =
  "      \ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]
  "
  "  In addition to the default completion contexts, you can plug in your own
  "  implementation by creating a globally accessible function that returns
  "  the completion type to use (eg. "\<c-x>\<c-u>").
  "
  "  Ex.
  "    function MyTagContext()
  "      if filereadable(expand('%:p:h') . '/tags')
  "        return "\<c-x>\<c-]>"
  "      endif
  "      " no return will result in the evaluation of the next configured context
  "    endfunction
  "    let g:SuperTabCompletionContexts =
  "      \ ['MyTagContext', 's:ContextText', 's:ContextDiscover']
  "
  "  Note: supertab also supports the b:SuperTabCompletionContexts variable
  "  allowing you to set the list of contexts separately for the current
  "  buffer, like from an ftplugin for example.
  "
  if !exists("g:SuperTabCompletionContexts")
    let g:SuperTabCompletionContexts = ['s:ContextText']
  endif

  " Determines if, and for how long, the current completion type is retained.
  " The possible values include:
  " 'completion' - The current completion type is only retained for the
  "                current completion.  Once you have chosen a completion
  "                result or exited the completion mode, the default
  "                completion type is restored.
  " 'insert'     - The current completion type is saved until you exit insert
  "                mode (via ESC).  Once you exit insert mode the default
  "                completion type is restored. (supertab default)
  " 'session'    - The current completion type is saved for the duration of
  "                your vim session or until you enter a different completion
  "                mode.
  if !exists("g:SuperTabRetainCompletionDuration")
    let g:SuperTabRetainCompletionDuration = 'insert'
  endif

  " Sets whether or not mid word completion is enabled.
  " When enabled, <tab> will kick off completion when ever a non whitespace
  " character is to the left of the cursor.  When disabled, completion will
  " only occur if the char to the left is non whitespace char and the char to
  " the right is not a keyword character (you are at the end of the word).
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

" SuperTabSetDefaultCompletionType(type) {{{
" Globally available function that users can use to set the default
" completion type for the current buffer, like in an ftplugin.
function! SuperTabSetDefaultCompletionType(type)
  " init hack for <c-x><c-v> workaround.
  let b:complCommandLine = 0

  let b:SuperTabDefaultCompletionType = a:type

  " set the current completion type to the default
  call SuperTabSetCompletionType(b:SuperTabDefaultCompletionType)
endfunction " }}}

" SuperTabSetCompletionType(type) {{{
" Globally available function that users can use to create mappings to quickly
" switch completion modes.  Useful when a user wants to restore the default or
" switch to another mode without having to kick off a completion of that type
" or use SuperTabHelp.  Note, this function only changes the current
" completion type, not the default, meaning that the default will still be
" restored once the configured retension duration has been met (see
" g:SuperTabRetainCompletionDuration).  To change the default for the current
" buffer, use SuperTabDefaultCompletionType(type) instead.  Example mapping to
" restore SuperTab default:
"   nmap <F6> :call SetSuperTabCompletionType("<c-p>")<cr>
function! SuperTabSetCompletionType(type)
  exec "let b:complType = \"" . escape(a:type, '<') . "\""
endfunction " }}}

" SuperTabAlternateCompletion(type) {{{
" Function which can be mapped to a key to kick off an alternate completion
" other than the default.  For instance, if you have 'context' as the default
" and want to map ctrl+space to issue keyword completion.
" Note: due to the way vim expands ctrl characters in mappings, you cannot
" create the alternate mapping like so:
"    imap <c-space> <c-r>=SuperTabAlternateCompletion("<c-p>")<cr>
" instead, you have to use \<lt> to prevent vim from expanding the key
" when creating the mapping.
"    gvim:
"      imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-p>")<cr>
"    console:
"      imap <nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-p>")<cr>
function! SuperTabAlternateCompletion(type)
  call SuperTabSetCompletionType(a:type)
  " end any current completion before attempting to start the new one.
  " use feedkeys to prevent possible remapping of <c-e> from causing issues.
  "call feedkeys("\<c-e>", 'n')
  " ^ since we can't detect completion mode vs regular insert mode, we force
  " vim into keyword completion mode and end that mode to prevent the regular
  " insert behavior of <c-e> from occurring.
  call feedkeys("\<c-x>\<c-p>\<c-e>", 'n')
  call feedkeys(b:complType)
  return ''
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
  " mode if configured to do so
  if g:SuperTabRetainCompletionDuration == 'insert'
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

  let b:SuperTabDefaultCompletionType = g:SuperTabDefaultCompletionType

  " set the current completion type to the default
  call SuperTabSetCompletionType(b:SuperTabDefaultCompletionType)
endfunction " }}}

" s:ManualCompletionEnter() {{{
" Handles manual entrance into completion mode.
function! s:ManualCompletionEnter()
  if &smd
    echo '' | echohl ModeMsg | echo '-- ^X++ mode (' . s:modes . ')' | echohl None
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

    if index(['insert', 'session'], g:SuperTabRetainCompletionDuration) != -1
      let b:complType = complType
    endif

    " Hack to workaround bug when invoking command line completion via <c-r>=
    if complType == "\<c-x>\<c-v>"
      return s:CommandLineCompletion()
    endif

    return complType
  endif

  echohl "Unknown mode"
  return complType
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
  if exists('b:SuperTabDefaultCompletionType') &&
  \ (!exists('b:complCommandLine') || !b:complCommandLine)
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

    " handle 'context' completion.
    if b:complType == 'context'
      let complType = s:ContextCompletion()
      if complType == ''
        exec "let complType = \"" .
          \ escape(g:SuperTabContextDefaultCompletionType, '<') . "\""
      endif
      return complType . key
    endif

    " Hack to workaround bug when invoking command line completion via <c-r>=
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

" s:ContextCompletion() {{{
function! s:ContextCompletion()
  let contexts = exists('b:SuperTabCompletionContexts') ?
    \ b:SuperTabCompletionContexts : g:SuperTabCompletionContexts

  for context in contexts
    try
      let Context = function(context)
      let complType = Context()
      unlet Context
      if type(complType) == 1 && complType != ''
        return complType
      endif
    catch /E700/
      echohl Error
      echom 'supertab: no context function "' . context . '" found.'
      echohl None
    endtry
  endfor
  return ''
endfunction " }}}

" s:ContextDiscover() {{{
function! s:ContextDiscover()
  let discovery = exists('g:SuperTabContextDiscoverDiscovery') ?
    \ g:SuperTabContextDiscoverDiscovery : []

  " loop through discovery list to find the default
  if !empty(discovery)
    for pair in discovery
      let var = substitute(pair, '\(.*\):.*', '\1', '')
      let type = substitute(pair, '.*:\(.*\)', '\1', '')
      exec 'let value = ' . var
      if value !~ '^\s*$' && value != '0'
        exec "let complType = \"" . escape(type, '<') . "\""
        return complType
      endif
    endfor
  endif
endfunction " }}}

" s:ContextText() {{{
function! s:ContextText()
  let exclusions = exists('g:SuperTabContextTextFileTypeExclusions') ?
    \ g:SuperTabContextTextFileTypeExclusions : []

  if index(exclusions, &ft) == -1
    let curline = getline('.')
    let cnum = col('.')
    let synname = synIDattr(synID(line('.'), cnum - 1, 1), 'name')
    if curline =~ '.*/\w*\%' . cnum . 'c' ||
      \ ((has('win32') || has('win64')) && curline =~ '.*\\\w*\%' . cnum . 'c')
      return "\<c-x>\<c-f>"

    elseif curline =~ '.*\(\w\|[\])]\)\(\.\|::\|->\)\w*\%' . cnum . 'c' &&
      \ synname !~ '\(String\|Comment\)'
      let omniPrecedence = exists('g:SuperTabContextTextOmniPrecedence') ?
        \ g:SuperTabContextTextOmniPrecedence : ['&completefunc', '&omnifunc']

      for omniFunc in omniPrecedence
        if omniFunc !~ '^&'
          let omniFunc = '&' . omniFunc
        endif
        if getbufvar(bufnr('%'), omniFunc) != ''
          return omniFunc == '&omnifunc' ? "\<c-x>\<c-o>" : "\<c-x>\<c-u>"
        endif
      endfor
    endif
  endif
endfunction " }}}

" Key Mappings {{{
  " map a regular tab to ctrl-tab (note: doesn't work in console vim)
  exec 'inoremap ' . g:SuperTabMappingTabLiteral . ' <tab>'

  imap <c-x> <c-r>=<SID>ManualCompletionEnter()<cr>

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
