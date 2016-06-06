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

define shared temp-table wrk1 no-undo
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
    field v-sumk as decim
    field v-rem as char
    field v-countr as char
    field tip as char
    field sys as char
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
    when 1 then v-type = "TR1,TR2,TR3,TR4".
    when 2 then v-type = "RT1,RT2,RT3,RT4".
    when 3 then v-type = "TR1,TR2,TR3,TR4,RT1,RT2,RT3,RT4".
    OTHERWISE leave.
end case.

for each txb.joudop where txb.joudop.whn >= v-dt1 and txb.joudop.whn <= v-dt2 and lookup(substring(txb.joudop.type,1,3),v-type) > 0 no-lock.
    find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
    if available  txb.joudoc then do:
        find first txb.jl where txb.jl.jh = txb.joudoc.jh no-lock no-error.
        if available txb.jl then do:
            create wrk1.
            wrk1.v-id = jl.who.
            wrk1.v-fil = v-fil-cnt.
            wrk1.v-doc = txb.joudoc.docnum.
            wrk1.v-jh = txb.joudoc.jh.
            wrk1.v-date = txb.joudoc.whn.
            wrk1.v-fio = txb.joudoc.info.
            case txb.joudoc.drcur:
                when 1 then wrk1.v-sum1 = txb.joudoc.dramt.
                when 2 then wrk1.v-sum2 = txb.joudoc.dramt.
                when 3 then wrk1.v-sum3 = txb.joudoc.dramt.
                when 4 then wrk1.v-sum4 = txb.joudoc.dramt.
                when 6 then wrk1.v-sum6 = txb.joudoc.dramt.
            end case.

            wrk1.v-sumk = txb.joudoc.comamt.
            wrk1.v-rem = trim(joudoc.remark[1]) + " " + trim(joudoc.remark[2]).
            wrk1.v-countr = entry(4,trim(txb.joudop.lname)).
            /*if joudop.type = "TR1" or joudop.type = "RT1" then wrk1.v-countr = entry(4,trim(txb.joudop.lname)).
            if joudop.type = "TR2" or joudop.type = "RT2" then wrk1.v-countr = entry(4,trim(txb.joudop.lname)).
            if joudop.type = "TR3" or joudop.type = "RT3" then wrk1.v-countr = entry(4,trim(txb.joudop.lname)).
            if joudop.type = "TR4" or joudop.type = "RT4" then wrk1.v-countr = entry(4,trim(txb.joudop.lname)).*/

            if substring(joudop.type,1,3) = "TR1" or substring(joudop.type,1,3) = "RT1" then wrk1.tip = "Отправление перевода".
            if substring(joudop.type,1,3) = "TR2" or substring(joudop.type,1,3) = "RT2" then wrk1.tip = "Получение перевода".
            if substring(joudop.type,1,3) = "TR3" or substring(joudop.type,1,3) = "RT3" then wrk1.tip = "Отмена перевода".
            if substring(joudop.type,1,3) = "TR4" or substring(joudop.type,1,3) = "RT4" then wrk1.tip = "Возврат перевода".

            if substring(joudop.type,4,1) = "1" then wrk1.sys = "WESTERN UNION".
            if substring(joudop.type,4,1) = "2" then wrk1.sys = "БЫСТРАЯ ПОЧТА".
            if substring(joudop.type,4,1) = "3" then wrk1.sys = "ЗОЛОТАЯ КОРОНА".
            if substring(joudop.type,4,1) = "4" then wrk1.sys = "ЮНИСТРИМ".
            find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
            if available txb.ofchis then do:
                find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                if available txb.ppoint then wrk1.v-sp = txb.ppoint.name.
            end.

        end. /*if available txb.jl*/
    end. /* if available  txb.joudoc*/
end. /* end for each */
