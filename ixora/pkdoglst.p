/* pkdoglst.p
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

/* pkdoglst.p Потребкредиты
   Список документов по оформлению потребкредитов с настройкой по видам кредитов

   20.03.2003 nadejda
*/

{mainhead.i}
{pk.i new}

form
  "<ENTER> - редактир.,  <INS> - вставка,  <Ctrl-D> - удаление"
  with centered row 21 no-box frame footer.


{jabrw.i 

&start     = " "
&head      = "pkdocs"
&headkey   = "name"
&index     = "name"
&formname  = "pkdoglst"
&framename = "f-docs"
&where     = " true "
&addcon    = "true"
&deletecon = "true"
&predelete = " " 
&precreate = " "
&postcreate = " pkdocs.credtype = '0'. pkdocs.rdt = g-today. pkdocs.rwho = g-ofc. "
&preupdate = " "
&update    = " pkdocs.name pkdocs.credtype pkdocs.proc pkdocs.separat "
&postupdate = " if not new pkdocs then assign pkdocs.udt = g-today pkdocs.uwho = g-ofc."
&prechoose = " "
&predisplay = " view frame footer. "
&display   = " pkdocs.name pkdocs.credtype pkdocs.proc pkdocs.separat "
&highlight = " pkdocs.name "
&postkey   = " "
&end       = " hide frame f-docs. hide frame footer. "
}

