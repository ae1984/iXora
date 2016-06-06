/* exc2arp.p
 * MODULE
        Обменные операции в Offline PragmaTX (зачисление комиссий с неплатежных валют клиентов)
 * DESCRIPTION
        Зачисление оффлайн обменных операций Offline PragmaTX
 * RUN
        
 * CALLER
        ex2arp.p         
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        07/01/2004 kanat
 * CHANGES
        23/02/2004 kanat - раскомментировал печать операционных ордеров и приходных ордеров
        24/02/2004 kanat - вызов vou_import заменил на вызов vou_bank
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

define variable v-jou as char.

def temp-table bcommpl like commonpl
               field brid as rowid.

def var v-rec-sum as decimal init 0.


for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 0 and commonpl.joudoc = ? 
                    and commonpl.type = 3 and commonpl.rmzdoc = ? and commonpl.txb = seltxb and deluid = ? no-lock:
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.sum.
end.


if v-rec-sum <> 0 then do:

for each bcommpl where bcommpl.deluid = ?:

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
                           
                       run trexcom (bcommpl.comsum,
                                    1).


                        if return-value = '' then do: undo. return. end.
             
                        s-jh = int(return-value).          
                        run setcsymb (s-jh, commonls.symb).

                        run jou.
                        v-jou = return-value.


			run vou_bank(2).

/*                      run vou_import.
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
end. /* сумма <> 0 */


