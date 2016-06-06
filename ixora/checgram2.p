/* checgram2.p
 * MODULE
        Работа с чеками
 * DESCRIPTION
        Проверка по всем филиалам: зарегистрирована чековая книжка или нет
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
        28/06/2012 dmitriy
 * BASES
        BANK TXB COMM
 * CHANGES
*/

def input parameter t-nono as int.
def input parameter t-ser as char.

def shared temp-table wrk
field nono as int
field cif as char
field bank as char
field chk as logi.

def var txbname as char.

find first txb.cmp no-lock no-error.
if avail txb.cmp then txbname = txb.cmp.name.


find first txb.gram where txb.gram.nono = t-nono and txb.gram.ser = t-ser and txb.gram.bank = "F" no-lock no-error.
if avail txb.gram then do:
    create wrk.
    wrk.nono = txb.gram.nono.
    wrk.cif = txb.gram.cif.
    wrk.chk = true.
    wrk.bank = txbname.
end.
else do:
    create wrk.
    wrk.bank = txbname.
    wrk.chk = false.
end.
