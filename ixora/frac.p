/* frac.p
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
        01/02/10 id00024 - Отсутствовал в библиотеке
        14.06.10 marinav - перекомпиляция
*/

/* ===================================================
   =                     FRAC.P                      =
   =         возвращает дробную часть числа          =
   ===================================================
   =   Created: 24.09.2001, by Alexander Muhovikov   =
   =================================================== */  

def input parameter myinnum as decimal.
def output parameter myoutnum as decimal.
def var sssss as char.
def var iiiii as integer.

sssss = string(myinnum).
iiiii = INDEX(sssss, '.').
if iiiii > 0 
   then myoutnum = decimal(substring(sssss,iiiii)).
   else myoutnum = 0.0.
 
