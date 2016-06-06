/* jou42-blkdel.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        При удалении проводки :
        Проверить, не была ли это проводка с транзитного счета валютного контроля на счет клиента
        Если это такая проводка, то снять отметку о зачислении средств на счет клиента
 * RUN
        
 * CALLER
        jou_main.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-1
 * AUTHOR
        13.10.2003 nadejda
 * CHANGES
        
*/


{vc.i}

def input parameter p-jh like jh.jh.

{comm-txb.i}
def var v-ourbank as char.
v-ourbank = comm-txb().

find vcblock where vcblock.bank = v-ourbank and vcblock.jh2 = p-jh exclusive-lock no-error.
if avail vcblock then do:
  assign vcblock.acc = ""
         vcblock.jh2 = 0
         vcblock.sts = "B"
         vcblock.cif = "".
  release vcblock.
end.


