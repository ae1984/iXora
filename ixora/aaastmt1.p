/* aaastmt1.p
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

/* aaastmt.p
*/

def new shared var s-aaa like aaa.aaa.

{proghead.i "PRINT MONTHLY ACCOUNT STATEMENT"}

{image1.i stmt.img}

{image2.i}

for each aaa where aaa.pass eq "" and aaa.sta ne "C"
   ,each lgr of aaa where lgr.led eq "DDA" or lgr.led eq "SAV":
  s-aaa = aaa.aaa.
  run s-aaast.
end.
{image3.i}
