/* a_rep7.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по обменным операциям
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
            23/08/2012 Luiza - добавила 100100 для обменных операций
            18.09.2012 Lyubov - ТЗ 1500, добавлена курсовая разница, поле тип операции, в отчет по 100500 добавлены переводные операции
            09/11/2012  Luiza - переход на счета конвертации (1859,2859,2858)
            09/01/2013 Luiza - убрала привязку к типу в таблице joudop
            18/07/2013 Luiza - ТЗ 1967
*/

def  shared var v-ch as int.
def  shared var v-dt1 as date.
def  shared var v-dt2 as date.
def  shared var v-fil-cnt as char format "x(30)".
def  shared var v-fil-int as int.

define shared temp-table wrk6 no-undo
    field v-fil as char
    field v-doc as char
    field v-jh as int
    field v-date as date
    field v-sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-crc1 as char
    field v-sum2 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field v-crc2 as char
    field v-rate as decim
    field v-exp as decim
    field v-rev as decim
    field v-rem as char
    field v-sp as char
    field v-id as char
    field v-type as char
    index ind1 is primary v-fil v-sp v-doc.

def var v-type as char.
def var v-type2 as char.
def buffer b-jl for txb.jl.
def buffer b-jl2 for txb.jl.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
message  "Ждите, идет подготовка данных для отчета " + v-fil-cnt .
pause 1.
v-fil-int = v-fil-int + 1.

/*v-type = "BOM,MC2,RF1,RF2,RF3,RT1,RT2,RT3,RT4".*/
if v-ch = 2 or v-ch = 3 then do:
    for each txb.joudop where txb.joudop.whn >= v-dt1 and txb.joudop.whn <= v-dt2 and trim(txb.joudop.type) <> "OBM" no-lock.
        find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
        if available  txb.joudoc then do:
            find first txb.jl where txb.jl.jh = txb.joudoc.jh and (txb.jl.gl = 185800 or txb.jl.gl = 185900 or txb.jl.gl = 285800 or txb.jl.gl = 285900) no-lock no-error.
            if available txb.jl then do:
                create wrk6.
                wrk6.v-id = txb.jl.who.
                wrk6.v-fil = v-fil-cnt.
                wrk6.v-doc = txb.joudoc.docnum.
                wrk6.v-jh = txb.joudoc.jh.
                wrk6.v-date = txb.joudoc.whn.
                if txb.joudop.type = 'BOM' then do:
                    wrk6.v-sum1 = txb.joudoc.dramt.
                    find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock.
                    wrk6.v-crc1 = txb.crc.code.
                    wrk6.v-sum2 = txb.joudoc.cramt.
                    find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock.
                    wrk6.v-crc2 = txb.crc.code.
                    wrk6.v-type = 'Обмен'.
                end.
                else do:
                    for each b-jl where b-jl.jh = txb.jl.jh and (b-jl.gl = 185800 or b-jl.gl = 185900 or b-jl.gl = 285800 or b-jl.gl = 285900) no-lock:
                        if b-jl.dc = "D" then do:
                            find first b-jl2 where b-jl2.jh = b-jl.jh and b-jl2.ln = b-jl.ln + 1 no-lock no-error.
                            if b-jl2.gl = 100500 then do:
                                wrk6.v-sum2 = wrk6.v-sum2 + b-jl.dam.
                                find first txb.crc where txb.crc.crc = b-jl.crc no-lock.
                                wrk6.v-crc2 = txb.crc.code.
                            end.
                        end.
                        else do:
                            find first b-jl2 where b-jl2.jh = b-jl.jh and b-jl2.ln = b-jl.ln - 1 no-lock no-error.
                            if b-jl2.gl = 100500 then do:
                                wrk6.v-sum1 = wrk6.v-sum1 + b-jl.cam.
                                find first txb.crc where txb.crc.crc = b-jl.crc no-lock.
                                wrk6.v-crc1 = txb.crc.code.
                            end.
                        end.
                    end.
                    wrk6.v-type = 'Перевод'.
                end.
                if txb.joudoc.srate > 1 then wrk6.v-rate = txb.joudoc.srate.
                else wrk6.v-rate = txb.joudoc.brate.
                wrk6.v-rem  = txb.joudoc.remark[1].
                find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
                if available txb.ofchis then do:
                    find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                    if available txb.ppoint then wrk6.v-sp = txb.ppoint.name.
                end.
                for each b-jl where b-jl.jh = txb.jl.jh and lookup(string(b-jl.gl),'453020,553020') > 0 no-lock:
                    if b-jl.gl = 453020 then wrk6.v-rev = wrk6.v-rev + b-jl.cam.
                    if b-jl.gl = 553020 then wrk6.v-exp = wrk6.v-exp + b-jl.dam.
                end.
            end. /*if available txb.jl*/
        end. /* if available  txb.joudoc*/
    end. /* end for each */
end.
if v-ch = 1 or v-ch = 3 then do:
    for each txb.joudoc where txb.joudoc.whn >= v-dt1 and txb.joudoc.whn <= v-dt2 and txb.joudoc.dracctype = "1" and txb.joudoc.cracctype = "1" /*and txb.joudoc.remark[1] begins "Обмен валюты."*/ no-lock.
        find first txb.jl where txb.jl.jh = txb.joudoc.jh and (txb.jl.gl = 185800 or txb.jl.gl = 185900 or txb.jl.gl = 285800 or txb.jl.gl = 285900) no-lock no-error.
        if available txb.jl then do:
            create wrk6.
            wrk6.v-id = jl.who.
            wrk6.v-fil = v-fil-cnt.
            wrk6.v-doc = txb.joudoc.docnum.
            wrk6.v-jh = txb.joudoc.jh.
            wrk6.v-date = txb.joudoc.whn.
            wrk6.v-sum1 = txb.joudoc.dramt.
            find first txb.crc where txb.crc.crc = txb.joudoc.drcur no-lock.
            wrk6.v-crc1 = txb.crc.code.
            wrk6.v-sum2 = txb.joudoc.cramt.
            find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock.
            wrk6.v-crc2 = txb.crc.code.
            if txb.joudoc.srate > 1 then wrk6.v-rate = txb.joudoc.srate.
            else wrk6.v-rate = txb.joudoc.brate.
            wrk6.v-rem  = txb.joudoc.remark[1].
            find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt <= txb.jl.whn no-lock no-error.
            if available txb.ofchis then do:
                find first txb.ppoint where txb.ppoint.dep = txb.ofchis.depart no-lock no-error.
                if available txb.ppoint then wrk6.v-sp = txb.ppoint.name.
            end.
            find first b-jl where b-jl.jh = txb.jl.jh and lookup(string(b-jl.gl),'453020,553020') > 0 no-lock no-error.
            if avail b-jl then do:
                if b-jl.gl = 453020 then wrk6.v-rev = b-jl.cam.
                if b-jl.gl = 553020 then wrk6.v-exp = b-jl.dam.
            end.
            wrk6.v-type = 'Обмен'.
        end. /*if available txb.jl*/
    end. /* end for each */
end.