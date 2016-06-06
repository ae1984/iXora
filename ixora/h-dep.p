/* h-dep.p
 * MODULE
        Файл помощи по департаментам 
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
        22/06/2004 kanat - Добавил возврат значения frame.
*/

{global.i}
def var v-depart as char.
find sysc where sysc.sysc = 'depart' no-lock no-error.
v-depart = sysc.chval.

{itemlist.i
       &file = "ppoint"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = "lookup(string(ppoint.depart), v-depart) <> 0"
       &flddisp = "ppoint.depart FORMAT "99" LABEL ""КОД ""
                   ppoint.name FORMAT ""x(50)"" LABEL ""НАИМЕНОВАНИЕ ДЕПАРТАМЕТА""" 
       &chkey = "depart"
       &chtype = "integer"
       &index  = "pdep" }
return frame-value.

