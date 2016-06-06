/* ned2arp.p
 * MODULE
        Offline PragmaTX (зачисление недостач кассиров)
 * DESCRIPTION
        Зачисление недостач кассиров Offline PragmaTX
 * RUN
        
 * CALLER
        excsofp.p         
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        29/03/2004 kanat
 * CHANGES
        06/04/2004 kanat - поменял АРП счета для погашений по валютам
        09/04/2004 kanat - поменял формирование примечаний для транзакций и приходных ордеров и поменял visible = yes на visible = no. 	 
        29/04/2004 kanat - поменял номера АРП счетов для тенге и долларов.
        01/10/2004 kanat - добавил условие по формированию операционных ордеров
        17/07/2006 marinav - для Уральска добавила номер счета - в будущем перенести в настройки
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/

{global.i}
{sysc.i}
{comm-txb.i}

def input parameter vdate as date.
def input parameter v-ofc as char.

def new shared var dbcrc as integer.
def new shared var crcrc as integer.

def var seltxb as int.
def var ourbank as char.
def var v-ofc-fullname as char.

find first ofc where ofc.ofc = v-ofc no-lock no-error.
if avail ofc then 
v-ofc-fullname = ofc.name.
else do:
message "Данные на кассира отсутствуют" view-as alert-box title "Внимание".
return.
end.

ourbank = comm-txb().
seltxb  = comm-cod().

{get-dep.i}
{yes-no.i}
{padc.i} 
{u-2-d.i}

def new shared var s-jh like jh.jh.

def var lcom  as logical init false.
def var cdate as date init today.
def var selgrp  as integer init 10.  /* Определяем номер группы в таблице commonls */
def var seltype as integer init 1.  /* type в таблице commonls */
def var docnum as integer.
def var dlm     as char.

def var cTitle as char init '' no-undo.
def var crlf as char.
def var s_sbank as char.
def var v-dr-gl as char.
def var v-arp-cr as char.

def var v-knp as char.
define variable v-jou as char.

def temp-table bcommpl like commonpl
               field brid as rowid.

def var v-rec-sum as decimal init 0.


for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 10 and commonpl.joudoc = ? and 
                        commonpl.rmzdoc = ? and commonpl.txb = seltxb and deluid = ? no-lock:           /* Недостачи */
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.sum.
end.

/* Все операции по зачислению на тр. счет дебиторов будут делаться с кассы */

     v-dr-gl  = '100100'.

if v-rec-sum <> 0 then do:

do transaction:
for each bcommpl:
find first commonls where commonls.txb = bcommpl.txb and    /* Ради приличия */
                          commonls.grp = bcommpl.grp and 
                          commonls.type = bcommpl.type and 
                          commonls.visible = no
                          no-lock no-error.
if not avail commonls then do:
 MESSAGE "Не настроена таблица commonls по обменным операциям." 
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Обменные операции.".
 return.
end.

  do transaction:

/* В валюте */
/*
usd - 001076480
eur - 001076781
kzt - 002904580
*/


     if bcommpl.typegrp = 1 then
     v-arp-cr = "000904922". /*'002904580'*/ 
     /*
     if ourbank = 'TXB02' then v-arp-cr = '250904340'.
     */
     if bcommpl.typegrp = 2 then
     v-arp-cr = "001076228". /*'001076480'*/ 

     if bcommpl.typegrp = 11 then
     v-arp-cr = '001076781'. /* Тест: 001076079 (EURO)*/


            run trx(6, 
            	    bcommpl.sum, 
                    bcommpl.typegrp, 
                    100100,
                    '', 
                    '', 
                    v-arp-cr, 
                    'Погашение недостачи кассира: ' + v-ofc-fullname,
                    '14','17','856').

                        /* Будут проводиться как прочие платежи */
   
                        if return-value = '' then do: undo. return. end.
             
                        s-jh = int(return-value).          
                        run setcsymb (s-jh, commonls.symb).

                        run nedjou.
                        v-jou = return-value.

                        if bcommpl.typegrp = 1 then
                        run vou_bank(0).
                        else
                        run vou_bank(1).

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and 
                                                                           commonpl.grp = 10 and                    
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

