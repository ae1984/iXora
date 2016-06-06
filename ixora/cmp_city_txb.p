/* cmp_city.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Город из таблицы cmp
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * AUTHOR
        14.02.2011 kapar
 * BASES
     	BANK, TXB
 * CHANGES
*/

def output parameter v-addr as char.

find first txb.cmp no-lock no-error.
if avail txb.cmp then do:
  if (int(txb.cmp.code) = 0) or (num-entries(txb.cmp.addr[1],",") = 5) then
    v-addr = entry(2, txb.cmp.addr[1],",").
  else
    v-addr = entry(3, txb.cmp.addr[1],",").
end.

