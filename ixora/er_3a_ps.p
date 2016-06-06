/* er_3a_ps.p
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
        12.07.2004 tsoy добавил коннект к БД ib
        21.09.2004 dpuchkov ограничение на просмотр платежей
        23/10/2012 id00810 - ТЗ 1554, добавлена переменная reas (new shared)
*/

def var acode like crc.code.
def var bcode like crc.code.
def buffer tgl for gl.
def new shared var remtrz like remtrz.remtrz.
def var t-pay like remtrz.amt.
def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.
def new shared var reas as char label "Причина отвержения " format "x(40)" no-undo.
def var ibhost as cha .

{lgps.i "new"}
m_pid = "3A" .
u_pid = "err_3A_ps" .
v-option = "rmzer3A".

def var v-rmz8i like remtrz.remtrz.
def new shared var s-remtrz like remtrz.remtrz.

form skip v-rmz8i with frame rmzor  side-label row 3  centered .


find sysc where sysc.sysc = "IBHOST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do :
 v-text = " Нет IBHOST записи в sysc файле ! ".
 run lgps .
 return .
end .
ibhost = sysc.chval .

v-text = "Прямой доступ к INTERNET базе данных"  . run lgps .
 if not connected("ib") then
  connect value(ibhost) no-error .

if not connected("ib")
then do:
 v-text = " INTERNET HOST не отвечает ." .  run lgps .
 message  " INTERNET HOST не отвечает ." .
 return .
end.



repeat :
{mainhead.i ERR_3A_}
  update v-rmz8i label "Платеж"
    validate (can-find (remtrz where remtrz.remtrz = v-rmz8i),
     "Платеж не найден !" ) with frame rmzor .
      s-remtrz = v-rmz8i.
      find first remtrz where remtrz.remtrz = s-remtrz no-lock.
/*****************************************************/
      find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
      if avail aaa then
      do:
         find cif where cif.cif = aaa.cif  no-lock no-error.
         find last cifsec where cifsec.cif = cif.cif no-lock no-error.
         if avail cifsec then
         do:
           find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
           if not avail cifsec then
           do:
                run crelog("n", cif.cif).
                message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
                undo,retry.

           end.
           else
           do:
              run crelog("u", cif.cif).
           end.
         end.
      end.
/*****************************************************/
  run s-remtrz.
  hide all.
  s-remtrz = "".
end.



















