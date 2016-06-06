/* slist_txb.p
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Реестр проведенных з/п платежей Salary
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.1.4.1.3
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        19.07.2013 damir - Внедрено Т.З. № 1931.
*/
def buffer b-joudoc for txb.joudoc.
def buffer b-joudop for txb.joudop.
def buffer b-aaa for txb.aaa.
def buffer b-cif for txb.cif.
def buffer b-cursts for txb.substs.

def shared var v-dtb as date.
def shared var v-dte as date.

def shared temp-table t-wrk no-undo
    field cif as char
    field name as char
    field iik as char
    field sum as deci
    field sumcom as deci
    field sts as char
    field dt as date
    field jou as char
    field paynum as char.

for each b-joudoc where b-joudoc.whn >= v-dtb and b-joudoc.whn <= v-dte no-lock:
    find b-joudop where b-joudop.docnum = b-joudoc.docnum no-lock no-error.
    if avail b-joudop then do: if b-joudop.type <> "SF1" then next. end.
    else next.
    find b-aaa where b-aaa.aaa = b-joudoc.dracc no-lock no-error.
    find b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
    if not (avail b-aaa and avail b-cif) then next.

    create t-wrk.
    t-wrk.cif = b-cif.cif.
    t-wrk.name = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
    t-wrk.iik = b-joudoc.dracc.
    t-wrk.sum = b-joudoc.dramt.
    t-wrk.sumcom = b-joudoc.comamt.
    t-wrk.dt = b-joudoc.whn.
    t-wrk.jou = b-joudoc.docnum.
    t-wrk.paynum = b-joudoc.infodoc[1]. /* Номер платежного поручения. П.м. 15.1.4.1.1 */

    find last b-cursts where b-cursts.sub = "jou" and b-cursts.acc = b-joudoc.docnum no-lock no-error .
    if avail b-cursts and b-cursts.sts = "con" then t-wrk.sts = "Пройден".
end.
