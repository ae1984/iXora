/* a_doch.p
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
            06/02/2012 Luiza - добавила пм признаки
            07/02/2012 Luiza - добавила подключение comm после вызова r-branch
            15/03/2012 Luiza - закомент заполнение таблицы tempch
            05.05.2012 damir - добавил кнопку <Заявление>.
            14/05/2012 Luiza - добавила вызов программы Get_Nal1
            05/09/2012 Luiza - добавила a_tng4
            27/02/2013 Luiza - ТЗ 1699 добавила меню штамп
            10/07/2013 Luiza - ТЗ 1948
*/


{mainhead.i}
define new shared variable var_handle   as widget-handle.
define variable new_document as logical.
def new shared var v-ek as integer no-undo.
def new shared var v-nomer like cslist.nomer no-undo.

def var v-select3 as integer no-undo.
def new shared var v_u as int no-undo.
def new shared var v-select31 as integer no-undo.
def new shared var v-select32 as integer no-undo.
def var v_prg as char.
def new shared var v-res111 as char.
def new shared var v-Get_Nal as logic init no.
def new shared var v-joudoc as char no-undo format "x(10)".


define new shared temp-table tempch
       field tempch as char
       field tempdes as char
       field tempswibic as char
       field tempcrc as int
       field temprnn as char.


run sel2 ("Выберите :", " 1. Касса (100100) | 2. Электронный кассир (100500) | 3. Выход ", output v-ek).
if keyfunction (lastkey) = "end-error" then return.
if (v-ek < 1) or (v-ek > 2) then return.
if v-ek = 2 then do:
    find first csofc where csofc.ofc = g-ofc no-lock no-error.
    if avail csofc then v-nomer = csofc.nomer.
    else do:
        message "Нет привязки к ЭК!" view-as alert-box error.
        return.
    end.
