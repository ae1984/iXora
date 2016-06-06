/* xdataou.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*  AGA - 19/0595 - добавлена возможность видеть для кодированных
		    клиентов в наименовании КОД клиента
*/

def var icha like cif.name.
def var ocha like cif.name.

def shared temp-table wcif like cif.
def shared var r-cif like cif.cif.
find first cif where r-cif eq cif.cif.
find first wcif where r-cif eq wcif.cif.

if substr(wcif.name,1,6) NE r-cif then do:
  run xdata(input wcif.name ,output ocha).
end.
else do:
  icha = substr(wcif.name,7).
  run xdata(input icha ,output ocha).
end.
cif.name = r-cif + ocha.

if substr(wcif.lname,1,6) NE r-cif then do:
  run xdata(input wcif.lname ,output ocha).
end.
else do:
  icha = substr(wcif.lname,7).
  run xdata(input icha ,output ocha).
end.
cif.lname = r-cif + ocha.

if substr(wcif.sname,1,6) NE r-cif then do:
  run xdata(input wcif.sname ,output ocha).
end.
else do:
  icha = substr(wcif.sname,7).
  run xdata(input icha ,output cif.sname).
end.
cif.sname = r-cif + ocha.

run xdata(input wcif.dba ,output cif.dba).
run xdata(input wcif.pss ,output cif.pss).
run xdata(input wcif.addr[1],output cif.addr[1]).
run xdata(input wcif.addr[2],output cif.addr[2]).
run xdata(input wcif.addr[3],output cif.addr[3]).
run xdata(input wcif.tel ,output cif.tel).
run xdata(input wcif.tlx ,output cif.tlx).
run xdata(input wcif.fax ,output cif.fax).
run xdata(input wcif.attn ,output cif.attn).
