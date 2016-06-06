/* M9_ps.p
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

/* {global.i}
 {lgps.i} */
 for each dproc where dproc.hst = "wait" no-lock . 
  if dproc.tout = 1000 then do:
     unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
     next. 
    end.
  find first sts where sts.pid = dproc.pid  no-lock no-error  .
   if avail sts then do:
     unix silent value("kill -SIGALRM " + string(dproc.u_pid)) .
   end.
 end.

  
