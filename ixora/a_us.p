/* a_us.p
 * MODULE
        Переводы по счетам клиентов в  ин.валюте
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
 * BASES
	BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES

*/


{mainhead.i}
define variable var_handle   as widget-handle.
define variable new_document as logical.

def var v-select as integer no-undo.
def new shared var v_u as int no-undo.
def new shared var v_dt as int no-undo.
def new shared var v_kt as int no-undo.
def new shared var v_dtk as int no-undo.
def new shared var v_ktk as int no-undo.
def new shared var v-sys as char no-undo.
def new shared var v-option as char .

v-select = 0.
repeat:
    v-select = 0.
    run sel2 (" ПЕРЕВОДЫ ПО СЧЕТАМ КЛИЕНТОВ ", "1. Переводы по счетам клиентов в  ин.валюте  |2. ВЫХОД ", output v-select).
    case v-select:
        when 1 then do:
            {lgps.i "new"}
            m_pid = "O" .
u_pid = "a_us" .
v-option = "remsubo".
run auto_menu("1").
        end. /*  v-select3 = 1.*/

        when 2 then return.
    end.
end. /* end repeat  */

procedure auto_menu:
define input parameter v_prg as char.
define sub-menu sub_doc
    menu-item d_new    label "&Создать"    rule
    menu-item  d_open  label "&Открыть"   rule
    menu-item  d_update  label "&Редакт."   rule
    menu-item d_delete label "&Удалить" rule
    menu-item d_exit   label "&Выход".

define sub-menu sub_trx
    menu-item t_create label "&Создать" rule
    menu-item t_screen label "&Экран"  rule
    menu-item t_print  label "&Печать"  rule
    menu-item t_delete label "&Удалить".

define sub-menu sub_swf
    menu-item f_swift label "&Свифт".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция".
    sub-menu sub_swf label "Свифт".


on choose of menu-item d_new do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    new_document = true.
    if v_prg = "1" then run a_us1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_open do:
    v_u = 1.
    new_document = false.
    if v_prg = "1" then run a_us1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_update do:
    v_u = 2.
    new_document = false.
    if v_prg = "1" then run a_us1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_delete do:
    if valid-handle (var_handle) then do:
       run Delete_document in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_create do:
    if valid-handle (var_handle) then do:
       run Create_transaction in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_screen do:
    if valid-handle (var_handle) then do:
       run Screen_transaction in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_print do:
    if valid-handle (var_handle) then do:
       run print_transaction in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_delete do:
    if valid-handle (var_handle) then do:
       run Delete_transaction in var_handle.
    end.
    hide message.
end.

on choose of menu-item f_swift do:
    v_u = 3.
    new_document = false.
    run a_us1 persistent set var_handle (input new_document).
end.

on choose of menu-item d_exit do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
end.
assign current-window:menubar = menu u_menu:handle.
wait-for choose of menu-item d_exit.

end procedure.
