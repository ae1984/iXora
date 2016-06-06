/* cclientGetNames.p
 * MODULE
        Риски
 * DESCRIPTION
        Группы клиентов - наименования/ФИО клиентов в группе
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

def shared temp-table wrk like cclient
  field clname as char.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

for each wrk where wrk.bank = s-ourbank:
    find first txb.cif where txb.cif.cif = wrk.clientId no-lock no-error.
    if avail txb.cif then wrk.clname = trim(trim(txb.cif.prefix) + ' ' + trim(txb.cif.name)).
end.
