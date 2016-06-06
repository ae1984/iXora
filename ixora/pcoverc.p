/* pcoverc.p
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
def var v-cover like remtrz.cover.
def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.

{lgps.i}
{rmz.f}


do transaction :
find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if available remtrz then do :
 if remtrz.jh2 ne ? and remtrz.jh2 ne 0 then do :
  v-text = "Вторая проводка уже сделана для " +
  remtrz.remtrz + " . Изменить транспорт невозможно!".
  run lgps.
  release remtrz.
 end.
 else do :
  v-cover = remtrz.cover.
  update remtrz.cover with frame remtrz.
  if remtrz.cover entered then do :
    v-text = "Транспорт изменен для " + remtrz.remtrz + " с " +
     string( v-cover) + " на " + string(remtrz.cover) .
    run lgps.
  end.
  release remtrz.
 end.
end.
end.
