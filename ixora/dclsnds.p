/* dclsnds.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        04/07/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        13.01.2009 alex - запись ошибок в лог, уведомление об ошибках на support.
        14.01.2009 alex - название базы в теме письма об ошибке.
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{global.i}

def var s-jh like jh.jh.

def var v-sum as dec.
def var v-nds as dec.
def var vdel as char.
def var v-rem as char.
def var v-tmpl as char.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v-mailmessage as char.
def var v-adr as char.

def var v-logfile as char no-undo.
v-logfile = "nds" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".txt".

procedure rec2log:
   define input parameter v-file as char no-undo.
   define input parameter v-str as char no-undo.
   output to value(v-file) append.
   put unformatted v-str skip.
   output close.
end procedure.

find first cmp no-lock no-error.
if avail cmp then v-adr = entry(1, cmp.addr[1]).
if cmp.name matches "*МКО*" then return.

find first sysc where sysc.sysc eq "nds" no-lock no-error.
if not avail sysc or (sysc.chval eq "") or (sysc.deval <= 0) then do:
    run rec2log(v-logfile, "Ошибка! Не настроен справочник в sysc ставки НДС и arp-счета!").
    run mail("support@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка начисления НДС " + v-adr, "Не настроен справочник в sysc ставки НДС и arp-счета!", "1", "", "").
    return.
end.

find first arp where arp.arp = trim(sysc.chval) no-lock no-error.
if not avail arp then do:
    run rec2log(v-logfile, "Ошибка! Отсутствует счет ARP. " + sysc.chval).
    run mail("support@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Ошибка начисления НДС " + v-adr, "Отсутствует счет ARP. " + sysc.chval, "1", "", "").
    return.
end.

for each gl where gl.gl >= 400000 and gl.gl < 500000 no-lock:

    find first sub-cod where (sub-cod.acc eq string(gl.gl)) and (sub-cod.d-cod eq "ndcgl") and (sub-cod.ccode eq "01") no-lock no-error.
    if not avail sub-cod then next.

    v-sum = 0. v-nds = 0.
    for each jl where (jl.jdt eq g-today) and (jl.dc eq "c") and (jl.gl eq gl.gl) and (jl.crc = 1) no-lock:
        v-sum = v-sum + jl.cam.
        run rec2log(v-logfile, string(gl.gl) + " " + string(jl.jh) + " " + string(jl.cam) + " " + string(round(jl.cam * sysc.deval / (1 + sysc.deval),2))).
    end.

    if v-sum gt 0 then do:
        v-nds = round(v-sum * sysc.deval / (1 + sysc.deval),2).

        vdel = "^".
        v-rem = "НДС за " + string(g-today,"99/99/9999") + " по счету ГК " + string(gl.gl).
        v-tmpl = "vnb0002".

        vparam = string(v-nds) + vdel + "1" + vdel + string(gl.gl) + vdel + sysc.chval + vdel + v-rem.
        run trxgen(v-tmpl, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
        if rcode = 0 then run rec2log(v-logfile, " --- " + string(gl.gl) + " " + string(s-jh) + " " + string(v-sum) + " " + string(v-nds)).
        else run rec2log(v-logfile, " Ошибка! Проводка не создана. " + rdes).
    end.

end.

