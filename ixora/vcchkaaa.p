/* vcchkaaa.p
 * MODULE

 * DESCRIPTION
        Проверка счета
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
*/

def shared var v-cif-f as char.
def shared var v-aaa-f as char.
def shared var v-crc as integer.

find first txb.aaa where txb.aaa.aaa = v-aaa-f and txb.aaa.cif = v-cif-f no-lock no-error.
if not avail txb.aaa then do:
    message 'Счет не найден!'.
    v-aaa-f = ''.
end.
else do:
    if txb.aaa.sta = 'C' then do:
        message 'Счет закрыт!'.
        v-aaa-f = ''.
    end.
    else if txb.aaa.crc <> v-crc then do:
        message 'Валюта старого и нового счета не совпадают!'.
        v-aaa-f = ''.

    end.

end.

