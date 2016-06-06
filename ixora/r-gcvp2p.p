/* r-gcvp2p.p
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
*/

def input parameter v-bank as char.

def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table wrk
             field bank as char
             field name like bank.cif.name
             field dt as date 
             field aaa like bank.aaa.aaa
             field pr as char.

def var v-name as char.
def var v-pr as char.

for each txb.aaa where txb.aaa.lgr = '246' no-lock.


       v-name = ''. 
       find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
       if avail txb.cif then v-name = txb.cif.name.
       /* менялась ли фамилия */
       find last txb.clfilials where txb.clfilials.cif = txb.cif.cif and txb.clfilials.whn >= v-dtb and txb.clfilials.whn <= v-dte no-lock no-error.
       if avail txb.clfilials then do:

           create wrk.
           assign wrk.bank = v-bank
                  wrk.name = v-name
                  wrk.dt   = txb.cif.expdt
                  wrk.aaa  = txb.aaa.aaa.
                  wrk.pr   = txb.clfilials.namefil.
       end.
 
       if txb.aaa.sta = "C" then do:
           find first txb.sub-cod where txb.sub-cod.sub = 'cif' and  txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
           if txb.sub-cod.rdt < v-dtb or txb.aaa.regdt > v-dte then next.

           create wrk.
           assign wrk.bank = v-bank
                  wrk.name = v-name
                  wrk.dt   = txb.cif.expdt
                  wrk.aaa  = txb.aaa.aaa.
                  wrk.pr   = ''.
       end.

end.

