/* x-jhnew.p
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

def shared var g-today as date.
def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-jh like jh.jh.

s-jh = next-value(jhnum).
create jh.
jh.jh = s-jh.
jh.who = g-ofc.
jh.whn = today.
jh.tim = time.
jh.jdt = g-today.
