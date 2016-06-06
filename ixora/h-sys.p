/* h-sys.p
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

/* h-quetyp.p */
{global.i}
def shared var v-sys as cha . 
def var h as int .
 h = 12 .
  do:
       {browpnp.i
        &h = "h"
        &where = "true"
        &frame-phrase = "row 1 centered scroll 1 h down overlay "
        &disp = "trxsys" 
        &file = "trxsys"
        &seldisp = "trxsys.system"
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " v-sys  =  trim(trxsys.system) . 
         hide all . "
       }
  end.
