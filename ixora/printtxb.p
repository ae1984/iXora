/* printtxb.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Определение типа ЮЛ или ФЛ.
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
        --/--/2012 damir
 * BASES
        BANK COMM TXB
 * CHANGES
        18.04.2012 damir.
*/

def input  parameter p-cif    as char.
def output parameter p-prefix as char.

find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then assign p-prefix = txb.cif.prefix.


