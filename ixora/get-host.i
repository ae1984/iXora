/* get-host.i
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

&IF DEFINED(get-host_i) = 0 &THEN 
&GLOBAL-DEFINE get-host_i

function get-host returns char (input db-name as char).
def var i as int.
do i = 1 to num-entries(DBPARAM(db-name)):
    if entry(i, DBPARAM(db-name)) begins "-H " then do:
        return entry(2, entry(i, DBPARAM(db-name)), " ").
    end.
end.
return "".
end function.

&ENDIF
