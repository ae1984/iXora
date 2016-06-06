/* movedarc.p
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

{global.i}
{lgps.i "new"}
m_pid = 'MOV'.
u_pid = 'movedarc'.

FOR each que where que.pid = 'D' and que.con = 'W' exclusive-lock. 

v-text = que.remtrz + ' архивирован  '.
que.pid = 'ARC'.
  que.dp = today.
  que.tp = time.
 run lgps.
end.

