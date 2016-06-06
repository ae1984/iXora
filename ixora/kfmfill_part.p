/* kfmfill_part.p
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
*/

{global.i}

{kfm.i}

def input parameter p-operId as integer no-undo.

define query q_prt for t-kfmprt.
def var v-rid as rowid.
def var v-rid2 as rowid.
def buffer bt-kfmprt for t-kfmprt.
def var v-partId as integer no-undo.
def var choice as logi no-undo.

def var v-chkErr as logi no-undo init no.
def var v-chkMess as char no-undo.

define browse b_prt query q_prt
       displ t-kfmprt.partId label "nn" format ">>9"
             t-kfmprt.partName label "ФИО/Наименование" format "x(98)"
             with 28 down overlay no-label title " Участники операции ".

define button partb label "Завершение ввода".
define frame f_prt b_prt help "<Enter>-Ред. <Ins>-Новый <Del>-Удалить <F4>-Выход с потерей измен." skip partb with width 110 row 3 /*overlay*/ no-box.

define frame f2_prt
    t-kfmprt.partId format ">>9"
    t-kfmprt.partName format "x(98)" validate(trim(t-kfmprt.partName) <> '', "Введите данные для идентификации участника!")
    with width 104 no-label overlay column 4 no-box.

function getPrtCount returns integer.
    def var res as integer no-undo.
    def buffer bb for t-kfmprt.
    res = 0.
    for each bb where bb.bank = s-ourbank and bb.operId = p-operId no-lock:
        res = res + 1.
    end.
    return res.
end function.

on "enter" of b_prt in frame f_prt do:
    if avail t-kfmprt then do:
        b_prt:set-repositioned-row(b_prt:focused-row, "always").
        v-rid = rowid(t-kfmprt).
        frame f2_prt:row = b_prt:focused-row + 5.
        displ t-kfmprt.partId t-kfmprt.partName with frame f2_prt.
        update t-kfmprt.partName with frame f2_prt.

        frame f_prt:visible = no.
        run kfmfill_part1(t-kfmprt.operId,t-kfmprt.partId).
        frame f_prt:visible = yes.

        open query q_prt for each t-kfmprt where t-kfmprt.bank = s-ourbank and t-kfmprt.operId = p-operId no-lock.
        reposition q_prt to rowid v-rid no-error.
        b_prt:refresh().
    end.
end.

on "insert" of b_prt in frame f_prt do:
    b_prt:set-repositioned-row(b_prt:focused-row, "always").
    find last t-kfmprt no-lock no-error.
    if avail t-kfmprt then v-partId = t-kfmprt.partId + 1.
    else v-partId = 1.
    create t-kfmprt.
    assign t-kfmprt.bank = s-ourbank
           t-kfmprt.operId = p-operId
           t-kfmprt.partId = v-partId
           t-kfmprt.partName = ''.
    v-rid = rowid(t-kfmprt).
    open query q_prt for each t-kfmprt where t-kfmprt.bank = s-ourbank and t-kfmprt.operId = p-operId no-lock.
    reposition q_prt to rowid v-rid no-error.
    b_prt:refresh().

    /* изменим записанное в признаке opNumPrt количество участников */
    find first t-kfmoperh where t-kfmoperh.bank = s-ourbank and t-kfmoperh.operId = p-operId and t-kfmoperh.dataCode = "opNumPrt" no-error.
    if avail t-kfmoperh then assign t-kfmoperh.dataValue = string(getPrtCount()) t-kfmoperh.dataValueVis = t-kfmoperh.dataValue.

    /* создадим набор признаков участника */
    for each kfmkrit where kfmkrit.priz = 1 no-lock:
        create t-kfmprth.
        assign t-kfmprth.bank = s-ourbank
               t-kfmprth.operId = p-operId
               t-kfmprth.partId = v-partId
               t-kfmprth.dataCode = kfmkrit.dataCode
               t-kfmprth.dataValue = ''
               t-kfmprth.dataValueVis = ''
               t-kfmprth.dataAdd = ''
               t-kfmprth.showOrder = kfmkrit.showOrder
               t-kfmprth.dataName = kfmkrit.dataName
               t-kfmprth.dataSpr = kfmkrit.dataSpr.
    end.

    apply "enter" to b_prt in frame f_prt.
end.

on "delete-character" of b_prt in frame f_prt do:
    if avail t-kfmprt then do:
        choice = no.
        message skip "Вы уверены, что хотите удалить участника из данных по операции?~n" + t-kfmprt.partName skip(1) view-as alert-box question buttons yes-no
                      title "Подтверждение" update choice.
        if choice then do:
            v-rid = ?.
            v-rid2 = rowid(t-kfmprt).
            b_prt:set-repositioned-row(b_prt:focused-row, "always").
            get next q_prt.
            if not avail t-kfmprt then get last q_prt.
            if avail t-kfmprt then v-rid = rowid(t-kfmprt).
            find first bt-kfmprt where rowid(bt-kfmprt) = v-rid2 exclusive-lock.
            if avail bt-kfmprt then do:
                for each t-kfmprth where t-kfmprth.bank = s-ourbank and t-kfmprth.operId = bt-kfmprt.operId and t-kfmprth.partId = bt-kfmprt.partId:
                    delete t-kfmprth.
                end.
                delete bt-kfmprt.
            end.
            open query q_prt for each t-kfmprt where t-kfmprt.bank = s-ourbank and t-kfmprt.operId = p-operId no-lock.
            if v-rid <> ? then reposition q_prt to rowid v-rid no-error.
            find first bt-kfmprt where bt-kfmprt.bank = s-ourbank and bt-kfmprt.operId = p-operId no-lock no-error.
            if avail bt-kfmprt then b_prt:refresh().

            /* изменим записанное в признаке opNumPrt количество участников */
            find first t-kfmoperh where t-kfmoperh.bank = s-ourbank and t-kfmoperh.operId = p-operId and t-kfmoperh.dataCode = "opNumPrt" no-error.
            if avail t-kfmoperh then assign t-kfmoperh.dataValue = string(getPrtCount()) t-kfmoperh.dataValueVis = t-kfmoperh.dataValue.
        end.
    end.
end.

on choose of partb in frame f_prt do:
    run kfm_fm1Chk(input s-ourbank, input p-operId, output v-chkErr, output v-chkMess).
    if v-chkErr then message v-chkMess view-as alert-box error.
    else do:
        frame f_prt:visible = no.
        kfmres = yes.
    end.
end.

open query q_prt for each t-kfmprt where t-kfmprt.bank = s-ourbank and t-kfmprt.operId = p-operId no-lock.
enable all with frame f_prt.

repeat:
    wait-for choose of partb in frame f_prt.
    if not (v-chkErr) then leave.
end.




