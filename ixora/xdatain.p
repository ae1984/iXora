/* xdatain.p
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

if substr(cif.name,1,6) NE r-cif then do:
  run xdata(input cif.name ,output ocha).
  wcif.name = r-cif + ocha.
end.
else do:
  icha = substr(cif.name,7).
  run xdata(input icha ,output wcif.name).
end.
if substr(cif.lname,1,6) NE r-cif then do:
  run xdata(input cif.lname ,output ocha).
  wcif.lname = r-cif + ocha.
end.
else do:
  icha = substr(cif.lname,7).
  run xdata(input icha ,output wcif.lname).
end.

if substr(cif.sname,1,6) NE r-cif then do:
  run xdata(input cif.sname ,output ocha).
  wcif.sname = r-cif + ocha.
end.
else do:
  icha = substr(cif.sname,7).
  run xdata(input icha ,output wcif.sname).
end.
run xdata(input cif.dba ,output wcif.dba).
run xdata(input cif.pss ,output wcif.pss).
run xdata(input cif.addr[1],output wcif.addr[1]).
run xdata(input cif.addr[2],output wcif.addr[2]).
run xdata(input cif.addr[3],output wcif.addr[3]).
run xdata(input cif.tel ,output wcif.tel).
run xdata(input cif.tlx ,output wcif.tlx).
run xdata(input cif.fax ,output wcif.fax).
run xdata(input cif.attn ,output wcif.attn).
