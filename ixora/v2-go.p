/* v2-go.p
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

{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".
def shared var g-today as date.

Message "Вы уверены?" update yn .

find first remtrz where remtrz.remtrz = s-remtrz no-lock  .
if remtrz.valdt2 > g-today  then  do:
 Message "Ошибка! 2дата > текущей даты!" . pause .
 return .
end.

if yn then do transaction :

find first que where que.remtrz = s-remtrz exclusive-lock no-error .

if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
 Message "Ошибка! Вы не являетесь владельцем!" . pause .
 undo.
 release que .
 return .
end.

if avail que then do :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .

  {canbal.i}
  {nbal+r.i}
  que.pid = m_pid.
  que.rcod = "0".
  v-text = " Отсылка " + remtrz.remtrz + " по маршруту , код возврата = "
        + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
  release que .
end.
end .
