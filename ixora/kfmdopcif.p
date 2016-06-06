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
        --/--/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
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

for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".

    connect value ("-db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + txb.login + " -P " + txb.password).

    run kfmdopcif_txb(p-res,p-clid).

    find first t-cif no-lock no-error.
    if avail t-cif then do:
        if connected ("txb") then disconnect "txb".
        leave.
    end.
end.
if connected ("txb") then disconnect "txb".