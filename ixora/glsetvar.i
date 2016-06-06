/* glsetvar.i
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

def shared var vtot like jl.dam extent 12.
def shared var vavg like jl.dam extent 12.
def shared var vttl like jl.dam.
def shared var vtavg like jl.dam.
def shared var vyst like jl.dam.
def shared var vydr like vyst.
def shared var vycr like vyst.
def shared var vmst like vyst.
def shared var vmdr like vyst.
def shared var vmcr like vyst.
def shared var vtst like vyst.
def shared var vtdr like vyst.
def shared var vtcr like vyst.
def shared var vtbl like vyst.

def {1} var vday as int extent 12 initial [31,28,31,30,31,30,31,31,30,31,30,31].
def {1} var vyrday as int.
def {1} var inc as int.
