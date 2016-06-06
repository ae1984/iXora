/* 3m_voz.p
 * MODULE
        Услуги системы Интернет банк
 * DESCRIPTION
        Возврат на 3А
 * RUN
        3m_voz.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-2-11
 * AUTHOR
        06/09/2004 saltanat
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{lgps.i}
def shared var s-remtrz like remtrz.remtrz.
def var yn as log initial false format "да/нет".

Message " Вы уверены ? " update yn .

if yn then do:

find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
 if not avail remtrz then do:
    message skip "Платеж не найден. Возможно клиент уже отозвал этот платеж  " skip(1) view-as alert-box title " ОШИБКА ! ".
    return.
end.

find first que where que.remtrz = s-remtrz exclusive-lock no-error .
if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
 Message " Вы не владелец !! Отправить невозможно " . pause .
 undo.
 release que .
 return .
end.
if avail que then do :
  que.pid = m_pid.
  que.rcod = "1" .
  v-text = " Отправлен " + remtrz.remtrz + " по маршруту 3М - 3A, rcod = " +
  que.rcod + " " + remtrz.sbank + " -> " + remtrz.rbank .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
  release que .
end. /* que */

end. /* yn */
