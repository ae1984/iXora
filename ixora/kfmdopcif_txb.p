/* kfmdopcif.p
 * MODULE
        Название модуля
 * DESCRIPTION
        поиск клиента по филиалам для выгрузки в AML
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
        23/06/2010 galina
 * BASES
        BANK TXB
 * CHANGES
        24/06/2010 galina - по РНН ищем только резидентов
        02/01/2013 madiyar - поиск по ИИН/БИН
*/

def input parameter p-res as char.
def input parameter p-clid as char.

def shared temp-table t-cif
    field fam as char
    field name as char
    field mname as char
    field iin as char
    field doctyp as char
    field publicf as char
    field rnn as char
    field numreg as char
    field dtreg as date
    field orgreg  as char
    field dtbth as date
    field bplace  as char
    field adres  as char
    field tel  as char
    field bank as char
    field cif as char.

def var v-bank as char.
v-bank = ''.
find first txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.
if avail txb.sysc and txb.sysc.chval <> '' then v-bank = txb.sysc.chval.

if p-res = '1' then find first txb.cif where txb.cif.bin = p-clid and txb.cif.type = 'P' and txb.cif.geo = '021' no-lock no-error.
else find first txb.cif where txb.cif.geo <> '021' and txb.cif.type = 'P' and txb.cif.pss matches '*' + p-clid + '*' no-lock no-error.
if avail txb.cif then do:
    create t-cif.
    t-cif.cif = txb.cif.cif.
    t-cif.rnn = txb.cif.jss.
    if txb.cif.pss <> '' then do:
        case num-entries(trim(txb.cif.pss),' '):
            when 1 then t-cif.numreg = txb.cif.pss.
            when 2 then do: t-cif.numreg = entry(1,txb.cif.pss, ' '). t-cif.dtreg = date(entry(2,txb.cif.pss,' ')) no-error. end.
            when 3 then do: t-cif.numreg = entry(1,txb.cif.pss, ' '). t-cif.dtreg = date(entry(2,txb.cif.pss, ' ')) no-error. t-cif.orgreg  = entry(3,txb.cif.pss, ' '). end.
            when 4 then do: t-cif.numreg = entry(1,txb.cif.pss, ' '). t-cif.dtreg = date(entry(2,txb.cif.pss, ' ')) no-error. t-cif.orgreg  = entry(3,txb.cif.pss, ' ') + ' ' +  entry(4,txb.cif.pss, ' '). end.
            otherwise t-cif.numreg = txb.cif.pss.
        end.
    end.

    if txb.cif.name <> '' then do:
        case num-entries(trim(cif.name),' '):
            when 1 then t-cif.fam = txb.cif.name.
            when 2 then do: t-cif.fam = entry(1,txb.cif.name,' '). t-cif.name = entry(2,txb.cif.name,' '). end.
            when 3 then do: t-cif.fam = entry(1,txb.cif.name,' '). t-cif.name = entry(2,txb.cif.name,' '). t-cif.mname = entry(3,txb.cif.name,' '). end.
        end.
    end.

    t-cif.dtbth = txb.cif.expdt.
    t-cif.bplace = txb.cif.bplace.
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'publicf' no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then t-cif.publicf = txb.sub-cod.ccode.


    t-cif.adres = txb.cif.addr[1].
    t-cif.tel = txb.cif.tel.
    t-cif.iin = txb.cif.bin.
    t-cif.bank = v-bank.
end.

