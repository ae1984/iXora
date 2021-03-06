﻿/* a_2cas.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Кассовые операции
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
            12/03/2012 Luiza - раскоммент вызов взноса на арп счета
            14/05/2012 Luiza - добавила вызов программы Get_Nal1
            09/07/2012 id00810 - добавлен взнос наличных денег по платежной карте
            14/08/2012 id00810 - добавлен pcpay.i для доп.обработки транзакций по пополнению счетов по ПК
            16/11/2012 Luiza  - добавила прставления время штампа проводки при создании линий для комиссии
            18/01/2013 Luiza - при открытии документа и редактировании добавила удаление handle
            27/02/2013 Luiza - ТЗ 1699 добавила меню штамп
            19/03/2013 Luiza - * ТЗ 1714 проводку на сумму комиссии создаем, если при приеме наличности ЭК отработал без ошибок
            15/05/2013 Luiza - ТЗ 1826 добавление евро для 100500
            10/07/2013 Luiza - ТЗ 1948
            23/07/2013 Luiza - ТЗ 1935 если в PCPAY статус 'send' транзакцию удалять нельзя
*/


{mainhead.i}
define variable var_handle   as widget-handle.
define variable new_document as logical.

def var v-select as integer no-undo.
def new shared var v-ek as integer no-undo.
def new shared var v-nomer like cslist.nomer no-undo.

def new shared var v_u as int no-undo.
def new shared var v_dt as int no-undo.
def new shared var v_kt as int no-undo.
def new shared var v_dtk as int no-undo.
def new shared var v_ktk as int no-undo.
def new shared var v-sys as char no-undo.
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


repeat:
    if v-Get_Nal then do:
        run Get_Nal1(v-joudoc,v-nomer).
        v-Get_nal = no.
        if v-select = 1 then run razbl.
        /* вызов pcpay.i - перенесла в Get_Nal1.
        find first jh where jh.sub = 'jou' and jh.ref = v-joudoc no-lock no-error.
        if avail jh then do:
            {pcpay.i}
        end. */
    end.
    v-select = 0.
    run sel2 (" ВЗНОС НАЛИЧНЫХ ДЕНЕГ ", "1. Взнос наличных денег на счет клиента |2. Взнос наличных денег на АРП счет  |3. Взнос наличн.денег по платежной карте  |4. ВЫХОД ", output v-select).
    if keyfunction (lastkey) = "end-error" then return.
    case v-select:
        when 1 then do:
            run auto_menu("1").
        end.

        when 2 then do:
             run auto_menu("2").
        end.
        when 3 then do:
             run auto_menu("3").
        end.
        when 4 then return.
    end.
end. /* end repeat  */

procedure auto_menu:
define input parameter v_prg as char.
define sub-menu sub_doc
    menu-item d_new    label "&Создать"    rule
    menu-item d_open   label "&Открыть"   rule
    menu-item d_update label "&Редакт."   rule
    menu-item d_delete label "&Удалить" rule
    menu-item d_100100 label "&Перевод на 100100" rule
    menu-item d_exit   label "&Выход".

define sub-menu sub_trx
    menu-item t_create label "&Создать" rule
    menu-item t_nal    label "&Прием наличных" rule
    /*menu-item t_screen label "&Экран"  rule*/
    menu-item t_print  label "&Печать"  rule
    menu-item t_delete label "&Удалить".

define sub-menu sub_stm
    menu-item s_stmp label "Штамп".

define  menu u_menu menubar
    sub-menu sub_doc label "Документ"
    sub-menu sub_trx label "Транзакция".
    sub-menu sub_stm label "Штамп".

if v-ek = 2 then MENU-ITEM t_nal:SENSITIVE = true.
else MENU-ITEM t_nal:SENSITIVE = false.

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
    if v_prg = "1" then run a_cas1    persistent set var_handle (input new_document).
    if v_prg = "2" then run a_cas1arp persistent set var_handle (input new_document).
    if v_prg = "3" then run a_cas1pc  persistent set var_handle (input new_document).
end.
on choose of menu-item d_open do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 1.
    new_document = false.
    if v_prg = "1" then run a_cas1    persistent set var_handle (input new_document).
    if v_prg = "2" then run a_cas1arp persistent set var_handle (input new_document).
    if v_prg = "3" then run a_cas1pc  persistent set var_handle (input new_document).
end.
on choose of menu-item d_update do:
    if valid-handle (var_handle) then do:
        apply "close" to var_handle.
        delete procedure var_handle.
        hide message.
    end.
    v_u = 2.
    new_document = false.
    if v_prg = "1" then run a_cas1    persistent set var_handle (input new_document).
    if v_prg = "2" then run a_cas1arp persistent set var_handle (input new_document).
    if v_prg = "3" then run a_cas1pc  persistent set var_handle (input new_document).
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

