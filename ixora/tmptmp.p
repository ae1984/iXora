﻿/* tmptmp.p
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

for each eps:
  eps.pdr[12] = 0.
  eps.pcr[12] = 0.
  eps.basic   = 0.
  eps.addr    = 0.
  eps.movein  = 0.
  eps.moveout = 0.
  eps.red     = 0.
end.
find sysc where sysc.sysc eq "CURMON".
sysc.inval = 1.