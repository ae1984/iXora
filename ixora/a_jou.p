/* a_jou.p
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
            14/02/2012 Luiza - добавила run to_screen( "default","") при создании транзакции (закрываем экран клиента)
            14/05/2012 Luiza - добавила вызов программы Get_Nal1
            15/05/2012 Luiza - при вызове qpay_state передаем joudoc.jh
            10/10/2012 Luiza перед изменением статуса в joudoc.resch[5] проверить статус проводки  = 6
            08/11/2012 Luiza - команда импорт для Юнистрим доступна
            28/11/2012 Luiza - ТЗ 1580 для отмены переводов Юнистрим, команда импорт доступна
            18/01/2013 Luiza - при открытии документа и редактировании добавила удаление handle
            21/01/2013 Luiza - поле номер перевода при импорте до 20 символов
            27/02/2013 Luiza - ТЗ 1699 добавила меню штамп
            01/04/2013 Luiza - ТЗ 1789 отмена быстрой почты и Western Union
            14/05/2013 Luiza - Тз 1843 отмена Юнистрим
            27/05/2013 Luiza - ТЗ 1857 отмена Юнистрим (возврат)
            10/07/2013 Luiza - ТЗ 1948
*/


{mainhead.i}
{to_screen.i}

define variable var_handle   as widget-handle.
define variable new_document as logical.

def var v-select as integer no-undo.
def new shared var v_u as int no-undo.
def new shared var v_dt as int no-undo.
def new shared var v_kt as int no-undo.
def new shared var v_dtk as int no-undo.
def new shared var v_ktk as int no-undo.
def new shared var v-sys as char no-undo.
def new shared var v-select3 as integer no-undo.
def new shared var v-select4 as integer no-undo.
def new shared var v-select5 as integer no-undo.
def new shared var v-select31 as integer no-undo.
DEF VAR Doc AS CLASS QPayClass.
DEF VAR Docu AS CLASS UPayClass.
def var p-errcode as integer no-undo init 0.
def var p-errdes as char no-undo init ''.
def new shared var v-ek as integer no-undo.
def new shared var v-nomer like cslist.nomer no-undo.
def new shared var v-res111 as char.
def new shared var v-Get_Nal as logic init no.
def new shared var v-joudoc as char no-undo format "x(10)".

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


