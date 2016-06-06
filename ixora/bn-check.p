/* bn-check.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Проверка реквизитов бенефициара
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
        05/09/2012 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
        24/09/2012 dmitriy - перекомпиляция
	25/09/2012 id00700 - перекомпиляция
*/

def input parameter t-bnacc as char.

def shared var v-bnrnn as char.
def shared var v-bncif as char.
def shared var v-bnacc as char.
def shared var v-bnkbe as char.
def shared var v-find as logi.

def var n as int.

v-bnrnn = "". v-bncif = "". v-bnacc = "". v-bnkbe = "".

if v-find then leave.

find first txb.aaa where txb.aaa.aaa = t-bnacc no-lock no-error.
if avail txb.aaa then do:
    v-bnacc = txb.aaa.aaa.
    v-find = yes.
end.

find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
if avail txb.cif then do:
    v-bncif = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
    v-bnrnn = txb.cif.bin.

    n = length (txb.cif.geo).
    v-bnkbe = substr(txb.cif.geo, n, 1).
    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
    v-bnkbe = v-bnkbe + txb.sub-cod.ccode.
end.




