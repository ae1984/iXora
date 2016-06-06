/* r-gcvp1p.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Отчет Период указывается с ... по ... включительно!!! 
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM TXB 
 * AUTHOR
        22.08.08  marinav
 * CHANGES
        22.07.2009 galina - не выводим 20-тизначные счета
*/

def input parameter v-bank as char.

def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table wrk
             field bank as char
             field name like bank.cif.name
             field dt as date 
             field aaa like bank.aaa.aaa.

def var v-name as char.

for each txb.aaa where txb.aaa.regdt >= v-dtb and txb.aaa.regdt <= v-dte and txb.aaa.lgr = '246' no-lock.
   /*galina - убрать после введения 20-тизначных счетов*/
   if length(txb.aaa.aaa) = 20 then next. 
   /**/
    
    v-name = ''.
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then v-name = txb.cif.name.

    create wrk.
    assign wrk.bank = v-bank
           wrk.name = v-name
           wrk.dt   = txb.cif.expdt
           wrk.aaa  = txb.aaa.aaa.

end.

