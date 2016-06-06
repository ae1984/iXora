/* dub22arp.p
 * MODULE
        Offline PragmaTX (зачисление комиссий за выдачи дубликатов)
 * DESCRIPTION
        Зачисление комиссий за выдачи дубликатов
 * RUN

 * CALLER
        excsofp.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        11/10/2004 kanat
 * CHANGES
        01/11/2004 kanat - добавил ФИО кассира в назначение транзакции по просьбе ДРР
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        01.02.2012 lyubov - изменила символ кассплана (20 на 100)

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
def var selgrp  as integer init 14.  /* Определяем номер группы в таблице commonls */
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


for each commonpl where commonpl.date = vdate and commonpl.uid = v-ofc and commonpl.grp = 14 and commonpl.joudoc = ? and
                        commonpl.rmzdoc = ? and commonpl.txb = seltxb and deluid = ? no-lock:           /* Дубликаты */
    create bcommpl.
    buffer-copy commonpl to bcommpl.
    bcommpl.brid = rowid (commonpl).
    v-rec-sum = v-rec-sum + commonpl.comsum.
end.

if v-rec-sum <> 0 then do:

find first tarif2 where tarif2.num  = "1" and tarif2.kod = "10"
                    and tarif2.stat = 'r' no-lock no-error.

do transaction:
find first commonls where commonls.txb = bcommpl.txb and    /* Ради приличия */
                          commonls.grp = bcommpl.grp and
                          commonls.visible = no
                          no-lock no-error.
if not avail commonls then do:
 MESSAGE "Не настроена справочник коммунальных получателей."
 VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Выдача дубликатов.".
 return.
end.

 	 do transaction:
                  run trx(6,
                          v-rec-sum,
                          1,
                          100100,
                          '',
                          tarif2.kont,
                          '',
                          "За выдачу дубликатов квитанции кассира: " + v-ofc-fullname,
                         '19','14','890').

                        if return-value = '' then do: undo. return. end.
                        s-jh = int(return-value).
                        run setcsymb (s-jh, 100).
                        run jou.
			run vou_bank(1).
	 end.

end. /* Еще один транзакционный блок */
end. /* сумма <> 0 */

