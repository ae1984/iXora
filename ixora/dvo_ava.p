/* dvo_ava.p
 * MODULE
        Внутрибанковские операции
 * DESCRIPTION
        Пополнение карточных счетов сотрудников Банка работниками ДВО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-3-5
 * AUTHOR
        08.01.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def new shared var v_u as int no-undo.
def var new_document as logical.
def var var_handle   as widget-handle.
def new shared var s-remtrz like remtrz.remtrz.
{lgps.i "new"}

run auto_menu.
if keyfunction (lastkey) = "end-error" then return.

procedure auto_menu:
    define sub-menu sub_doc
        menu-item d_new    label "&Создать" rule
        menu-item d_open   label "&Открыть" rule
        menu-item d_update label "&Редакт." rule
        menu-item d_exit   label "&Выход".

    define sub-menu sub_trx
        menu-item t_create label "&Создать".         rule
        menu-item t_print label "&Печать".

    define  menu u_menu menubar
        sub-menu sub_doc label "Документ"
        sub-menu sub_trx label "Транзакция".

    on choose of menu-item d_new do:
        if valid-handle (var_handle) then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        new_document = true.
        run dvo_ava1 persistent set var_handle (input new_document).
    end.
    on choose of menu-item d_open do:
        v_u = 1.
        new_document = false.
        run dvo_ava1 persistent set var_handle (input new_document).
    end.
    on choose of menu-item d_update do:
        v_u = 2.
        new_document = false.
        run dvo_ava1 persistent set var_handle (input new_document).
    end.
    on choose of menu-item t_print do:
        if valid-handle (var_handle) then do:
           run print_transaction in var_handle.
        end.
        hide message.
    end.
    on choose of menu-item t_create do:
        if valid-handle (var_handle) then do:
           run Create_transaction in var_handle.
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
    assign current-window:menubar = menu u_menu:handle.
    wait-for choose of menu-item d_exit.
end procedure.