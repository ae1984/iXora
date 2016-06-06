/* pccreds.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Анкета клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def new shared var v-aaa      as char no-undo.
def new shared var s-credtype as char init '10'.
def new shared var v-bank     as char no-undo.
def new shared var v-cifcod   as char no-undo.
def new shared var s-ln       as inte no-undo.
def new shared var v-cls      as logi no-undo init no.
def new shared var s-lon      as char.
def new shared var s-ourbank  as char.
def new shared var s-pkankln  as inte.

def var v-select  as inte no-undo.
def var v-select1 as inte no-undo.

def var i as int.
def var v-access as logi init no.

define button but10   label "АНКЕТА".
define button but1    label "ЗАЯВЛЕНИЯ".
define button but2    label "ОТЧЕТ ГЦВП И КБ".
define button but3    label "КРЕД.СКОРИНГ".
define button but4    label "РЕШЕНИЕ О ФИНАНС.".
define button but8    label "ОТКРЫТИЕ СЧЕТОВ".
define button but5    label "ДОГОВОРА".
define button but6    label "ЗАКЛЮЧЕНИЕ".
define button but7    label "ПРОТОКОЛА".
define button but9    label "ОТКАЗ КЛИЕНТА".
define button but11   label "ДОСРОЧ.ПОГАШЕНИЕ".
define button b-ext   label "ВЫХОД".

define frame a1
    but10 but1 but2 but3 but4 but8 but5 but6 but7 but9 but11 b-ext
    with width 110 side-labels row 3 no-box.

ON CHOOSE OF b-ext IN FRAME a1 do:
    apply "window-close" to CURRENT-WINDOW.
end.

{chbin.i}
{chk12_innbin.i}

enable but10 b-ext with frame a1.

on choose of but10 in frame a1 do:
    run ekanket.
    if v-cifcod <> '' then enable but10 but1 but2 but3 but4 but8 but5 but6 but7 but9 but11 b-ext with frame a1.
    else enable but10 b-ext with frame a1.
end.


on choose of but1 in frame a1 do:
    find first optitsec where optitsec.proc = "expreq" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ЗАЯВЛЕНИЯ'! " view-as alert-box.
        undo, return.
    end.
    else run expreq.
end.

on choose of but2 in frame a1 do:
    find first optitsec where optitsec.proc = "expquery" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ОТЧЕТ ГЦВП И КБ'! " view-as alert-box.
        undo, return.
    end.
    else do:
        hide frame a1.
        run expquery.
        enable but1 but2 but3 but4 but8 but5 but6 but7 but9 but11 b-ext with frame a1.
    end.
end.

on choose of but3 in frame a1 do:
    find first optitsec where optitsec.proc = "cs_data2" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'КРЕД.СКОРИНГ'! " view-as alert-box.
        undo, return.
    end.
    else do:
        hide frame a1.
        run cs_data2.
        enable but1 but2 but3 but4 but8 but5 but6 but7 but9 but11 b-ext with frame a1.
    end.
end.

on choose of but4 in frame a1 do:
   find first optitsec where optitsec.proc = "ekfundc" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'РЕШЕНИЕ О ФИНАНС.'! " view-as alert-box.
        undo, return.
    end.
    else run ekfundc.
end.

on choose of but8 in frame a1 do:
    find first optitsec where optitsec.proc = "eknewacc" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ОТКРЫТИЕ СЧЕТОВ'! " view-as alert-box.
        undo, return.
    end.
    else run eknewacc.
end.

on choose of but5 in frame a1 do:
    find first optitsec where optitsec.proc = "ekcrcont" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ДОГОВОРА'! " view-as alert-box.
        undo, return.
    end.
    else run ekcrcont.
end.

on choose of but6 in frame a1 do:
    find first optitsec where optitsec.proc = "ekzakl" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ЗАКЛЮЧЕНИЯ'! " view-as alert-box.
        undo, return.
    end.
    else run ekzakl.
end.

on choose of but7 in frame a1 do:
    find first optitsec where optitsec.proc = "ekprot" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ПРОТОКОЛА'! " view-as alert-box.
        undo, return.
    end.
    else run ekprot.
end.

on choose of but9 in frame a1 do:
    find first optitsec where optitsec.proc = "denial" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ОТКАЗ КЛИЕНТА'! " view-as alert-box.
        undo, return.
    end.
    else run denial.
end.

on choose of but11 in frame a1 do:
    find first optitsec where optitsec.proc = "ekdpog" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к пункту меню 'ДОСРОЧ.ПОГАШЕНЕ'! " view-as alert-box.
        undo, return.
    end.
    else run ekdpog.
    enable but1 but2 but3 but4 but8 but5 but6 but7 but9 but11 b-ext with frame a1.
end.

wait-for choose of b-ext or window-close of current-window.