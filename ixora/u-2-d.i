/* u-2-d.i
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
    u-2-d.p   
    Транслятор koi8-dos...
    Пропер С.В.
*/

function u-2-d returns char ( 
    
    input c as char
    
    ).
    
def var a as char
    init 'йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕЁНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ'
    case-sensitive. 
def var b as char
    init '©ФЦЄҐ­ёХИ§ЕЙДКў ЇЮ®«¤¦МОГА¬ЁБЛЎН‰–“Љ…ПЌѓ™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ'
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
       n = index( a, d ).
       s = s + if n > 0 then substr( b, n, 1 ) else d.
    end.
    return s.

end function. 

/*
{d-2-u.p}
display d-2-u( u-2-d( 'йцукенгшщзхъфывапролджэячсмитьбю' )) format 'x(64)'.
display d-2-u( u-2-d( 'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ' )) format 'x(64)'.
display d-2-u( u-2-d( 'пропер' )).
return.
*/

/***/

