/*dcmain.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC - ввод основных критериев
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-1-1 опция Main
 * AUTHOR
        29/12/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        08/02/2012 id00810 - для ODC
 */

{global.i}
{LC.i}

def shared var s-lc       like lc.lc.
def shared var v-cif      as char.
def shared var v-lcsts    as char.
def shared var v-lcsumcur as deci.
def shared var v-lcsumorg as deci.
def shared var v-lccrc1   as char.
def shared var v-lccrc2   as char.
def shared var v-lcdtexp  as date.
def shared var s-lcprod   as char.
def var v-crcname  as char no-undo.
def var v-crc      as int  no-undo.
def var v-sp       as char no-undo.
def var i          as int  no-undo.
def var v-chose    as logi no-undo.
def var v-errMsg   as char no-undo.
def var v-amt      as deci no-undo.
def var v-by       as char no-undo.
def var v-dt       as date no-undo.
def var v-num      as int  no-undo.
def var v-docs     as char no-undo.
{LCvalid.i}

def temp-table wrk no-undo
  field id  as int
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmain.
def var v-rid as rowid.

define browse b_LC query q_LC
       displ t-LCmain.dataName     format "x(37)"
             t-LCmain.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MAIN ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmain.
def buffer b-lch for lch.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 no-box.

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
    t-LCmain.value1   format "x(35)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame fd-lch
    t-lcmain.dataName format "x(37)"
    v-dt              format "99/99/9999" validate(validh(t-lcmain.kritcode,t-lcmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame fr-lch
    t-lcmain.dataName format "x(37)"
    v-amt             format "zzz,zzz,zzz,zz9.99" validate(validh(t-lcmain.kritcode,t-lcmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame fi-lch
    t-lcmain.dataName format "x(37)"
    v-amt             format "zzz,zzz,zzz,zz9" validate(validh(t-lcmain.kritcode,t-lcmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and lch.value1 <> '' then v-crc = int(lch.value1).

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'Amount' no-lock no-error.
if avail lch and lch.value1 <> '' then v-amt = deci(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'by' no-lock no-error.
if avail lch and lch.value1 <> '' then v-by = lch.value1.

find first pksysc where pksysc.sysc = s-lcprod no-lock no-error.
if not avail pksysc then return.
v-sp = pksysc.chval.

empty temp-table t-LCmain.

do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCmain.
    assign t-LCmain.LC        = s-lc
           t-LCmain.kritcode  = LCkrit.dataCode
           t-LCmain.showOrder = i
           t-LCmain.dataName  = LCkrit.dataName
           t-LCmain.dataSpr   = LCkrit.dataSpr
           t-LCmain.bank      = s-ourbank.
    if t-LCmain.kritcode = 'DtExp' then t-LCmain.dataname = 'Expiry/Value Date'.

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then do:
        if t-LCmain.kritcode = 'DtAdv' and lookup(v-lcsts,'FIN,CLS,CNL') = 0 then t-LCmain.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCh except LCh.LC to t-LCmain.
    end.
    else do:
        if t-LCmain.kritcode = 'DtAdv'  then t-LCmain.value1 = string(g-today,'99/99/9999').
        if t-LCmain.kritcode = 'TRNum'  then t-LCmain.value1 = s-lc.
        if t-LCmain.kritcode = 'ClCode' then t-LCmain.value1 = v-cif.
        if t-LCmain.kritcode = 'MT410'  then t-LCmain.value1 = 'YES'.
    end.
    if t-LCmain.kritcode = 'Docs'  and t-LCmain.value1 = '' then do:
        find first codific where codific.codfr = 'lcdocs' no-lock no-error.
        if avail codific then
        for each codfr where codfr.codfr = codific.codfr no-lock:
            v-docs = v-docs + string(codfr.name[1],'x(55)').
        end.
    end.
    if t-LCmain.kritcode = 'RemBank' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else  t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
    if s-lcprod = 'odc' then do:
        if t-LCmain.kritcode = 'RemBank' then t-LCmain.dataname = 'To institution'.
        if t-LCmain.kritcode = 'DtAdv'   then t-LCmain.dataname = 'Create date'.
        if t-LCmain.kritcode = 'ClCode'  then t-LCmain.dataname = 'Principal Code'.
        if t-LCmain.kritcode = 'ComAcc'  then t-LCmain.dataname = "Drawer's Account".
        if t-LCmain.kritcode = 'Client'  then t-LCmain.dataname = "Drawee".
    end.
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:
        if t-LCmain.kritcode ='TRNum' then return.
        if t-LCmain.kritcode ='Tenor' and v-by = '4' then return.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if  lookup(t-LCmain.kritcode,'Client,Drawer') > 0 then do:
            {editor_update.i
                &var            = "t-LCmain.value1"
                &frame          = "fr1"
                &framep         = "column 42 row 5 overlay no-labels width 45. frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines      = "4"
                &num_down       = "4"
            }
        end.

        if t-LCmain.kritcode = 'Docs' then do:
           if t-LCmain.value1 = '' then t-LCmain.value1 = v-docs.
           {editor_update.i
                &var            = "t-LCmain.value1"
                &frame          = "fr2"
                &framep         = "column 42 row 5 overlay no-labels width 65. frame fr2:row = b_LC:focused-row + 2"
                &chars_in_line  = "55"
                &num_lines      = "15"
                &num_down       = "15"
            }
        end.

        if t-LCmain.kritcode = 'StoRInf' then do:
           {editor_update.i
                &var            = "t-LCmain.value1"
                &frame          = "fr3"
                &framep         = "column 42 row 5 overlay no-labels width 45. frame fr3:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines      = "6"
                &num_down       = "6"
            }
        end.

        if t-LCmain.kritcode = 'By' then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ  t-LCmain.DataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
            v-by = t-LCmain.value1.
            if v-by ne '1' and v-by ne '4' then do:
               message 'Incorrect value!' view-as alert-box error.
               t-lcmain.value1 = ''.
               t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).
               return.
            end.
            if v-by = '4' then do:
                find first b-LCmain where b-LCmain.kritcode = 'Tenor' exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'ComAcc' then do:
            find first aaa where aaa.aaa = trim(t-LCmain.value1) no-lock no-error.
            if avail aaa then do:
                find first b-LCmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
                if avail  b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = string(aaa.crc).
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-lcmain.kritcode = 'DtAdv' or t-lcmain.kritcode = 'DtExp' then do:
            v-dt = date(t-lcmain.value1).
            frame fd-lch:row = b_lc:focused-row + 3.
            displ t-lcmain.dataName v-dt with frame fd-lch.
            update v-dt  with frame fd-lch.
            t-lcmain.value1 = string(v-dt,'99/99/9999').
        end.
        else if t-lcmain.kritcode = 'Amount' then do:
            v-amt = deci(t-lcmain.value1).
            frame fr-lch:row = b_lc:focused-row + 3.
            displ t-lcmain.dataName v-amt with frame fr-lch.
            update v-amt with frame fr-lch.
            t-lcmain.value1 = string(v-amt).
        end.
        else if t-lcmain.kritcode = 'Number' then do:
            v-num = int(t-lcmain.value1).
            frame fi-lch:row = b_lc:focused-row + 3.
            displ t-lcmain.dataName v-num with frame fi-lch.
            update v-num with frame fi-lch.
            t-lcmain.value1 = string(v-num).
        end.

        else if lookup(t-LCmain.kritcode,"Client,Drawer,Docs,StoRInf") = 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
        end.

        if t-LCmain.kritcode = 'RemBank' then do:
            find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
            if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).

        open query q_LC for each t-LCmain no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
end.

on help of t-LCmain.value1 in frame f2_LCh do:
    if t-LCmain.kritcode = 'RemBank' then do:
            run swiftfind(output t-LCmain.value1).

            find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
            if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
            displ t-LCmain.value1 with frame f2_LCh.

    end.
    if t-LCmain.kritcode = 'ComAcc' then do:
        {itemlist.i
         &set = "acc"
         &file = "aaa"
         &findadd = "find first crc where crc.crc = aaa.crc no-lock no-error. v-crcname = ''. if avail crc then v-crcname = crc.code. "
         &frame = "row 6 centered scroll 1 20 down width 40 overlay "
         &where = " aaa.cif = v-cif and aaa.sta <> 'C' and substr(string(aaa.gl),1,4) = '2203' "
         &flddisp = " aaa.aaa label 'Account' format 'x(20)' v-crcname label 'Currency' "
         &chkey = "aaa"
         &index  = "aaa-idx1"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCmain.value1 = aaa.aaa.
         displ t-LCmain.value1 with frame f2_LCh.

    end.

     if lookup(t-LCmain.kritcode,'Drawee,ComAcc,RemBank') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode and LCkrit.LCtype = 'I' /*and LCkrit.priz = v-priz*/ no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &set = "1"
                    &file = "codfr"
                    &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' and can-do(if codfr.codfr = 'lcby' then '1,4' else '*',codfr.code) "
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
        find current LCh no-lock no-error.
        if lch.kritcode = 'Amount' and trim(lch.value1) <> ''
        then assign v-lcsumcur = deci(lch.value1)
                    v-lcsumorg = deci(lch.value1).
        if lch.kritcode = 'DtExp' and lch.value1 <> ?
        then v-lcdtexp = date(lch.value1).
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmain no-lock.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.
