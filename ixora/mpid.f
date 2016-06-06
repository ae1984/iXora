/* mpid.f
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

form " " dproc.pid column-label "Process"
dproc.copy label "Cp" dproc.tout label "Pause"  dproc.u_pid idle
label "  Idle " v-dproc no-label 
  with column 42 h down title m_hst overlay frame pid.
