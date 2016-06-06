/* rmzdruka.p
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

{mainhead.i}
{lgps.i "new"}
m_pid = "R".
def new shared var s-remtrz like remtrz.remtrz.
def new shared stream m-doc.
def var i as inte.
def var nprn as inte format "z9" initial 1.
repeat on endkey undo, return:
update s-remtrz label "Номер платежа   " with
       row 5 centered side-labels frame rem.
update nprn label "Сколько?" with
       row 9 centered side-labels frame dau.
find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
  if not available remtrz then do:
     bell.
     {mesg.i 230}.
     undo, retry.
  end.


find sysc where sysc.sysc = "CLECOD" no-lock no-error.
 if not avail sysc then do:
   message  " Записи CLECOD нет в файле sysc  " .  pause .
   return .
 end.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 message  " Записи OURBNK нет в файле sysc !! ".
 pause .
 return .
end.

 find crc where crc.crc = remtrz.tcrc no-lock.
/* find jh where jh.jh = remtrz.jh2 no-lock no-error.
  if not available jh then do :
      message  "Нет 2 проводки для платежа " + remtrz.remtrz.
      pause .
      return.
   end.
 */
  s-remtrz = remtrz.remtrz .
  output stream m-doc to value("remtrz.doc").

  do i = 1 to nprn:
   run pdpsr.
           /*
           if rem.crc2 = 1 then do:
              run mufjs1. pause 0.
           end.
           else do:
              run mufj1. pause 0.
           end.
           */
  end.
     output stream m-doc close.
     output to terminal.
     unix silent prit value("remtrz.doc").
     /*
     unix silent /bin/rm -f value(remtrz.remtrz + ".doc").
   */
end.
