/* fs_kc.i
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


     if v-srok ge 0 and v-srok le 30 then do: 
        find first t_kci where nn = 1 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.
     if v-srok ge 31 and v-srok le 90 then do: 
        find first t_kci where nn = 2 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.
     if v-srok ge 91 and v-srok le 180 then do: 
        find first t_kci where nn = 3 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.
     if v-srok ge 181 and v-srok le 360 then do: 
        find first t_kci where nn = 4 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.
     if v-srok ge 361 and v-srok le 720 then do: 
        find first t_kci where nn = 5 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.
     if v-srok > 720 then do: 
        find first t_kci where nn = 6 no-lock no-error.
        {1} = {1} + balance.
        {2} = {2} + balance * ln%his.intrate / 100.
     end.

