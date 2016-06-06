/* d-2-u.i
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
    d-2-u.p   
    Транслятор dos-koi8...
    Пропер С.В.
*/

function d-2-u returns char ( 
    
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
       n = index( b, d ).
       s = s + if n > 0 then substr( a, n, 1 ) else d.
    end.
    return s.

end function. 

/*
display d-2-u( '©ФЦЄҐ­ёХИ§ЕЙДКў ЇЮ®«¤¦МОГА¬ЁБЛЎН' ) format 'x(64)'.
display d-2-u( '‰–“Љ…Ќѓ™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ' ) format 'x(64)'.
display d-2-u( 'ЏЮ®ЇҐЮ' ).    
return.
*/

/***/

