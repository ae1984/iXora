/* pcciffindtxb.p
 * MODULE
        Поиск клиента по ИИН
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
        25/11/2013 galina ТЗ2199
 * BASES
        BANK TXB
 * CHANGES
*/
def input parameter p-bin as char.

def output parameter  p-find as logi.
def output parameter  p-rnn as char.
def output parameter p-sname as char.
def output parameter p-fname as char.
def output parameter p-mname as char.
def output parameter p-namelat1 as char.
def output parameter p-namelat2 as char.
def output parameter p-birth as date.
def output parameter p-tel1 as char.
def output parameter p-tel2 as char.
def output parameter p-addr1 as char.
def output parameter p-addr2 as char.
def output parameter p-expdt1 as date.
def output parameter p-rez as logi.
def output parameter p-country  as char.
def output parameter p-work as char.
def output parameter p-migrn as char.
def output parameter p-migrdt1 as date.
def output parameter p-migrdt2 as date.
def output parameter p-position as char.
def output parameter p-nomdoc as char.
def output parameter p-isswho as char.
def output parameter p-issdt1 as date.

def var v-publicf as logi.

find first txb.cif where txb.cif.bin = p-bin no-lock no-error.
if avail txb.cif then do:
    p-find = yes.
    find first txb.sub-cod where txb.sub-cod.acc =  txb.cif.cif and txb.sub-cod.sub = 'cln' and txb.sub-cod.d-cod = 'publicf' no-lock no-error.
    if avail txb.sub-cod then v-publicf =  if txb.sub-cod.ccode = '1' then no else yes.
    assign
    p-rnn      = txb.cif.jss
    p-sname    = entry(1,txb.cif.name,' ')
    p-fname    = entry(2,txb.cif.name,' ')
    p-mname    = entry(3,txb.cif.name,' ')
    p-namelat1 = if num-entries(txb.cif.namelat,' ') = 2 then  entry(1,txb.cif.namelat,' ') else ''
    p-namelat2 = if num-entries(txb.cif.namelat,' ') = 2 then  entry(2,txb.cif.namelat,' ') else ''
    p-birth    = txb.cif.expdt
    p-tel1   = txb.cif.tel
    p-tel2   = txb.cif.fax
    p-addr1  = txb.cif.addr[1]
    p-addr2  = txb.cif.addr[2]
    p-expdt1   = txb.cif.dtsrokul
    p-rez      = if txb.cif.irs = 1 then yes else no
    p-country  = if txb.cif.irs = 1 then 'KAZ' else ''
    p-work     = txb.cif.ref[8]
    p-migrn    = txb.cif.migr-number
    p-migrdt1  = txb.cif.migr-dt
    p-migrdt2  = txb.cif.migr-dt-exp
    p-position = if v-publicf then txb.cif.sufix else ''
    p-nomdoc   = entry(1,txb.cif.pss,' ')
    p-isswho   = if num-entries(txb.cif.pss,' ') > 2 then entry(3,txb.cif.pss,' ') else ''
    p-issdt1   = if num-entries(txb.cif.pss,' ') > 1 then date(entry(2,txb.cif.pss,' ')) else ?.

end.
else p-find = no.

