/* s-garan.f
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26.05.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
*/

define variable ko as character format "x(10)" extent 2 init [
       "Распоряжение",
       "Выход"].
define variable i as integer.

form
    ko
    with no-label 1 down row 14 overlay 1 columns column 1 frame ko.

def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.