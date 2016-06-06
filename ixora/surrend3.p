/* surrend3.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        выплата сдачи ЭК через кассу
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
 * AUTHOR
        04/06/2012 Luiza
 * CHANGES
            22/08/2012 luiza добавила входящ параметр v-crc
*/

define input parameter v-jh as integer no-undo. /* Номер проводки*/
define input parameter v-summ as decimal no-undo. /*Сумма платежа*/
define input parameter v-arp as character no-undo. /*Арп счет 100500 по дебету*/
define input parameter v-crc as int no-undo. /* Валюта*/
define output parameter ss-jh as integer no-undo. /* Номер новой проводки*/
def new shared var s-jh like jh.jh.
define shared var g-ofc  as char.
def var vdel as char no-undo initial "^".
def var v-param as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v_title as char no-undo. /*наименование платежа */
def var v_arp as char format "x(20)" no-undo. /* счет карточка ARP*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_oper as char no-undo format "x(45)".  /* Назначение платежа*/
def var v_doc as char.
v_title = "выдача остатков/сдачи через кассу".
def var v-info as char.
def var v-cifmin as char.
def var v-perkod as char.
def var v-passp as char.
/*------------------------------------*/
{keyord.i}

   form
        v-crc   label " Валюта                  "  skip
        v-summ  LABEL " Сумма                   "  format ">>>,>>>,>>>,>>>,>>9.99" help " Введите сумму платежа" skip
        v_code  label " КОД                     "  skip
        v_kbe   label " КБе                     "  skip
        v_knp   label " КНП                     "  format "x(3)" skip
        v_oper  label " Назначение платежа      "  format "x(40)" skip
        v-ja    label " Формировать транзакцию ?"
        WITH  SIDE-LABELS CENTERED ROW 7
    TITLE v_title width 70 FRAME f_main.



on "END-ERROR" of frame f_main do:
  hide frame f_main no-pause.
end.

v_oper = "Выдача остатка / сдачи".

find first jh where jh.jh = v-jh no-lock no-error.
if avail jh then do:
    find first joudop where joudop.docnum  = jh.party no-lock no-error.
    if available joudop and joudop.type begins "BOM" then v_oper = "Выдача остатка/сдачи от обменной операции через ЭК".
    find first joudoc where joudoc.docnum  = jh.party no-lock no-error.
    v-info = joudoc.info.
    v-cifmin = joudoc.kfmcif.
    v-perkod = joudoc.perkod.
    v-passp = joudoc.passp.
end.

find first trxcods where trxcods.trxh = v-jh and trxcods.trxln = 1 and trxcods.codfr = "locat" no-lock no-error.
if available trxcods then v_kbe = trim(trxcods.code).
find first trxcods where trxcods.trxh = v-jh and trxcods.trxln = 1 and trxcods.codfr = "secek" no-lock no-error.
if available trxcods then v_kbe = v_kbe + trim(trxcods.code).
v_code = "14".
v_knp = "890".
displ v-crc  v-summ v_code v_kbe v_knp v_oper with frame f_main.

update v-ja  with frame f_main.
if not v-ja or keyfunction (lastkey) = "end-error" then do:
    hide frame f_main.
    undo,return.
end.

s-jh = 0.
/* формир v-param для trxgen.p */
v-param = string(v-summ) + vdel + string(v-crc) + vdel + v-arp + vdel +
            v_oper + vdel + substring(v_code,1,1) + vdel + substring(v_kbe,1,1)
            + vdel + substring(v_code,2,1)+ vdel + substring(v_kbe,2,1) + vdel + v_knp.
run trxgen ("JOU0041", vdel, v-param, "jou", "", output rcode, output rdes, input-output s-jh).
if rcode <> 0 then do:
    message rdes.
    pause.
    undo, return.
end.

run trxsts (input s-jh, input 5, output rcode, output rdes).
if rcode ne 0 then do:
    message rdes.
    undo, return.
end.
run jou.
v_doc = return-value.
find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
if available joudoc then do:
    joudoc.info  = v-info.
    joudoc.benname = v-info.
    joudoc.kfmcif = v-cifmin.
    joudoc.perkod = v-perkod.
    joudoc.passp = v-passp.
end.
find first joudoc no-lock no-error.

find first jh where jh.jh = s-jh exclusive-lock.
jh.party = v_doc.
jh.jh2 = v-jh.
find first jh no-lock no-error.
run chgsts("jou", v_doc, "cas").

if v-crc = 1 then do:
    create jlsach .
    jlsach.jh = s-jh.
    jlsach.amt = v-summ .
    jlsach.ln = 1 .
    jlsach.lnln = 1.
    jlsach.sim = 300 .
    create jlsach .
    jlsach.jh = s-jh.
    jlsach.amt = v-summ .
    jlsach.ln = 2 .
    jlsach.lnln = 1.
    jlsach.sim = 300 .
    release jlsach.
end.

ss-jh = s-jh.
MESSAGE "ПРОВОДКА СФОРМИРОВАНА, НОМЕР: " + string(s-jh) view-as alert-box.
if v-noord = no then run vou_bankt(1, 1, "").
else run printord(s-jh,"").
hide frame f_main.
