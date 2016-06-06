/* gotoD.p
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

 {global.i}
 {lgps.i }
 def shared var s-remtrz like remtrz.remtrz.
def var yn as log initial false format "да/нет".
 def shared var per as int.
 u_pid = 'goto-D'.

 do transaction :
 find first remtrz  where remtrz.remtrz = s-remtrz exclusive-lock  no-error.
 find first que where que.remtrz = s-remtrz
  exclusive-lock no-error.
 if que.pid = 'GD' and remtrz.jh1 = ? then
  do:
   Message " Are you sure ? " update yn .
   if  yn then do:
    que.dw = today.
    que.tw = time.
    que.pid = "D".
    que.con = "W".
    que.pri = integer(substr(que.npar,13,5)).
    v-text = s-remtrz + " was selected and send G -> D " .
    run lgps.
    per = 1.
    end.
  end.
  else do:
  message "Before delete 1 TRX".
  end.
end.
