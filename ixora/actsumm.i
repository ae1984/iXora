/* actsumm.i
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

for each aaa where aaa.cif = "p2040" break by aaa.lgr:
      find lgr of aaa no-lock.
      display lgr.des aaa.aaa  aaa.cr[1] - aaa.dr[1].
      end.
