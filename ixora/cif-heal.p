/* cif-heal.p
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

/* checked */
/* cif-heal.p
*/

{global.i}

{
head2e.i
&var = "def shared var s-cif like cif.cif."
&start = "find cif where cif.cif = s-cif."
&form =
 " cif.headoff
 "
&fldupdt =
" text(cif.headoff)
"
&frame = "1 col centered row 3 overlay no-label
          title "" Head Office Information """
&vseleform = "1 col row 3 no-label col 67 overlay "
&flddisp =
 "cif.headoff
 "
&file = "cif"
&index = "cif"
&prg1  = "x"
&prg2  = "x"
&prg3  = "x"
&prg4  = "x"
&prg5  = "x"
&prg6  = "x"
&prg7  = "x"
&prg8  = "x"
&prg9  = "x"
&prg10 = "x"
}
