/* cor768.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод/редактирование полей МТ768
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

def shared var s-lc     like LC.LC.
def shared var v-cif    as char.
def shared var v-lcsts  as char.
def shared var s-lcprod as char.
def shared var s-fmt    as char.
def var v-crc    as int.
def var i        as int no-undo.
def var v-fname  as char.
def var v-logsno as char no-undo init "no,n,нет,н,1".

def var v-accopt as char no-undo.

find first lch where lch.lc = s-lc and lch.kritcod = 'mt768' no-lock no-error.
if avail lch and lch.value1 = 'no' then return.

{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmain.
def var v-rid as rowid.

v-fname = " MT768 ".

define browse b_LC query q_LC
       displ t-LCmain.dataName     format "x(37)"
             t-LCmain.dataValueVis format "x(65)"
             with 25 down overlay no-label title v-fname.
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmain.
def buffer b-lch    for lch.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose  as logi init yes.
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
    t-LCmain.dataName format "x(37)"
    t-LCmain.value1   format "x(65)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

find first pksysc where pksysc.sysc = 'ffc768' no-lock no-error.
if not avail pksysc then return.

find first lch where lch.lc = s-lc and lch.kritcode = 'AccBnkOp' no-lock no-error.
if avail lch and lch.value1 <> '' then v-accopt = lch.value1.

empty temp-table t-LCmain.
i = 1.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.

    create t-LCmain.
    assign
        t-LCmain.LC        = s-lc
        t-LCmain.kritcode  = LCkrit.dataCode
        t-LCmain.showOrder = i
        t-LCmain.dataName  = LCkrit.dataName
        t-LCmain.dataSpr   = LCkrit.dataSpr
        t-LCmain.bank      = s-ourbank.

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then buffer-copy LCh except LCh.LC to t-LCmain.

    if t-LCmain.kritcode = 'InsTo730' and t-LCmain.value1 = '' then do:
        find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'Sender' no-lock no-error.
        if avail b-lch then t-LCmain.value1 = b-lch.value1.
    end.
    if t-LCmain.kritcode = 'TRNum' then t-LCmain.dataName = 'Related Reference'.

    if t-LCmain.kritcode = 'BankRef' then t-LCmain.dataName = 'Transaction Reference Number'.

    if t-LCmain.kritcode = 'DtAdv' then t-LCmain.dataName = 'Date of Message being Acknowledged'.

    if t-LCmain.kritcode = 'InsTo730' and t-LCmain.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.

    if t-LCmain.kritcode = 'AccBnk' and v-accopt = 'A' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.

    else t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.
    if avail t-LCmain then do:
        if lookup(t-LCmain.kritcode,'SendRef,ReceRef,DtAdv') > 0 then return.
        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if lookup(t-LCmain.kritcode,'StoRI730,DetCharg') > 0 then do:
            {editor_update.i
                &var    = "t-LCmain.value1"
                &frame  = "fr1"
                &framep = "column 42 row 5 overlay no-labels width 45 . frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.

        if t-LCmain.kritcode = "AccBnkOp" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
            v-accopt = t-LCmain.value1.
            t-LCmain.dataValueVis = t-LCmain.value1.
        end.

        if t-LCmain.kritcode = "AccBnk" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
            /*t-LCmain.dataValueVis = t-LCmain.value1.*/
            if v-accopt = 'A' then do:
                find first swibic where swibic.bic begins t-LCmain.value1 no-lock no-error.
                if not avail swibic then do:
                    message ' Incorrect BIC ' view-as alert-box.
                    t-LCmain.value1 = ''.
                end.
                t-LCmain.dataValueVis = t-LCmain.value1.
            end.
        end.

        if t-LCmain.kritcode = "AccIdent" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 format 'x(35)' with frame f2_LCh.
            t-LCmain.dataValueVis = t-LCmain.value1.
        end.

        if t-LCmain.kritcode = "AmtChaC" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
            find first crc where crc.crc = int(t-LCmain.value1) no-lock no-error.
            t-LCmain.dataValueVis = t-LCmain.value1 + ' - ' + crc.code.
        end.

        if t-LCmain.kritcode = "AmtChaA" then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
            t-LCmain.value1 = trim(replace (t-LCmain.value1,'.',',')).
            t-LCmain.dataValueVis = t-LCmain.value1.
        end.

        else t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).

        open query q_LC for each t-LCmain no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCmain.value1 in frame f2_LCh do:

    if t-LCmain.kritcode = 'InsTo730' then do:
        run swiftfind(output t-LCmain.value1).
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-LCmain.value1 with frame f2_LCh.
    end.

    if t-LCmain.kritcode = 'AccBnk' and v-accopt = 'A' then do:
        run swiftfind(output t-LCmain.value1).
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-LCmain.value1 with frame f2_LCh.
    end.

    if lookup(t-LCmain.kritcode, 'AmtChaC,AccBnkOp') > 0 then do:
       find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &set = "codfr"
                    &file = "codfr"
                    &frame = "row 7 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' "
                    &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                    &chkey = "code"
                    &index  = "cdco_idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
                t-LCmain.value1 = codfr.code.
                t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).
                displ t-LCmain.value1 with frame f2_LCh.
            end.
        end.
    end.

end.

def var v-chkMess as char no-undo.
on choose of bsave in frame f_LC do:
    i = 0.
    for each t-LCmain no-lock:

        i = i + 1.
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCmain.kritcode exclusive-lock no-error.
        if not avail LCh then create LCh.

        buffer-copy t-LCmain to LCh.

        find first lcswt where lcswt.lc = s-lc and lcswt.ref = s-lc and lcswt.mt = 'I768' no-lock no-error.
        if not avail lcswt then do:
            create lcswt.
            assign lcswt.lc     = s-lc
                   lcswt.LCtype = 'E'
                   lcswt.ref    = s-lc
                   lcswt.sts    = 'NEW'
                   lcswt.mt     = 'I768'
                   lcswt.fname2 = 'I768' + replace(trim(s-lc),'/','-') + '_' + '00000'
                   lcswt.rdt    = g-today
                   lcswt.LCcor  = 0.
        end.

        find current LCh no-lock no-error.

    end.
    if i > 0 then message " Saved!!! " view-as alert-box information.

    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmain no-lock use-index idx_sort.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.