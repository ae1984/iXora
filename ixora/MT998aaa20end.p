/* MT998aaa20end.p
 * MODULE
        Убиваем процес AAA20
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
        17.06.2009 galina
 * BASES 
        BANK        
 * CHANGES
        
        
*/
{lgps.i "new"}

m_pid = "AAA20".

find first dproc where dproc.pid = m_pid no-lock no-error.
   if avail dproc then do:
      v-text = " Процесс AAA20 завершил свою работу. Начинается останов процесса... ".
      run lgps.
      find current dproc exclusive-lock no-error.
      dproc.tout = 1000.
   end.