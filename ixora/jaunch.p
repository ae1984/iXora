/* jaunch.p
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

/*jaunch.p mult.i
04.08.95
*/

{mainhead.i}

def shared var s-cif like cif.cif.

find first checks where checks.cif eq s-cif no-lock no-error.
if not available checks then do:
    bell.
    message "У клиента нет чековой книжки".
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
&display = "checks.nono checks.lidzno checks.regdt /*checks.otime*/
            checks.who checks.prizn
            checks.undt when prizn eq '*' /*checks.untime*/
            checks.whu when prizn eq '*'
            checks.celon when prizn eq '*'"
&numprg = "prompt"
&preadd = " "
&update = "/*checks.nono
           checks.lidzno when checks.lidzno eq 0
           checks.regdt checks.otime
          checks.who
          checks.prizn checks.celon
         checks.undt checks.untime checks.whu*/"
&postupdate = "/*if checks.prizn = '*' then do: checks.undt = g-today.
              checks.whu = g-ofc. end.*/"
&postadd = "/*checks.regdt = g-today.
            checks.who = g-ofc.*/"
&get = " "
&put = " "
&end = " "
}

