/* h-trxsys.p
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
def new shared var v-sys like trxhead.system . 
def var h as int .
 h = 12 .
  do:
      run h-sys.
  /*
   Message  " Systems ? " update  v-sys  . */ 
       {browpnp.i
        &h = "h"
        &where = " (( trxhead.system  matches
         ""*"" + v-sys + ""*"" ) or ( v-sys = """" )) "
        &frame-phrase = "row 1 centered scroll 1 h down overlay "
        &disp = "trxhead.system column-label ""Sys"" 
         trxhead.code   column-label ""Code""
         trxhead.des"
        &file = "trxhead"
        &seldisp = "trxhead.system trxhead.code trxhead.des"
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " frame-value = 
         trxhead.system + string(trxhead.code,""9999"")  . 
         hide all . "
       }
  end.
