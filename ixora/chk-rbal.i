/* chk-rbal.i
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
        05.10.2005 dpuchkov добавил проверку для налоговых платежей и пенсионных платежей
        11.10.2012 Lyubov - ТЗ 1528, добавлен КНП зарплатных платежей 311
*/


/*** KOVAL Проверка остатка на счете по RMZ

return :
?         - была ошибка
decimal - остаток, отриц. или положит.

***/

function Chk-rbal returns decimal ( rmz as char).
def var vbal as decimal.
def buffer xaaa for aaa.
def buffer rrmz for remtrz.
def var v-text as char.
def buffer bx-aas for aas.
def var i-sta as integer init 0.


   find first rrmz where rrmz.remtrz = rmz no-lock.
   if not avail rrmz then do:
      v-text = "Ошибка! chk-rbal запись с " + rmz + " не найдена...".
      run lgps.
      return ?.
   end.

   find first aaa where aaa.aaa = rrmz.dracc no-lock no-error.
   if not avail aaa then do:
      v-text = "Ошибка! chk-rbal  Счет " + rrmz.dracc + " не найден...".
      run lgps.
      return ?.
   end.

   if aaa.craccnt <> "" then

    find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
    vbal = aaa.cbal - aaa.hbal +
    ( if available xaaa then xaaa.cbal else 0 ) -
    ( if rrmz.svcaaa = rrmz.dracc then rrmz.svca else 0 ) - rrmz.amt.

find first sub-cod where sub-cod.acc = rmz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "911,912,913,931,932") <> 0 and substr (rrmz.rcvinfo[1], 2, 3) = "TAX" then do:
   i-sta = 0.
   find last bx-aas where bx-aas.aaa = aaa.aaa and bx-aas.sta = 2 no-lock no-error.
   if avail bx-aas then do:
      find last bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "16,11") <> 0 no-lock no-error.
      if avail bx-aas then do:
         i-sta = 1.
      end.
   end.


   if i-sta <> 1 then do:
      for each bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "2,11,16") <> 0 no-lock:
          vbal = vbal + bx-aas.chkamt.
      end.
   end.
end.
if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017,311") <> 0 and substr (rrmz.rcvinfo[1], 2, 3) = "PSJ" then do:
   i-sta = 0.
   find last bx-aas where bx-aas.aaa = aaa.aaa and bx-aas.sta = 2 no-lock no-error.
   if not avail bx-aas then do:
      for each bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "11,16") <> 0 no-lock:
          vbal = vbal + bx-aas.chkamt.
      end.
   end.
end.



    if vbal < 0 then return vbal.
    if svcaaa <> "" then do:
        find first aaa where aaa.aaa = rrmz.svcaaa no-lock no-error.
        if not avail aaa then do:
            v-text = "Ошибка! " + rrmz.svcaaa + " не найден...".
            run lgps.
            return ?.
        end.

        if aaa.craccnt <> "" then
        find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
        vbal = aaa.cbal - aaa.hbal +
        ( if available xaaa then xaaa.cbal else 0 ) - rrmz.svca.

find first sub-cod where sub-cod.acc = rmz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "911,912,913,931,932") <> 0 and substr (rrmz.rcvinfo[1], 2, 3) = "TAX" then do:
   i-sta = 0.
   find last bx-aas where bx-aas.aaa = aaa.aaa and bx-aas.sta = 2 no-lock no-error.
   if avail bx-aas then do:
      find last bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "16,11") <> 0 no-lock no-error.
      if avail bx-aas then do:
         i-sta = 1.
      end.
   end.

   if i-sta <> 1 then do:
      for each bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "2,11,16") <> 0 no-lock:
          vbal = vbal + bx-aas.chkamt.
      end.
   end.
end.
if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017,311") <> 0 and substr (rrmz.rcvinfo[1], 2, 3) = "PSJ" then do:
   i-sta = 0.
   find last bx-aas where bx-aas.aaa = aaa.aaa and bx-aas.sta = 2 no-lock no-error.
   if not avail bx-aas then do:
      for each bx-aas where bx-aas.aaa = aaa.aaa and lookup(string(bx-aas.sta), "11,16") <> 0 no-lock:
          vbal = vbal + bx-aas.chkamt.
      end.
   end.
end.


        if vbal < 0 then return vbal.
   end.
   return vbal.
end function.
