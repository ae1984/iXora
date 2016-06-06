/* vccardnardat.p
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
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def input parameter p-bank as char.
def input parameter p-date as date.
def input parameter p-sts  as char.

def shared temp-table t-temp
    field cif      as char
    field ctnum    as char
    field ctdate   as char
    field ncrc     as char
    field cardnum  as char
    field sumoper  as char
    field dateoper as char
    field codetype as char
    field desnar   as char.

def var v-crc    as char.
def var v-desnar as char.
def var v-temp   as char.

main:
for each vccardnar where vccardnar.bank = p-bank and vccardnar.dndate = p-date no-lock:
    case trim(p-sts):
        when "A" then do:
            if not (vccardnar.priznak = "N" or vccardnar.priznak = "D") then next main.
        end.
        when "N" then do:
            if not (vccardnar.priznak = "N") then next main.
        end.
        when "D" then do:
            if not (vccardnar.priznak = "D") then next main.
        end.
    end.
    find first vccontrs where vccontrs.contract = vccardnar.contract and vccontrs.sts <> "C" no-lock no-error.
    if avail vccontrs then do:
        find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
        if avail txb.cif then do:
            find first txb.ncrc where txb.ncrc.crc = vccontrs.ncrc no-lock no-error.
            if avail txb.ncrc then v-crc = txb.ncrc.code.
            find first txb.codfr where txb.codfr.codfr = "vcmsg115" and txb.codfr.code = trim(string(vccardnar.codetype)) no-lock no-error.
            if avail txb.codfr then v-desnar = txb.codfr.name[1].
            create t-temp.
            assign
            t-temp.cif      = trim(txb.cif.name) + " " + trim(txb.cif.prefix)
            t-temp.ctnum    = vccontrs.ctnum
            t-temp.ctdate   = string(vccontrs.ctdate, "99.99.9999")
            t-temp.ncrc     = trim(v-crc)
            t-temp.cardnum  = string(vccardnar.uninum,"9999999999")
            t-temp.sumoper  = string(vccardnar.sumvaloper, ">>>>>>>>>>>>>>9.99")
            t-temp.dateoper = string(vccardnar.dtvaloper, "99.99.9999")
            t-temp.codetype = string(vccardnar.codetype, ">>>>9")
            t-temp.desnar   = trim(v-desnar).
        end.
    end.

end.


