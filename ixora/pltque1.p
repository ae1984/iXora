/* pltque1.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Автоматическая оплата суммы в удостоверяющий центр
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
 * BASES
        TXB COMM
 * AUTHOR
       19/05/2010 id00004
 * CHANGES
       29/06/2012 k.gitalov изменил сумму платежа на 1620

*/






def input  parameter pExtid  as char .
def input parameter pAccount as char no-undo.
def output parameter rcod as char.
def output parameter rdes as char.




  find last txb.aaa where txb.aaa.aaa = pAccount and txb.aaa.cif = pExtid no-lock no-error.
  if avail txb.aaa then do:
     if (txb.aaa.cbal - txb.aaa.hbal)  >= 1620 then do:
        rcod = "1".
     end.
     else do:
        rcod = "0".
        rdes = "Нехватка средств" .
     end.
  end.
  else do:
     rcod = "0".
     rdes = "Не найден счет" .
  end.