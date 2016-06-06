/* findjh31.p
 * MODULE
        Название модуля
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
        03/10/2011  - поиск  jh3
 * BASES

 * CHANGES
                05/09/2012 Luiza - проверка для платежей возврат внутрибанковского перевода
*/
def input parameter ii-rmz as char no-undo.
def output parameter ii-jh3 as int no-undo.


ii-jh3 = 0.
find first txb.remtrz where txb.remtrz.remtrz = ii-rmz no-lock no-error.
if avail txb.remtrz then ii-jh3 = txb.remtrz.jh3.
if ii-jh3 < 1 or ii-jh3 = ? then do:
    find first txb.joudop where txb.joudop.docnum = ii-rmz and txb.joudop.type = "TN1" no-lock no-error.
    if available txb.joudop then ii-jh3 = 2.
end.