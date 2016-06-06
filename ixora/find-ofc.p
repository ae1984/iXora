/* find-ofc.p
 * MODULE
        Быстрые переводы
 * DESCRIPTION
        поиск менеджеров по id
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-reestr
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        31/03/2011 dmitriy
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared temp-table tt-rtranslat
   field number as char
   field date like r-translat.date
   field nomer like r-translat.nomer
   field summa like r-translat.summa
   field crc like r-translat.crc
   field summ-com like r-translat.summ-com
   field rec-fam like r-translat.rec-fam
   field rec-name like r-translat.rec-name
   field rec-otch like r-translat.rec-otch
   field rec-code like r-translat.rec-code
   field jh like r-translat.jh
   field stat like r-translat.stat
   field rec-bank like r-translat.rec-bank
   field who like r-translat.who
   field ofc-name as char
   index idx is primary crc date nomer
   index idx2 ofc-name.

def shared temp-table tt-translat
   field number as char
   field date like translat.date
   field nomer like translat.nomer
   field summa like translat.summa
   field crc like translat.crc
   field commis like translat.commis
   field rec-fam like translat.rec-fam
   field rec-name like translat.rec-name
   field rec-otch like translat.rec-otch
   field jh like translat.jh
   field stat like translat.stat
   field who like translat.who
   field ofc-name as char
   index idx is primary crc date nomer
   index idx2 ofc-name.

for each tt-rtranslat where tt-rtranslat.ofc-name = '':
  find txb.ofc where txb.ofc.ofc = tt-rtranslat.who no-lock no-error.
  if avail txb.ofc then tt-rtranslat.ofc-name = txb.ofc.name.
end.

for each tt-translat where tt-translat.ofc-name = '':
  find txb.ofc where txb.ofc.ofc = tt-translat.who no-lock no-error.
  if avail txb.ofc then tt-translat.ofc-name = txb.ofc.name.
end.
