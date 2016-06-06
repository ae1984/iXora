/* cclientFind.p
 * MODULE
        Риски
 * DESCRIPTION
        Группы клиентов - поиск нужного клиента
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
        01/03/2011 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def output parameter p-cif_txb as char no-undo.
def output parameter p-cifname_txb as char no-undo.
def frame fr skip(1)
    p-cif_txb label " Код клиента" format "x(6)" validate(can-find(txb.cif where txb.cif.cif = p-cif_txb no-lock),"Нет такого клиента") " "
    skip(1)
    with centered side-labels overlay row 13.

on "help" of p-cif_txb in frame fr do:
    run h-ciftxb(output p-cif_txb).
    displ p-cif_txb with frame fr.
end.

update p-cif_txb with frame fr.

hide frame fr.

find first txb.cif where txb.cif.cif = p-cif_txb no-lock no-error.
if avail txb.cif then p-cifname_txb = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).


