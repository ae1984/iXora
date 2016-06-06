/* ndssvi.i
 * MODULE
        Pragma
 * DESCRIPTION
        Поиск номера и серии свидетельства НДС Банка
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
        2101/2005 sasco
 * CHANGES
        20/04/2005 kanat - добавил формат выходных данных
        16/01/08 marinav - поменялся номер
*/

define variable ndssvi as character format "x(30)" initial "60305 N 0081596 от 19.09.2007".
find sysc where sysc.sysc = "ndssvi" no-lock no-error.
if avail sysc then ndssvi = sysc.chval.

