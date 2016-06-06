/*advrchkd.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advice of Refusal
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
        18/03/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
*/
{global.i}
{LC.i}

def shared var s-lc like LC.LC.
def shared var v-cif as char.
def shared var v-cifname as char.
def shared var v-lcsts as char.
def shared var v-lcsumcur as deci.
def shared var v-lcsumorg as deci.
def shared var v-lccrc1 as char.
def shared var v-lccrc2 as char.
def shared var v-lcdtexp as date.

def shared var s-sts like lcevent.sts.
def shared var s-number like lcevent.number.
def shared var s-event like lcevent.event.

def var v-crcname as char.
def var v-crc as int.
def var count_crit as int.
def var v-dt1 as date.

def var v-TotAmtClO734 as char.

{LCvalid.i}
def var i as integer no-undo.

def temp-table t-LCevent no-undo like LCeventh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    field num as int
    index idx_sort is primary num.

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCevent.
def var v-rid as rowid.

define browse b_LC query q_LC
       displ t-LCevent.dataName  format "x(37)"
             t-LCevent.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MAIN ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCevent.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.

on "end-error" of frame f_LC do:
    if s-sts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else hide all no-pause.

    end.
    else hide all no-pause.

end.
define frame f2_LCh
    t-LCevent.dataName format "x(37)"
    t-LCevent.value1 format "x(65)" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


empty temp-table t-LCevent.
v-TotAmtClO734 = ''.

find first pksysc where pksysc.sysc = 'AdvR734' no-lock no-error.
if avail pksysc then do:
 if num-entries(pksysc.chval) <= 0 then return.
end.
else return.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.dataCode = entry(i, pksysc.chval) no-lock no-error.
    create t-LCevent.
    t-LCevent.num = i.
    t-LCevent.LC = s-lc.
    t-LCevent.kritcode = LCkrit.dataCode.
    t-LCevent.showOrder = LCkrit.showOrder.
    t-LCevent.dataName = LCkrit.dataName.
    t-LCevent.dataSpr = LCkrit.dataSpr.
    t-LCevent.number = s-number.
    t-LCevent.event = s-event.
    find first LCeventh where LCeventh.LC = s-lc and LCeventh.kritcode = LCkrit.dataCode and LCeventh.number = s-number no-lock no-error.
    if avail LCeventh then do:
        /*if s-corsts = 'FIN' then*/
        buffer-copy LCeventh except LCeventh.LC to t-LCevent.
    end.
    else do:
        if t-LCevent.kritcode = 'SendTRN734' then t-LCevent.value1 = s-lc.
        if t-LCevent.kritcode = 'DtUtil734' or t-LCevent.kritcode = 'DtTtAmtCl734' then t-LCevent.value1 = string(g-today,'99/99/9999').
        t-LCevent.bank = s-ourbank.
    end.

    if lookup(t-LCevent.kritcode,'AccWBnkB734,InstTo734') > 0 and t-LCevent.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
        if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else  t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode,t-LCevent.value1).
end.


on "enter" of b_LC in frame f_LC do:
    if s-sts <> 'NEW' then return.

    if avail t-LCevent then do:
        if lookup(t-LCevent.kritcode,'SendTRN734') > 0 then return.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCevent).

        if lookup(t-LCevent.kritcode,'AccWBnkA734') > 0 then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.

            /*
            find first aaa where aaa.aaa = trim(t-LCevent.value1) no-lock no-error.
            if not avail aaa then do:
               message "Account not found!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               t-LCevent.value1 = ''.
            end.*/
        end.






        if lookup(t-LCevent.kritcode,'DtUtil734,DtTtAmtCl734') > 0 then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.

            v-dt1 = date(t-LCevent.value1) no-error.
            if error-status:error then do:
               t-LCevent.value1 = ''.
               message "Error date format!" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            end.

        end.

        if  lookup(t-LCevent.kritcode,'ChCl734,S2RInf734') > 0 then do:
            if t-LCevent.value1 = '' then t-LCevent.value1 = '//'.
            {editor_update.i
                &var    = "t-LCevent.value1"
                &frame  = "fr1"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr1:row = b_lc:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.
        if  lookup(t-LCevent.kritcode,'Disc734') > 0 then do:
            {editor_update.i
                &var    = "t-LCevent.value1"
                &frame  = "fr2"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr2:row = b_lc:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "40"
                &num_down  = "15"
            }
        end.
/*
        if  lookup(t-LCevent.kritcode,'DisOfDoc734') > 0 then do:
            if t-LCevent.value1 = '' then t-LCevent.value1 = '//'.
            {editor_update.i
                &var    = "t-LCevent.value1"
                &frame  = "fr3"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr3:row = b_lc:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "3"
                &num_down  = "3"
            }
        end.
*/
        if lookup(t-LCevent.kritcode,'DisOfDoc734') > 0 then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
        end.


/*
        if lookup(t-LCmess.kritcode,"RREF") <> 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmess.dataName t-LCmess.value1 with frame f2_LCh.
            update t-LCmess.value1 with frame f2_LCh.
        end.
*/


        if t-LCevent.kritcode = 'TotAmtClO734' then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
            /*if t-LCevent.value1 = 'B' then t-LCevent.value1 = 'D'.*/
            /*v-TotAmtClO734 = t-LCevent.value1.*/

             /*
            if v-TotAmtClO734 = 'A' then do:
               find first b-lcmain where b-lcmain.LC = s-lc and b-lcmain.kritcode = 'BenIns' and b-lcmain.number = s-number no-lock no-error.
               if avail b-lcmain and b-lcmain.value1 <> '' then do:

               end.
            end.
            */
        end.

        if lookup(t-LCevent.kritcode,'CurUtil734,CurTtAmtCl734') > 0 then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
        end.

        if lookup(t-LCevent.kritcode,'AmtUtil734,TtAmtCl734') > 0 then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
        end.


        if t-LCevent.kritcode = 'PrBnkRef734' then do:
            frame f2_LCh:row = b_lc:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
        end.

        if lookup(t-LCevent.kritcode,"AccWBnkB734,InstTo734") <> 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCh.
            update t-LCevent.value1 with frame f2_LCh.
        end.

        if lookup(t-LCevent.kritcode,'AccWBnkB734,InstTo734') > 0 and t-LCevent.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
            if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).



        open query q_LC for each t-LCevent no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCevent.value1 in frame f2_LCh do:
    if lookup(t-LCevent.kritcode,'TotAmtClO734,CurUtil734,CurTtAmtCl734,DisOfDoc734') > 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCevent.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &file = "codfr"
                    &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' "
                    &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                    &chkey = "code"
                    &index  = "cdco_idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
                t-LCevent.value1 = codfr.code.
                t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).
                displ t-LCevent.value1 with frame f2_LCh.
            end.
        end.
    end.

    if lookup(t-LCevent.kritcode,'AccWBnkB734,InstTo734') > 0 then do:
       run swiftfind(output t-LCevent.value1).

       find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
       if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
       displ t-LCevent.value1 with frame f2_LCh.
    end.
end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_LC do:
    i = 0.
    for each t-LCevent no-lock:

        i = i + 1.
        find first LCeventh where LCeventh.LC = s-lc and LCeventh.kritcode = t-LCevent.kritcode and LCeventh.number = s-number exclusive-lock no-error.
        if not avail LCeventh then create LCeventh.

        buffer-copy t-LCevent to LCeventh.
        find current LCeventh no-lock no-error.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCevent no-lock use-index idx_sort.

if s-sts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.