end.
repeat:
    run to_screen( "default","").
    hide all.
    if v-Get_Nal then do:
        run Get_Nal1(v-joudoc,v-nomer).
        v-Get_nal = no.
    end.
    v-select3 = 0.
    run sel2 (" ПЕРЕВОДЫ  БЕЗ ОТКРЫТИЯ СЧЕТА ", "1. ПЕРЕВОДЫ В ТЕНГЕ БЕЗ ОТКРЫТИЯ СЧЕТА |2. ПЕРЕВОДЫ В ИН ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА
                |3. ОТМЕНА/ВОЗВРАТ ПЕРЕВОДА  |4. ВЫХОД ", output v-select3).
    if keyfunction (lastkey) = "end-error" then return.
    case v-select3:
        when 1 then  do:
            v-select31 = 0.
            run sel2 (" ПЕРЕВОДЫ В ТЕНГЕ БЕЗ ОТКРЫТИЯ СЧЕТА ", "1. ОТПРАВЛЕНИЕ ПЕРЕВОДА |2. ПОЛУЧЕНИЕ ПЕРЕВОДА |3. ВОЗВРАТ ВНУТРИБАНКОВСКОГО ПЕРЕВОДА |4. ВЫХОД ", output v-select31).
            if keyfunction (lastkey) = "end-error" then undo.
            case v-select31:
                when 1 then  do:
                    v-select32 = 0.
                    run sel2 (" ОТПРАВЛЕНИЕ ПЕРЕВОДА ", "1. ВНУТРИБАНКОВСКИЙ ПЕРЕВОД |2. ПЕРЕВОД В ДРУГОЙ БАНК |3. ВЫХОД ", output v-select32).
                    if keyfunction (lastkey) = "end-error" then undo.
                    case v-select32:
                        when 1 then  do:
                            run auto_menu("3").
                            /*empty temp-table tempch.
                            {r-branch.i &proc = "findarphelp1"}*/
                            /*подключение comm */
                            find sysc where sysc.sysc = 'CMHOST' no-lock no-error.
                            if avail sysc then connect value (sysc.chval) no-error.
                            /*--------------------------------------------------------*/
                        end.
                        when 2 then  run auto_menu("4").
                        when 3 then  return.
                    end case.  /* v-select32 */
                end.
                when 2 then  run auto_menu("5").
                when 3 then do: v-ek = 1. run auto_menu("7").  end.
                when 4 then return.
            end case.  /* v-select31 */
        end.
        when 2 then  do:
            v-select31 = 0.
            run sel2 (" ПЕРЕВОДЫ В ИН ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА ", "1. ОТПРАВЛЕНИЕ ПЕРЕВОДА |2. ПОЛУЧЕНИЕ ПЕРЕВОДА |3. ВЫХОД ", output v-select31).
            if keyfunction (lastkey) = "end-error" then undo.
            case v-select31:
                when 1 then  run auto_menu("1").
                when 2 then  run auto_menu("2").
                when 3 then return.
            end case.  /* v-select31 */
        end.
        when 3 then run auto_menu("6").
        when 4 then return.
    end case.  /* v-select31 */
end.


procedure auto_menu:
    define input parameter v_prg as char.
    define sub-menu sub_doc
        menu-item d_new    label "&Создать"    rule
        menu-item  d_open  label "&Открыть"   rule
        menu-item  d_update  label "&Редакт."   rule
        menu-item  d_subcod  label "&Признаки"   rule
        menu-item d_delete label "&Удалить" rule
        menu-item d_100100 label "&Перевод на 100100" rule
        menu-item d_exit   label "&Выход".

    define sub-menu sub_trx
        menu-item t_create label "&Создать" rule
        menu-item t_nal    label "&Прием/Выдача наличных" rule
        /*menu-item t_screen label "&Экран"  rule*/
        menu-item t_print  label "&Печать"  rule
        menu-item t_delete label "&Удалить".

    define sub-menu sub_swf
        menu-item f_swift label "&Свифт/ПлатПоруч".

    define sub-menu sub_scr
        menu-item s_open label "&Открыть".
        menu-item s_close label "&Закрыть".

    define sub-menu sub_app
        menu-item c_appli label "&Заявление".

    define sub-menu sub_stm
        menu-item s_stmp label "Штамп".

    define  menu u_menu menubar
        sub-menu sub_doc label "Документ"
        sub-menu sub_trx label "Транзакция"
        sub-menu sub_swf label "Свифт/ПлатПоруч"
        sub-menu sub_scr label "Экран клиента".
        sub-menu sub_app label "Заявление".
        sub-menu sub_stm label "Штамп".

    on choose of menu-item s_open do:
        if valid-handle (var_handle) then do:
           if v_prg <> "7" then run sc in var_handle.
        end.
        hide message.
    end.
    on choose of menu-item s_close do:
        if v_prg <> "7" then run to_screen( "default","").
    end.

    if /*v-select31 = 2  and*/ v-ek = 2 then MENU-ITEM t_nal:SENSITIVE = true.
    else MENU-ITEM t_nal:SENSITIVE = false.

    if v-ek = 1 then MENU-ITEM s_stmp:SENSITIVE = true.
    else MENU-ITEM s_stmp:SENSITIVE = false.

    /*if v-ek = 2 then MENU-ITEM t_delete:SENSITIVE = false.
    else MENU-ITEM t_delete:SENSITIVE = true.*/

    if v-ek = 2 then MENU-ITEM d_100100:SENSITIVE = true.
    else MENU-ITEM d_100100:SENSITIVE = false.

    on choose of menu-item d_100100 do:
        if valid-handle (var_handle) then do:
           run Create_100100 in var_handle.
        end.
        hide message.
    end.

    on choose of menu-item d_new do:
        if valid-handle (var_handle) then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        new_document = true.
        if v_prg = "1" then run a_foreign1 persistent set var_handle (input new_document).
        if v_prg = "2" then run a_foreign2 persistent set var_handle (input new_document).
        if v_prg = "3" then run a_tng1     persistent set var_handle (input new_document).
        if v_prg = "4" then run a_tng2     persistent set var_handle (input new_document).
        if v_prg = "5" then run a_tng3     persistent set var_handle (input new_document).
        if v_prg = "6" then run a_foreign3 persistent set var_handle (input new_document).
        if v_prg = "7" then run a_tng4     persistent set var_handle (input new_document).
    end.
    on choose of menu-item d_open do:
        if valid-handle (var_handle) then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        v_u = 1.
        new_document = false.
        if v_prg = "1" then run a_foreign1 persistent set var_handle (input new_document).
        if v_prg = "2" then run a_foreign2 persistent set var_handle (input new_document).
        if v_prg = "3" then run a_tng1     persistent set var_handle (input new_document).
        if v_prg = "4" then run a_tng2     persistent set var_handle (input new_document).
        if v_prg = "5" then run a_tng3     persistent set var_handle (input new_document).
        if v_prg = "6" then run a_foreign3 persistent set var_handle (input new_document).
        if v_prg = "7" then run a_tng4     persistent set var_handle (input new_document).
    end.
    on choose of menu-item d_update do:
        if valid-handle (var_handle) then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        v_u = 2.
        new_document = false.
        if v_prg = "1" then run a_foreign1 persistent set var_handle (input new_document).
        if v_prg = "2" then run a_foreign2 persistent set var_handle (input new_document).
        if v_prg = "3" then run a_tng1     persistent set var_handle (input new_document).
        if v_prg = "4" then run a_tng2     persistent set var_handle (input new_document).
        if v_prg = "5" then run a_tng3     persistent set var_handle (input new_document).
        if v_prg = "6" then run a_foreign3 persistent set var_handle (input new_document).
        if v_prg = "7" then run a_tng4     persistent set var_handle (input new_document).
        v_u = 1.
    end.
    on choose of menu-item d_delete do:
        if valid-handle (var_handle) then do:
           run Delete_document in var_handle.
        end.
        hide message.
    end.

    on choose of menu-item d_subcod do:
        if valid-handle (var_handle) then do:
           if v_prg <> "7" then run a_subcod in var_handle.
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
       if valid-handle (var_handle) then do:
           if v_prg = "1" or v_prg = "4" then do:
                run swift_open in var_handle.
           end.
           if v_prg = "3" or v_prg = "7" then do:
               run prtppp1 in var_handle.
            end.
            hide message.
       end.
    end.

    on choose of menu-item c_appli do:
        if valid-handle(var_handle) then do:
            if v_prg <> "7" then run print_statement in var_handle.
        end.
        hide message.
    end.
    on choose of menu-item s_stmp do:
        if valid-handle (var_handle) then do:
           run Stamp_transaction in var_handle.
        end.
        hide message.
    end.
    on choose of menu-item d_exit do:
        if valid-handle (var_handle) then do:
            apply "close" to var_handle.
            delete procedure var_handle.
            hide message.
        end.
        return.
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


