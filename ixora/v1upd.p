/* v1upd.p
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
  v-date = remtrz.valdt1.
  update remtrz.valdt1 with frame remtrz.
  if remtrz.valdt1 entered then do :
    v-text = "Дата 1 проводки изменена для " + remtrz.remtrz + " с " +
     string( v-date) + " на " + string(remtrz.valdt1) .
    run lgps.
  end.
release remtrz.
end.
end.
