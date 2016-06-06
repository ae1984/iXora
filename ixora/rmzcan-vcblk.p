/* rmzcan-vcblk.p
 * MODULE
        Платежная система
 * DESCRIPTION
        При удалении второй проводки внешнего платежа:
        Если вторая проводка была блокировкой суммы на транзитном счете валютного контроля, то удаление записи в списке блокированных сумм
 * RUN
        
 * CALLER
        rmzcan.p, rmzcan2.p, rmzcano.p, rmzcanG.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-...
 * AUTHOR
        09.10.2003 nadejda
 * CHANGES
*/

{vc.i}

def input parameter v-remtrz like remtrz.remtrz.

{comm-txb.i}
def var v-ourbank as char.
v-ourbank = comm-txb().

find vcblock where vcblock.bank = v-ourbank and vcblock.remtrz = v-remtrz exclusive-lock no-error.
if avail vcblock then delete vcblock.

