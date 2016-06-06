/* cifcnt.p
 * MODULE
        Клиенты
 * DESCRIPTION
        Подсчет количества клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT

 * INHERIT
        cifcnt-txb.p
 * MENU
        Пункт меню
 * AUTHOR
        15/07/05 sasco
 * CHANGES
        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/

/* 90, 92 - быстрые деньги */

def new shared temp-table tmp

    field txb    as char /* филиал */
    field type   as char /* юр - физ */
    field rko    as char /* СПФ */
    field depart as int  /* номер СПФ */

    field cifall as int  /* всего клиентов */
    field cifaaa as int  /* с действующими счетами */
    field cifact as int  /* активных клиентов */
    field cifbd  as int  /* клиенты быстрых денег */
    field ioall  as int  /* всего в интернет офисе */
    field ioact  as int  /* открытых договоров в интернет офисе */
    field iodoc  as int  /* с оборотами */

    index itmp is primary txb depart type.

def new shared var vdt as date.
def new shared var ftime as int.

vdt = today - 90.

update vdt label "Дата начала поиска кредитовых оборотов" with row 3 centered frame datfr title "Для поиска активных клиентов".
hide frame datfr.

run connib.
ftime = time.

/******************************************************************************/

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run cifcnt-txb.
    end.
    if connected ("txb")  then disconnect "txb".
end.
else  do:
    find first comm.txb where comm.txb.consolid and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run cifcnt-txb.
    end.
    if connected ("txb")  then disconnect "txb".
end.

/******************************************************************************/

if connected ('ib') then disconnect 'ib'.

output to rpt.csv.
put unformatted "Филиал;Тип;СПФ;Всего CIF;С действ. счетами;С оборотами;Быстрые деньги;Всего в Интернет;С действ. договором Интернет;Активность в Интернет" skip.
for each tmp:
    put unformatted tmp.txb ";"
                    if tmp.type = "P" then "Физ" else "Юр" ";"
                    tmp.rko ";"
                    tmp.cifall ";"
                    tmp.cifaaa ";"
                    tmp.cifact ";"
                    tmp.cifbd ";"
                    tmp.ioall ";"
                    tmp.ioact ";"
                    tmp.iodoc ";"
                    skip.
end.
output close.

unix silent cptwin rpt.csv excel.

