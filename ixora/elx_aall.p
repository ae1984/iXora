/* elx-aall.p
 * MODULE
        Elecsnet
 * DESCRIPTION
        АлмаТВ - список платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        elx_almtvin.p
 * MENU
        5-2-1-3-7-1
 * AUTHOR
        03/05/2006 dpuchkov.
 * CHANGES
        12.02.2007 id00004 добавил alias
*/

{get-dep.i}
{comm-txb.i}
def var ourbank as char         no-undo.
def var ourcode as integer      no-undo.
def var ourlist as char init '' no-undo.
ourbank = comm-txb().
ourcode = comm-cod().

def shared var g-today as date.
def var alldoc as logical init true no-undo.
def var rid as rowid no-undo.
def var dat as date no-undo.

define variable docdnum as int  no-undo.
define variable docuid as char  no-undo.
define buffer talmatv for comm.almatv .

def var s_rid as char           no-undo.
def var s_payment as char       no-undo.
def var s_service as char       no-undo.
def var totalc as decimal       no-undo.

dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

define variable candel as log   no-undo.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.


def var totalt as dec           no-undo.


def var v-tarif as decimal init 0 no-undo.
find first tarif2 where tarif2.num = '5' and tarif2.kod = '83' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then do:
   v-tarif = tarif2.proc.
end.
if v-tarif = 0 then  do:
   message "Внимание: не настроены тарифы".
   return.
end.


DEFINE QUERY q1 FOR mobi-almatv.
def browse b1 
    query q1 no-lock
    display 
     /* string(get-dep(uid, dtfk),"99") */ "01" format "99999" label "РКО" 
      left-trim(string(mobi-almatv.Ndoc,">>>>>>>9")) format "x(8)" label "No контр." 
        mobi-almatv.f       format "x(15)" label "Фамилия"
        mobi-almatv.address format "x(10)" label "Адрес"
        mobi-almatv.summ - round((mobi-almatv.summ * v-tarif / 100), 2)  format "->>>>>>>9.99" label "Сумма" 
        round((mobi-almatv.summ * v-tarif / 100), 2) /*mobi-almatv.commis*/  format ">>>>>9.99" label "Комис."
        with 14 down title "Платежи АЛМА TV" no-labels.

DEFINE BUTTON bedt LABEL "Просмотр".        
DEFINE BUTTON bbks LABEL "БКС".
DEFINE BUTTON bprn LABEL "Печать".
DEFINE BUTTON bext LABEL "Выход".
DEFINE BUTTON bacc LABEL "Итог".

def frame f1 
    b1 
    skip
    space(15)
    bedt
    bbks 
    bprn
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        run elx_almtvin(dat, false, rowid(mobi-almatv), mobi-almatv.Ndoc).
        b1:refresh().
    end.


ON CHOOSE OF bbks IN FRAME f1
    do:
    s_rid = string(mobi-almatv.Ndoc).

    s_payment = s_rid + "#" + 'За услуги Алма ТВ' + "#" + string(mobi-almatv.summ) + "#" + string(mobi-almatv.commis) + "#" + "0" + "#" + "KZT".

    run bks(s_payment,"NO").
    b1:refresh().
    end.




ON CHOOSE OF bprn IN FRAME f1
    do:
        run elx_almtvprn (rowid(mobi-almatv), mobi-almatv.Ndoc).
    end.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(mobi-almatv).
    for each mobi-almatv where mobi-almatv.dt = dat no-lock:
        ACCUMULATE mobi-almatv.summ (TOTAL COUNT).
        ACCUMULATE mobi-almatv.commis (TOTAL).
    end.
    totalt = (accum total mobi-almatv.summ).
    totalc = (accum total mobi-almatv.commis).

    message "Количество платежей: " (accum count mobi-almatv.summ) skip 
            "Hа сумму: " totalt - round((totalt * v-tarif / 100), 2) skip
            "Комиссия: " /*totalc*/ round(totalt * v-tarif / 100, 2) skip
            "Всего: " totalt + totalc skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Платежи АЛМА TV" .
    find mobi-almatv where rowid(mobi-almatv) = rid.
    
end.

/* open query q1 for each almatv where almatv.dtfk = dat and (alldoc or almatv.uid = userid("bank")) and almatv.txb = ourcode and almatv.deluid = ? no-lock. */

open query q1 for each mobi-almatv where mobi-almatv.dt = dat /*and almatv.deluid = ?*/ no-lock.





ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
