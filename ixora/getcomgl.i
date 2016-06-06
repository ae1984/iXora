/* getcomgl.i
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        06/07/2005 saltanat - Добавила вх. параметр v-aaa, и выборка из исключений по счетам. 
        06.07.2005 saltanat - Выборка льгот по счетам.
        22/06/2006 nataly   - добавила обработку  счета ГК , еслт счет ГК не найден !
*/

function getcomgl returns char (v-aaa as char, v-cif as char, v-com as char).
def var rgl like gl.gl.
/* 06/07/05 saltanat - Добавлен поиск по исключениям клиента по счетам */
if v-aaa ne '' then 
   find first tarifex2 where tarifex2.aaa  = v-aaa 
                         and tarifex2.cif  = v-cif 
                         and tarifex2.str5 = v-com 
                         and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then rgl = tarifex2.kont.
else do:
find first tarifex where tarifex.str5 = v-com and tarifex.cif = v-cif 
                     and tarifex.stat = 'r' no-lock no-error.  
if avail tarifex then rgl = tarifex.kont.                                        
else do:
    find first tarif2 where tarif2.str5 = v-com and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then rgl = tarif2.kont.                                         
    else rgl = 0.
end. /* if not avail tarifex */   
end. /* if not avail tarifex2 */
return string(rgl, "999999").
end function.
