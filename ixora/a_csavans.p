/* csavans.p
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
                        20/06/2012 Luiza - заменила слово ТЕМПО-КАССА на МИНИКАССУ
            18/01/2013 Luiza - при открытии документа и редактировании добавила удаление handle
*/


{mainhead.i}

define            variable var_handle   as widget-handle.
define            variable new_document as logical.

define new shared variable v_u          as integer       no-undo.
define new shared variable v-select     as integer       no-undo.
define new shared variable v-selch      as integer       no-undo.



v-select = 0.
/*run sel2 (" НАЛИЧНОСТЬ В ТЕМПО-КАССЕ ", "1. ВЫДАЧА НАЛИЧНОСТИ В ТЕМПО-КАССУ |2. ПРИНЯТИЕ НАЛИЧНОСТИ ИЗ ТЕМПО-КАССЫ
            |3. ПЕРЕМЕЩЕНИЕ ИЗ ТЕМПО-КАССЫ В СЕЙФ |4. ПЕРЕМЕЩЕНИЕ ИЗ СЕЙФА В ТЕМПО-КАССУ |5. ВЫХОД ", output v-select).*/
run sel2 (" НАЛИЧНОСТЬ В МИНИКАССЕ ", "1. ВЫДАЧА НАЛИЧНОСТИ В МИНИКАССУ |2. ПРИНЯТИЕ НАЛИЧНОСТИ ИЗ МИНИКАССЫ
            |3. ВЫХОД ", output v-select).
if (v-select < 1) or (v-select > 2) then return.

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
/*menu-item t_delete label "&Удалить".*/

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
        if v-select <= 2 then run a_csavans1 persistent set var_handle (input new_document).
    /*if v-select = 3  then run a_csavans3 persistent set var_handle (input new_document).
    if v-select = 4  then run a_csavans4 persistent set var_handle (input new_document).*/
    end.
on choose of menu-item d_open
    do:
        if valid-handle (var_handle) then
        do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        v_u = 1.
        new_document = false.
        if v-select <= 2 then run a_csavans1 persistent set var_handle (input new_document).
    /*if v-select = 3  then run a_csavans3 persistent set var_handle (input new_document).
    if v-select = 4  then run a_csavans4 persistent set var_handle (input new_document).*/
    end.
on choose of menu-item d_update
    do:
        if valid-handle (var_handle) then
        do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        v_u = 2.
        new_document = false.
        if v-select <= 2 then run a_csavans1 persistent set var_handle (input new_document).
    /*if v-select = 3  then run a_csavans3 persistent set var_handle (input new_document).
    if v-select = 4  then run a_csavans4 persistent set var_handle (input new_document).*/
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
/*on choose of menu-item t_delete do:
    if valid-handle (var_handle) then do:
       run Delete_transaction in var_handle.
    end.
    hide message.
end.*/
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

