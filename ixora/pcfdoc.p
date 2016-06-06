/* pcfdoc.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        поиск реквизитов клиента
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
        19/07/2012 id00810
 * BASES
 		BANK COMM TXB
 * CHANGES
*/

def input  param p-cif  as char no-undo.
def output param p-doc  as char no-undo.
def output param p-code as char no-undo.
def        var   v-ec   as char no-undo.
find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if avail txb.cif then do:
    p-doc = txb.cif.pss.
    find last txb.sub-cod where txb.sub-cod.acc   = p-cif
                            and txb.sub-cod.sub   = "cln"
                            and txb.sub-cod.d-cod = "secek"
                            no-lock no-error.
    if avail txb.sub-cod then v-ec = txb.sub-cod.ccode.
    if v-ec = '' or v-ec = 'msc' then do:
        message "Не заполнен сектор экономики клиента!" view-as alert-box error.
        undo, return.
    end.
    if can-do('021,022',txb.cif.geo) then p-code = substr(txb.cif.geo,3,1) + v-ec.
    else do:
        message "Проверьте ГЕО-код клиента!" view-as alert-box error.
        undo, return.
    end.
end.