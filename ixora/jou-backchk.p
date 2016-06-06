/* jou-backchk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Восстановление чека в списке неиспользованных
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
        27/09/2012 dmitriy - измененил сообщение по удалению/восстановлению чеков

*/

def input parameter p-chk as int.
def input parameter p-cif as char.
def var del-page as logi format "Да/Нет".
def var s1 as char.
def var s2 as char.
def var str-pages as char.



/*------- возврат/удаление чека в список неиспользованных --------*/
del-page = no.
find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.cif = p-cif no-lock no-error.
if avail txb.checks then message "Чек испорчен ?" view-as alert-box question buttons yes-no title "" update del-page.
if del-page = yes then do:
        find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.pages <> "" and txb.checks.cif = p-cif no-lock no-error.
        if avail txb.checks and index(txb.checks.pages, string(p-chk)) > 0 then do:
            if index(txb.checks.pages, string(p-chk)) > 0 then do:
                s1 = substr(txb.checks.pages, 1, index(txb.checks.pages, string(p-chk)) - 1).
                s2 = substr(txb.checks.pages, index(txb.checks.pages, string(p-chk)) + length(string(p-chk)) + 1).
                str-pages = s1 + s2.
            end.
        end.
        do transaction:
            find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.pages <> "" and txb.checks.cif = p-cif exclusive-lock no-error.
            if avail txb.checks and index(txb.checks.pages, string(p-chk)) > 0 then do:
                txb.checks.pages = str-pages.
                find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.cif = p-cif no-lock no-error.
            end.
        end.
end.
if del-page = no then
do transaction:
    find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.cif = p-cif exclusive-lock no-error.
    if avail txb.checks and index(txb.checks.pages, string(p-chk)) = 0 then
    txb.checks.pages = txb.checks.pages + string(p-chk) + "|".
    find last txb.checks where txb.checks.nono <= p-chk and txb.checks.lidzno >= p-chk and txb.checks.cif = p-cif no-lock no-error.
end.
/*-----------------------------------------------------------*/