v-select = 0.
repeat:
    v-select31 = 0.
    v-select3 = 0.
    v-select5 = 0.
    v-select4 = 0.
    run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ ", "1. ОТПРАВЛЕНИЕ ПЕРЕВОДА |2. ВЫПЛАТА ПЕРЕВОДА |3. ОТМЕНА/ВОЗВРАТ ПЕРЕВОДА |4. ВЫХОД ", output v-select31).
    if keyfunction (lastkey) = "end-error" then return.
    repeat:
        run to_screen( "default","").
        hide all.
        if v-Get_Nal then do:
            run Get_Nal1(v-joudoc,v-nomer).
            v-Get_nal = no.
            run zk.
        end.
        case v-select31:
            when 1 then do:
                v-select3 = 0.
                v-select5 = 0.
                v-select4 = 0.
                run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ (отправление)", /*"1. Система 'WESTERN UNION' |2. Система 'БЫСТРАЯ ПОЧТА'
                |*/ "3. Система 'ЗОЛОТАЯ КОРОНА' |5. ВЫХОД ", output v-select3).
                if keyfunction (lastkey) = "end-error" then return.
                v-select3 = v-select3 + 2.
                case v-select3:
                    when 1 then do:
                        if v-ek  = 1 then v_dt = 100100. else v_dt = 100500.
                        v_kt = 287035.
                        if v-ek  = 1 then v_dtk = 100100. else v_dtk = 100500.
                        v_ktk = 287035.
                        v-sys = " системой WESTERN UNION".
                        run auto_menu("1").
                    end. /*  v-select3 = 1.*/

                    when 2 then do:
                        if v-ek  = 1 then v_dt = 100100. else v_dt = 100500.
                        v_kt = 287034.
                        if v-ek  = 1 then v_dtk = 100100. else v_dtk = 100500.
                        v_ktk = 287034.
                        v-sys = " системой БЫСТРАЯ ПОЧТА".
                        run auto_menu("1").
                    end. /*  v-select3 = 2.*/
                    when 3 then do:
                        if v-ek  = 1 then v_dt = 100100. else v_dt = 100500.
                        v_kt = 287037.
                        if v-ek  = 1 then v_dtk = 100100. else v_dtk = 100500.
                        v_ktk = 287037.
                        v-sys = " системой ЗОЛОТАЯ КОРОНА".
                        run auto_menu("1").
                    end. /*  v-select3 = 3.*/
                    /*when 4 then do:
                        if v-ek  = 1 then v_dt = 100100. else v_dt = 100500.
                        v_kt = 287036.
                        if v-ek  = 1 then v_dtk = 100100. else v_dtk = 100500.
                        v_ktk = 287036.
                        v-sys = " системой ЮНИСТРИМ".
                        run auto_menu("1").
                    end.*/ /*  v-select3 = 4.*/
                    when 5 or when 4 then return.
                    OTHERWISE leave.
                end case.  /* v-select3 */
                hide all.
            end. /*  v-select31 = 1.*/
            when 2 then do:
                v-select5 = 0.
                v-select4 = 0.
                run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ (выплаты)", /*"1. Система 'WESTERN UNION' |2. Система 'БЫСТРАЯ ПОЧТА'
                |*/ "3. Система 'ЗОЛОТАЯ КОРОНА' |5. ВЫХОД ", output v-select4).
                if keyfunction (lastkey) = "end-error" then return.
                v-select4 = v-select4 + 2.
                case v-select4:
                    when 1 then do:
                        v_dt = 187035.
                        if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                        v-sys = " системой WESTERN UNION".
                        run auto_menu("2").
                    end. /*  v-select4 = 1.*/

                    when 2 then do:
                        v_dt = 187034.
                        if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                        v-sys = " системой БЫСТРАЯ ПОЧТА".
                        run auto_menu("2").
                    end. /*  v-select4 = 2.*/
                    when 3 then do:
                        v_dt = 187037.
                        if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                        v-sys = " системой ЗОЛОТАЯ КОРОНА".
                        run auto_menu("2").
                    end. /*  v-select4 = 3.*/
                    /*when 4 then do:
                        v_dt = 187036.
                        if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                        v-sys = " системой ЮНИСТРИМ".
                        run auto_menu("2").
                    end.*/ /*  v-select4 = 4.*/
                    when 5 or when 4 then return.
                    OTHERWISE leave.
                end case.  /* v-select4 */
            end. /*  v-select31 = 2.*/
            when 3 then do:
                v-select5 = 0.
                v-select4 = 0.
                run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ (отмена/возврат)", "1. ОТМЕНА |2. ВОЗВРАТ |3. ВЫХОД ", output v-select5).
                if keyfunction (lastkey) = "end-error" then return.
                case v-select5:
                    when 1 then do:
                        v-select4 = 0.
                        run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ (отмена)", /*"1. Система 'WESTERN UNION' |2. Система 'БЫСТРАЯ ПОЧТА'
                        | */ "3. Система 'ЗОЛОТАЯ КОРОНА' |5. ВЫХОД ", output v-select4).
                        v-select4 = v-select4 + 2.
                        if keyfunction (lastkey) = "end-error" then undo.
                        case v-select4:
                            when 1 then do:
                                v_dt = 287035.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой WESTERN UNION".
                                run auto_menu("3").
                            end. /*  v-select4 = 1.*/

                            when 2 then do:
                                v_dt = 287034.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой БЫСТРАЯ ПОЧТА".
                                run auto_menu("3").
                            end. /*  v-select4 = 2.*/
                            when 3 then do:
                                v_dt = 287037.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой ЗОЛОТАЯ КОРОНА".
                                run auto_menu("3").
                            end. /*  v-select4 = 3.*/
                            /*when 4 then do:
                                v_dt = 287036.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой ЮНИСТРИМ".
                                run auto_menu("3").
                            end.*/ /*  v-select4 = 4.*/
                            when 5 or when 4 then return.
                            OTHERWISE leave.
                        end case.  /* v-select4 */
                    end.
                    when 2 then do: /* Возврат */
                        v-select4 = 0.
                        run sel2 (" БЫСТРЫЕ ПЕРЕВОДЫ (возврат)", /*"1. Система 'WESTERN UNION' |2. Система 'БЫСТРАЯ ПОЧТА'
                        |*/ "3. Система 'ЗОЛОТАЯ КОРОНА' |5. ВЫХОД ", output v-select4).
                        if keyfunction (lastkey) = "end-error" then undo.
                        v-select4 = v-select4 + 2.
                        case v-select4:
                            when 1 then do:
                                v_dt = 187035.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой WESTERN UNION".
                                run auto_menu("4").
                            end. /*  v-select4 = 1.*/

                            when 2 then do:
                                v_dt = 187034.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой БЫСТРАЯ ПОЧТА".
                                run auto_menu("4").
                            end. /*  v-select4 = 2.*/
                            when 3 then do:
                                v_dt = 187037.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой ЗОЛОТАЯ КОРОНА".
                                run auto_menu("4").
                            end. /*  v-select4 = 3.*/
                            /*when 4 then do:
                                v_dt = 187036.
                                if v-ek  = 1 then v_kt = 100100. else v_kt = 100500.
                                v-sys = " системой ЮНИСТРИМ".
                                run auto_menu("4").
                            end.*/ /*  v-select4 = 4.*/
                            when 5 or when 4 then return.
                            OTHERWISE leave.
                        end case.  /* v-select4 */
                    end.
                    when 3 then return.
                end case.
            end. /*  v-select31 = 3.*/
            when 4 then return.
            OTHERWISE leave.
        end case.  /* v-select31 */
    end. /* end repeat  */

