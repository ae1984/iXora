/* getdep.i
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
        22/02/06 nataly
 * BASES
        BANK
 * CHANGES
        10/11/2008 madiyar - изменил поиск, иначе не подтягивался индекс
*/

function getdep returns char (v-cif as char).
def var vdep as integer no-undo.
def var vpoint as integer no-undo.
def var v-dep as char no-undo.

find cif where cif.cif = v-cif no-lock no-error.
if avail cif then do: 

 vpoint = integer(cif.jame) / 1000 - 0.5.
 vdep = integer(cif.jame) - vpoint * 1000.
 find ppoint where ppoint.point = 1 and ppoint.depart = vdep no-lock no-error.
 if avail ppoint then v-dep = ppoint.tel1.
end.
else v-dep = "000" .

return string(v-dep, "999").
end function.

