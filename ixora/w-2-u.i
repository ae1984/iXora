/* w-2-u.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
    12.09.2000
    w-2-u.p   
    Транслятор 1251-koi8...
    Пропер С.В.
*/

function w-2-u returns char ( 
    
    input c as char
    
    ).
    
def var a as char
    init 'йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ'
    case-sensitive. 
def var b as char
    init 'ИЖСЙЕМЦЬЫГУЗТШБЮОПНКДФЩЪВЯЛХРЭАЧижсйемцьыгузтшбюопнкдфщъвялхрэач'
    case-sensitive.
def var s as char init ''.
def var d as char init ''.
def var n as integer.
def var l as integer.
def var i as integer.

    l = length( c ). 
    if l < 1 then return s.
    do i = 1 to l:
       d = substr( c, i, 1 ). 
       n = index( b, d ).
       s = s + if n > 0 then substr( a, n, 1 ) else d.
    end.
    return s.

end function. 

/*

display w-2-u( 'ИЖСЙЕМЦЬЫГУЗТШБЮОПНКДФЩЪВЯЛХРЭАЧ' ) format 'x(64)'.
display w-2-u( 'ижсйемцьыгузтшбюопнкдфщъвялхрэач' ) format 'x(64)'.
display w-2-u( 'ЪВЯЛХРЭАЧ' ).    
return.

*/

/***/

