/* pschk_txb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Проверка наличия запущенных процессов в филиале
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
        02/10/2013 galina ТЗ2104
 * BASES
        BANK TXB
 * CHANGES
*/

def output parameter p-pschk as logi.
find first txb.dproc no-lock no-error.
if avail txb.dproc then p-pschk = yes.
else p-pschk = no.


