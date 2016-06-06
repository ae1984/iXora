/* cif-arc.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* cif-arc.p 
   Информация о закрытых счетах

   25.04.2003 nadejda скопировано из cif-aaa.p
*/

{global.i}

def shared var s-cif like cif.cif.

def temp-table waaa 
    field aaa as char
    field lgr as char
    field midd as char
    index main is primary unique lgr midd aaa.

find cif where cif.cif = s-cif no-lock.

for each aaa where aaa.cif = s-cif and aaa.sta = "c" no-lock break by aaa.aaa:
   find lgr where lgr.lgr = aaa.lgr no-lock.
   if lgr.led = 'ODA' then next.
   create waaa.
   waaa.aaa = aaa.aaa.
   waaa.lgr = aaa.lgr.
   waaa.midd = substr(aaa.aaa, 4, 3).
end.

{cif-aaa.i}

