/* chkcl.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Проверка списка - клиент/не клиент 
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
        04/10/2005 madiyar
 * BASES
        bank, comm, txb
 * CHANGES
        02/08/2006 madiyar - no-undo
*/

def shared temp-table tmpcl no-undo
  field cif as char
  field rnn as char
  field is-cl as logical
  index idx is primary cif.

for each tmpcl:
  if tmpcl.is-cl then next.
  find first txb.cif where txb.cif.jss = tmpcl.rnn no-lock no-error.
  if avail txb.cif then do:
    find first txb.aaa where txb.aaa.cif = txb.cif.cif and trim(txb.aaa.sta) <> "C" no-lock no-error.
    if avail txb.aaa then tmpcl.is-cl = yes.
  end.
end.

