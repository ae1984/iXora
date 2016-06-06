/* tdaaabhist.p
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
        22.08.2006 u00124 перекомпиляция
*/

def input parameter vaaa like aaa.aaa.
def shared var g-lang as char.

{jabro.i
&start = " "
&head = "aab"
&headkey = "aaa"
&where = "aab.aaa = vaaa"
&index = "aab"
&formname = "tdaaabhist"
&framename = "aab"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " "
&display = "aab.fdt aab.bal aab.rate"
&highlight = "aab.fdt"
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = " "
&end = "hide frame aab. hide message."
}
