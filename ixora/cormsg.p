/*cormsg.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Ввод основных критериев корреспонденции MT 799
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
{LC.i}

def shared var s-lc      like lc.lc.
def shared var s-lcprod  as char.
def shared var s-lctype  as char.
def shared var s-lccor   like lcswt.lccor.
def shared var v-lcsts   as char.
def var v-krit    as char.
def var v-crc     as int.
def var v-cif     as char.

{LCvalid.i}
def var i as integer no-undo.

def var v-str as char.
v-str = 'O799-'.

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

def buffer b-lch for lch.

define browse b_LC query q_LC
       displ t-LCmess.dataName     format "x(37)"
             t-LCmess.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MT 799 ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmess.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.

on "end-error" of frame f_LC do:
    if v-lcsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_LCh
    t-LCmess.dataName format "x(37)"
    t-LCmess.value1   format "x(35)" validate(validh(t-LCmess.kritcode,t-LCmess.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCmess.

find first pksysc where pksysc.sysc = 'outswt_criteria' no-lock no-error.
if avail pksysc then do:
    if num-entries(pksysc.chval) <= 0 then return.
    else do:
        if s-lctype = 'E' then v-krit = '141,96,64,56'.
        else v-krit = pksysc.chval.
    end.
end.
else return.

do i = 1 to num-entries(v-krit):
    find first LCkrit where LCkrit.showOrder = integer(entry(i, v-krit)) no-lock no-error.
    create t-LCmess.
    assign t-LCmess.num = i
           t-LCmess.LC = s-lc
           t-LCmess.kritcode = LCkrit.dataCode
           t-LCmess.showOrder = LCkrit.showOrder
           t-LCmess.dataName = LCkrit.dataName
           t-LCmess.dataSpr = LCkrit.dataSpr.
           if s-lctype eq 'I' then t-LCmess.value4 = v-str + string(s-lccor,'999999').
           t-LCmess.bank = s-ourbank.

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then buffer-copy LCh except LCh.LC to t-LCmess.

    if t-LCmess.kritcode = 'AdvBank' and t-LCmess.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmess.value1 no-lock no-error.
        if avail swibic then t-LCmess.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.

    if t-LCmess.kritcode = 'TRNum' then do:
        if s-lctype = 'E' then do:
            t-LCmess.dataName = 'Related Reference'.
            find first lch where lch.lc = s-lc and lch.kritcod = t-LCmess.kritcode no-lock no-error.
            if avail lch then t-LCmess.value1 = lch.value1.
        end.

        else t-LCmess.value1 = s-lc.
    end.

    if t-LCmess.kritcode = 'BankRef' then do:
        t-LCmess.dataName = 'Transaction Reference Number'.
        t-LCmess.value1 = s-lc.
    end.
    t-LCmess.dataValueVis = getVisual(t-LCmess.kritcode,t-LCmess.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.

    if avail t-LCmess then do:
        /*if lookup(t-LCmess.kritcode,'TRNum') > 0 then return.*/

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

        if t-LCmess.kritcode = "RREF" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
            update t-LCmess.value1 with frame f2_LCh.
        end.

        if s-lctype = 'E' then do:
            if t-LCmess.kritcode = "TRNum" then do:
                frame f2_LCh:row = b_LC:focused-row + 3.
                displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
                update t-LCmess.value1 with frame f2_LCh.
            end.
        end.

        if t-LCmess.kritcode = "AdvBank" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
            update t-LCmess.value1 with frame f2_LCh.
        end.

        t-LCmess.dataValueVis = getVisual(t-LCmess.kritcode, t-LCmess.value1).

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
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCmess.kritcode /*and LCh.value4 = v-str + string(s-lccor,'999999')*/ exclusive-lock no-error.
        if not avail LCh then create LCh.
        buffer-copy t-LCmess to LCh.
        find first lcswt where lcswt.lc = s-lc and lcswt.ref = s-lc no-lock no-error.
        if not avail lcswt then do:
            create lcswt.
            assign lcswt.lc     = s-lc
                   lcswt.LCtype = s-lctype
                   lcswt.ref    = s-lc
                   lcswt.sts    = 'NEW'
                   lcswt.mt     = 'I799'
                   lcswt.fname2 = 'I799' + replace(trim(s-lc),'/','-') + '_' + string(s-lccor,'99999')
                   lcswt.rdt    = g-today
                   lcswt.LCcor  = 0.
        end.
        find current LCh no-lock no-error.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmess no-lock use-index idx_sort.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.