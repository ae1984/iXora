/* opokk2.p
 * MODULE
        Касса
 * DESCRIPTION
        Отчет по остаткам кассы - консолидированный
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24.11.2010 evseev
 * BASES
        BANK COMM TXB
 * CHANGES
        03.12.2010 evseev суммирование 100100 + 100200
        14.12.10   marinav - добавлен счет 100110

*/

def input parameter dat as date no-undo.
def input parameter txbid as int no-undo.
def input parameter city as char no-undo.
/*def output parameter v-list as char no-undo.*/
def var v-bal like txb.glday.bal.
def var v-bal1 like txb.glday.bal.
define shared temp-table tbl_opokk
    field txb        as int
    field filialname as char init ''
	field crc        like bank.crc.crc
	field bal        like bank.glday.bal.

for each bank.crc no-lock:

   v-bal = 0.
   find last txb.glday where txb.glday.gl = 100200 and txb.glday.gdt < dat and txb.glday.crc = bank.crc.crc no-lock no-error.
   if avail txb.glday  then do:
     v-bal = txb.glday.bal.
   end.

   v-bal1 = 0.
   find last txb.glday where txb.glday.gl = 100100 and txb.glday.gdt < dat and txb.glday.crc = bank.crc.crc no-lock no-error.
   if avail txb.glday then do:
     v-bal1 = txb.glday.bal.
   end.

   find last txb.glday where txb.glday.gl = 100110 and txb.glday.gdt < dat and txb.glday.crc = bank.crc.crc no-lock no-error.
   if avail txb.glday then do:
     v-bal1 = v-bal1 + txb.glday.bal.
   end.

   if v-bal + v-bal1 <> 0 then do:
      create tbl_opokk.
        assign
         tbl_opokk.txb = txbid
         tbl_opokk.filialname = city
         tbl_opokk.crc = txb.glday.crc
         tbl_opokk.bal = v-bal + v-bal1.
   end.
end.