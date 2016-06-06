/* r-clmax1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
        08/05/2012 dmitriy - отменил возможность формирования консолид.отчета во всех филиалах, кроме ЦО
*/

def input parameter v-dat as date.

/******************************************************************************/

find last bank.sysc where bank.sysc.sysc = 'ourbnk' no-lock no-error.

if sysc.chval = 'TXB00' then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-dopmax (input v-dat).
    end.
    if connected ("txb")  then disconnect "txb".
end.
else  do:
    find first comm.txb where comm.txb.consolid and comm.txb.city = integer(substr(bank.sysc.chval,4,2)) no-lock no-error.
    if avail comm.txb then do:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run r-dopmax (input v-dat).
    end.
    if connected ("txb")  then disconnect "txb".
end.

/******************************************************************************/