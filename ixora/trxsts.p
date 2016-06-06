/* trxsts.p
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
        29.09.2006 u00568 Evgeniy - по тз 469 пусть печатает чек бкс по 100200
        05.03.2012 damir - добавил keyord.i, printord.p
        06.03.2012 damir - исключения для п.м. 4.1.8. g-fname = "TIYN"
        07.03.2012 damir - убрал shared parameter s-jh.
        11.03.2012 damir - исключения для п.м. 4.2.15.g-fname = "cas110"
        28.05.2012 k.gitalov - добавил дату штампа
*/

{global.i}
{keyord.i} /*Переход на новые и старые форматы выходных форм*/

def input parameter  vjh    as inte.
def input parameter  vsts   as inte.
def output parameter rcode  as inte initial 100.
def output parameter rdes   as char.

def var errlist     as char extent 32.
def var s_payment   as character.

errlist[22] = "Can't find transaction for stamp.".
errlist[23] = "Can't stamp cash transaction.".
errlist[32] = "Illegal transaction status.".

find sysc where sysc.sysc = "cashgl" no-lock.
if vsts < 0 and vsts > 6 then do:
    rcode = 32.
    rdes = errlist[rcode] + ": sts=" + string(vsts).
    return.
end.
find first jh where jh.jh = vjh no-lock no-error.
if not available jh then do:
    rcode = 22.
    rdes = errlist[rcode] + " " + string(vjh,"zzzzzzz9").
    return.
end.

do transaction:
    find jh where jh.jh = vjh exclusive-lock.
    assign jh.sts = vsts.
      if vsts = 6 then assign jh.stmp_tim = time jh.jdt_sts = today.
    for each jl where jl.jh = vjh exclusive-lock:
        assign jl.sts = vsts.
        if jl.sts = 6 then assign jl.teller = g-ofc.
    end.
    rcode = 0.

    if vsts = 6 then do:
        s_payment = ''.
        find jh where jh.jh = vjh no-lock.
        for each jl where jl.jh = vjh and jl.jdt = jh.jdt and (jl.gl = 100100  or jl.gl = 100200 or jl.gl = 100300 or jl.gl = 100500)
        no-lock:
            find first crc where crc.crc = jl.crc no-lock no-error.
            s_payment = s_payment + string(vjh) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
        end.
        s_payment = right-trim(s_payment,"|").
        if s_payment <> '' then if v-noord = no then run bks (s_payment,"TRX").

        if v-noord = yes then do:
            if trim(g-fname) <> "TIYN" and trim(g-fname) <> "cas110" then run printord(vjh,""). /*Печать новых форматов кассовых ордеров*/
        end.
    end.
end.
