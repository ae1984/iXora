/* cif-aaa.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* cif-aaa.p
   Просмотр счетов клиента

   25.04.2003 nadejda - показываются только активные счета, закрытые вынесены в cif-arc.p
   06/08/2010 id00363 - Добавил историю пролонгаций cif-aaa.i
   27/05/2011 evseev - изменения в cif-aaa.i
   15.08.20111 ruslan - изменения в cif-aaa.i
   07/10/2011 evseev - изменения в cif-aaa.i
   16/01/2012 lyubov - изменения в cif-aaa.i

*/

{global.i}

def shared var s-cif like cif.cif.

def temp-table waaa
    field aaa as char
    field lgr as char
    field midd as char
    index main is primary unique lgr midd aaa.

find cif where cif.cif = s-cif no-lock.

for each aaa where aaa.cif = s-cif no-lock break by aaa.aaa:
   find lgr where lgr.lgr = aaa.lgr no-lock.
   if lgr.led = 'ODA' then next.
   if aaa.sta <> "c" then do:
     create waaa.
     waaa.aaa = aaa.aaa.
     waaa.lgr = aaa.lgr.
     waaa.midd = substr(aaa.aaa, 4, 3).
   end.
end.

{cif-aaa.i}
