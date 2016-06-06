/* lnsch-.p
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

def input parameter vjh like jh.jh.
def input parameter vgl like jl.gl.
def input parameter vacc like jl.acc.
def input parameter vtim like jl.tim.
def input parameter vjdt like jl.jdt.
def input parameter vdam like jl.dam.
def input parameter vcam like jl.cam.
run lnsch-0(vjh, vgl, vacc, vtim, vjdt, vdam, vcam).

