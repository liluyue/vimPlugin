cnoremap <F2> :call AdbActivity()<cr>
:if exists("g:debugAdb")
finish 
:endif
:let g:debugAdb=1
"echo g:debugAdb
let g:apkPkg="pkg"
let g:apkPath="path"
let g:apkActivity="act"
let g:apks=[ {apkPkg:"com.excelliance.dualaid",apkPath:"",apkActivity:""}, {apkPkg:"com.excean.mvoice",apkPath:"Z:/wxtool2/HHDDZ/proj.android/app/build/outputs/apk/com.excean.mvoice_15022_1_release.apk",apkActivity:""}, {apkPkg:"com.excean.wxaid",apkPath:"Z:/wxtool/HHDDZ/proj.android/app/build/outputs/apk/",apkActivity:""} ]
if(!exists('g:apkPackageList'))
	let g:apkPackageList=["com.excelliance.dualaid","com.excean.mvoice","com.excean.wxaid"]
endif
if(!exists('g:apkPathList'))
	let g:apkPathList=[]
endif
"应用安装
let s:dir=expand('<sfile>:h') 
:command! -nargs=+ -complete=file ApkReverse  :execute "!java -jar ".s:dir . "/apktool.jar d "<q-args>
:command! -nargs=+ -complete=file AdbInstall :call AdbInstall(<f-args>)
":command! -nargs=+ -complete=file AdbInstall :let result=split(system('adb install '.fnamemodify(<q-args>,':p')),'\n') | let result=result[1:2]+result[-4:-1] |for item in result | echo item |endfor
"应用卸载
:command! -nargs=1 -complete=var	AdbUninstall :call AdbUninstall(<f-args>)
"应用清空数据
:command! -nargs=1 AdbClear :call AdbClear(<f-args>)
if(0)
	"logcat
	:command! -nargs=1 -complete=file AdbLogCatV :execute '!start /b adb logcat -v time > ' .<f-args>
	:command!  AdbLogCatC :execute '!start /b adb logcat -c' 
endif
"adb pull
:command! -nargs=+ -complete=custom,SdcardFile AdbPull :execute '!start /b adb pull ' <q-args>
"adb push
:command! AdbCurrentAct let g:adbCurrentAct=substitute(matchstr(system('adb shell dumpsys activity activities'),'mResumedActivity: .\{-,\}\zscom\S*'),"/","","g") | echo g:adbCurrentAct

:command! -nargs=1 -complete=file AdbPush :execute '!start /b adb push ' <q-args>."/sdcard/"
:let g:isIconv=1
:function! SdcardFile(A,L,P)
let l:A=substitute((a:A=~'^/'?'':'/').a:A,'[/\\][^/\\]\{-,}$','','')
let l:A=l:A.'/'
:let l:files=systemlist('adb shell ls -a '.l:A)
:let l:files=map(l:files,'substitute(l:A.v:val,"\n\\|\r","","g")')
"let l:files=filter(l:files,'v:val=~a:A')
"let g:SdFiles=l:files
"let g:SdcardFileALP=[" start a:A--".a:A,'a:L--'.a:L,'a:P--'.a:P,'l:A--'.l:A]
"return l:files
:if(len(l:files)<1)
:  return 
elseif(len(l:files)==1&&string(l:files)=~'No such file or directory\|Permission denied')
:  return
:endif
:let l:result=join(l:files,"\n")
"let g:SdFile=l:result
:return g:isIconv?iconv(l:result,'utf8','gbk'):l:result
:endfunction

:let g:adbCmd=['adb shell getprop']
function! AdbShowPid(package)
	if (a:package>0)
		let a:pkg=g:apkPackageList[a:package-1]
	else
		let a:pkg=a:package
	endif
	echo a:pkg
	:call append('.',filter(systemlist('adb shell ps'),'v:key==0 || v:val =~ a:pkg'))

endfunction
function! AdbShowResultInCurrent(cmd)
call append('.',split(system(a:cmd),'\n'))
endfunction	
function! AdbActivity()
	let tmpfile = tempname()
	:exe "tabedit ". tmpfile
	:0,$d
	:r !adb shell dumpsys activity activities
	:w
	:  let buflist = []
	:for i in range(tabpagenr('$'))
	:   call extend(buflist, tabpagebuflist(i + 1))
	:endfor
	":let @/ = "View Hierarchy"
	":execute " 1|/mResume/;/View Hierarchy"
	:execute " 1|/mResumedActivity/"
	":echo buflist
endfunction
function! AdbMemory(package)
	if (a:package>0)
		let a:pkg=g:apkPackageList[a:package-1]
	else
		let a:pkg=a:package
	endif
	echo a:pkg
	let tmpfile = tempname()
	:exe "tabedit ". tmpfile
	:0,$d
	:let l:result=systemlist('adb shell dumpsys meminfo '.a:pkg)
	:call map(l:result,'substitute(v:val,"\r\\+","","g")')
	:call append(0,l:result)
	:w
	:  let buflist = []
	:for i in range(tabpagenr('$'))
	:   call extend(buflist, tabpagebuflist(i + 1))
	:endfor
	:execute ' 1| /TOTAL'
	":echo buflist
endfunction

let g:adbInstallOption="-t"

"install by apk path
function! AdbInstall(package,...)
	:let l:package=a:package==0?fnamemodify(a:package,':p'):a:package
	:if(l:package>0&&len(g:apkPathList)>=l:package)
	:let l:package=g:apkPathList[l:package-1]
	:elseif (l:package=~".*\.apk")
	:let l:exist=0
	:for path in g:apkPathList
	: if(path==l:package)
	:     let l:exist=1
	:  break
	: endif
	:endfor
	:if(!l:exist)
	:call add(g:apkPathList,l:package)
	:endif
	:endif
	echo l:package
	:let result=split(system('adb install '.g:adbInstallOption.' '.l:package ),'\n') 
	:let result=len(result)>5?result[0:1]+result[-4:-1] : result
	:for item in result 
	:echo item 
	:endfor
endfunction

"uninstall by package
function! AdbUninstall(package)
	if (a:package>0)
		let a:pkg=g:apkPackageList[a:package-1]
	else
		let a:pkg=a:package
	endif
	echo a:pkg
	:echo  system('adb uninstall '.a:pkg)

endfunction


"clear apk data by package
function! AdbClear(package)
	if (a:package>0)
		let a:pkg=g:apkPackageList[a:package-1]
	else
		let a:pkg=a:package
	endif
	echo a:pkg
	:echo  system('adb shell pm clear '.a:pkg)
endfunction
