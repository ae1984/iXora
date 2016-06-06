 /* kzrepscrcf1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Обменные курсы наличных иностранной валюты филиалов
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
        BANK TXB
 * CHANGES
        26.04.2011 aigul - изменила вывод валют
*/
def shared var dtb as date.
def shared var dte as date.
def var v-dt as date.

def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.

find txb.cmp no-lock no-error.
s-ourbank = txb.cmp.name.

def shared temp-table wrk
    field fil as char
    field i as int
    field dt as date
    field tm as char
    field rasp as char
    field crc as char
    field buy1 as decimal
    field sell1 as decimal
    field buy2 as decimal
    field sell2 as decimal
    field buy3 as decimal
    field sell3 as decimal
    field buy4 as decimal
    field sell4 as decimal.

do v-dt = dtb to dte:
    for each txb.crclg where txb.crclg.whn = v-dt and txb.crclg.sts = "V" no-lock break by txb.crclg.order:
        IF FIRST-OF(txb.crclg.order) then create wrk.
        wrk.dt = txb.crclg.whn.
        wrk.rasp = txb.crclg.order.
        wrk.tm = string(txb.crclg.tim, "HH:MM:SS").
        wrk.crc = txb.crclg.crctxt.
        if txb.crclg.crctxt = "USD" then do:
            wrk.buy1 = txb.crclg.crcpok.
            wrk.sell1 = txb.crclg.crcprod.
        end.
        else if txb.crclg.crctxt = "EUR" then do:
            wrk.buy2 = txb.crclg.crcpok.
            wrk.sell2 = txb.crclg.crcprod.
        end.
        else if (txb.crclg.crctxt = "RUB" or txb.crclg.crctxt = "RUR") then do:
            wrk.buy3 = txb.crclg.crcpok.
            wrk.sell3 = txb.crclg.crcprod.
        end.
        else if txb.crclg.crctxt = "GBP" then do:
            wrk.buy4 = txb.crclg.crcpok.
            wrk.sell4 = txb.crclg.crcprod.
        end.
        else do:
            wrk.buy4 = 0.
            wrk.sell4 = 0.
            find first txb.crc where txb.crc.code = txb.crclg.crctxt no-lock no-error.
            if avail txb.crc then wrk.crc = txb.crc.code.
        end.
        wrk.fil = s-ourbank.
    end.

    for each txb.crchis where txb.crchis.rdt = v-dt no-lock /*use-index crcrdt*/ break by txb.crchis.order:
        IF FIRST-OF(txb.crchis.order) then create wrk.
        wrk.dt = txb.crchis.rdt.
        wrk.tm = string(txb.crchis.tim, "HH:MM:SS").
        wrk.rasp = txb.crchis.order.
        find first txb.crc where txb.crc.crc = txb.crchis.crc no-lock no-error.
        if avail txb.crc then wrk.crc = txb.crc.code.
        if txb.crchis.crc = 2 then do:
            wrk.buy1 = txb.crchis.rate[2].
            wrk.sell1 = txb.crchis.rate[3].
        end.
        else if txb.crchis.crc = 3 then do:
            wrk.buy2 = txb.crchis.rate[2].
            wrk.sell2 = txb.crchis.rate[3].
        end.
        else if txb.crchis.crc = 4 then do:
            wrk.buy3 = txb.crchis.rate[2].
            wrk.sell3 = txb.crchis.rate[3].
        end.
        else if txb.crchis.crc = 6 then do:
            wrk.buy4 = txb.crchis.rate[2].
            wrk.sell4 = txb.crchis.rate[3].
        end.
        else do:
            wrk.buy4 = 0.
            wrk.sell4 = 0.
            find first txb.crc where txb.crc.crc = txb.crchis.crc no-lock no-error.
            if avail txb.crc then wrk.crc = txb.crc.code.
        end.
        wrk.fil = s-ourbank.
    end.
end.
