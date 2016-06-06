/* kfmOnlineMail.p
 * MODULE
        отправка сообщения на почту при совпадении со списком террористов
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
        13/07/2010 galina
 * BASES
        BANK
 * CHANGES
        17.08.2010 galina - добавила логи и имя менеджера
        19/08/2010 galina - перекомпиляция
*/

{global.i}
def input parameter p-operDoc as char.
def var s-ourbank as char.
def var v-bname as char.
def var v-maillist as char.
def var v-ofc as char.
def var i as integer.
find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if avail sysc and sys.chval <> '' then s-ourbank = sysc.chval.

find first txb where txb.consolid and txb.bank = s-ourbank no-lock no-error.
if avail txb then v-bname = txb.info.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofc = ofc.ofc + ' ' + ofc.name.

v-maillist = ''.
find first sysc where sysc.sysc = "kfmmail" no-lock no-error.
if avail sysc and trim(sysc.chval) <> '' then do:
    do i = 1 to num-entries(sysc.chval):
        if trim(entry(i,sysc.chval)) <> '' then do:
            if v-maillist <> '' then v-maillist = v-maillist + ','.
            v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@metrocombank.kz".
        end.
    end. /* do i = 1 */

    if v-maillist <> '' then  run mail(v-maillist ,"METROCOMBANK <abpk@metrocombank.kz>", 'Совпадение со списком ИПДЛ и террористов',"Филиал: " + v-bname + "\n " + "Номер документа в iXora: " + p-operDoc + "\n " + "Менеджер " + v-ofc, "", "","").

end.