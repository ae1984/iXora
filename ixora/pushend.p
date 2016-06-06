/* pushend.p
 * MODULE
        Останов процесса PUSH_ps
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08/01/2009 galina
 * BASES
        BANK
 * CHANGES
*/

{global.i}


{lgps.i "new"}
m_pid = "PUSH".

find first dproc where dproc.pid = m_pid no-lock no-error.
if avail dproc then do:
   v-text = " Процесс PUSH завершил свою работу. Начинается останов процесса... ".
   run lgps.
   find current dproc exclusive-lock no-error.
   dproc.tout = 1000.
end.