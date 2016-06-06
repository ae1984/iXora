/* a_rep4.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по комиссии со счета клиента
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

define shared temp-table wrk3 no-undo
    field v-fil as char
    field v-doc as char
    field v-jh as int
    field v-date as date
    field v-fio as char
    field v-chet as char
    field v-crck as char
    field v-sumk as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-tar as char
    field v-rem as char
    field v-sp as char
    field v-id as char
    index ind1 is primary v-fil v-sp v-doc.

def var v-type as char init "CM1".

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

for each txb.joudop where txb.joudop.whn >= v-dt1 and txb.joudop.whn <= v-dt2 and lookup(txb.joudop.type,v-type) > 0 no-lock.
    find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
    if available  txb.joudoc then do:
        find first txb.jl where txb.jl.jh = txb.joudoc.jh no-lock no-error.
        if available txb.jl then do:
            create wrk3.
            wrk3.v-id = jl.who.
            wrk3.v-fil = v-fil-cnt.
            wrk3.v-doc = txb.joudoc.docnum.
            wrk3.v-jh = txb.joudoc.jh.
            wrk3.v-date = txb.joudoc.whn.
            wrk3.v-fio = txb.joudoc.info.
            wrk3.v-chet = txb.joudoc.dracc.
            find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock.
            wrk3.v-crck = txb.crc.code.
            wrk3.v-sumk = txb.joudoc.comamt.
            wrk3.v-tar = txb.joudoc.comcode.
            /*wrk3.v-rem = trim(txb.joudoc.remark[1]) + " " + trim(txb.joudoc.remark[2]).*/
            wrk3.v-rem = trim(txb.jl.rem[1]).
            find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
            if available txb.ofchis then do:
                find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                if available txb.ppoint then wrk3.v-sp = txb.ppoint.name.
            end.

        end. /*if available txb.jl*/
    end. /* if available  txb.joudoc*/
end. /* end for each */
