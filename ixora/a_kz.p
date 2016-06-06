/* a_kz.p
 * MODULE
        Переводы по счетам клиентов в тенге
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
        05.05.2012 damir - добавлена новая кнопка <Заявление>.
        27.07.2012 id00810 - добавлены переводы на счета по ПК
*/


{mainhead.i}
define variable var_handle   as widget-handle.
define variable new_document as logical.

def var v-select  as integer no-undo.
def var v-select1 as integer no-undo.
def new shared var v_u as int no-undo.
def new shared var v_dt as int no-undo.
def new shared var v_kt as int no-undo.
def new shared var v_dtk as int no-undo.
def new shared var v_ktk as int no-undo.
def new shared var v-sys as char no-undo.
def new shared var v-option as char .
def new shared var s-remtrz like remtrz.remtrz.


{lgps.i "new"}
repeat:
    v-select = 0.
    run sel2 (" ПЕРЕВОДЫ ПО СЧЕТАМ КЛИЕНТОВ ", "1. Переводы со счета клиента в тенге  |2. Переводы со счета клиента в ин.валюте |3. Внутренние переводы |4. Переводы со счета клиента на счет ПК  |5. ВЫХОД ", output v-select).
    if keyfunction (lastkey) = "end-error" then return.
    case v-select:
        when 1 then do:
            m_pid = "P" .
            u_pid = "a_kz" .
            v-option = "remsubk".
            run auto_menu("1").
        end. /*  v-select = 1.*/
        when 2 then do:

            m_pid = "O" .
            u_pid = "a_us" .
            v-option = "remsubo".
            run auto_menu("2").
        end. /*  v-select = 2.*/
        when 3 then do:
            run auto_menu("3").
        end. /*  v-select = 3.*/
        when 4 then do:
            v-select1 = 0.
            run sel2 (" ПЕРЕВОДЫ НА СЧЕТА ПО ПК ", "1. Внутри филиала  |2. В другой филиал  |3. ВЫХОД ", output v-select1).
            if keyfunction (lastkey) = "end-error" then return.
            case v-select1:
                when 1 then do:
                    run auto_menu("41").
                end.
                when 2 then do:
                    run auto_menu("42").
                end.
                when 3 then return.
            end. /*  v-select = 4.*/
        end.
        when 5 then return.
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
    /*menu-item t_screen label "&Экран"  rule*/
    menu-item t_print  label "&Печать"  rule
    menu-item t_delete label "&Удалить".

define sub-menu sub_swf
    menu-item f_swift label "&Свифт/ПлатПоруч".

define sub-menu sub_app
    menu-item c_appli label "&Заявление".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция"
    sub-menu sub_swf label "Свифт/ПлатПоруч"
    sub-menu sub_app label "Заявление".

on choose of menu-item d_new do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    new_document = true.
    if v_prg = "1" then do:
        run a_kz1 persistent set var_handle (input new_document).
        if keyfunction (lastkey) <> "end-error" then do:
            run rmzoutg.
            run part2 in var_handle.
        end.
    end.
    if v_prg = "2" then do:
        run a_us1 persistent set var_handle (input new_document).
        if keyfunction (lastkey) <> "end-error" then do:
            run part2 in var_handle.
        end.
    end.
    if v_prg = "3"  then run a_cas3 persistent set var_handle (input new_document).
    if v_prg = "41" then run a_pc1  persistent set var_handle (input new_document).
    if v_prg = "42" then run a_pc2  persistent set var_handle (input new_document).
end.
on choose of menu-item d_open do:
   if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 1.
    new_document = false.
    if v_prg = "1"  then run a_kz1  persistent set var_handle (input new_document).
    if v_prg = "2"  then run a_us1  persistent set var_handle (input new_document).
    if v_prg = "3"  then run a_cas3 persistent set var_handle (input new_document).
    if v_prg = "41" then run a_pc1  persistent set var_handle (input new_document).
    if v_prg = "42" then run a_pc2  persistent set var_handle (input new_document).
    /*if v_prg = "4" then run a_cas3pc persistent set var_handle (input new_document).*/
end.
on choose of menu-item d_update do:
   if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 2.
    new_document = false.
    if v_prg = "1" then run a_kz1 persistent set var_handle (input new_document).
    if v_prg = "2" then do:
        run a_us1 persistent set var_handle (input new_document).
        run part2 in var_handle.
    end.
    if v_prg = "3"  then run a_cas3 persistent set var_handle (input new_document).
    if v_prg = "41" then run a_pc1  persistent set var_handle (input new_document).
    if v_prg = "42" then run a_pc2  persistent set var_handle (input new_document).
    /*if v_prg = "4" then run a_cas3pc persistent set var_handle (input new_document).*/
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

on choose of menu-item f_swift do:
   if v_prg = "1" then do:
    if valid-handle (var_handle) then do:
       run prtppp1 in var_handle.
    end.
    hide message.
   end.
   if v_prg = "3" /*or v_prg = "41"  or v_prg = "42"*/ then do:
    if valid-handle (var_handle) then do:
       run prtppp1 in var_handle.
    end.
    hide message.
   end.
   if v_prg = "2" then do:
       if valid-handle (var_handle) then do:
                run swift_open in var_handle.
            hide message.
       end.
   end.
end.
on choose of menu-item c_appli do:
    if valid-handle(var_handle) then do:
        run print_statement in var_handle.
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
