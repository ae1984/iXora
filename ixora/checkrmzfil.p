/* checkrmzfil.p
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
        15/11/2006 - suchkov
 * CHANGES
*/

def input parameter rmz like txb.remtrz.remtrz .
def output parameter ib as logical .

find txb.remtrz where txb.remtrz.remtrz = rmz no-lock no-error .
if available txb.remtrz and txb.remtrz.source = "IBH" then ib = true .
                                                      else ib = false.

