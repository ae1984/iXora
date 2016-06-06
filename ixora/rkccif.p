/* rkccif.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Копирование клиентской записи в базу РКЦ
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
        14/02/2008 madiyar
 * BASES
        BANK TXB
 * CHANGES
*/

def input parameter v-cif as char no-undo.

find first bank.cif where bank.cif.cif = v-cif no-lock no-error.
if not avail bank.cif then return.

find first txb.cif where txb.cif.cif = v-cif no-lock no-error.
if avail txb.cif then return.

create txb.cif.
buffer-copy bank.cif to txb.cif.


