let search_crash=1
set shortmess+=I
if has("win32")
	noremap <C-S-E> :execute' !start '.expand("%:h")<cr>
endif
nmap <c-c> "*y
nmap <F2>    :call Search_crash('')<cr>
nmap crashl  :execute 'normal '.g:crashLineNumber.'G'<cr>
nmap <F3>    :call Search_crash(expand('<cword>'))<cr>
nmap <F4>    :call Search_crash(expand('<cWORD>'))<cr>
nmap <F5>   :call PositionDrawable(expand('<cWORD>'),expand('%:p:h'))<cr>
noremap <a-left> :tabp<cr>
noremap <a-right> :tabn<cr>
"search command
:command -nargs=? ShowSearch :call Search_crash(<q-args>)
:command -nargs=? Translate :call Tran(<q-args>)

"adb command
"au BufRead,BufNewFile * set filetype=logcat 
let g:crashLineNumber=-1
function! Search_crash(a)
: if a:a == "" 
:let s:shutDown='Shutting\s\+down'
:let s:crash='uncaughtException'
:let s:fatal='fatal'
:let l:pos= search(s:shutDown.'\|'.s:crash.'\|'.s:fatal.'\c')
let g:crashLineNumber=l:pos
:if l:pos!=0  
echo "crash line number:".l:pos
"execute "normal".l:pos."G"
endif
: let s:search='uncaughtException\|fatal\|'.s:shutDown.'\c'
: else 
: let s:search=a:a
: endif
:cclose
":echo s:search
:execute ":vimg /". s:search ."/j %"
:cw
:highlight MyGroup cterm=reverse gui=reverse ctermfg=6
:call matchadd("MyGroup",s:search)
endfunction

function! Uniq()
:sort 
:g/^\(.*\)$\n\1$/d
endfunction

function! PositionDrawable(drawable,path)
 :let  s:cword='"'.a:drawable.'"\|/\s*'.a:drawable.'\s*"\|/\s*'.a:drawable."\\s*<"
 :echo s:cword
 :let s:path=a:path."/**/*.xml  ". a:path."/**/*.java"
 :exec "vimgrep '".s:cword ."'  ".s:path 
endfunction


"show window of cmd result
function! Show_CmdResult()
  let a:winnr=bufwinnr(s:title)
  if (a:winnr>=0)
    execute a:winnr . 'wincmd w'
    execute 'normal ggdG'
  else
    let a:lineCounter=10
    execute 'belowright '. a:lineCounter .'split ++bad=drop '.s:title
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  endif
endfunction

let s:title='cmd result'



let s:translator_engines = {
    \ 'youdao': 'http://fanyi.youdao.com/openapi.do?keyfrom=FuDesign2008&key=1676087853&type=data&doctype=json&version=1.1&q=<QUERY>',
    \ 'baidu': 'http://openapi.baidu.com/public/2.0/bmt/translate?client_id=K4GwmBaiSfbCd0a6OfOCpHcd&q=<QUERY>&from=auto&to=auto'
    \}
let g:translator_engine="youdao"
function! Tran(word)
  "call Show_CmdResult()
   let a:url=substitute(s:translator_engines[g:translator_engine],"<QUERY>",a:word,"")
  "execute 'Utl openLink '. a:url
  execute '0r !start '.a:url
endfunction
