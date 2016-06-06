/* aaablock0.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Блокировка всех счетов клиента на сумму просрочки по кредиту
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
        20/03/2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run aaablock.  /* поиск задолжников и запись результата в aas */.
end.
if connected ("txb") then disconnect "txb".