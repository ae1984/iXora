/* r-gcvp3p.p
 * MODULE
        отчеты по ГЦВП - выплата пенсий и пособий
 * DESCRIPTION
        Отчет по отсутствию операций по счету 
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

def shared temp-table wrk
             field bank as char
             field name like bank.cif.name
             field dt as date 
             field aaa like bank.aaa.aaa
             field jdt as date. 

def var v-name as char.

for each txb.aaa where txb.aaa.regdt < v-dtb - 90 and txb.aaa.lgr = '246' no-lock.
                                       
    v-name = ''.
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then v-name = txb.cif.name.

    find last txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.dc = 'D' no-lock no-error.
    if not avail txb.jl then do:
       create wrk.
       assign wrk.bank = v-bank
              wrk.name = v-name
              wrk.dt   = txb.cif.expdt
              wrk.aaa  = txb.aaa.aaa.
    end.
    if avail txb.jl and txb.jl.jdt < v-dtb - 90 then do:
       create wrk.
       assign wrk.bank = v-bank
              wrk.name = v-name
              wrk.dt   = txb.cif.expdt
              wrk.aaa  = txb.aaa.aaa
              wrk.jdt  = txb.jl.jdt.
    end.

end.

