/* a_rep1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по переводным операциям
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
*/

def  shared var v-ch as int.
def  shared var v-dt1 as date.
def  shared var v-dt2 as date.
def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.

define shared temp-table wrk no-undo
    field v-fil as char
    field v-doc as char
    field v-jh as int
    field v-date as date
    field v-fio as char
    field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-sum2 as decim
    field v-sum3 as decim
    field v-sum4 as decim
    field v-sum6 as decim
    field v-sum as decim
    field v-sumk as decim
    field v-rem as char
    field v-countr as char
    field tip as char
    field v-sp as char
    field v-id as char
    index ind1 is primary v-fil v-sp v-doc.

def var v-type as char.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

case v-ch:
    when 1 then v-type = "FR1,FR2,FR3,TN3,TN4,TN5".
    when 2 then v-type = "RF1,RF2,RF3,NT3,NT4,NT5".
    when 3 then v-type = "FR1,FR2,FR3,TN3,TN4,TN5,RF1,RF2,RF3,NT3,NT4,NT5".
    OTHERWISE leave.
end case.


for each txb.joudop where txb.joudop.whn >= v-dt1 and txb.joudop.whn <= v-dt2 and lookup(txb.joudop.type,v-type) > 0 no-lock.
    find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
    if available  txb.joudoc then do:
        find first txb.jl where txb.jl.jh = txb.joudoc.jh no-lock no-error.
        if available txb.jl then do:
            create wrk.
            wrk.v-id = jl.who.
            wrk.v-fil = v-fil-cnt.
            wrk.v-doc = txb.joudoc.docnum.
            wrk.v-jh = txb.joudoc.jh.
            wrk.v-date = txb.joudoc.whn.
            wrk.v-fio = txb.joudoc.info.
            case txb.joudoc.drcur:
                when 1 then wrk.v-sum1 = txb.joudoc.dramt.
                when 2 then wrk.v-sum2 = txb.joudoc.dramt.
                when 3 then wrk.v-sum3 = txb.joudoc.dramt.
                when 4 then wrk.v-sum4 = txb.joudoc.dramt.
                when 6 then wrk.v-sum6 = txb.joudoc.dramt.
                OTHERWISE wrk.v-sum = txb.joudoc.dramt.
            end case.

            if txb.joudoc.comcur <> 1 then do:
                find last txb.crchis where txb.crchis.crc = txb.joudoc.comcur and txb.crchis.rdt <= txb.joudoc.whn no-lock no-error.
                if avail txb.crchis then wrk.v-sumk = txb.joudoc.comamt * txb.crchis.rate[1].
            end.
            else wrk.v-sumk = txb.joudoc.comamt.
            wrk.v-rem = trim(joudoc.remark[1]) + " " + trim(joudoc.remark[2]).
            if txb.joudop.type = "FR1" or txb.joudop.type = "RF1" then wrk.v-countr = entry(9,txb.joudop.fname,"^").
            if txb.joudop.type = "FR2" or txb.joudop.type = "RF2" then wrk.v-countr = entry(4,trim(txb.joudop.lname)).
            if txb.joudop.type = "FR3" or txb.joudop.type = "RF3" then wrk.v-countr = entry(4,trim(txb.joudop.lname)).
            if txb.joudop.type = "TN3" or txb.joudop.type = "NT3" then wrk.v-countr = entry(5,txb.joudop.lname,"^").
            if txb.joudop.type = "TN4" or txb.joudop.type = "NT4" then wrk.v-countr = entry(3,txb.joudop.lname,"^").
            if txb.joudop.type = "TN5" or txb.joudop.type = "NT5" then wrk.v-countr = entry(4,txb.joudop.lname,"^").

            if txb.joudop.type = "FR1" or txb.joudop.type = "RF1"  or txb.joudop.type = "TN3" or txb.joudop.type = "NT3" or txb.joudop.type = "TN4" or txb.joudop.type = "NT4" then wrk.tip = "Отправление перевода".
            if txb.joudop.type = "FR2" or txb.joudop.type = "RF2"  or txb.joudop.type = "TN5" or txb.joudop.type = "NT5" then wrk.tip = "Получение перевода".
            if txb.joudop.type = "FR3" or txb.joudop.type = "RF3" then wrk.tip = "Отмена перевода".

            find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
            if available txb.ofchis then do:
                find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                if available txb.ppoint then wrk.v-sp = txb.ppoint.name.
            end.
        end. /*if available txb.jl*/
    end. /* if available  txb.joudoc*/
end. /* end for each */
