/* dclslncom.p
 * MODULE
        Закрытие операционного дня
 * DESCRIPTION
        Амортизация комиссии по кредитам
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
        01/10/2011 madiyar
 * BASES
        BANK
 * CHANGES
        03/10/2011 madiyar - в транзакцию передается валюта займа
        06/10/2011 madiyar - подправил округление
        08/11/2011 madiyar - если договор прерван (проставлен признак clsa), забираем всю комиссию на доходы
        09/11/2011 madiyar - поменял признак clsa -> clsarep
        29/12/2011 madiyar - амортизация комиссий по займам
        04/01/2012 madiyar - исправление
        07/02/2012 madiyar - подправил расчет комиссии
        08/02/2012 madiyar - валюта всегда тенге
        30/01/2013 sayat(id01143) - ТЗ 1681 от 30/01/2013 предусмотрена амортизации комиссии по валютным займам
        31/01/2013 sayat(id01143) - ТЗ 1681 перекомпиляция в связи с изменением шаблона LON0178
*/

{global.i}

def var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.
def var v-rem as char no-undo.

def var v-dtfrom as date no-undo.
def var v-dtto as date no-undo.
def var v-commonth as deci no-undo.
def var v-comday as deci no-undo.
def var v-com as deci no-undo.
def var v-com_rnd as deci no-undo.
def var v-com_all as deci no-undo.
def var v-sum as deci no-undo.
def var v-takeall as logi no-undo.
def var v-bal as deci no-undo.
def var v-duedt as date no-undo.

def shared var s-target as date.

def var v-lev1 as integer no-undo.
v-lev1 = 42. /* 1434 */
def var v-lev2 as integer no-undo.
v-lev2 = 31. /* 4434 */

for each lon no-lock:
    if lon.opnamt <= 0 then next.

    /*
    if lon.gua <> 'CL' then next.
    */
    if year(lon.rdt) < 2011 then next.

    v-takeall = no.
    v-duedt = lon.duedt.
    if lon.ddt[5] <> ? then v-duedt = lon.ddt[5].
    if lon.cdt[5] <> ? then v-duedt = lon.cdt[5].
    if v-duedt < s-target then v-takeall = yes.
    else do:
        if lon.gua = "CL" then do:
            find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'clsarep' no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> 'msc' then v-takeall = yes.
        end.
        else do:
            run lonbal('lon',lon.lon,g-today,"1,7,2,9,16,4,5",yes,output v-bal).
            if v-bal <= 0 then v-takeall = yes.
        end.
    end.

    find first lnscc where lnscc.lon = lon.lon and lnscc.stdat > g-today no-lock no-error.
    if not avail lnscc then next.
    else do:
        v-dtto = lnscc.stdat.
        v-commonth = lnscc.stval.
    end.
    find first loncon where loncon.lon = lon.lon no-lock no-error.

    run lonbalcrc('lon',lon.lon,g-today,string(v-lev1),yes,1,output v-com_all).
    v-com_all = - v-com_all.

    v-com = 0.

    if not v-takeall then do: /* считаем по графику амортизации */
        find last lnscc where lnscc.lon = lon.lon and lnscc.stdat <= g-today no-lock no-error.
        if avail lnscc then v-dtfrom = lnscc.stdat.
        else do:
            v-dtfrom = lon.rdt.
            find first lnscg where lnscg.lng = lon.lon and lnscg.flp > 0 no-lock no-error.
            if avail lnscg and lnscg.stdat <> v-dtfrom then v-dtfrom = lnscg.stdat.
        end.
        v-comday = v-commonth / (v-dtto - v-dtfrom).
        if v-dtto >= s-target then v-com = v-comday * (s-target - g-today) + loncon.accrued[1].
        else do:
            v-com = v-comday * (v-dtto - g-today) + loncon.accrued[1].
            find first lnscc where lnscc.lon = lon.lon and lnscc.stdat > v-dtto no-lock no-error.
            if avail lnscc then do:
                v-comday = lnscc.stval / (lnscc.stdat - v-dtto).
                v-com = v-com + v-comday * (s-target - v-dtto).
            end.
        end.
    end.
    else do: /* нужно забирать все, если есть что забирать */
        if v-com_all <> 0 then do:
            v-com = v-com_all.
            run savelog("amortcom", "CL closed " + lon.cif + " " + lon.lon + " com=" + trim(string(v-com,"->>>,>>>,>>>,>>9.99"))).
        end.
    end.

    if abs(v-com) > 0 then do transaction:
        v-com_rnd = round(v-com,2).
        v-sum = abs(v-com_rnd).
        if v-takeall then v-rem = "Доходы по амортизации комиссии за предоставление кредитной линии/займа по кредитному договору N " + loncon.lcnt.
        else v-rem = "Доходы по амортизации комиссии за предоставление кредитной линии/займа по кредитному договору N " + loncon.lcnt + ", за период с " + string(g-today,"99/99/9999") + " по " + string(s-target - 1,"99/99/9999").
        if lon.crc = 1 then do:
            if v-com > 0 then do:
                v-param = string(v-sum) + vdel + "1" + vdel +
                          string(v-lev1) + vdel +
                          lon.lon + vdel +
                        string(v-lev2) + vdel +
                        v-rem.
            end.
            else do:
                v-param = string(v-sum) + vdel + "1" + vdel +
                          string(v-lev2) + vdel +
                          lon.lon + vdel +
                        string(v-lev1) + vdel +
                        v-rem.
            end.
            s-jh = 0.
            run trxgen("LON0152",vdel,v-param,"lon",lon.lon,output rcode,output rdes,input-output s-jh).
            if rcode <> 0 then do:
                run savelog("msfocomerr", "ERROR " + lon.cif + " " + lon.lon + " " + rdes + " " + v-param).
                message rdes.
                pause 1000.
            end.
            else do:
                find current loncon exclusive-lock.
                loncon.accrued[1] = v-com - v-com_rnd.
                find current loncon no-lock.
                run lonresadd(s-jh).
            end.
        end.
        else do:
            find first crc where crc.crc = lon.crc no-lock no-error.
            if v-com > 0 then do:
                v-param = string(v-sum)  + vdel + string(lon.crc) + vdel + string(v-lev1) + vdel +
                          lon.lon + vdel + v-rem + vdel + string(round(v-sum * crc.rate[1],2))
                          + vdel + "1" + vdel + string(v-lev2).
            end.
            else do:
                v-param = string(round(v-sum * crc.rate[1],2)) + vdel + "1" + vdel + string(v-lev2) + vdel +
                          lon.lon + vdel + v-rem + vdel + string(v-sum) + vdel +
                          string(lon.crc) + vdel + string(v-lev1).
            end.
            s-jh = 0.
            run trxgen("LON0178",vdel,v-param,"lon",lon.lon,output rcode,output rdes,input-output s-jh).
            if rcode <> 0 then do:
                run savelog("msfocomerr", "ERROR " + lon.cif + " " + lon.lon + " " + rdes + " " + v-param).
                message rdes.
                pause 1000.
            end.
            else do:
                find current loncon exclusive-lock.
                loncon.accrued[1] = v-com - v-com_rnd.
                find current loncon no-lock.
                run lonresadd(s-jh).
            end.
        end.
    end.
end.


