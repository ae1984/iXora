/* csincas.p
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
 * BASES
	BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
                07.12.2011 Luiza
                14/02/2012 Luiza - закомментировала частичную выгрузку

*/


{mainhead.i}
define            variable var_handle   as widget-handle.
define            variable new_document as logical.

define new shared variable v_u          as integer       no-undo.
define new shared variable v-selch      as integer       no-undo.
define new shared variable v-select     as integer       no-undo.

v-select = 0.
run sel2 (" ИНКАССАЦИЯ ЭК ", "1. ПОПОЛНЕНИЕ ЭК |2. ВЫГРУЗКА ЭК  |3. ВЫХОД ", output v-select).
if (v-select < 1) or (v-select > 2) then return.

v-selch = 2.

define sub-menu sub_doc
    menu-item d_new    label "&Создать"    rule
    menu-item  d_open  label "&Открыть"   rule
    menu-item  d_update  label "&Редакт."   rule
    menu-item d_delete label "&Удалить" rule
    menu-item d_exit   label "&Выход".

define sub-menu sub_trx
    menu-item t_create label "&Создать" rule
    /*menu-item t_screen label "&Экран"  rule*/
    menu-item t_print  label "&Печать"  rule.
menu-item t_delete label "&Удалить".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция".

on choose of menu-item d_new 
    do:
        if valid-handle (var_handle) then 
        do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        new_document = true.
        case v-select:
            when 1 then 
                do:
                    run csincas2 persistent set var_handle (input new_document).
                end.
            when 2 then 
                do:
                    run csincas3 persistent set var_handle (input new_document).
                end.
        end case.

    end.
on choose of menu-item d_open 
    do:
        v_u = 1.
        new_document = false.
        case v-select:
            when 1 then 
                do:
                    run csincas2 persistent set var_handle (input new_document).
                end.
            when 2 then 
                do:
                    run csincas3 persistent set var_handle (input new_document).
                end.
        end case.
    end.
on choose of menu-item d_update 
    do:
        v_u = 2.
        new_document = false.
        case v-select:
            when 1 then 
                do:
                    run csincas2 persistent set var_handle (input new_document).
                end.
            when 2 then 
                do:
                    run csincas3 persistent set var_handle (input new_document).
                end.
        end case.
    end.
on choose of menu-item d_delete 
    do:
        if valid-handle (var_handle) then 
        do:
            run Delete_document in var_handle.
        end.
        hide message.
    end.
on choose of menu-item t_create 
    do:
        if valid-handle (var_handle) then 
        do:
            run Create_transaction in var_handle.
        end.
        hide message.
    end.
/*on choose of menu-item t_screen do:
    if valid-handle (var_handle) then do:
       run Screen_transaction in var_handle.
    end.
    hide message.
end.*/
on choose of menu-item t_print 
    do:
        if valid-handle (var_handle) then 
        do:
            run print_transaction in var_handle.
        end.
        hide message.
    end.
on choose of menu-item t_delete 
    do:
        if valid-handle (var_handle) then 
        do:
            run Delete_transaction in var_handle.
        end.
        hide message.
    end.
on choose of menu-item d_exit 
    do:
        if valid-handle (var_handle) then 
        do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
    end.
assign 
    current-window:menubar = menu u_menu:handle.
wait-for choose of menu-item d_exit.