end.
procedure auto_menu:
    define input parameter v_prg as char.
define sub-menu sub_doc
    menu-item d_new    label "&Создать"    rule
    menu-item  d_open  label "&Открыть"   rule
    menu-item  d_import  label "&Импорт"   rule
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

define sub-menu sub_scr
    menu-item s_open label "&Открыть".
    menu-item s_close label "&Закрыть".

define sub-menu sub_stm
    menu-item s_stmp label "Штамп".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция".
    sub-menu sub_scr label "Экран клиента".
    sub-menu sub_stm label "Штамп".

if v-ek = 2 then MENU-ITEM d_100100:SENSITIVE = true.
else MENU-ITEM d_100100:SENSITIVE = false.

if v-ek = 1 then MENU-ITEM s_stmp:SENSITIVE = true.
else MENU-ITEM s_stmp:SENSITIVE = false.

on choose of menu-item d_100100 do:
    if valid-handle (var_handle) then do:
       run Create_100100 in var_handle.
    end.
    hide message.
end.

on choose of menu-item s_open do:
    if valid-handle (var_handle) then do:
       run sc in var_handle.
    end.
    hide message.
end.
on choose of menu-item s_close do:
    run to_screen( "default","").
end.

if /*(v-select31 = 2 or  v-select31 = 3) and*/ v-ek = 2 then MENU-ITEM t_nal:SENSITIVE = true.
else MENU-ITEM t_nal:SENSITIVE = false.

/*if v-ek = 2 then MENU-ITEM t_delete:SENSITIVE = false.
else MENU-ITEM t_delete:SENSITIVE = true.*/


if v-sys = " системой ЗОЛОТАЯ КОРОНА" or v-sys = " системой ЮНИСТРИМ" then MENU-ITEM d_import:SENSITIVE = true.
else MENU-ITEM d_import:SENSITIVE = false.

/*if v-sys = " системой ЗОЛОТАЯ КОРОНА"  then MENU-ITEM d_new:SENSITIVE = false.
else MENU-ITEM d_new:SENSITIVE =true .*/

/*****************************************************************************************************/
on choose of menu-item d_import do:
   define frame finddocframe documn as char format "x(20)" label  "номер перевода" skip
   with  side-labels  title "поиск перевода".

   on end-error of documn or return of documn in  frame finddocframe
   do:
      apply "go" to current-window.
      hide frame finddocframe .
   end.

  /* documn:screen-value in frame finddocframe  = "993338086".*/

   set documn with  frame finddocframe.

   if documN = "" then return.

   if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.

    if v-sys = " системой ЗОЛОТАЯ КОРОНА" then do:
        Doc = NEW QPayClass(documN).
        run qpay_import( Doc , output p-errcode, output p-errdes).
        if p-errcode <> 0 then do:
        /*Импорт не удался*/
           message p-errdes view-as alert-box.
           HIDE FRAME FindDocFrame.
           return.
        end.
    end.
    if v-sys = " системой ЮНИСТРИМ"  then do:
        Docu = NEW UPayClass(documN).
        run upay_import( Docu , output p-errcode, output p-errdes).
        if p-errcode <> 0 then do:
        /*Импорт не удался*/
           message p-errdes view-as alert-box.
           HIDE FRAME FindDocFrame.
           return.
        end.
    end.
    new_document = true.
    /*run to_screen( "default","").*/
    if v_prg = "1" then run a_transf1 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "2" then run a_transf2 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "3" then run a_transf3 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "4" then run a_transf4 persistent set var_handle (input new_document, input Doc, input Docu).
    /* run to_screen("qtransfer", v-res111). */
    if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR .
    if VALID-OBJECT(Docu)  then DELETE OBJECT Docu NO-ERROR .

