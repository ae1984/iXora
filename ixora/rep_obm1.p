/* rep_obm1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по нал обменным операциям
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
	BANK TXB
 * AUTHOR
        10/01/2013 Luiza
        02/08/2013 Luiza - ТЗ 2007 доработка отчета
 * CHANGES
*/

def  shared var ch as int.
def  shared var dt1 as date.
def  shared var dt2 as date.
def  shared var fil-cnt as char format "x(30)".
def  shared var fil-int as int.

define shared temp-table wrk no-undo
    field fil as char
    field doc as char
    field jh as int
    field dat as date
    field fio as char
    field crc as int
    field vrate as decim
    field ratus as decim
    field namecrc as char
    field gld as int
    field sumd as decim
    field sumtngd as decim
    field glc as int
    field sumc as decim
    field sumtngc as decim
    field dc as char
    field rem as char
    field nal as logic
    index ind is primary fil jh.

def var type as char.
def buffer b-jl for txb.jl.

function GetRate returns decimal(crc as int, dt as date,dc as char,tim as int).
    find last txb.crchis where txb.crchis.crc = crc and txb.crchis.whn <= dt and txb.crchis.tim <= tim no-lock no-error.
    if available txb.crchis then if dc = "d" then return txb.crchis.rate[3]. else return txb.crchis.rate[2].
    else return 0.
end.

find first txb.cmp no-lock no-error.
if available txb.cmp then fil-cnt = txb.cmp.name.
displ  "Ждите, формир-ся данные " + fil-cnt format "x(70)" with row 15 frame ww .
pause 0.
fil-int = fil-int + 1.

type = "BOM,MC2,RF1,RF2,RF3,RT1,RT2,RT3,RT4,EK1,EK2,".
/* обмен по 100500 */
    for each txb.joudop where txb.joudop.whn >= dt1 and txb.joudop.whn <= dt2  no-lock.
        find first txb.joudoc where txb.joudoc.docnum = txb.joudop.docnum no-lock no-error.
        if available  txb.joudoc then do:
            if txb.joudoc.dracctype = "1" and txb.joudoc.cracctype = "1" then next. /* значит 100100 */
            for each txb.jl where txb.jl.jh = txb.joudoc.jh and (txb.jl.gl = 185800 or txb.jl.gl = 285800) and txb.jl.crc <> 1  no-lock .
                if substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
                create wrk.
                wrk.fil = fil-cnt.
                wrk.doc = txb.joudoc.docnum.
                wrk.jh = txb.joudoc.jh.
                wrk.dat = txb.joudoc.whn.
                wrk.fio = txb.joudoc.info + " " + txb.joudoc.passp  + " " + string(txb.joudoc.passpdt) .
                wrk.dc = txb.jl.dc.
                wrk.crc = txb.jl.crc.
                wrk.rem = txb.jl.rem[1].
                wrk.nal = yes.
                find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
                if available txb.jh then wrk.ratus = GetRate(2,txb.jl.jdt,txb.jl.dc,txb.jh.tim).
                find first txb.crc where txb.crc.crc = txb.jl.crc no-lock.
                wrk.namecrc = txb.crc.code.
                if txb.jl.dc = "D" then do: /* значит продано */
                    wrk.sumc = txb.jl.dam.
                    wrk.vrate = txb.joudoc.srate.
                    wrk.sumtngc = txb.jl.dam * txb.joudoc.srate.
                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                    wrk.glc = b-jl.gl.
                    wrk.gld = txb.jl.gl.
                end.
                else do: /* значит куплено */
                    wrk.sumd = txb.jl.cam.
                    wrk.vrate = txb.joudoc.brate.
                    wrk.sumtngd = txb.jl.cam * txb.joudoc.brate.
                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                    wrk.gld = b-jl.gl.
                    wrk.glc = txb.jl.gl.
                end.
            end. /* for each txb.jl */
        end. /* if available  txb.joudoc*/
    end. /* end for each */

/* обмен по 100100 */
    for each txb.joudoc where txb.joudoc.whn >= dt1 and txb.joudoc.whn <= dt2 and txb.joudoc.dracctype = "1" and txb.joudoc.cracctype = "1" /*and txb.joudoc.remark[1] begins "Обмен валюты."*/ no-lock.
        find first txb.jl where txb.jl.jh = txb.joudoc.jh and (txb.jl.gl = 185800 or txb.jl.gl = 285800) and txb.jl.crc <> 1 no-lock no-error.
        if available txb.jl then do:
            create wrk.
            wrk.fil = fil-cnt.
            wrk.doc = txb.joudoc.docnum.
            wrk.jh = txb.joudoc.jh.
            wrk.dat = txb.joudoc.whn.
            wrk.fio = txb.joudoc.info + " " + txb.joudoc.passp  + " " + string(txb.joudoc.passpdt) .
            wrk.dc = txb.jl.dc.
            wrk.crc = txb.jl.crc.
            wrk.rem = txb.jl.rem[1].
            wrk.nal = yes.
            find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
            if available txb.jh then wrk.ratus = GetRate(2,txb.jl.jdt,txb.jl.dc,txb.jh.tim).
            find first txb.crc where txb.crc.crc = txb.jl.crc no-lock.
            wrk.namecrc = txb.crc.code.
            if txb.jl.dc = "D" then do: /* значит продано */
                wrk.sumc = txb.jl.dam.
                wrk.vrate = txb.joudoc.srate.
                wrk.sumtngc = txb.jl.dam * txb.joudoc.srate.
                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                wrk.gld = b-jl.gl.
                wrk.glc = txb.jl.gl.
            end.
            else do: /* значит куплено */
                wrk.sumd = txb.jl.cam.
                wrk.vrate = txb.joudoc.brate.
                wrk.sumtngd = txb.jl.cam * txb.joudoc.brate.
                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                wrk.glc = b-jl.gl.
                wrk.gld = txb.jl.gl.
            end.
        end. /*if available txb.jl*/
    end. /* end for each */

/* безнал ------------------------------------------------------------------------*/
/*    for each txb.jl where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 and (txb.jl.gl = 185800 or txb.jl.gl = 285800) and txb.jl.crc <> 1 and (txb.jl.trx = "uni0065" or txb.jl.trx = "vnb0026") use-index jdt no-lock.
        create wrk.
        wrk.fil = fil-cnt.
        find first txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.
        if available txb.jh then wrk.doc = txb.jh.ref.
        wrk.jh = txb.jl.jh.
        wrk.dat = txb.jl.whn.
        wrk.fio = "" .
        wrk.dc = txb.jl.dc.
        wrk.crc = txb.jl.crc.
        wrk.nal = no.
        find first txb.crc where txb.crc.crc = txb.jl.crc no-lock.
        wrk.namecrc = txb.crc.code.
        if txb.jl.dc = "D" then do: /* значит продано */
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
            wrk.sumc = txb.jl.dam.
            wrk.vrate = b-jl.cam / txb.jl.dam.
            wrk.sumtngc = b-jl.cam.
            wrk.rem = b-jl.rem[1].
        end.
        else do: /* значит куплено */
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
            if available b-jl then do:
                wrk.sumd = txb.jl.cam.
                wrk.vrate = b-jl.dam / txb.jl.cam.
                wrk.sumtngd = b-jl.dam.
                wrk.rem = txb.jl.rem[1].
           end.
        end.
    end.*/