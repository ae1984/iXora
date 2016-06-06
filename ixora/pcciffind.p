/* pcciffind.p
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
        BANK COMM
 * CHANGES
*/


def input parameter p-bin as char.


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

def var v-find as logi.
def var v-path as char no-undo.

find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.


if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.
v-find = no.

for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    if bank.cmp.name matches ("*МКО*") and (comm.txb.txb=0 or comm.txb.txb=3 or comm.txb.txb=5 or comm.txb.txb=7 or comm.txb.txb=8 or comm.txb.txb=9 or comm.txb.txb=10 or comm.txb.txb=11 or comm.txb.txb=12 or comm.txb.txb=13 or comm.txb.txb=14 or comm.txb.txb=15) then next.
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run pcciffindtxb(p-bin, output v-find,output p-rnn,output p-sname,output p-fname, output p-mname, output p-namelat1,output p-namelat2,output p-birth,output p-tel1,output p-tel2, output p-addr1,output p-addr2,output p-expdt1,output p-rez,output p-country,output p-work, output p-migrn,output p-migrdt1,output p-migrdt2,output p-position,output p-nomdoc,output p-isswho,output p-issdt1).
    if v-find then leave.
end.

if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".



