/* snx1.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Загрузка платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        IB COMM TXB
 * AUTHOR
        09/10/09 id00004
*/

def input  parameter v-rmz        as char .
def output parameter v-payval as char no-undo.

def buffer b-remtrz for txb.remtrz.
def buffer b-que for txb.que.
find last b-remtrz where b-remtrz.remtrz = v-rmz exclusive-lock no-error.
find last b-que where b-que.remtrz = v-rmz exclusive-lock no-error.
if avail b-remtrz and avail b-que then do:
   if avail b-que and b-que.pid = "3A"  and not locked (b-remtrz) and  b-remtrz.jh1 = ? then do:
      delete  b-remtrz.
      release b-remtrz.
/*      delete  b-que.
      release b-que. */
      v-payval = "ok" .
   end.
end.

