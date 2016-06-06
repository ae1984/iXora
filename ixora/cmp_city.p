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
     	BANK
 * CHANGES
*/

def output parameter v-addr as char.

find first cmp no-lock no-error.
if avail cmp then do:
  if (int(cmp.code) = 0) or (num-entries(cmp.addr[1],",") = 5) then
    v-addr = entry(2, cmp.addr[1],",").
  else
    v-addr = entry(3, cmp.addr[1],",").
end.

