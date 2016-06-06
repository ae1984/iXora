/* set-limit.p

 * MODULE

 * DESCRIPTION
        Установка овердрафта для определенного счета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM TXB
 * AUTHOR
        15.07.2010 k.gitalov
 * CHANGES

*/

def input param iTXB as char.
def input param iCif as char.
def input param iAcc as char.
def input param iSumm as deci.

def buffer b-aaa for txb.aaa.
def var overacc as char.

   find txb.sysc where txb.sysc.sysc = 'OURBNK' no-lock no-error.
   if avail txb.sysc then
   do:
    if txb.sysc.chval = iTXB then
    do:
      do transaction:
       find first b-aaa where b-aaa.cif = iCif and  b-aaa.aaa = iAcc and b-aaa.sta <> "E" and b-aaa.sta <> "C"  no-lock no-error.
	   if avail b-aaa then
	   do:

	     overacc = b-aaa.craccnt.
	     find first b-aaa where b-aaa.aaa = overacc exclusive-lock no-error.
	     if avail b-aaa then
	     do:
	       b-aaa.cbal = iSumm.
	       b-aaa.opnamt = iSumm.
	     end.
	     else do:  message "Отсутсвтвует овердрафтный счет для " iAcc view-as alert-box. undo. end.
	   end.
	   else do: message "Не найден счет " iAcc view-as alert-box. undo. end.
	  end. /*transaction*/
    end.
   end.
   else do: message "Отсутствует переменная OURBNK!" view-as alert-box. end.

