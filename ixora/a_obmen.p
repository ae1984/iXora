/* a_obmen.p
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
	BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
                07.12.2011 Luiza
                14/05/2012 Luiza - добавила вызов программы Get_Nal1
                18/01/2013 Luiza - при открытии документа и редактировании добавила удаление handle
                10/07/2013 Luiza - ТЗ 1948

*/


{global.i}

define variable var_handle   as widget-handle.
define variable new_document as logical.
def new shared var v-ek as integer no-undo.
def new shared var v-nomer like cslist.nomer no-undo.

def var v-select as integer no-undo.
def new shared var v_u as int no-undo.
def new shared var v_dt as int no-undo.
def new shared var v_kt as int no-undo.
def new shared var v_dtk as int no-undo.
def new shared var v_ktk as int no-undo.
def new shared var v-sys as char no-undo.
def new shared var v-Get_Nal as logic init no.
def new shared var v-joudoc as char no-undo format "x(10)".
def new shared var v-res111 as char.
def new shared var v-ex as logic init no.

/*run sel2 ("Выберите :", " 1. Касса (100100) | 2. Электронный кассир (100500) | 3. Выход ", output v-ek).
if (v-ek < 1) or (v-ek > 2) then return.
if v-ek = 1 then run auto_menu("1").*/
repeat:
    if v-ex then return.
    if v-Get_Nal then do:
        run Get_Nal1(v-joudoc,v-nomer).
        v-Get_nal = no.
        return.
    end.

    v-ek = 2.
    if v-ek = 2 then do:
        find first csofc where csofc.ofc = g-ofc no-lock no-error.
        if avail csofc then v-nomer = csofc.nomer.
        else do:
            message "Нет привязки к ЭК!" view-as alert-box error.
            return.
        end.
        run auto_menu("1").
    end.
end.
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
    menu-item t_nal    label "&Прием/Выдача наличных" rule
    /*menu-item t_screen label "&Экран"  rule*/
    menu-item t_print  label "&Печать"  rule
    menu-item t_delete label "&Удалить".

define sub-menu sub_scr
    menu-item s_open label "&Открыть".
    menu-item s_close label "&Закрыть".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция".
    sub-menu sub_scr label "Экран клиента".

/*if v-ek = 2 then MENU-ITEM t_delete:SENSITIVE = false.
else MENU-ITEM t_delete:SENSITIVE = true.*/

on choose of menu-item s_open do:
    if valid-handle (var_handle) then do:
       run sc in var_handle.
    end.
    hide message.
end.

on choose of menu-item s_close do:
    run to_screen( "default","").
end.

on choose of menu-item d_new do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    new_document = true.
    if v_prg = "1" then run a_obmen1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_open do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 1.
    new_document = false.
    if v_prg = "1" then run a_obmen1 persistent set var_handle (input new_document).
end.
on choose of menu-item d_update do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 2.
    new_document = false.
    if v_prg = "1" then run a_obmen1 persistent set var_handle (input new_document).
    v_u = 1.
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
/*on choose of menu-item t_screen do:
    if valid-handle (var_handle) then do:
       run Screen_transaction in var_handle.
    end.
    hide message.
end.*/
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
on choose of menu-item d_exit do:
    v-ex = yes.
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
end.
on choose of menu-item t_nal do:
    if valid-handle (var_handle) then do:
        run Get_Nal in var_handle.
        if v-Get_Nal then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        else v-Get_nal = no.
    end.
    else v-Get_nal = no.
end.

assign current-window:menubar = menu u_menu:handle.
wait-for choose of menu-item d_exit or choose of menu-item t_nal.

end procedure.