procedure razbl:
    /* разблокируем сумму пополнения----------------------------------------------*/

    def var v-payee as char.
    find first joudoc where joudoc.docnum = v-joudoc no-lock.
    if not available joudoc then undo,return.
    find first jh where jh.jh = joudoc.jh no-lock no-error.
    if available jh and jh.sts = 6 then do:
        v-payee = "Пополнение счета клиента через ЭК 100500 |" + TRIM(STRING(joudoc.jh, "zzzzzzzzzz9")).
        find aas where aas.aaa = joudoc.cracc and aas.payee = v-payee and aas.chkamt = joudoc.cramt exclusive-lock no-error.
        if not avail aas then return.

        find aaa where aaa.aaa = joudoc.cracc exclusive-lock no-error.
        if not avail aaa then undo, return.
        for each aas_hist where aas_hist.aaa = aas.aaa and
                                aas_hist.ln = aas.ln and
                                aas_hist.chkamt = aas.chkamt and
                                aas_hist.payee = aas.payee:
           delete aas_hist.
        end.

        aaa.hbal = aaa.hbal - aas.chkamt.
        delete aas.
          release aas.
          release aas_hist.

        /* Luiza 07.07.2011 ТЗ 901 часть 1 ----------------------------------------------------------------------------------------*/
        /* создаем линии для комиссии при пополнении счета клиента, если суммы на счете для снятия комиссии было не достаточно в момент пополнения.*/
        if trim(joudoc.vo,"&") <> "" then do:
            if NUM-ENTRIES(joudoc.vo,"&") <= 4 then do: /* значит линии комиссии не созданы */
                def var ss-jh1 as int.
                def var v_doc as char.

                define variable rcode   as integer no-undo.
                define variable rdes    as character no-undo.
                define variable vdel    as character initial "^" no-undo.
                find first aaa where aaa.aaa = joudoc.comacc no-lock no-error.
                if not available aaa then do:
                    message "Ошибка, не найден счет клиента в таблице ааа"  view-as alert-box error.
                    return.
                end.
                else do:
                    def var v-comcode as char init "".
                    find first tarif2 where tarif2.str5  = joudoc.comcode no-lock no-error.
                    if available tarif2 then v-comcode = tarif2.pakalp.
                    if aaa.cbal - aaa.hbal < joudoc.comamt then do: /* тогда запишем в долг   */
                        create bxcif.
                        bxcif.cif = aaa.cif.
                        bxcif.amount = joudoc.comamt.
                        bxcif.whn = g-today.
                        bxcif.who = g-ofc.
                        bxcif.tim = time.
                        bxcif.aaa = joudoc.comacc.
                        bxcif.type = joudoc.comcode.
                        bxcif.crc = aaa.crc.
                        bxcif.pref = yes.
                        bxcif.jh = joudoc.jh.
                        if v-comcode <> "" then bxcif.rem = "#Комиссия за " + v-comcode  + ". За " + string(g-today) + " пополнение счета транз: " + string(joudoc.jh).
                        else bxcif.rem = "#Комиссия за (код комиссии) " + joudoc.comcode + ". За " + string(g-today) + " пополнение счета транз: " + string(joudoc.jh).

                        find first joudoc where joudoc.docnum = v-joudoc exclusive-lock no-error.
                        joudoc.vo = joudoc.vo + "&debt".
                        find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
                    end.
                    else do:
                        ss-jh1 = joudoc.jh.
                        if joudoc.docnum = trim(entry(4,joudoc.vo,"&")) then do:
                            for each jl where jl.jh = ss-jh1 exclusive-lock.
                                jl.sts = 0.
                            end.
                            for each jh where jh.jh = ss-jh1 exclusive-lock.
                                jh.sts = 0.
                            end.
                            run trxgen (entry(1,joudoc.vo,"&"), vdel, entry(2,joudoc.vo,"&"), entry(3,joudoc.vo,"&") , entry(4,joudoc.vo,"&"), output rcode, output rdes, input-output ss-jh1).
                            if rcode ne 0 then do:
                                message rdes.
                                pause.
                                undo, return.
                            end.
                            MESSAGE "Проводка для комиссии сформирована: " + string(ss-jh1) view-as alert-box.
                            for each jl where jl.jh = ss-jh1 exclusive-lock.
                                jl.sts = 6.
                                jl.teller = g-ofc.
                            end.
                            for each jh where jh.jh = ss-jh1 exclusive-lock.
                                jh.sts = 6.
                                assign jh.stmp_tim = time
                                       jh.jdt_sts = today.
                            end.
                            find first jh  no-lock.
                            find first jl  no-lock.

                            find first joudoc where joudoc.docnum = v-joudoc exclusive-lock no-error.
                            joudoc.vo = joudoc.vo + "&stamp".
                            find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
                        end.
                    end.  /* end else*/
                end. /* else do */
            end. /* if NUM-ENTRIES(joudoc.vo,"&") <= 4  */
        end. /*  if trim(joudoc.vo,"&") <> "" */
    end. /* if available jh and jh.sts = 6*/
end procedure.