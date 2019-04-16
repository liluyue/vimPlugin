let s:dir=expand('<sfile>:h:h') 
:command! -range Json :execute ":<line1>,<line2>py3file ". s:dir . "/py/json_format.py"
