/* stl.p
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

/*def var s1 as char init "Jopa Jopa Jopa".
def var s2 as char init "".
def var i as int.
run stl(s1, 2, 12, ' ', output s2, output i ).
displ "|" + s1 + "|" format "x(60)" skip "|" + s2 + "|" format "x(60)" skip i skip.
pause.
run sss(s1, 2, 12, ' ', output s2, output i ).
displ "|" + s1 + "|" format "x(60)" skip "|" + s2 + "|" format "x(60)" skip i.
*/
/*procedure stl.*/
def input parameter str1 as char.
def input parameter ind as int.
def input parameter len as int.
def input parameter dlm as char.
def output parameter str2 as char.
def output parameter ind2 as int.
def var i as int init 0.
def var s as char.
str2 = substring(str1, ind, len).
if ind + len <= length(str1) then i = r-index(str2, dlm) - 1.
else i = length(str2).
if i > 0 then do:
    str2 = substring(str2, 1, i).
    ind2 = ind + i .
end.
return.
/*
end procedure.
*/