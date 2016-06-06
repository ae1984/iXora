/* swmt-den.i
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

/***  KOVAL 

Возвращает были ли в строке недопустимы символы для ввода Swift - макета 

in -  1 char
out - True если недопустимый символ

***/


function swmt-den returns logical (content as char).
def var str as char init "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-?:()., +".

 if index(str, trim(content)) = 0 then return true. 
 			          else return false.
end.

