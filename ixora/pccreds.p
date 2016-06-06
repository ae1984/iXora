/* pccreds.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Карточка клиента по кредитным лимитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        22.06.2013 Lyubov - доп к ТЗ № 1752
*/

/*{er.i}*/
{global.i}

def new shared var v-aaa      as char no-undo.
def new shared var s-credtype as char init '4' no-undo.
def new shared var v-bank     as char no-undo.
def new shared var v-cifcod   as char no-undo.
def new shared var s-ln       as inte no-undo.
def new shared var v-cls      as logi no-undo init no.

def var v-select  as inte no-undo.
def var v-select1 as inte no-undo.

def var i as int.
def var v-access as logi init no.

define button but10   label "АНКЕТА".
define button but11   label "АНКЕТА".
define button but1    label "РАЗМЕР ЗП/РАСЧЕТ КЛ".
define button but2    label "ОТЧЕТ ГЦВП И КБ".
define button but3    label "КРЕД.СКОРИНГ".
define button but4    label "РАСЧЕТ ГЭСВ".
define button but5    label "РЕШЕНИЕ О ФИНАНС.".
define button but6    label "КД/ДОП.СОГЛ. к КД".
define button but7    label "ЗАЯВЛЕНИЯ".
define button b-ext   label "ВЫХОД".

define frame a1
    but10 but1 but2 but3 but4 but5 but6 but7 b-ext
    with width 110 side-labels row 3 no-box.

define button but8   label "КОНТРОЛЬ КРЕДИТА".
define button but9   label "КОНТРОЛЬ ДПК".

define frame a2
    but11 but8 but9 b-ext
    with width 110 side-labels row 3 no-box.


ON CHOOSE OF b-ext IN FRAME a1 do:
    apply "window-close" to CURRENT-WINDOW.
end.

ON CHOOSE OF b-ext IN FRAME a2 do:
    apply "window-close" to CURRENT-WINDOW.
end.

{chbin.i}
{chk12_innbin.i}


run sel2 ("Выберите :", " 1. Установление/изменение кред. лимита | 2. Закрытие кредитного лимита | 3. Выход ", output v-select).
case v-select:
    when 1 then v-cls = no.
    when 2 then  v-cls = yes.
    when 3 then return.
end.

if not v-cls then enable but10 b-ext with frame a1.
else enable but11 b-ext with frame a2.

on choose of but10 in frame a1 do:
    find first optitsec where optitsec.proc = "pcanket" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'АНКЕТА'! " view-as alert-box.
        undo, return.
    end.
    else do:
        run pcanket.
        enable but1 but2 but3 but4 but5 but6 but7 b-ext with frame a1.
    end.
end.

on choose of but1 in frame a1 do:
    find first optitsec where optitsec.proc = "pccrlim" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'РАЗМЕР ЗП/РАСЧЕТ КЛ'! " view-as alert-box.
        undo, return.
    end.
    else run pccrlim.
end.

on choose of but2 in frame a1 do:
    find first optitsec where optitsec.proc = "pcquery" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'ОТЧЕТ ГЦВП И КБ'! " view-as alert-box.
        undo, return.
    end.
    else do:
        hide frame a1.
        run pcquery.
        enable but1 but2 but3 but4 but5 but6 but7 b-ext with frame a1.
    end.
end.

on choose of but3 in frame a1 do:
    find first optitsec where optitsec.proc = "cs_data1" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'КРЕД.СКОРИНГ'! " view-as alert-box.
        undo, return.
    end.
    else do:
        hide frame a1.
        run cs_data1.
        enable but1 but2 but3 but4 but5 but6 but7 b-ext with frame a1.
    end.
end.

on choose of but4 in frame a1 do:
    find first optitsec where optitsec.proc = "pcGES" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'РАСЧЕТ ГЭСВ'! " view-as alert-box.
        undo, return.
    end.
    else run pcGES.
end.

on choose of but5 in frame a1 do:
    find first optitsec where optitsec.proc = "pcfundc" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'РЕШЕНИЕ О ФИНАНС.'! " view-as alert-box.
        undo, return.
    end.
    else run pcfundc.
end.

on choose of but6 in frame a1 do:
    find first optitsec where optitsec.proc = "pccrcont" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'КД/ДОП.СОГЛ. к КД'! " view-as alert-box.
        undo, return.
    end.
    else run pccrcont.
end.

on choose of but7 in frame a1 do:
    find first optitsec where optitsec.proc = "pcreques" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'ЗАЯВЛЕНИЯ'! " view-as alert-box.
        undo, return.
    end.
    else run pcreques.
end.

on choose of but11 in frame a2 do:
    find first optitsec where optitsec.proc = "pcanket" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'АНКЕТА'! " view-as alert-box.
        undo, return.
    end.
    else do:
        run pcanket.
        enable but11 but8 but9 b-ext with frame a2.
    end.
end.

on choose of but8 in frame a2 do:
    find first optitsec where optitsec.proc = "pcconcr" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'КОНТРОЛЬ КРЕДИТА'! " view-as alert-box.
        undo, return.
    end.
    else run pcconcr.
    enable but11 but8 but9 b-ext with frame a2.
end.

on choose of but9 in frame a2 do:
    find first optitsec where optitsec.proc = "pcconfin" no-lock no-error.
    if not avail optitsec or lookup(g-ofc,optitsec.ofcs) = 0 then do :
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        do i = 1 to num-entries(ofc.expr[1],','):
            if can-do(optitsec.ofcs,entry(i,ofc.expr[1],',')) then v-access = yes.
        end.
    end.
    else v-access = yes.
    if not v-access then do:
        message " Нет доступа к меню 'КОНТРОЛЬ ДПК'! " view-as alert-box.
        undo, return.
    end.
    else run pcconfin.
    enable but11 but8 but9 b-ext with frame a2.
end.

wait-for window-close of current-window.
