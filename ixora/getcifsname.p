/* getcifsname.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Получение корокого наименования клиента по номеру счета
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
        04/09/2013 galina - ТЗ 1885
 * BASES
        BANK TXB
 * CHANGES
*/


def input parameter p-aaa as char.
def output parameter p-sname as char.
p-sname = ''.
find first txb.aaa where txb.aaa.aaa = p-aaa no-lock no-error.
if avail txb.aaa then do:
    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if avail txb.cif then p-sname = trim(txb.cif.sname).
end.

