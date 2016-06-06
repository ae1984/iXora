/* kfmfill_operh.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Вывод формы ФМ-1 менеджеру для заполнения
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        31.03.2010 galina - явно указала ширину фрейма xf
        16/07/2010 galina - не редактируем признаки подозрительности для операций фин.мониторинга
        20/07/2010 galina - добавила переменную s-operType
*/

{global.i}

{kfm.i}
{kfmValid.i}

define query q_operh for t-kfmoperh.
def var v-rid as rowid.

define browse b_operh query q_operh
       displ t-kfmoperh.dataName label "Поле" format "x(32)"
             t-kfmoperh.dataValueVis label "Значение" format "x(70)"
             with 28 down overlay no-label title " Данные по операции ".

define button operb label "Перейти к редактированию участников".
define frame f_operh b_operh help "<Enter>-Редакт. <F2>- Справ. <F4>-Выход с потерей изменений" skip operb with width 110 row 3 /*overlay*/ no-box.

{adres.f}

def var v-errMsg as char no-undo init "Введено некорректное значение или значение отсутствует в справочнике!".

define frame f2_operh
    t-kfmoperh.dataName format "x(32)"
    t-kfmoperh.dataValue format "x(70)" validate(validh(t-kfmoperh.dataCode,t-kfmoperh.dataValue, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


on "enter" of b_operh in frame f_operh do:
    if avail t-kfmoperh then do:
        if lookup(t-kfmoperh.dataCode,"fm1Num,fm1Date,opId") > 0 then return.
        if lookup(t-kfmoperh.dataCode,"msgReas2,opSus1,opSus2,opSus3,opSusDes") > 0 and s-operType <> 'su'then return.

        b_operh:set-repositioned-row(b_operh:focused-row, "always").
        v-rid = rowid(t-kfmoperh).
        if t-kfmoperh.dataCode = "subjAddr" then do:
            v-adres = t-kfmoperh.dataValue.
            assign v-country2 = ''
                   v-region = ''
                   v-city = ''
                   v-street = ''
                   v-house = ''
                   v-office = ''
                   v-index = ''
                   v-title = t-kfmoperh.dataName.
            {adres.i}
            t-kfmoperh.dataValue = v-adres.
        end.
        else do:
            frame f2_operh:row = b_operh:focused-row + 5.
            displ t-kfmoperh.dataName t-kfmoperh.dataValue with frame f2_operh.
            update t-kfmoperh.dataValue with frame f2_operh.
        end.

        t-kfmoperh.dataValueVis = getVisual(t-kfmoperh.dataCode, t-kfmoperh.dataValue).

        open query q_operh for each t-kfmoperh no-lock.
        reposition q_operh to rowid v-rid no-error.
        b_operh:refresh().
    end.
end.

on help of t-kfmoperh.dataValue in frame f2_operh do:
    find first kfmkrit where kfmkrit.dataCode = t-kfmoperh.dataCode no-lock no-error.
    if avail kfmkrit and trim(kfmkrit.dataSpr) <> '' then do:
        find first codfr where codfr.codfr = trim(kfmkrit.dataSpr) no-lock no-error.
        if avail codfr then do:
            {itemlist.i
                &file = "codfr"
                &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                &where = " codfr.codfr = trim(kfmkrit.dataSpr) "
                &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
                &chkey = "code"
                &index  = "cdco_idx"
                &end = "if keyfunction(lastkey) = 'end-error' then return."
            }
            t-kfmoperh.dataValue = codfr.code.
            /*t-kfmoperh.dataValueVis = getVisual(t-kfmoperh.dataCode, t-kfmoperh.dataValue).*/
            displ t-kfmoperh.dataValue with frame f2_operh.
        end.
    end.
end.

on choose of operb in frame f_operh do:
    kfmres = yes.
end.

open query q_operh for each t-kfmoperh no-lock use-index idx_sort.
enable all with frame f_operh.

wait-for choose of operb.



