/* MT998end.p
 * MODULE
        Убиваем процес MT998
 * DESCRIPTION
        Процесс, запускающий все отчеты в pushrep по графику
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        
 * AUTHOR
        16.09.2008 galina
 * BASES 
        BANK        
 * CHANGES
        
        
*/
{lgps.i "new"}

m_pid = "MT998".

find first dproc where dproc.pid = m_pid no-lock no-error.
   if avail dproc then do:
      v-text = " Процесс MT998 завершил свою работу. Начинается останов процесса... ".
      run lgps.
      find current dproc exclusive-lock no-error.
      dproc.tout = 1000.
   end.