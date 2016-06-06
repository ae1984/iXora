/* kzrepscrc1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет по опорным курсам валют
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
        25.03.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        20.04.2011 aigul поменяла TXB на COMM
*/

/*def input parameter p-bank as char.*/
def input parameter dtb as date.
def input parameter dte as date.
def var v-dt as date no-undo.
def shared temp-table wrk
    field dt as date
    field tm as char
    field rasp as int
    field crc as char
    field buy1 as decimal
    field sell1 as decimal
    field spred1 as decimal
    field buy2 as decimal
    field sell2 as decimal
    field spred2 as decimal
    field buy3 as decimal
    field sell3 as decimal
    field spred3 as decimal
    field buy4 as decimal
    field sell4 as decimal
    field spred4 as decimal.

do v-dt = dtb to dte:
    for each scrc where scrc.regdt = v-dt no-lock break by scrc.order:
        if first-of(scrc.order) then do:
            create wrk.
            wrk.dt = scrc.regdt.
            wrk.tm = string(scrc.tim, "HH:MM:SS").
            wrk.rasp = scrc.order.
            find first crc where crc.crc = scrc.crc no-lock no-error.
            if avail crc then wrk.crc = crc.code.
        end.
        find first wrk where wrk.rasp = scrc.order exclusive-lock no-error.
        if avail wrk then do:
            if scrc.crc = 2 then do:
                wrk.buy1 = scrc.buycrc.
                wrk.sell1 = scrc.sellcrc.
                wrk.spred1 = scrc.minspr.
            end.
            else if scrc.crc = 3 then do:
                wrk.buy2 = scrc.buycrc.
                wrk.sell2 = scrc.sellcrc.
                wrk.spred2 = scrc.minspr.
            end.
            else if scrc.crc = 4 then do:
                wrk.buy3 = scrc.buycrc.
                wrk.sell3 = scrc.sellcrc.
                wrk.spred3 = scrc.minspr.
            end.
            else do:
                find first crc where crc.crc = scrc.crc no-lock no-error.
                if avail crc then wrk.crc = crc.code.
                wrk.buy4 = 0.
                wrk.sell4 = 0.
                wrk.spred4 = 0.
            end.
        end.
    end.
end.
