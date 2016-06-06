/* f-2-w.i
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
    12.09.2000
    f-2-w.p   
    Транслятор файла koi8-1251...
    Пропер С.В.
*/

function f-2-w returns int ( 
    
    input f-i as char,
    input f-o as char
    
    ).
    
def var s as char init ''.
def var n as integer.
def var i as integer.

    output to value( f-o ).
    input from value( f-i ) no-echo.
    repeat:
       import unformatted s.
       s = u-2-w( s ).
       put unformatted s + chr( 13 ) + chr( 10 ).
       n = n + length( s ) + 2.
    end.

    output close.
    input close.
    return n.

end function. 

/*
display f-2-w( 'f-2-w.p', 'f-2-w.w' ).
return.
*/

/***/

