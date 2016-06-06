/* vyd2arp.p
 * MODULE
        Offline PragmaTX (выдача подотчета в тенге для обменных операций)
 * DESCRIPTION
        Выдача в подотчет в тенге для обменных операций Offline PragmaTX
 * RUN

 * CALLER
        excsofp.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        22/04/2004 kanat
 * CHANGES
        27/04/2004 kanat - изменил формирование счета АРП для подотчета
        28/04/2004 kanat - уменьшил количество печатываемых ордеров до 1 штуки.
        20.05.04 nadejda - добавлен параметр в vou_bank_ex - печатать ли опер.ордера
        12/09/2005 kanat Добавил условие по удаленныи квитанциям
        01.02.2012 lyubov - изменила символ кассплана (560 на 330)
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
def var selgrp  as integer init 11.  /* Определяем номер группы в таблице commonls */
def var seltype as integer init 1.  /* type в таблице commonls */
def var docnum as integer.
def var dlm     as char.

def var cTitle as char init '' no-undo.
def var crlf as char.
def var s_sbank as char.
def var v-dr-gl as char.
def var v-carp  as char.
def var v-fio as char.

def var v-knp as char.
define variable v-jou as char.

def temp-table bcommpl like commonpl
               field brid as rowid.

def var v-rec-sum as decimal init 0.


for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 11 and commonpl.joudoc = ? and
                        commonpl.rmzdoc = ? and commonpl.txb = seltxb and deluid = ? no-lock:           /* Недостачи */
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.sum.
end.

/* Все операции по зачислению на тр. счет дебиторов будут делаться с кассы */

     v-dr-gl  = '100100'.

find last ofchis where ofchis.ofc = v-ofc and ofchis.regdt <= vdate no-lock no-error.
if avail ofchis then do:
find last ofcprofit where ofcprofit.ofc = ofchis.ofc and ofcprofit.regdt <= vdate no-lock no-error.
if not avail ofcprofit then do:
message "Кассир отсутствует в истории изменения профит-центров" view-as alert-box title "Внимание".
return.
end.
end.
else do:
message "Кассир отсутствует в истории" view-as alert-box title "Внимание".
return.
end.


for each bcommpl where bcommpl.deluid = ?:
find first commonls where commonls.txb = bcommpl.txb and    /* Ради приличия */
                          commonls.grp = bcommpl.grp
                          no-lock no-error.
if not avail commonls then do:
 MESSAGE "Не настроена таблица commonls по выдачам в подотчет."
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Выдачи в подотчет.".
 return.
end.


  do transaction:

v-carp = "".

/* В валюте */

for each arp where arp.gl = 100300 no-lock:
  if arp.crc <> 1 then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> "obmen1003" then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> ofcprofit.profit then next.

  if arp.crc = 1 then v-carp = arp.arp.

  if v-carp <> "" then leave.
end.

if v-carp = "" then do:
  message skip " Не настроены счета ARP для загружаемого кассира в тенге!?"
    skip(1) view-as alert-box title "Ошибка".
  return.
end.


find first ofc where ofc.ofc = bcommpl.uid no-lock no-error.
if avail ofc then
v-fio = ofc.name.
else do:
v-fio = "Unknown".
message "Неизвестный кассир!!!" view-as alert-box title "Внимание".
return.
end.


            run trx(6,
                    bcommpl.sum,
                    1,
                    '',
                    v-carp,
                    v-dr-gl,
                    '',
                    'Подотчет АРП обменных пунктов (KZT), ' + v-fio,
                    '14',
                    '14',
                    '890').

                        if return-value = '' then do: undo. return. end.

                        s-jh = int(return-value).
                        run setcsymb (s-jh,"330").

                        run jou.
                        v-jou = return-value.

                        message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder as logical.
                        run vou_bank_ex(1,"1", v-prtorder).

                        find commonpl where rowid (commonpl) = bcommpl.brid no-error.
                        if not available commonpl then find commonpl where commonpl.txb = seltxb and
                                                                           commonpl.grp = 11 and
                                                                           commonpl.type = bcommpl.type and
                                                                           commonpl.uid = bcommpl.uid and
                                                                           commonpl.dnum = bcommpl.dnum and
                                                                           commonpl.sum = bcommpl.sum
                                                                           no-lock no-error.
                        if avail commonpl then assign commonpl.joudoc = v-jou.

   end. /* do transaction */

end. /* for each bcommpl */

