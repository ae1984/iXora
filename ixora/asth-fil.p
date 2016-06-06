/* asth-fil.p
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

/*helpaaa.p */ 
{global.i}
define shared var helptmp as char.
def shared var v-fil  like codfr.code. 

{apbra.i

&start     = " "
&head      = "codfr"
&headkey   = "codfr"
&index     = "cdco_idx"
&formname  = "hcodfr"
&framename = "hcodfr"
&where     = "codfr.codfr = 'brnchs' "
&addcon    = "false"
&deletecon = "false"
&precreate = " "
&display   = "codfr.code codfr.name[1]"
&highlight = "codfr.code codfr.name[1]"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do
              on endkey undo, leave:
              frame-value = codfr.code.
              helptmp     = codfr.code.
              hide frame haaaa.
              return.
              end."
}














