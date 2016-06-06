/*lcmessO799.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод основных критериев 799
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
        03/02/2011 evseev - взял за основу LCmain
 * BASES
        BANK COMM
 * CHANGES
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        13/05/2011 id00810 - для события Advise of amendment
        07/02/2012 id00810 - для EXSBLC
        05.03.2012 Lyubov  - передаем формат сообщения шареной переменной s-mt
*/
{global.i}
{LC.i}

def shared var s-lc      like lc.lc.
def shared var v-cif     as char.
def shared var s-lcprod  as char.
def shared var s-corsts  like lcswt.sts.
def shared var s-lccor   like lcswt.lccor.
def shared var s-lcamend like lcamend.lcamend.
def shared var s-mt      as int.
def var v-crc      as int.

{LCvalid.i}
def var i as integer no-undo.

def var v-str as char.
v-str = 'O' + string(s-mt) + '-'.

def temp-table t-LCmess no-undo like LCh
    field showOrder    as int
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    field num as int
    index idx_sort is primary num.

def temp-table wrk no-undo
  field id  as int
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmess.
def var v-rid as rowid.

define browse b_LC query q_LC
       displ t-LCmess.dataName     format "x(37)"
             t-LCmess.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MT " + string(s-mt) + " ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmess.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.

on "end-error" of frame f_LC do:
    if s-corsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else hide all no-pause.

    end.
    else hide all no-pause.

end.
define frame f2_LCh
    t-LCmess.dataName format "x(37)"
    t-LCmess.value1   format "x(65)" validate(validh(t-LCmess.kritcode,t-LCmess.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

if s-lcamend > 0 and lookup(s-lcprod,'exlc,expg,exsblc') > 0 then do:
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'AdvBy' no-lock no-error.
    if not avail lcamendh then return.
    if lcamendh.value1 <> '0' then return.
end.

empty temp-table t-LCmess.

find first pksysc where pksysc.sysc = 'outswt_criteria' no-lock no-error.
if avail pksysc then do:
 if num-entries(pksysc.chval) <= 0 then return.
end.
else return.

do i = 1 to num-entries(pksysc.chval):
/*for each LCkrit where LCkrit.LCtype = 'I' and LCkrit.priz = 'c' no-lock:*/
    find first LCkrit where LCkrit.showOrder = integer(entry(i, pksysc.chval)) no-lock no-error.
    create t-LCmess.
    t-LCmess.num = i.
    t-LCmess.LC = s-lc.
    t-LCmess.kritcode = LCkrit.dataCode.
    t-LCmess.showOrder = LCkrit.showOrder.
    t-LCmess.dataName = LCkrit.dataName.
    t-LCmess.dataSpr = LCkrit.dataSpr.
    t-LCmess.value4 = v-str + string(s-lccor,'999999').

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode and LCh.value4 = v-str + string(s-lccor,'999999') no-lock no-error.
    if avail LCh then do:
        /*if s-corsts = 'FIN' then*/ buffer-copy LCh except LCh.LC to t-LCmess.
    end.
    else do:
        if t-LCmess.kritcode = 'TRNum' then t-LCmess.value1 = s-lc.
        if s-lcprod = 'sblc' then do:
            if t-LCmess.kritcode = 'RREF' then t-LCmess.value1 = 'NON REF'.
            if t-LCmess.kritcode = 'AdvBank' then do:
                find first LCh where LCh.LC = s-lc and LCh.kritcode = 'Advbank' no-lock no-error.
                if avail lch then t-LCmess.value1 = LCh.value1.
            end.
        end.
        t-LCmess.bank = s-ourbank.
    end.

    if lookup(t-LCmess.kritcode,'AdvBank') > 0 and t-LCmess.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmess.value1 no-lock no-error.
        if avail swibic then t-LCmess.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else  t-LCmess.dataValueVis = getVisual(t-LCmess.kritcode,t-LCmess.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if s-corsts <> 'NEW' then return.

    if avail t-LCmess then do:
        if lookup(t-LCmess.kritcode,'TRNum') > 0 then return.
        if s-lcprod = 'sblc' and lookup(t-LCmess.kritcode,'RREF,AdvBank') > 0 then return.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmess).
        if  t-LCmess.kritcode = 'Narrat' then do:
            {editor_update.i
             &var    = "t-LCmess.value1"
             &frame  = "fr1"
             &framep = "column 42 row 5 overlay no-labels width 60. frame fr1:row = b_LC:focused-row + 2"
             &chars_in_line  = "50"
             &num_lines  = "35"
             &num_down  = "15"
            }
        end.

        if lookup(t-LCmess.kritcode,"RREF") <> 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
            update t-LCmess.value1 with frame f2_LCh.
        end.

        if lookup(t-LCmess.kritcode,'AdvBank') > 0 and t-LCmess.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCmess.value1 no-lock no-error.
            if avail swibic then t-LCmess.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCmess.dataValueVis = getVisual(t-LCmess.kritcode, t-LCmess.value1).

        if lookup(t-LCmess.kritcode,"AdvBank") <> 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
            update t-LCmess.value1 with frame f2_LCh.
        end.


        open query q_LC for each t-LCmess no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCmess.value1 in frame f2_LCh do:
    if lookup(t-LCmess.kritcode,'AdvBank') > 0 then do:
       run swiftfind(output t-LCmess.value1).

       find first swibic where swibic.bic = t-LCmess.value1 no-lock no-error.
       if avail swibic then t-LCmess.dataValueVis = swibic.bic + ' - ' + swibic.name.
       displ t-LCmess.value1 with frame f2_LCh.
    end.
end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_LC do:
    i = 0.
    for each t-LCmess no-lock:

        i = i + 1.
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCmess.kritcode and LCh.value4 = v-str + string(s-lccor,'999999') exclusive-lock no-error.
        if not avail LCh then create LCh.

        buffer-copy t-LCmess to LCh.
        find current LCh no-lock no-error.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmess no-lock use-index idx_sort.

if s-corsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.




