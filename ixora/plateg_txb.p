/* plateg_txb.p
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
        02.03.05 saltanat
 * CHANGES
*/
define input parameter dtb as date.
define input parameter dte as date.
define output parameter ibhkol_cl as inte init 0.
define output parameter ibhsum_cl as deci init 0.
define output parameter ibhkol_gr as inte init 0.
define output parameter ibhsum_gr as deci init 0.

for each txb.remtrz where txb.remtrz.rdt >= dtb and txb.remtrz.rdt <= dte no-lock.
   if txb.remtrz.source ne 'IBH' then next.
   if txb.remtrz.rbank begins 'TXB' then next.
   if remtrz.cover = 1 then do:
      ibhkol_cl = ibhkol_cl + 1.
      ibhsum_cl = ibhsum_cl + remtrz.amt.
   end.
   else do:
      ibhkol_gr = ibhkol_gr + 1.
      ibhsum_gr = ibhsum_gr + remtrz.amt.
   end.
end.