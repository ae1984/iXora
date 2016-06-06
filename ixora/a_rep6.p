/* a_rep6.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по урегулированию вознаграждений
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
def shared var v-sh as char.

if keyfunction (lastkey) = "end-error" then return.
v-sh = return-value.
if substring(v-sh,2,1) = "9" then return.

define shared temp-table wrk5 no-undo
    field v-fil as char
    field v-uni as char
    field v-name as char
    field v-doc as char
    field v-jh as int
    field v-date as date
    field v-sum as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-crc as char
    field v-chet as char
    field v-fio as char
    field v-rem as char
    field v-sp as char
    field v-id as char
    index ind1 is primary v-fil v-sp v-doc.

def var v-type as char.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

for each txb.ujo where txb.ujo.whn >= v-dt1 and txb.ujo.whn <= v-dt2 and trim(txb.ujo.sys) + trim(txb.ujo.code) = substring(v-sh,5,7)  no-lock.
    find first txb.jl where txb.jl.jh = txb.ujo.jh no-lock no-error.
    if available txb.jl then do:
        create wrk5.
        wrk5.v-id = jl.who.
        wrk5.v-fil = v-fil-cnt.
        wrk5.v-uni = substring(v-sh,5,7).
        find first txb.trxhead where txb.trxhead.system = substring(v-sh,5,3) and trxhead.code = int(substring(v-sh,9,4)) no-lock no-error.
        if available txb.trxhead then wrk5.v-name = txb.trxhead.des.
        wrk5.v-doc = txb.ujo.docnum.
        wrk5.v-jh = txb.ujo.jh.
        wrk5.v-date = txb.ujo.whn.
        if txb.jl.dam > 0 then wrk5.v-sum = txb.jl.dam.
        else wrk5.v-sum = txb.jl.cam.
        find first txb.crc where txb.crc.crc = txb.jl.crc no-lock.
        wrk5.v-crc = txb.crc.code.
        wrk5.v-chet = txb.jl.acc.
        wrk5.v-fio = txb.ujo.info.
        wrk5.v-rem = txb.ujo.rem[1].
        find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
        if available txb.ofchis then do:
            find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
            if available txb.ppoint then wrk5.v-sp = txb.ppoint.name.
        end.
    end. /*if available txb.jl*/
end. /* end for each */
