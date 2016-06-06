/* zfunlstp.p
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

/* checked */
/* zfunlst.p */

output to printer page-size 60.

for each fun break by fun.grp:
  display fun.grp format 'zz9' fun.fun
          fun.dam[1](total by fun.grp)
          fun.cam[1](total by fun.grp)
          with frame fun down width 132.
end.
