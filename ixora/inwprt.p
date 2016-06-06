/* inwprt.p
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

/* ---------------------------------------------- */
/* 31/01/2003: sasco - print RMZ#, OFC, DATE, SUM */
/* ---------------------------------------------- */

def shared var s-remtrz like remtrz.remtrz.
def shared var g-ofc as char.
def shared var g-today as date.

find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if not avail remtrz then return.
output to rmz.prn.
put skip(2).
put unformatted remtrz.remtrz format "x(16)" " " 
                g-ofc format "x(8)" " "
                g-today " "
                remtrz.amt format '>,>>>,>>>,>>9.99' SKIP(1).
output close.
unix silent prit rmz.prn.
