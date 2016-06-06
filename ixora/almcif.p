/* almcif.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Проверка соотсветствия счета клиента в ЦО счету в Алм.фил.
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
        10/08/2010 galina
 * BASES
        BANK TXB
 * CHANGES
        08.02.2013 evseev - tz-1704
*/


def shared var v-cif-f as char.
def shared var v-cifname-f as char.
def shared var v-rnn-f as char.
def shared var v-rnn as char no-undo.
def shared var v-kbe as char no-undo.

find first txb.cif where txb.cif.cif = v-cif-f no-lock no-error.
if not avail txb.cif then do:
    message 'Клиент не найден!'.
    v-cif-f = ''.
end.
if avail txb.cif then do:
    if txb.cif.bin <> v-rnn then do:
        message 'БИН клиента АФ не соотвествует БИН клиента в ЦО!'.
        v-cif-f = ''.
    end.
    else do:
        v-cifname-f = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
        v-rnn-f = txb.cif.bin.
        if txb.cif.geo <> '021' then v-kbe = '2'.
        else v-kbe = '1'.
        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then v-kbe = v-kbe + txb.sub-cod.ccode.
        else v-kbe = ''.
    end.
end.

