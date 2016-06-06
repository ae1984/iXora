/*dcpmain.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: ввод критериев платежа
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
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
{LC.i}

def shared var s-lc      like lc.lc.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.
def shared var s-paysts  like lcpay.sts.
def shared var s-lcpay   like lcpay.lcpay.

def var v-crc      as int  no-undo.
def var v-collacc  as char no-undo.
def var v-lcsum    as deci no-undo.
def var i          as int  no-undo.
def var v-crcname  as char no-undo.
def var v-dt       as date no-undo.
def var v-amt      as deci no-undo.
def var v-opt      as char no-undo.
def var v-optA     as logi no-undo.
def var v-chose    as logi no-undo init yes.
def var v-errMsg   as char no-undo.
def var v-accopt   as char no-undo.
def var v-benopt   as char no-undo.
def var v-ordopt   as char no-undo.
def var v-scorropt as char no-undo.
def var v-rcorropt as char no-undo.
def var v-scopt    as char no-undo.

def buffer b-pksysc for pksysc.

{LCvalid.i}
def temp-table wrk no-undo
  field id  as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCpay.
def var v-rid as rowid.

define browse b_pay query q_LC
       displ t-LCpay.dataName     format "x(37)"
             t-LCpay.dataValueVis format "x(65)"
             with 32 down overlay no-label title " PAY ".
def button bsave label "SAVE".

define frame f_pay b_pay help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 no-box.

on "end-error" of frame f_pay do:
    if s-paysts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_pay.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_LCpayh
    t-LCpay.dataName format "x(37)"
    t-LCpay.value1 format "x(35)" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f1_LCpayh
    t-LCpay.dataName format "x(37)"
    t-LCpay.value1 format "x(16)" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame fd-lch
    t-LCpay.dataName format "x(37)"
    v-dt             format "99/99/9999" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.
define frame fr-lch
    t-LCpay.dataName format "x(37)"
    v-amt            format "zzz,zzz,zzz,zz9.99" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCpay.
assign v-collacc = ''
       v-accopt = ''
       v-benopt  = ''
       v-crc     = 0.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'ActBnkOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-accopt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'BenBnkOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-benopt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'OrdBnkOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-ordopt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'SCorrOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-scorropt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'RCorrOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-rcorropt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'PAmt' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-lcsum = deci(LCpayh.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).

find first pksysc where pksysc.sysc = s-lcprod + '_pay' no-lock no-error.
if not avail pksysc then return.

i = 1.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCpay.
    assign t-LCpay.LC       = s-lc
           t-LCpay.LCpay    = s-lcpay
           t-LCpay.kritcode = LCkrit.dataCode.
    assign t-LCpay.showOrder = i
           t-LCpay.dataName  = LCkrit.dataName
           t-LCpay.dataSpr   = LCkrit.dataSpr
           t-LCpay.bank      = s-ourbank.
    if t-LCpay.kritcode = 'ClCode'  and s-lcprod = 'odc' then t-LCpay.dataname = "Drawer's Code".
    if t-LCpay.kritcode = 'CollAcc' then t-LCpay.dataname = if s-lcprod = 'odc' then "Drawer's Account"            else "Document Account".
    if t-LCpay.kritcode = 'ComAcc'  then t-LCpay.dataname = if s-lcprod = 'odc' then "Drawer's Commission Account" else "Commission Account".
    if t-LCpay.kritcode = 'PAmt'    then t-LCpay.dataname = if s-lcprod = 'odc' then "Amount"                      else "Amount Collected".
    if t-LCpay.kritcode = 'SCor202' then t-LCpay.dataname = "Correspondent Bank".
    find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCpayh then do:
        if t-LCpay.kritcode = 'VDate' and s-paysts <> 'FIN' and s-paysts <> 'PAY' then t-LCpay.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCpayh except LCpayh.LC to t-LCpay.
    end.
    else do:
        if t-LCpay.kritcode = 'LCamt' then do:
             find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
             if avail lch and trim(lch.value1) <> '' then  t-LCpay.value1 = lch.value1.
        end.

        if t-LCpay.kritcode = 'VDate'  then t-LCpay.value1 = string(g-today,'99/99/9999').
        if t-LCpay.kritcode = 'KOD'    then t-LCpay.value1 = '14'.
        if t-LCpay.kritcode = 'KBE'    then t-LCpay.value1 = if v-crc = 1 then '14' else '24'.
        if t-LCpay.kritcode = 'TRNum'  then t-LCpay.value1 = caps(s-lc).
        if t-LCpay.kritcode = 'Numpay' then t-LCpay.value1 = string(s-lcpay,'99').
        if t-LCpay.kritcode = 'MT400'  then t-LCpay.value1 = 'YES'.
        if lookup(t-LCpay.kritcode,'ClCode,Drawer,ComAcc,Number,RemBank,Client') > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = t-LCpay.kritcode no-lock no-error.
            if avail lch then t-LCpay.value1 = lch.value1.
        end.
        if t-LCpay.kritcode = 'CurCode' then t-LCpay.value1 = string(v-crc).
    end.

    if t-LCpay.kritcode = 'PAmt' then do:
         if v-lcsum = 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
            if avail lch and trim(lch.value1) <> '' then v-lcsum = deci(lch.value1).
         end.
         t-LCpay.value1 = string(v-lcsum).
    end.
    v-optA = no.
    case t-LCpay.kritcode:
        when 'OrdBnk' then if v-ordopt   = 'A'  then v-optA = yes.
        when 'SCorr'  then if v-scorropt = 'A'  then v-optA = yes.
        when 'RCorr'  then if v-rcorropt = 'A'  then v-optA = yes.
        when 'ActBnk' then if v-accopt   = 'A'  then v-optA = yes.
        when 'BenBnk' then if v-benopt   = 'A'  then v-optA = yes.
    end case.
    if v-optA then do:
        find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
        if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode,t-LCpay.value1).
end.

on help of t-LCpay.value1 in frame f2_LCpayh do:
    if lookup(t-LCpay.kritcode,'OrdBnk,SCorr,RCorr,ActBnk,BenBnk') > 0 then do:
        if t-LCpay.kritcode = 'OrdBnk' and v-ordopt   = 'A' then v-optA = yes. else
        if t-LCpay.kritcode = 'SCorr'  and v-scorropt = 'A' then v-optA = yes. else
        if t-LCpay.kritcode = 'RCorr'  and v-rcorropt = 'A' then v-optA = yes. else
        if t-LCpay.kritcode = 'ActBnk' and v-accopt   = 'A' then v-optA = yes. else
        if t-LCpay.kritcode = 'BenBnk' and v-benopt   = 'A' then v-optA = yes.
        if v-optA then do:
            run swiftfind(output t-LCpay.value1).
            find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
            if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        displ t-LCpay.value1 with frame f2_LCpayh.
    end.
    if t-LCpay.kritcode = 'SCor202' then do:
            {itemlist.i
            &file    = "LCswtacc"
            &set     = "fr2"
            &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
            &where   = " LCswtacc.crc = v-crc and LCswtacc.swift <> ''"
            &flddisp = " LCswtacc.accout label 'Account' format 'x(20)' LCswtacc.bnkname label 'Name' format 'x(50)' "
            &chkey   = "accout"
            &index   = "crc"
            &end     = "if keyfunction(lastkey) = 'end-error' then return."
            }
            t-LCpay.value1 = LCswtacc.accout.
            find first LCswtacc where LCswtacc.accout = t-LCpay.value1 no-lock no-error.
            if avail LCswtacc then t-LCpay.dataValueVis = t-LCpay.value1.
            displ t-LCpay.value1 with frame f2_LCpayh.
    end.
    if lookup(t-LCpay.kritcode,'CollAcc') > 0 then do:
        {itemlist.i
         &set     = "acc"
         &file    = "aaa"
         &findadd = "find first crc where crc.crc = aaa.crc no-lock no-error. v-crcname = ''. if avail crc then v-crcname = crc.code. "
         &frame   = "row 6 centered scroll 1 20 down width 40 overlay "
         &where   = " aaa.cif = v-cif and aaa.sta <> 'C' and substr(string(aaa.gl),1,4) = '2203' and aaa.crc = v-crc "
         &flddisp = " aaa.aaa label 'Account' format 'x(20)' v-crcname label 'Currency' "
         &chkey   = "aaa"
         &index   = "aaa-idx1"
         &end     = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCpay.value1 = aaa.aaa.
         displ t-LCpay.value1 with frame f2_LCpayh.
    end.
    if lookup(t-LCpay.kritcode,'CollAcc,SCor202,OrdBnk,SCorr,RCorr,ActBnk,BenBnk') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCpay.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &file    = "codfr"
                    &frame   = "row 6 centered scroll 1 20 down width 91 overlay "
                    &where   = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' "
                    &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                    &chkey   = "code"
                    &index   = "cdco_idx"
                    &end     = "if keyfunction(lastkey) = 'end-error' then return."
                }
                t-LCpay.value1 = codfr.code.
                t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode, t-LCpay.value1).
                displ t-LCpay.value1 with frame f2_LCpayh.
            end.
        end.
    end.
end.

on "enter" of b_pay in frame f_pay do:
    if s-paysts <> 'NEW' then return.

    if avail t-LCpay then do:
        if lookup(t-LCpay.kritcode,'TRNum,ClCode,Drawer,ComAcc,CurCode,VDate,Number,RemBank,Client,KOD,KBE') > 0 then return.
        b_pay:set-repositioned-row(b_pay:focused-row, "always").
        v-rid = rowid(t-LCpay).

        if lookup(t-LCpay.kritcode,'StoRInf,DetCharg,DetAmtAd') > 0 then do:
            {editor_update.i
                &var            = "t-LCpay.value1"
                &frame          = "fr1"
                &framep         = "column 42 row 5 overlay no-labels width 45. frame fr1:row = b_pay:focused-row + 1"
                &chars_in_line  = "35"
                &num_lines      = "6"
                &num_down       = "6"
            }
        end.

        if t-LCpay.kritcode = 'MatDt' then do:
            v-dt = date(t-LCpay.value1).
            frame fd-lch:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName v-dt with frame fd-lch.
            update v-dt  with frame fd-lch.
            t-LCpay.value1 = string(v-dt,'99/99/9999').
        end.
        if can-do('PAmt,AmtRem,ComAmtI,ComAmtE',t-LCpay.kritcode) then do:
            v-amt = deci(t-LCpay.value1).
            frame fr-lch:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName v-amt with frame fr-lch.
            update v-amt with frame fr-lch.
            t-LCpay.value1 = string(v-amt).
        end.

        if t-LCpay.kritcode = 'RRef' then do:
            frame f1_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f1_LCpayh.
            update t-LCpay.value1 format 'x(16)' with frame f1_LCpayh.
        end.

        if lookup(t-LCpay.kritcode,"RRef,MatDt,PAmt,AmtRem,ComAmtI,ComAmtE,OrdBnk,SCorr,RCorr,BenBnk") = 0 then do:
            frame f2_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
            update t-LCpay.value1 with frame f2_LCpayh.
        end.

        if can-do('OrdBnkOp,SCorrOp,RCorrOp,ActBnkOp,BenBnkOp',t-LCpay.kritcode) then do:
            frame f1_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f1_LCpayh.
            update t-LCpay.value1 with frame f1_LCpayh.
            t-LCpay.value1 = caps(t-LCpay.value1).
            v-optA = if t-LCpay.value1 = 'A' then yes else no.
            if v-optA then do:
               find first b-LCpay where b-LCpay.LC = s-lc and b-LCpay.kritcode = replace(t-LCpay.kritcode,'Op','') no-lock no-error.
               if avail b-LCpay and b-LCpay.value1 <> '' then do:
                  find first swibic where swibic.bic = b-LCpay.value1 no-lock no-error.
                  if not avail swibic then do:
                     find current b-LCpay exclusive-lock no-error.
                     b-LCpay.value1 = ''.
                     b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                     find current b-LCpay no-lock no-error.
                  end.
               end.
            end.
            if t-LCpay.kritcode = 'OrdBnkOp' then v-ordopt   = t-LCpay.value1. else
            if t-LCpay.kritcode = 'SCorrop'  then v-scorropt = t-LCpay.value1. else
            if t-LCpay.kritcode = 'RCorrOp'  then v-rcorropt = t-LCpay.value1. else
            if t-LCpay.kritcode = 'ActBnkOp' then v-accopt   = t-LCpay.value1. else
                                                  v-benopt   = t-LCpay.value1.
        end.

        if can-do('OrdBnk,SCorr,RCorr,ActBnk,BenBnk',t-LCpay.kritcode) then do:
            if t-LCpay.kritcode = 'OrdBnk' then v-opt = v-ordopt.   else
            if t-LCpay.kritcode = 'SCorr'  then v-opt = v-scorropt. else
            if t-LCpay.kritcode = 'RCorr'  then v-opt = v-rcorropt. else
            if t-LCpay.kritcode = 'ActBnk' then v-opt = v-accopt.   else
                                                v-opt = v-benopt.
            if v-opt = 'A' then do:
                frame f2_LCpayh:row = b_pay:focused-row + 3.
                displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
                update t-LCpay.value1 with frame f2_LCpayh.
            end.
            if v-opt = 'B' then do:
                frame f1_LCpayh:row = b_pay:focused-row + 3.
                displ  t-LCpay.DataName t-LCpay.value1 with frame f1_LCpayh.
                update t-LCpay.value1 format "x(35)" with frame f1_LCpayh.
            end.
            if v-opt = 'D' then do:
               {editor_update.i
                    &var            = "t-LCpay.value1"
                    &frame          = "fr4"
                    &framep         = "column 42 row 5 overlay no-labels width 45. frame fr4:row = b_pay:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines      = "4"
                    &num_down       = "4"
               }
            end.
        end.

        if (lookup(t-LCpay.kritcode,'InsTo756,RCor,Intermid,InsTo202,SCor756') > 0
        or (t-LCpay.kritcode = 'ActBnk' and v-accopt = 'A') or (t-LCpay.kritcode = 'BenIns' and v-benopt = 'A'))
        and t-LCpay.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
            if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode, t-LCpay.value1).

        open query q_LC for each t-LCpay no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_pay:refresh().
    end.
end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_pay do:
    i = 0.
    for each t-LCpay no-lock:
        i = i + 1.
        find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = t-LCpay.kritcode exclusive-lock no-error.
        if not avail LCpayh then create LCpayh.

        buffer-copy t-LCpay to LCpayh.
        find current LCpayh no-lock no-error.

    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCpay no-lock use-index idx_sort.

if s-paysts = 'NEW' then enable all with frame f_pay.
else enable b_pay with frame f_pay.

wait-for window-close of current-window or choose of bsave.

