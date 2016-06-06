/* check_control.p
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
        29.10.2004 tsoy
 * CHANGES
*/


def input  parameter g-ofc   as char.
def input  parameter v-ofc   as char.
def output parameter v-ret   as logical.
def buffer b-ofc for ofc. 

find ofc where ofc.ofc = g-ofc no-lock no-error.
find b-ofc where b-ofc.ofc = v-ofc no-lock no-error.

v-ret = false.
if avail ofc and avail b-ofc then do: 
    find codfr where codfr = "control" and code = ofc.titcd  no-lock no-error.
    if not avail codfr then do:
        v-ret = true.
        return.
    end. 
    else do:
        if lookup (codfr.name[1], b-ofc.titcd) > 0 then do:
           v-ret = true.
           return.
        end.
    end.
end.



