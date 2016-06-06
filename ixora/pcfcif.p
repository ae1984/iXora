/* pcfcif.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        поиск наименования клиента
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
        19/09/2012 id00810
 * BASES
 		BANK TXB
 * CHANGES
*/

def input  param p-cif     as char no-undo.
def output param p-cifname as char no-undo.

find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then p-cifname = txb.cif.prefix + ' ' + txb.cif.name.
