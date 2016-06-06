/* s-go.p
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
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{lgps.i }
{global.i}
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "да/нет".
def var ok as log .
Message " Are you sure ? " update yn .

find first remtrz where remtrz.remtrz = s-remtrz no-lock  .
if remtrz.cover eq 0 then do:
 Message " REMTRZ.COVER eq 0 yet !! Impossible to send " . pause .
 return .
end.

if yn then do transaction :

find first que where que.remtrz = s-remtrz exclusive-lock no-error .

if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
 Message " Not owner !! Impossible to send " . pause .
 undo.
 release que .
 return .
end.

if avail que then do :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .

  {canbal.i}
  {nbal+r.i}
  que.pid = m_pid.
  que.rcod = "99" .

     if remtrz.cover = 4 then que.rcod = "10" .
     if remtrz.cover = 1 then que.rcod = "20" .
     if remtrz.cover = 3 then que.rcod = "30" .


  v-text = " Send " + remtrz.remtrz + " by route , rcod = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
  release que .
end.
end .