end.
/*****************************************************************************************************/

on choose of menu-item d_new do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    new_document = true.
    /*run to_screen( "default","").*/
    if v_prg = "1" then run a_transf1 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "2" then run a_transf2 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "3" then run a_transf3 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "4" then run a_transf4 persistent set var_handle (input new_document, input Doc, input Docu).
    /* run to_screen("qtransfer", v-res111). */
end.
on choose of menu-item d_open do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 1.
    new_document = false.
    if v_prg = "1" then run a_transf1 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "2" then run a_transf2 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "3" then run a_transf3 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "4" then run a_transf4 persistent set var_handle (input new_document, input Doc, input Docu).
end.
on choose of menu-item d_update do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 2.
    new_document = false.
    if v_prg = "1" then run a_transf1 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "2" then run a_transf2 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "3" then run a_transf3 persistent set var_handle (input new_document, input Doc, input Docu).
    if v_prg = "4" then run a_transf4 persistent set var_handle (input new_document, input Doc, input Docu).
    v_u = 1.
    /* run to_screen("qtransfer", v-res111). */
end.
on choose of menu-item d_subcod do:
    if valid-handle (var_handle) then do:
       run a_subcod in var_handle.
    end.
    hide message.
end.

on choose of menu-item d_delete do:
    if valid-handle (var_handle) then do:
       run Delete_document in var_handle.
    end.
    hide message.
end.
on choose of menu-item t_create do:
    /*run to_screen( "default","").*/
    if valid-handle (var_handle) then do:
       run Create_transaction in var_handle.
    end.
    hide message.
end.

on choose of menu-item s_stmp do:
    if valid-handle (var_handle) then do:
       run Stamp_transaction in var_handle.
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

procedure zk:
 def var p-tr-state as char.
 def var p-err as log no-undo init yes.
 def var p-errdes as char no-undo init ''.

   /***** Интеграция с Золотой короной *************************************************************/
   find first joudoc where joudoc.docnum = v-joudoc and joudoc.rescha[5] <> '' no-lock no-error.
   if avail joudoc then do:
    find first jl where jl.jh = joudoc.jh no-lock no-error.
    if available jl and jl.sts = 6 then do:
       case entry(1, joudoc.rescha[5], " "):
         when 'ZK' then do:
           if entry(2, joudoc.rescha[5], " ") = "2" then p-tr-state = "0". /* отправка */
           if entry(2, joudoc.rescha[5], " ") = "5" then p-tr-state = "1". /* выдача */
           if entry(2, joudoc.rescha[5], " ") = "6" then p-tr-state = "2". /* возврат */
           if entry(2, joudoc.rescha[5], " ") = "7" then p-tr-state = "2". /* отмена */

           run qpay_state(entry(3, joudoc.rescha[5], " "),string(joudoc.jh),p-tr-state,output p-errdes,output p-err).
           if not p-err then do:
             /*Ошибка при изменении статуса*/
             message "Ошибка при изменении статуса документа " entry(3, joudoc.rescha[5], " ") "~n" p-errdes view-as alert-box.
             /* И отправить сообщение контроллеру для ручного изменения статуса в АРМ*/
           end.

         end.
         when 'UN' then do:
                if entry(2, joudoc.rescha[5], " ") = "10" then p-tr-state = "1". /* отправка */
                if entry(2, joudoc.rescha[5], " ") = "42" then p-tr-state = "2". /* выдача */
                if entry(2, joudoc.rescha[5], " ") = "42" then p-tr-state = "2". /* возврат */

           run upay_state(entry(3, joudoc.rescha[5], " "),string(joudoc.jh),p-tr-state,output p-errdes,output p-err).
           if not p-err then do:
             /*Ошибка при изменении статуса*/
             message "Ошибка при изменении статуса документа " entry(3, joudoc.rescha[5], " ") "~n" p-errdes view-as alert-box.
             /* И отправить сообщение контроллеру для ручного изменения статуса в АРМ*/
           end.

         end.
         when 'WU' then do:
          /*когда будем интегрировать например с WU*/
         end.
         otherwise do:
         end.
       end case.
   end.
 end.
end procedure.
