/* a_rep1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по кассовым операциям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
	BANK COMM TXB
 * AUTHOR
        18/04/2012 Luiza
 * CHANGES

            18/07/2012 Luiza добавила типы межфил инкассации и ПК
            24/072012 Luiza добавила типы ПК

*/

def  shared var v-ch as int.
def  shared var v-dt1 as date.
def  shared var v-dt2 as date.
def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.

define shared temp-table wrk2 no-undo
    field v-fil as char
    field v-doc as char
    field v-jh as int
    field v-date as date
    field v-fio as char
    field v-crc as char
    field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-sum2 as decim
    field v-sum3 as decim
    field v-sumk as decim
    field v-rem as char
    field v-sp as char
    field v-id as char
    index ind1 is primary v-fil v-sp v-doc.

def var v-type as char.
def var v-info as char.
def var v-benname as char.
def var v-sum1type as char.
def var v-sum2type as char.
def var v-sum3type as char.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

case v-ch:
    when 1 then v-type = "CS1,CS2,INC,INC2,CS4,CS5,CS6,CS7".
    when 2 then v-type = "EK1,EK2,NIC,NIC2,EK4,EK5,EK6,EK7".
    when 3 then v-type = "CS1,CS2,INC,INC2,CS4,CS5,CS6,CS7,EK1,EK2,NIC,NIC2,EK4,EK5,EK6,EK7".
    OTHERWISE leave.
end case.
v-info = "CS1,EK1,CS4,EK4,CS5,EK5,INC,CS6,EK6".
v-benname = "CS2,EK2,INC2,CS7,EK7".
v-sum1type = "CS1,EK1,CS4,EK4,CS7,EK7".
v-sum2type = "CS2,EK2,CS5,EK5,CS6,EK6".
v-sum3type = "INC,NIC,INC2".

for each txb.joudop where txb.joudop.whn >= v-dt1 and txb.joudop.whn <= v-dt2 and lookup(txb.joudop.type,v-type) > 0 no-lock.
    find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
    if available  txb.joudoc then do:
        find first txb.jl where txb.jl.jh = txb.joudoc.jh no-lock no-error.
        if available txb.jl then do:
            create wrk2.
            wrk2.v-id = jl.who.
            wrk2.v-fil = v-fil-cnt.
            wrk2.v-doc = txb.joudoc.docnum.
            wrk2.v-jh = txb.joudoc.jh.
            wrk2.v-date = txb.joudoc.whn.
            if lookup(txb.joudop.type,v-info) > 0 then wrk2.v-fio = txb.joudoc.info.
            if lookup(txb.joudop.type,v-benname) > 0 then wrk2.v-fio = txb.joudoc.benname.

            find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock no-error.
            if available txb.crc then wrk2.v-crc = txb.crc.code.

            if lookup(txb.joudop.type,v-sum1type) > 0 then wrk2.v-sum1 = txb.joudoc.dramt.

            if lookup(txb.joudop.type,v-sum2type) > 0 then wrk2.v-sum2 = txb.joudoc.dramt.

            if lookup(txb.joudop.type,v-sum3type) > 0 then wrk2.v-sum3 = txb.joudoc.dramt.


            if txb.joudoc.comcur <> 1 then do:
                find last txb.crchis where txb.crchis.crc = txb.joudoc.comcur and txb.crchis.rdt <= txb.joudoc.whn no-lock no-error.
                if avail txb.crchis then wrk2.v-sumk = txb.joudoc.comamt * txb.crchis.rate[1].
            end.
            else wrk2.v-sumk = txb.joudoc.comamt.
            wrk2.v-rem = trim(txb.joudoc.remark[1]) + " " + trim(txb.joudoc.remark[2]) + " " + trim(txb.joudoc.rescha[3]).
            find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
            if available txb.ofchis then do:
                find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                if available txb.ppoint then wrk2.v-sp = txb.ppoint.name.
            end.

        end. /*if available txb.jl*/
    end. /* if available  txb.joudoc*/
end. /* end for each */
