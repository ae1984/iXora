/* lc750.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Ввод основных критериев (EXLC: Advice of discrepancy,IMLC: Authorisation to Pay...)
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
        31/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        13/10/2011 id00810 - для событий IMLC: Authorization to Reimburse (MT740),Amendment to an Authorization to Reimburse (MT747),
                             EXLC: Reimbursement Claim (MT742)
 */

{global.i}
{LC.i}
def temp-table t-lcevt no-undo like lceventh
    field showOrder    as int
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    index idx_sort showOrder.

def shared var s-lc       like lc.lc.
def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var s-lcprod   as char.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var v-lcdtexp  as date.
def shared var v-lcsumcur as deci.

def var v-crcname  as char no-undo.
def var v-crc      as int  no-undo.
def var v-lcsum    as deci no-undo.
def var v-sp       as char no-undo.
def var v-nf       as char no-undo.
def var v-accopt   as char no-undo.
def var v-accoptr  as char no-undo.
def var v-accoptb  as char no-undo.
def var v-chose    as logi no-undo.
def var v-errMsg   as char no-undo.
def var v-rekv     as char no-undo init 'PlcExp,Benef,PerAmt,MaxCrAmt,AdAmCov,AvlWith,By,DrfAt,Drawee,AppRule,MPayDet,DefPayD'.
def var v-rekv1    as char no-undo init 'BankRef,CreditN,DtIs,IssBank'.
{LCvalid.i}

def temp-table wrk no-undo
  field id  as int
  field txt as char
  index idx is primary id.

def var i as integer no-undo.

define query q_LC for t-lcevt.
def var v-rid as rowid.

if s-event = 'discr'    then v-nf = 'MT750'. else
if s-event = 'rclaim'   then v-nf = 'MT742'. else
if s-event = 'authr'    then v-nf = 'MT740'. else
if s-event = 'amdauthr' then v-nf = 'MT747'. else
                             v-nf = 'MT752'.

define browse b_evt query q_LC
       displ t-lcevt.dataName     format "x(37)"
             t-lcevt.dataValueVis format "x(65)"
             with 25 down overlay no-label title v-nf.
def button bsave label "SAVE".
def buffer b-lcevt    for t-lcevt.
def buffer b-lceventh for lceventh.
def buffer b-lcevent  for lcevent.
define frame f_evt b_evt help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

