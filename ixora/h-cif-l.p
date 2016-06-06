/* h-cif-l.p
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

def shared var g-lang as char.
{jabrw.i
&start = " "
&head = "cif"
&headkey = "cif"
&where = "cif.geo > '010' and cif.geo < '013'"
&index = "geo"
&formname = "h-cif-l"
&framename = "h-cif-l"
&addcon = "false"
&deletecon = "false"
&predisplay = " "
&display = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ cif.name"
&highlight = "cif.cif cif.name"
&postcreate = " "
&postdisplay = " "
&postadd = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              frame-value = cif.cif.
              hide frame h-cif-l.
              return.
            end."

&end = "hide frame h-cif-l."
}
