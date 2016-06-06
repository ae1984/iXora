/* dcls_clclose.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Автоматическое обнуление остатков условных обязательств по КЛ при наступлении срока периода доступности
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
        26/01/2011 madiyar
 * BASES
        BANK
 * CHANGES
*/

{global.i}
{lonlev.i}

def new shared var s-jh like jh.jh.

def shared var s-target as date.
def shared var s-bday as log.
def shared var s-intday as int.

def var dn1 as integer.
def var dn2 as decimal.

def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var s-glremx as char extent 5.

def var sum15 as deci no-undo.
def var sum35 as deci no-undo.

define stream m-out.
output stream m-out to value("lonclclose" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".txt").


for each lon where lon.gua = 'CL' no-lock:
    
    find first cif where cif.cif = lon.cif no-lock no-error.
    if not avail cif then next.

    run lonbalcrc('lon',lon.lon,g-today,"15",yes,lon.crc,output sum15).
    sum15 = - sum15.
    run lonbalcrc('lon',lon.lon,g-today,"35",yes,lon.crc,output sum35).
    sum35 = - sum35.

    find first loncon where loncon.lon = lon.lon no-lock no-error.
    find first crc where crc.crc = lon.crc no-lock no-error.
    
    
    if sum15 > 0 and lon.idt15 <> ? then do:
        if g-today >= lon.idt15 then do transaction:
            v-param = string(sum15) + vdel + lon.lon.
            s-glremx[1] = "Списание возобн. дост. остатка КЛ (по сроку), " + lon.lon + " " + if avail loncon then loncon.lcnt else ''.
            s-glremx[1] = s-glremx[1] + " " + trim(string(sum15,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                          " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
            v-param = v-param + vdel + s-glremx[1] + vdel + vdel + vdel + vdel.
            s-jh = 0.
            run trxgen ("LON0139", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            if rcode <> 0 then do:
                put stream m-out unformatted 'Error Списание(15) ' lon.cif ' ' lon.lon ' ' string(sum15,"->>>,>>>,>>>,>>9.99") ' ' rdes + " Ошибка списания возобн. дост. остатка КЛ по сроку!" skip.
                message rdes + " Ошибка списания возобн. дост. остатка КЛ по сроку!".
                pause 1000.
            end.
            else do:
                run lonresadd(s-jh).
                put stream m-out unformatted 'Списание(15) ' lon.cif ' ' lon.lon ' ' string(sum15,"->>>,>>>,>>>,>>9.99") ' jh=' s-jh skip.
            end.
        end. /* transaction */
    end.

    if sum35 > 0 and lon.idt35 <> ? then do:
        if g-today >= lon.idt35 then do transaction:
            v-param = string(sum35) + vdel + lon.lon.
            s-glremx[1] = "Списание невозобн. дост. остатка КЛ (по сроку), " + lon.lon + " " + if avail loncon then loncon.lcnt else ''.
            s-glremx[1] = s-glremx[1] + " " + trim(string(sum35,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                          " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
            v-param = v-param + vdel + s-glremx[1] + vdel + vdel + vdel + vdel.
            s-jh = 0.
            run trxgen ("LON0140", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            if rcode <> 0 then do:
                put stream m-out unformatted 'Error Списание(35) ' lon.cif ' ' lon.lon ' ' string(sum35,"->>>,>>>,>>>,>>9.99") ' ' rdes + " Ошибка списания невозобн. дост. остатка КЛ по сроку!" skip.
                message rdes + " Ошибка списания невозобн. дост. остатка КЛ по сроку!".
                pause 1000.
            end.
            else do:
                run lonresadd(s-jh).
                put stream m-out unformatted 'Списание(35) ' lon.cif ' ' lon.lon ' ' string(sum35,"->>>,>>>,>>>,>>9.99") ' jh=' s-jh skip.
            end.
        end. /* transaction */
    end.
    
end.

output stream m-out close.


