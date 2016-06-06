/* findkorclr.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Определяет - работает ли банк-корреспондент банка-получателя по клирингу, 
	если нет то возвращает false
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
	3-outg.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        09.06.05 u00121
 * CHANGES
 * BASES
	TXB
*/
def input param i-bank as char . /*БИК проверяемого банка-получателя*/
def output param l-clr as log init false. /*возвращаемый параметр: false, не работает по клирингу; true, работает по клирингу (по умолчанию банк-корреспондент не работает по клирингу)*/

def var v-cbank as char. /*БИК банка-корреспондента*/

find last txb.bankl where txb.bankl.bank = i-bank no-lock no-error. /*найдем банк-получатель в справочнике банков*/
if avail txb.bankl then
do:
	v-cbank = txb.bankl.cbank. /*запомним БИК банка-корреспондента*/
	find last txb.bankl where txb.bankl.bank = v-cbank  no-lock no-error. /*Найдем банк-корреспондент в справочнике банков*/
	if avail txb.bankl and bankl.crbank = "clear" then /*если нашли и он работает по клирингу*/
		l-clr = true. /*возвращаем true*/
end.

