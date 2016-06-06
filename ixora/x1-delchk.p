/* x1-delchk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Удаление чека из списка неиспользованных, при штамповке транзакции
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
        25/09/2012 dmitriy
 * BASES
        TXB COMM
 * CHANGES
*/

def input parameter p-chk as int.
def input parameter p-cif as char.
def var s1 as char.
def var s2 as char.
def var str-pages as char.

find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.pages <> "" and txb.checks.cif = p-cif no-lock no-error.
if avail txb.checks then do:
    if index(txb.checks.pages, string(p-chk)) > 0 then do:
        s1 = substr(txb.checks.pages, 1, index(txb.checks.pages, string(p-chk)) - 1).
        s2 = substr(txb.checks.pages, index(txb.checks.pages, string(p-chk)) + length(string(p-chk)) + 1).
        str-pages = s1 + s2.
    end.
end.
do transaction:
    find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.pages <> "" and txb.checks.cif = p-cif exclusive-lock no-error.
    if avail txb.checks then do:
        txb.checks.pages = str-pages.
        find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.cif = p-cif no-lock no-error.
    end.
end.
