/* v2upd.p
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

def var s-rem like rem.rem . 
def shared var s-remtrz like remtrz.remtrz.
def shared frame remtrz.
def var v-date as date.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.

{lgps.i}
{rmz.f}


do transaction :
find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if available remtrz then do :
  v-date = remtrz.valdt2.
  update remtrz.valdt2 with frame remtrz.
  if remtrz.valdt2 entered then do :
    v-text = "Дата 2 проводки изменена для " + remtrz.remtrz + " с " +
    string( v-date) + " на " + string(remtrz.valdt2) .
    
    find first jh where jh.jh = remtrz.jh1 no-lock no-error .
    if avail jh and jh.party begins "RMO"
     then s-rem = substr(jh.party,1,10).
     if s-rem ne "" then
     find first rem where rem.rem = s-rem exclusive-lock no-error .
     if avail rem then 
      do:
       rem.valdt = remtrz.valdt2 .
       v-text = v-text + " RMO = " + s-rem .
      end.
    run lgps.
  end.
release remtrz.
end.
end.
