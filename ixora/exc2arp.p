/* exc2arp.p
 * MODULE
        Обменные операции в Offline PragmaTX (зачисление)
 * DESCRIPTION
        Зачисление оффлайн обменных операций Offline PragmaTX
 * RUN
        
 * CALLER
        excsofp.p         
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        29/01/2004 kanat
 * CHANGES
        03/03/2004 kanat Добавил передачу даты проведения операции в процедуру trexoff.  
        23/03/2004 kanat Добавил еще один транзакционный блок - для отката всех операций кассира.
        27/09/2004 kanat Сделал группировку по номерам квитанций при формировании временной таблицы операций за день
        29/09/2004 kanat Добавил группировку по типам операций	 
        13/10/2004 kanat Так как кассиры берут аванс перед обменными операциями, а не остаток в конце дня - 
                         то для упорядочивания операций - они будут делаться в группировке номеров квитанций
        24/08/2005 kanat Закомментировал формирование операционного ордера 
        12/09/2005 kanat Добавил условие по удаленныи квитанциям
*/


{global.i}
{sysc.i}
{comm-txb.i}

def input parameter vdate as date.
def input parameter v-ofc as char.

def var seltxb as int.
def var ourbank as char.
ourbank = comm-txb().
seltxb  = comm-cod().

{get-dep.i}
{yes-no.i}
{padc.i}
{u-2-d.i}

def new shared var s-jh like jh.jh.

def var lcom  as logical init false.
def var cdate as date init today.
def var selgrp  as integer init 0.  /* Определяем номер группы в таблице commonls */
def var seltype as integer init 1.  /* type в таблице commonls */
def var docnum as integer.
def var dlm     as char.

def var cTitle as char init '' no-undo.
def var crlf as char.
def var s_sbank as char.

def var v-knp as char.
define variable v-jou as char.
def temp-table bcommpl like commonpl
               field brid as rowid.
def var v-rec-sum as decimal init 0.

def new shared var vs-drcur as integer.
def new shared var vs-crcur as integer.
def new shared var vs-dramt as decimal.
def new shared var vs-cramt as decimal.
def new shared var vs-rem as char.
def new shared var vs-rate1 as decimal.
def new shared var vs-rate2 as decimal.
def new shared var vs-dracctype as char.
def new shared var vs-cracctype as char.


def new shared var vrat as decimal decimals 2.

def var crc_temp1 as char.
def var crc_temp2 as char.

def var dr_sum as decimal.
def var dr_cur as integer.
def var dr_rate as char.

def var cr_cur as integer.
def var cr_rate as char.

def var v-temp-sum as decimal.
def var v-temp-razn as decimal.

def var v-dr-sum as decimal.
def var v-cr-sum as decimal.

def var v-exc-sum as decimal.

g-fname = "obmen".

for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 0 and commonpl.joudoc = ?  
                    and commonpl.type <> 3 and commonpl.rmzdoc = ? and commonpl.txb = seltxb and deluid = ? 
                    no-lock break by commonpl.dnum:
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.sum.
end.


if v-rec-sum <> 0 then do:

do transaction:

for each bcommpl where bcommpl.deluid = ? break by bcommpl.dnum:

find first commonls where commonls.txb = bcommpl.txb and    /* Ради приличия */
                          commonls.grp = bcommpl.grp  
                          no-lock no-error.
if not avail commonls then do:
 MESSAGE "Не настроена таблица commonls по обменным операциям." 
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Обменные операции.".
 return.
end.


do transaction:
/* В валюте */
            vrat = decimal(bcommpl.chval[2]).
            vs-rem = 'Обмен валюты'. 

	    vs-dracctype = '4'.
            vs-cracctype = '4'.  
                             
            if bcommpl.type = 1 then do:    /* Покупка */
            v-knp = '211'.
            vs-drcur = bcommpl.typegrp.
            vs-crcur = 1.
            v-exc-sum = bcommpl.sum.

            vs-dramt = bcommpl.sum.
            vs-cramt = bcommpl.comsum.
            vs-rate1 = decimal(bcommpl.chval[2]).
            vs-rate2 = 1.

            end.

            if bcommpl.type = 2 then do:    /* Продажа */
            v-knp = '221'.
            vs-drcur = 1.
            vs-crcur = bcommpl.typegrp.
            v-exc-sum = bcommpl.comsum.

            vs-dramt = bcommpl.comsum.
            vs-cramt = bcommpl.sum.
            vs-rate1 = 1.
            vs-rate2 = decimal(bcommpl.chval[2]).

            end.

                       run trexoff('Зачисление обменных операций для Offline PragmaTX',
				    v-exc-sum,
				    vs-drcur,
                                    vs-rem,
                                    vs-crcur,
			            v-ofc,
                                    bcommpl.date).

                        if return-value = '' then do: undo. return. end.
             
                        s-jh = int(return-value).          
                        run setcsymb (s-jh, commonls.symb).

                        run excjou.
                        v-jou = return-value.

/*
                        run vou_import.
*/

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and 
                                                                           commonpl.grp = 0 and                    
                                                                           commonpl.type = bcommpl.type and        
                                                                           commonpl.uid = bcommpl.uid and          
                                                                           commonpl.dnum = bcommpl.dnum and        
                                                                           commonpl.sum = bcommpl.sum              
                                                                           no-lock no-error.                       
                        if avail commonpl then assign commonpl.joudoc = v-jou.

   end. /* do transaction */
end. /* for each bcommpl */
end. /* Еще один транзакционный блок */
end. /* сумма <> 0 */

