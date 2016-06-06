/* dclspenot.p
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
	    Возврат отсроченной пени на внебалансовую пеню, автоматическое списание отсроченной пени при полном погашении кредита
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
        14/04/2010 madiyar
 * BASES
        BANK
 * CHANGES
        16/04/2010 madiyar - перекомпиляция
*/

{global.i}

define shared var s-intday as int.

def new shared var s-jh like jh.jh.
def var v-rem as char no-undo.
def var vparam as char no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var vdel as char no-undo initial "^".

def var v-dayspr as integer no-undo.

def var v-bal as deci no-undo.
def var v-bal33 as deci no-undo.

def var v-logfile as char no-undo.
v-logfile = "penotsr".

for each lon no-lock:
    run lonbalcrc('lon',lon.lon,g-today,"33",yes,1,output v-bal33).
    if v-bal33 <= 0 then next.

    if lon.sts = 'C' then do:
        /* списываем */
        v-rem = "Списание отсроченной пени в связи с полным погашением, сс.счет " + lon.lon.
        vparam = string(v-bal33) + vdel + string(lon.lon) + vdel +
                 v-rem + vdel + vdel + vdel + vdel.

        s-jh = 0.
        run trxgen("lon0132", vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

        if rcode <> 0 then do:
            message rcode rdes.
            pause.
            undo, return.
        end.

        run lonresadd(s-jh).
        run savelog(v-logfile, lon.lon + " списание KZT" + string(v-bal33) + " trx=" + string(s-jh)).
    end.
    else do:
        find first londebt where londebt.lon = lon.lon no-lock no-error.
        if not avail londebt then next.

        run lonbal('lon',lon.lon,g-today,"4,7,9",yes,output v-bal).
        if v-bal > 0 then do:
            v-dayspr = londebt.days_od.
            if londebt.days_prc > v-dayspr then v-dayspr = londebt.days_prc.
            v-dayspr = v-dayspr + s-intday.
            if v-dayspr >= 90 then do:
                v-rem = "Перенос отсроченной пени в срочную, сс.счет " + lon.lon.
                vparam = string(v-bal33) + vdel + string(lon.lon) + vdel +
                         v-rem + vdel + vdel + vdel + vdel.

                s-jh = 0.
                run trxgen("lon0131", vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).

                if rcode <> 0 then do:
                    message rcode rdes.
                    pause.
                    undo, return.
                end.

                run lonresadd(s-jh).
                run savelog(v-logfile, lon.lon + " перенос KZT" + string(v-bal33) + " trx=" + string(s-jh)).
            end.
        end.
    end.
end.

