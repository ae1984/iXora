﻿/* check.p
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
        13.10.05 dpuchkov добавил серию чека
*/

/*check.p mult.i
10.07.95
*/

{mainhead.i}
def shared var s-cif like cif.cif.

find first checks where checks.cif eq s-cif no-lock no-error.
if not available checks then do:
    message "У клиента нет чековых книжек !".
    pause 1.
    return.
end.

{mult.i
&head = "checks"
&headkey = "nono"
&where = "checks.cif eq s-cif"
&index = "cif"
&type = "integer"
&datetype = "integer"
&formname = "checks"
&framename = "checks"
&addcon = "true"
&deletecon = "true"
&updatecon = "true"
&display = "checks.nono   label 'С'
            checks.lidzno label 'По'
            checks.regdt  label 'Дата рег.'
            checks.ser    label 'Серия' format 'x(2)'
            checks.who    label 'Исполн.'
            checks.prizn  label 'Признак'
            checks.undt   label 'Аннулир.' when prizn eq '*' /*checks.untime*/
            checks.whu    label 'Исполн.' when prizn eq '*'
            checks.celon  label 'Причина' when prizn eq '*'"

&numprg = "prompt"
&preadd = " "
&update = "/*checks.nono*/
           checks.lidzno when checks.lidzno eq 0
           /*checks.regdt checks.otime
          checks.who */
          checks.prizn checks.celon
         /*checks.undt checks.untime checks.whu*/"
&postupdate = "if checks.prizn = '*' then do: checks.undt = g-today.
              checks.whu = g-ofc.
              find gram where gram.nono = checks.nono and gram.ser = checks.ser no-error.
              if not available gram then return.
              gram.anuatz = '*'.
              gram.atzdat = g-today.
              gram.atzwho = g-ofc.
              end."

&postadd = "checks.regdt = g-today.
            checks.who = g-ofc."
&get = " "
&put = " "
&end = " "
}
