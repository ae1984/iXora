/* checktime.i
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
        06/12/04 pragma
 * CHANGES
*/

def var v-tb as integer.
def var v-te as integer.

{findsysc.i "LBHBG" "v-tb" "inval"} /*  9  */
{findsysc.i "LBHEG" "v-te" "inval"} /*  18  */


if time > v-te * 3600 OR time < v-tb * 3600 then do:
   return.
end. 

