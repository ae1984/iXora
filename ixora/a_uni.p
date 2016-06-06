/* a_uni.p
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
            07.12.2011 создан по подобию uni_main.p вместо вызова uni_doc.p вызывается a_uni_doc1.p
*/

/** uni_main.p **/


define variable var_handle   as widget-handle.
define variable new_document as logical.


define sub-menu sub_doc
    menu-item d_new    label "&Создать"    rule
    menu-item d_old    label "&Открыть"    rule
    menu-item d_close  label "&Закрыть"  rule
    menu-item d_view   label "&Просмотр"   rule
    menu-item d_edit   label "&Редакт."   rule
    menu-item d_delete label "&Удалить" rule
    menu-item d_exit   label "&Выход".

define sub-menu sub_trx
    menu-item t_create label "&Создать" rule
    menu-item t_print  label "&Печать"  rule
    /*menu-item t_screen label "&Экран"  rule*/
    menu-item t_delete label "&Удалить".

define sub-menu sub_sts
    menu-item s_status  label "&Статус" rule
    menu-item s_codific label "&Справочник".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция"
    sub-menu sub_sts label "Статус".



on choose of menu-item d_new do:
    if valid-handle (var_handle) then do:
        message "Закройте текущий документ.".
        return.
    end.
    hide message.
    new_document = true.
    run a_uni_doc1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_old do:
    if valid-handle (var_handle) then do:
        message "Закройте текущий документ.".
        return.
    end.
    hide message.
    new_document = false.
    run a_uni_doc1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_close do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
        return.
    end.
end.
on choose of menu-item d_view do:
    if valid-handle (var_handle) then do:
       apply "u2" to var_handle.
    end.
    hide message.
end.
on choose of menu-item d_edit do:
    if valid-handle (var_handle) then do:
       apply "u1" to var_handle.
    end.
    hide message.
end.
on choose of menu-item d_delete do:
    if valid-handle (var_handle) then do:
       run Delete_document in var_handle.
    end.
    hide message.
end.
on choose of menu-item d_exit do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
end.
on choose of menu-item t_create do:
    if valid-handle (var_handle) then do:
       run Create_transaction in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_print do:
    if valid-handle (var_handle) then do:
       run Print_transaction in var_handle.
    end.
    hide message.
end.
/*on choose of menu-item t_screen do:
    if valid-handle (var_handle) then do:
       run Screen_transaction in var_handle.
    end.
    hide message.
end.*/
on choose of menu-item t_delete do:
    if valid-handle (var_handle) then do:
       run Delete_transaction in var_handle.
    end.
    hide message.
end.
on choose of menu-item s_status do:
    if valid-handle (var_handle) then do:
        apply "u3" to var_handle.
    end.
    hide message.
end.
on choose of menu-item s_codific do:
    if valid-handle (var_handle) then do:
       run Codific in var_handle.
    end.
    hide message.
end.

assign current-window:menubar = menu u_menu:handle.
wait-for choose of menu-item d_exit.