on "end-error" of frame f_evt do:
    if s-sts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_evt.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_lceventh
    t-lcevt.dataName format "x(37)"
    t-lcevt.value1   format "x(65)" validate(validh(t-lcevt.kritcode,t-lcevt.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.
define frame f1_lceventh
    t-lcevt.dataName format "x(37)"
    t-lcevt.value1   format "x(16)" validate(validh(t-lcevt.kritcode,t-lcevt.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

v-crc = 0.
find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and (lceventh.kritcode = 'AccBnkOp' or lceventh.kritcode = 'SCorrOp' or lceventh.kritcode = 'NBankOp') no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-accopt = lceventh.value1.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'RCorrOp' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-accoptr = lceventh.value1.

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'BenBnkOp' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-accoptb = lceventh.value1.

find first pksysc where pksysc.sysc = s-lcprod + '_' + s-event no-lock no-error.
if not avail pksysc then return.
v-sp = pksysc.chval.

empty temp-table t-lcevt.
i = 1.
do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-lcevt.
    assign
        t-lcevt.lc        = s-lc
        t-lcevt.event     = s-event
        t-lcevt.number    = s-number
        t-lcevt.kritcode  = LCkrit.dataCode
        t-lcevt.showOrder = i
        t-lcevt.dataName  = LCkrit.dataName
        t-lcevt.dataSpr   = LCkrit.dataSpr.

    if s-event = 'amdauthr' then do:
        if t-lcevt.kritcode = 'Date'   then t-lcevt.dataName = 'Date of the Original Authorization'.
        if t-lcevt.kritcode = 'Amount' then t-lcevt.dataName = 'Amount of the Original Authorization'.
    end.
    if s-event = 'rclaim' then do:
        if t-lcevt.kritcode = 'BankRef'   then t-lcevt.dataName = "Claiming Bank's Reference".
        if t-lcevt.kritcode = 'PrincAmt'  then t-lcevt.dataName = 'Principal Amount Claimed'.
        if t-lcevt.kritcode = 'AddAmt'    then t-lcevt.dataName = 'Additional Amount Claimed'.
    end.

    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = LCkrit.dataCode no-lock no-error.
    if avail lceventh then do:
        if lookup(t-lcevt.kritcode,'VDate,Date') > 0 and lookup(s-sts,'FIN,CLS,CNL') = 0 and s-event <> 'amdauthr' then t-lcevt.value1 = string(g-today,'99/99/9999').
        else buffer-copy lceventh except lceventh.lc to t-lcevt.
    end.
    else do:
        if lookup(t-lcevt.kritcode,'SendRef,CreditN') > 0 and s-event <> 'rclaim' then t-lcevt.value1 = s-lc.
        if lookup(t-lcevt.kritcode,'PrincCrc,AddCrc,lcCrc,TAmtCrc') > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then t-lcevt.value1 = lch.value1.
        end.
        if lookup(t-lcevt.kritcode,'TotAmtAd,Amount') > 0 then t-lcevt.value1 = string(v-lcsumcur).
        if lookup(t-lcevt.kritcode,'VDate,Date') > 0 then do:
            if s-event <> 'amdauthr' then t-lcevt.value1 = string(g-today,'99/99/9999').
            else do:
                find last b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = 'authr' no-lock no-error.
                if avail b-lcevent
                then find first b-lceventh where b-lceventh.lc = b-lcevent.lc and b-lceventh.event = b-lcevent.event and b-lceventh.number = b-lcevent.number and b-lceventh.kritcode = 'Date' no-lock no-error.
                if avail b-lceventh then t-lcevt.value1 = b-lceventh.value1.
            end.
        end.
        if (s-event = 'authr' or s-event = 'amdauthr') and lookup(t-lcevt.kritcode,v-rekv) > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = t-lcevt.kritcode no-lock no-error.
            if avail lch then t-lcevt.value1 = lch.value1.
        end.
        if s-event = 'rclaim' and lookup(t-lcevt.kritcode,v-rekv1) > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = t-lcevt.kritcode no-lock no-error.
            if avail lch then t-lcevt.value1 = lch.value1.
        end.
        if t-lcevt.kritcode = 'DtExp' then t-lcevt.value1 = string(v-lcdtexp,'99/99/9999').
        t-lcevt.bank = s-ourbank.
    end.

    if t-lcevt.kritcode = 'InstTo' and t-lcevt.value1 <> '' then do:
        find first swibic where swibic.bic = t-lcevt.value1 no-lock no-error.
        if avail swibic then t-lcevt.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    if lookup(t-lcevt.kritcode,'AccBnk,SCorr,NBank') > 0 and v-accopt = 'A'then do:
        find first swibic where swibic.bic = t-lcevt.value1 no-lock no-error.
        if avail swibic then t-lcevt.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    if t-lcevt.kritcode = 'RCorr' and v-accoptr = 'A'then do:
        find first swibic where swibic.bic = t-lcevt.value1 no-lock no-error.
        if avail swibic then t-lcevt.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.

    else t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode,t-lcevt.value1).

end.

on "enter" of b_evt in frame f_evt do:
    if s-sts <> 'NEW' then return.

    if avail t-lcevt then do:
        if lookup(t-lcevt.kritcode,'SendRef,CreditN,lcCrc,TonAmtAd,Amount,DtExp,NewAmt') > 0 then return.
        if (s-event = 'authr' or s-event = 'amdauthr') and lookup(t-lcevt.kritcode,'PlcExp,Benef,PerAmt,MaxCrAmt,AdAmCov,AvlWith,By,DrfAt,Drawee,MPayDet,DefPayD') > 0 then return.
        if s-event = 'amdauthr' and t-lcevt.kritcode = 'date' then return.

        b_evt:set-repositioned-row(b_evt:focused-row, "always").
        v-rid = rowid(t-lcevt).

        if lookup(t-lcevt.kritcode,'RRef,PrBnkRef,RBRef') > 0 then do:
            frame f2_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame f2_lceventh.
            update t-lcevt.value1 format 'x(16)' with frame f2_lceventh.
        end.
        if lookup(t-lcevt.kritcode,'AccIdent') > 0 then do:
            frame f1_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame f1_lceventh.
            update t-lcevt.value1 format 'x(35)' with frame f1_lceventh.
        end.
        if lookup(t-lcevt.kritcode,'AccBnkOp,SCorrOp,RCorrOp,NBankOp,BenBnkOp') > 0 then do:
            frame f2_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame f2_lceventh.
            update t-lcevt.value1 with frame f2_lceventh.
            if t-lcevt.kritcode = 'RCorrOp' then v-accoptr = t-lcevt.value1.
            else if t-lcevt.kritcode = 'BenBnkOp' then v-accoptb = t-lcevt.value1.
            else v-accopt = t-lcevt.value1.
            if (t-lcevt.kritcode = 'RCorrOp' and v-accoptr = 'A') or (t-lcevt.kritcode = 'BenBnkOp' and v-accoptb = 'A') or  (t-lcevt.kritcode <> 'RCorrOp' and t-lcevt.kritcode <> 'BenBnkOp' and v-accopt = 'A') then do:
               find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = substr(t-lcevt.kritcode,1,length(t-lcevt.kritcode) - 2) no-lock no-error.
               if avail b-lcevt and b-lcevt.value1 <> '' then do:
                  find first swibic where swibic.bic = b-lcevt.value1 no-lock no-error.
                  if not avail swibic then do:
                     find current b-lcevt exclusive-lock no-error.
                     b-lcevt.value1 = ''.
                     b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                     find current b-lcevt no-lock no-error.
                  end.
               end.
            end.
        end.

        if lookup(t-lcevt.kritcode,'AccBnk,SCorr,RCorr,NBank,BenBnk') > 0 then do:
            if (t-lcevt.kritcode = 'RCorr' and v-accoptr = 'A') or (t-lcevt.kritcode = 'BenBnk' and v-accoptb = 'A') or  (t-lcevt.kritcode <> 'RCorr'  and t-lcevt.kritcode <> 'BenBnk' and v-accopt = 'A') then do:
                frame f2_lceventh:row = b_evt:focused-row + 3.
                displ t-lcevt.dataName t-lcevt.value1 with frame f2_lceventh.
                update t-lcevt.value1 with frame f2_lceventh.
            end.
            if (t-lcevt.kritcode = 'RCorr' and v-accoptr = 'B') or  (t-lcevt.kritcode <> 'RCorr' and v-accopt = 'B') then do:
                frame f1_lceventh:row = b_evt:focused-row + 3.
                displ  t-lcevt.DataName t-lcevt.value1 with frame f1_lceventh.
                update t-lcevt.value1 format "x(35)" with frame f1_lceventh.
            end.
            if (t-lcevt.kritcode = 'RCorr' and v-accoptr = 'D') or (t-lcevt.kritcode = 'BenBnk' and v-accoptb = 'D') or  (t-lcevt.kritcode <> 'RCorr'  and t-lcevt.kritcode <> 'BenBnk' and v-accopt = 'D')  then do:
               {editor_update.i
                    &var    = "t-lcevt.value1"
                    &frame  = "fr4"
                    &framep = "column 36 row 5 overlay no-labels width 45. frame fr4:row = b_evt:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines  = "4"
                    &num_down  = "4"
               }
            end.
        end.

        if lookup(t-lcevt.kritcode,'SToRInf,ChargDed,ChargAdd,ChargesD,OthChr,Charges')> 0 then do:
            {editor_update.i
                &var    = "t-lcevt.value1"
                &frame  = "fr1"
                &framep = "column 42 row 5 overlay no-labels width 45. frame fr1:row = b_evt:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
             }
        end.
        if t-lcevt.kritcode = 'Discrep' then do:
            {editor_update.i
                &var    = "t-lcevt.value1"
                &frame  = "fr2"
                &framep = "column 42 row 5 overlay no-labels width 45. frame fr2:row = b_evt:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "40"
                &num_down  = "10"
             }
        end.
        if t-lcevt.kritcode = 'Narrat' then do:
            {editor_update.i
                &var    = "t-lcevt.value1"
                &frame  = "fr3"
                &framep = "column 42 row 15 overlay no-labels width 45. frame fr2:row = b_evt:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "20"
                &num_down  = "10"
             }
        end.

        if t-lcevt.kritcode = 'DecAmt' /*and t-lcevt.value1 <> ''*/ then do:
            frame f1_lceventh:row = b_evt:focused-row + 3.
            displ  t-lcevt.DataName t-lcevt.value1 with frame f1_lceventh.
            update t-lcevt.value1 with frame f1_lceventh.

             find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'IncAmt' no-lock no-error.
             if avail b-lcevt and trim(b-lcevt.value1) <> '' then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = ''.
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
            find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'NewAmt' no-lock no-error.
             if avail b-lcevt then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = string(v-lcsumcur - deci(t-lcevt.value1)).
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
        end.

        if t-lcevt.kritcode = 'IncAmt' then do:
            frame f1_lceventh:row = b_evt:focused-row + 3.
            displ  t-lcevt.DataName t-lcevt.value1 with frame f1_lceventh.
            update t-lcevt.value1 with frame f1_lceventh.
             find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'DecAmt' no-lock no-error.
             if avail b-lcevt and trim(b-lcevt.value1) <> '' then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = ''.
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
            find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'NewAmt' no-lock no-error.
             if avail b-lcevt then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = string(v-lcsumcur + deci(t-lcevt.value1)).
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
        end.

        if lookup(t-lcevt.kritcode,'SToRInf,ChargDed,ChargAdd,Discrep,RRef,AccBnk,AccBnkOp,SCorrOp,SCorr,RCorrOp,RCorr,ChargesD,OthChr,RBRef,AccIdent,DecAmt,IncAmt,Narrat,Charges,BenBnkOp,BenBnk') = 0 then do:
            frame f2_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame f2_lceventh.
            update t-lcevt.value1 with frame f2_lceventh.
        end.
        t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode, t-lcevt.value1).

        open query q_LC for each t-lcevt no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_evt:refresh().
    end.
end.
on help of t-lcevt.value1 in frame f2_lceventh do:

    if t-lcevt.kritcode = 'InstTo' or (lookup(t-lcevt.kritcode,'AccBnk,SCorr,NBank') > 0 and v-accopt = 'A') or (t-lcevt.kritcode = 'RCorr' and v-accoptr = 'A') or (t-lcevt.kritcode = 'BenBnk' and v-accoptb = 'A') then do:
        run swiftfind(output t-lcevt.value1).
        find first swibic where swibic.bic = t-lcevt.value1 no-lock no-error.
        if avail swibic then t-lcevt.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-lcevt.value1 with frame f2_lceventh.
    end.
    else do:
    find first LCkrit where LCkrit.dataCode = t-lcevt.kritcode  no-lock no-error.
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
            t-lcevt.value1 = codfr.code.
            t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode, t-lcevt.value1).
            displ t-lcevt.value1 with frame f2_lceventh.
        end.
    end.
    end.
end.

def var v-chkMess as char no-undo.
on choose of bsave in frame f_evt do:
    i = 0.
    for each t-lcevt no-lock:

        i = i + 1.
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = t-lcevt.kritcode exclusive-lock no-error.
        if not avail lceventh then create lceventh.

        buffer-copy t-lcevt to lceventh.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.
open query q_LC for each t-lcevt no-lock use-index idx_sort.

if s-sts = 'NEW' then enable all with frame f_evt.
else enable b_evt with frame f_evt.

wait-for window-close of current-window or choose of bsave.
