/* sm-wrdcrc.p
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
        07/03/2008 madiyar - евро 11->3
        14/09/2009 madiyar - работала некорректно, когда число заканчивалось на 11,12,13,14, исправил
*/

/*
  sm-wrdcrc.p
  DESCR: процедура возвращает название валюты в правильном падеже
  CREATED AT: 06.06.01
*/


def var crc1 as char extent 11 initial ["тенге,тенге,тенге,тиын,тиын,тиын",
    "доллар США,доллара США,долларов США,цент,цента,центов",
    "евро,евро,евро,евроцент,евроцента,евроцентов",
    "рубль,рубля,рублей,копейка,копейки,копеек",
    "", "", "", "", "", "", ""].

/*define input parameter i-summa1 as char.
define input parameter i-summa2 as char.
define input parameter i-crc like crc.crc.
define output parameter o-crcdes1 as char.
define output parameter o-crcdes2 as char.*/


/*find_des(input i-summa1,i-summa2,i-crc,)

case i-crc:
   when 1 then do: find_des(input)  end.
   when 2 then do:   end.
   when 3 then do:   end.
   when 4 then do:   end.
end.  */


/*procedure find_des:*/

define input parameter astr1 as char.
define input parameter astr2 as char.
define input parameter n like crc.crc.
define output parameter des1 as char.
define output parameter des2 as char.
def var num1 as int.
def var num2 as int.
def var num3 as int.

num1 = integer(substring(astr1, length(astr1,"CHARACTER"), 1)).
case num1:
     when 1 then do:
        num3 = 0.
        if length(astr1,"CHARACTER") > 1 then num3 = integer(substring(astr1, length(astr1,"CHARACTER") - 1, 1)).
        if num3 = 1 then des1 = entry(3,crc1[n]).
        else des1 = entry(1,crc1[n]).
     end.
     when 2 or when 3 or when 4 then do:
        num3 = 0.
        if length(astr1,"CHARACTER") > 1 then num3 = integer(substring(astr1, length(astr1,"CHARACTER") - 1, 1)).
        if num3 = 1 then des1 = entry(3,crc1[n]).
        else des1 = entry(2,crc1[n]).
     end.
     otherwise des1 = entry(3,crc1[n]).
end case.

num2 = integer(substring(astr2, length(astr2,"CHARACTER"), 1)).

case num2:
     when 1 then do:
        num3 = 0.
        if length(astr2,"CHARACTER") > 1 then num3 = integer(substring(astr2, length(astr2,"CHARACTER") - 1, 1)).
        if num3 = 1 then des2 = entry(6,crc1[n]).
        else des2 = entry(4,crc1[n]).
     end.
     when 2 or when 3 or when 4 then do:
        num3 = 0.
        if length(astr2,"CHARACTER") > 1 then num3 = integer(substring(astr2, length(astr2,"CHARACTER") - 1, 1)).
        if num3 = 1 then des2 = entry(6,crc1[n]).
        else des2 = entry(5,crc1[n]).
     end.
     otherwise des2 = entry(6,crc1[n]).
end case.



/*end procedure.*/