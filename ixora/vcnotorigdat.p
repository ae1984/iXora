/* vcnotorigdat.p
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

def shared temp-table t-temp
    field cifname as char
    field contr   as char
    field ps      as char
    field daypros as inte.

def var v-day        as inte. /*Кол-во дней просрочки*/
def var v-nameclient as char.
def var v-psnum      as char.

def shared var v-date as date.

for each vccontrs where vccontrs.bank = p-bank and vccontrs.ctoriginal = no no-lock:
    assign v-nameclient = "" v-psnum = "".
    v-day = v-date - vccontrs.ctregdt.
    if v-day >= 31 then do:
        find first txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
        if avail txb.cif then v-nameclient = trim(txb.cif.name) + " " + trim(txb.cif.prefix).
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then v-psnum = vcps.dnnum + string(vcps.num).
        else v-psnum = "".
        create t-temp.
        assign
        t-temp.cifname = v-nameclient
        t-temp.contr = vccontrs.ctnum + " " + string(vccontrs.ctdate)
        t-temp.ps = v-psnum
        t-temp.daypros = v-day - 30.
    end.
end. /*for each vccontrs*/

