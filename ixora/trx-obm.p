/* trx-obm.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * BASES
	    BANK COMM
 * CHANGES
        09.09.2003 sasco печать БКС
        27.01.2004 sasco    - убрал today для cashofc
        29.09.2006 u00568 Evgeniy - по тз 469 пусть печатает чек бкс по 100200
        22/06/2011 madiyar - добавил по кассе счет 100500
        20.01.2012 damir - убрал печать БКС,добавил keyord.i.
        25.01.2012 damir - перекомпиляция.
        02.02.2012 lyubov - добавила в выборку сим.касспл. условие "cashpl.act"
        05.03.2012 damir - добавил keyord.i, printord.p
        07.03.2012 damir - убрал shared parameter s-jh...

*/

{keyord.i} /*Переход на новые и старые форматы выходных форм*/

def input parameter  p-pjh like jh.jh.

def shared var g-ofc    like ofc.ofc.
def shared var g-fname  as char.

def var c-gl        like gl.gl.
def var s_payment   as char.
def var v-err       as char no-undo.

find sysc where sysc.sysc = "CASHGL" no-lock.
c-gl = sysc.inval.

do on error undo, retry:
    find first jl where jl.jh = p-pjh no-error.
    if not available jl then do.
        message "Транзакция не найдена!".
        bell. bell.
        pause.
        next.
    end.

    find jh where jh.jh = p-pjh.
    find cursts where cursts.sub eq jh.sub and cursts.acc eq jh.ref use-index subacc no-lock no-error.
    if cursts.sts ne "cas" then do:
        message "Статус документа не  <cas>!".
        bell. bell.
        pause.
        next.
    end.

    find jl of jh where ((jl.gl = c-gl) or (jl.gl = 100500)) and jl.crc = 1 exclusive-lock no-error.
    find first jlsach where jlsach.jh = jl.jh and jlsach.ln = jl.ln no-lock no-error.
    if not available jlsach  then do:
        message "Не введен символ кас.плана !".
        bell. bell.
        pause.
        next.
    end.
    find first cashpl where cashpl.sim = jlsach.sim and cashpl.act no-lock no-error.
    if not available cashpl then do:
        message "Нет такого символа кас.плана!".
        bell. bell.
        pause.
        next.
    end.

    jl.rem[5] = string(cashpl.sim,"zzz") + " " + cashpl.des.

    /* ЭК */
    find first jl where jl.jh = jh.jh and jl.gl = 100500 no-lock no-error.
    if avail jl then do:
        v-err = ''.
        run csobm(p-pjh, output v-err).
        if v-err <> '' then do:
            message v-err view-as alert-box error.
            return.
        end.
    end.
    /* ЭК - end */

    for each jl of jh exclusive-lock:
        jl.sts = 6.
        jl.teller = g-ofc.
        /* --------------------> 11.10.2001, by sasco >------------------- */
        /* --------------------- generate CASHOFC record ----------------- */
        find sysc where sysc.sysc = 'CASHGL' no-lock.
        if (jl.gl = sysc.inval) or (jl.gl = 100500) then do:
            find cashofc where
                cashofc.ofc = g-ofc and
                cashofc.whn = jl.jdt and
                cashofc.crc = jl.crc and
                cashofc.sts = 2
                no-error.
            if avail cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
            else do:
                create cashofc.
                cashofc.whn = jl.jdt.
                cashofc.ofc = g-ofc.
                cashofc.crc = jl.crc.
                cashofc.sts = 2.
                cashofc.amt = jl.dam - jl.cam.
            end.
        end.
        /* --------------------< 11.10.2001, by sasco <------------------- */
    end.

    release jl.
    jh.sts = 6.

    s_payment = ''.

    for each jl where jl.jh = jh.jh and jl.jdt = jh.jdt and (jl.gl = 100100 or jl.gl = 100200 or jl.gl = 100300 or jl.gl = 100500) no-lock:
        find first crc where crc.crc = jl.crc no-lock no-error.
        s_payment = s_payment + string(jh.jh) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
    end.

    s_payment = right-trim(s_payment,"|").
    if s_payment <> '' then do:
        if g-fname = "csobmen" then run bks1 (s_payment,"TRX").
        else do:
            if v-noord = no then run bks (s_payment,"TRX").
        end.
    end.

    if jh.sub ne "" and jh.ref ne "" and jh.sub ne "lon" then do:
        run chgsts(jh.sub, jh.ref, "rdy").
    end.

    if v-noord = yes then run printord(p-pjh,""). /*Печать новых форматов кассовых ордеров*/

end.
