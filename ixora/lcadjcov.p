/*lcadjcov.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Adjust - Cover Transfer/Maintain Charges - ввод критериев
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
        12/07/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        19/08/2011 id00810 - создание реквизита ArpAcc (lceventh)
        06/09/2011 id00810 - для EXPG
        14/12/2011 id00810 - для случая crc = 1
        29/03/2012 id00810 - некорректно отображались реквизиты AccType, AccNum, заполненные ранее
        06/06/2012 Lyubov  - изменения по ТЗ, AccType выбирается по F2, в зависимости от выбора подтягивается AccNum
        06.08.2012 Lyubov  - если появилось покрытия - счет определяем из lcamendh
 */

{global.i}
{LC.i}

def shared var s-lc      like lc.lc.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.
def shared var s-event   like lcevent.event.
def shared var s-number  like lcevent.number.
def shared var s-sts     like lcevent.sts.
def var v-crc     as int  no-undo.
def var v-crcold  as int  no-undo.
def var v-arp     as char no-undo.
def var v-lcsum   as deci no-undo.
def var v-opt     as char no-undo.
def var v-title   as char no-undo.
def var i         as int  no-undo.
def var v-chose   as logi no-undo init yes.
def var v-errMsg  as char no-undo.
def var v-accopt  as char no-undo.
def var v-benopt  as char no-undo.
def var v-acctype as char no-undo.
def var v-collacc as char no-undo.
def var v-yes     as logi no-undo.
def buffer b-pksysc for pksysc.

{LCvalid.i}
def temp-table t-LCevent no-undo like LCeventh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def buffer b-LCevent for t-LCevent.

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCevent.
def var v-rid as rowid.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch and lch.value2 = '' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'CollACC' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
end.
else if lch.value2 = '0' then do:
    find first lcamendh where lcamendh.lc = s-lc and lcamendh.kritcode = 'CollACC' no-lock no-error.
    if avail lch then v-collacc = lch.value1.
end.

find first LCeventh where LCeventh.LC = s-lc and LCeventh.event = s-event  and lceventh.number = s-number and LCeventh.kritcode = 'Opt' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then assign v-opt = LCeventh.value1 v-title = if lceventh.value1 = 'yes' then ' Cover Transfer ' else ' Maintain Charges '.

define browse b_event query q_LC
       displ t-LCevent.dataName  format "x(37)"
             t-LCevent.dataValueVis format "x(65)"
             with 32 down overlay no-label title v-title.
def button bsave label "SAVE".

define frame f_event b_event help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

on "end-error" of frame f_event do:
    if s-sts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_event.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_LCeventh
    t-LCevent.dataName format "x(37)"
    t-LCevent.value1 format "x(65)" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f1_LCeventh
    t-LCevent.dataName format "x(37)"
    t-LCevent.value1 format "x(16)" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f3_LCeventh
    t-LCevent.dataName format "x(37)"
    t-LCevent.value1 format "x(50)" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCevent.
assign v-accopt = ''
       v-benopt = ''
       v-crc    = 0
       v-arp    = ''.

if v-opt = 'yes'then do:
    find first LCeventh where LCeventh.LC = s-lc and LCeventh.event = s-event  and lceventh.number = s-number and LCeventh.kritcode = 'AccType' no-lock no-error.
    if avail LCeventh and LCeventh.value1 <> '' then v-acctype = LCeventh.value1.

    find first LCeventh where LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'AccInsOp' no-lock no-error.
    if avail LCeventh and LCeventh.value1 <> '' then v-accopt = LCeventh.value1.

    find first LCeventh where LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'BenInsOp' no-lock no-error.
    if avail LCeventh and LCeventh.value1 <> '' then v-benopt = LCeventh.value1.
end.

find first LCeventh where LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'CurCode' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-crc = int(lceventh.value1).
else do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
    if avail lch and lch.value1 <> '' then v-crc = int(lch.value1).
end.
v-crcold = v-crc.

if v-opt = 'yes' then do:
    if v-crc = 1 then find first pksysc where pksysc.sysc = 'lc_adjust1' no-lock no-error.
    else find first pksysc where pksysc.sysc = 'lc_adjust' no-lock no-error.
end.
else find first pksysc where pksysc.sysc = 'lc_adjustch' no-lock no-error.

if not avail pksysc then return.

if v-crc = 1 then v-benopt = 'A'.

i = 1.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCevent.
    t-LCevent.LC = s-lc.
    t-LCevent.event = s-event.
    t-LCevent.number = s-number.
    t-LCevent.kritcode = LCkrit.dataCode.
    assign t-LCevent.showOrder = i /*LCkrit.showOrder*/
           t-LCevent.dataName  = LCkrit.dataName
           t-LCevent.dataSpr   = LCkrit.dataSpr
           t-LCevent.bank      = s-ourbank.
    if t-LCevent.kritcode = 'BenIns' and v-crc = 1 then t-LCevent.dataname = 'Beneficiary Institution'.
    if v-opt = 'no' then do:
        if t-LCevent.kritcode = 'SCor202' then t-LCevent.dataname = if v-crc = 1 then 'Tranzit Account' else 'Correspondent Bank'.
        if t-LCevent.kritcode = 'PAmt'    then t-LCevent.dataname = 'Amount'.
    end.
    find first LCeventh where LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number and LCeventh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCeventh then do:
        if t-LCevent.kritcode = 'VDate' and s-sts <> 'FIN' then t-LCevent.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCeventh except LCeventh.LC to t-LCevent.
    end.
    else do:
        if t-LCevent.kritcode = 'VDate' then t-LCevent.value1 = string(g-today,'99/99/9999').
        if t-LCevent.kritcode = 'KOD'   then t-LCevent.value1 = '14'.
        if t-LCevent.kritcode = 'KBE'   then t-LCevent.value1 = if v-crc = 1 then '14' else '24'.
        if t-LCevent.kritcode = 'KNP'   then t-LCevent.value1 = if s-lcprod = 'pg' then '182' else '181'.
        if t-LCevent.kritcode = 'TRNum' then t-LCevent.value1 = caps(s-lc).

        if t-LCevent.kritcode = 'Benpay' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.
        if t-LCevent.kritcode = 'ClCode' then do:
            if s-lcprod = 'imlc' then find first lch where lch.lc = s-lc and lch.kritcode = 'ApplCode' no-lock no-error.
            else if s-lcprod = 'pg' then find first lch where lch.lc = s-lc and lch.kritcode = 'PrCode' no-lock no-error.
            else if s-lcprod = 'expg' then find first lch where lch.lc = s-lc and lch.kritcode = 'BenCode' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.
        if t-LCevent.kritcode = 'Client' then do:
            if s-lcprod = 'imlc' then find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            else if s-lcprod = 'pg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
            else if s-lcprod = 'expg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.

        if t-LCevent.kritcode = 'CurCode' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.
        if t-LCevent.kritcode = 'PTax'  then t-LCevent.value1 = 'NO'.
        if t-LCevent.kritcode = 'MT202' then t-LCevent.value1 = if v-crc = 1 then 'NO' else 'YES'.
        if t-LCevent.kritcode = 'SCor202' and v-crc = 1 then do:
            find first b-pksysc where b-pksysc.sysc = 'lc_adj_acc' no-lock no-error.
            if avail b-pksysc then t-LCevent.value1 = b-pksysc.chval.
        end.
    end.

    case t-LCevent.kritcode:

        when 'AccIns' then do:
            if v-accopt = 'A' then do:
                find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
                if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
            end.
            if t-LCevent.kritcode = 'AccIns' and v-accopt <> 'A' then t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode,t-LCevent.value1).
        end.

        when 'BenIns' then do:
            if v-benopt = 'A' then do:
                if v-crc > 1 then do:
                    find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
                    if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
                end.
                else do:
                    find first bankl where bankl.bank = t-LCevent.value1 no-lock no-error.
                    if avail bankl then t-LCevent.dataValueVis = bankl.bank + ' - ' + bankl.name.
                end.
            end.
            else t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode,t-LCevent.value1).
        end.

        otherwise t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode,t-LCevent.value1).
    end case.
end.

on help of t-LCevent.value1 in frame f2_LCeventh do:
    if lookup(t-LCevent.kritcode,'Intermid,AccIns') > 0 then do:
        if t-LCevent.kritcode <> 'AccIns' or (t-LCevent.kritcode = 'AccIns' and v-accopt = 'A') then do:
            run swiftfind(output t-LCevent.value1).

            find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
            if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        displ t-LCevent.value1 with frame f2_LCeventh.
    end.

    if t-LCevent.kritcode = 'BenIns' then do:
        if v-benopt = 'A' then do:
            if v-crc > 1 then do:
                run swiftfind(output t-LCevent.value1).
                find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
                if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
            end.
            else do:
                run h_bnk(output t-LCevent.value1).
                find first bankl where bankl.bank = t-LCevent.value1 no-lock no-error.
                if avail bankl then t-LCevent.dataValueVis = bankl.bank + ' - ' + bankl.name.
            end.
            displ t-LCevent.value1 with frame f2_LCeventh.
        end.
    end.

    if lookup(t-LCevent.kritcode,'InsTo202') > 0 then do:
        {itemlist.i
            &file = "LCswtacc"
            &set = "fr1"
            &frame = "row 6 centered scroll 1 20 down width 91 overlay "
            &where = " LCswtacc.crc = v-crc and LCswtacc.swift <> '' "
            &flddisp = " LCswtacc.swift label 'Swift' format 'x(11)' LCswtacc.bnkname label 'Name' format 'x(50)' "
            &chkey = "swift"
            &index  = "crc"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
            }
            t-LCevent.value1 = LCswtacc.swift.

            find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
            if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
            displ t-LCevent.value1 with frame f2_LCeventh.
    end.

    if lookup(t-LCevent.kritcode,'SCor202') > 0 then do:
        if v-crc > 1 then do:
        {itemlist.i
            &file = "LCswtacc"
            &set = "fr2"
            &frame = "row 6 centered scroll 1 20 down width 91 overlay "
            &where = " LCswtacc.crc = v-crc and LCswtacc.swift <> '' "
            &flddisp = " LCswtacc.accout label 'Account' format 'x(20)' LCswtacc.bnkname label 'Name' format 'x(50)' "
            &chkey = "accout"
            &index  = "crc"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
            }
            t-LCevent.value1 = LCswtacc.accout.
            find first LCswtacc where LCswtacc.accout = t-LCevent.value1 no-lock no-error.
            if avail LCswtacc then t-LCevent.dataValueVis = t-LCevent.value1.
            displ t-LCevent.value1 with frame f2_LCeventh.
        end.
    end.

    if t-LCevent.kritcode = 'AccType' then do:
        find first LCkrit where LCkrit.dataCode = t-LCevent.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                if s-lcprod = 'PG' then do:
                {itemlist.i
                    &file = "codfr"
                    &set = "fr3"
                    &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' and lookup(codfr.code,'8,12') > 0 "
                    &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                    &chkey = "code"
                    &index  = "cdco_idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
                end.
                else do:
                {itemlist.i
                    &file = "codfr"
                    &set = "fr4"
                    &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' and lookup(codfr.code,'5,9') > 0 "
                    &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                    &chkey = "code"
                    &index  = "cdco_idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
                end.
                t-LCevent.value1 = codfr.code.
                t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).
                displ t-LCevent.value1 with frame f2_LCeventh.
            end.
        end.
    end.

    if lookup(t-LCevent.kritcode,'SCor202,Intermid,AccIns,BenIns,InsTo202,AccType') = 0 then do:
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
                displ t-LCevent.value1 with frame f2_LCeventh.
            end.
        end.
    end.
end.

on "enter" of b_event in frame f_event do:
    if s-sts <> 'NEW' then return.
    if avail t-LCevent then do:
        if lookup(t-LCevent.kritcode,'PTax,AmtTax,TRNum,ClCode,Client,KOD,KBe,KNP,BenPay,AccNum') > 0 then return.
        if t-LCevent.kritcode = 'SCor202' and v-crc = 1 then return.
        b_event:set-repositioned-row(b_event:focused-row, "always").
        v-rid = rowid(t-LCevent).

       if  lookup(t-LCevent.kritcode,'SRInf202') > 0 then do:
            {editor_update.i
                &var    = "t-LCevent.value1"
                &frame  = "fr1"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr1:row = b_event:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.

        if lookup(t-LCevent.kritcode,"RRef,SRInf202,AccIns,BenIns") = 0 then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 with frame f2_LCeventh.
        end.

        if t-LCevent.kritcode = 'RRef' then do:
            frame f1_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f1_LCeventh.
            update t-LCevent.value1 format 'x(16)' with frame f1_LCeventh.
        end.

        if t-LCevent.kritcode = 'VDate' then do:
            frame f1_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f1_LCeventh.
            update t-LCevent.value1 format 'x(10)' with frame f1_LCeventh.
        end.

        if lookup(t-LCevent.kritcode,"RRef,SRInf202,AccIns,BenIns") = 0 then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 with frame f2_LCeventh.
        end.
/*---------------------------------------------------------------------------------------------*/
       if t-LCevent.kritcode = 'AccType' then do:
           find first codfr where codfr.codfr = 'lcacctype' and codfr.code = t-LCevent.value1 no-lock no-error.
           if avail codfr then do:
                if (s-lcprod = 'PG' and (t-LCevent.value1 = '8' or t-LCevent.value1 = '12')) or (lookup(s-lcprod,'IMLC,SBLC') > 0 and t-LCevent.value1 = '9') then do:
                    find first b-LCevent where b-LCevent.kritcode = 'AccNum' no-lock no-error.
                    if avail b-LCevent then do:
                        find current b-LCevent exclusive-lock no-error.
                        b-LCevent.value1 = substr(codfr.name[1],1,6).
                        b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                        displ t-LCevent.value1 with frame f1_LCeventh.
                    end.
                end.
                else if lookup(s-lcprod,'IMLC,SBLC') > 0 and t-LCevent.value1 = '5' then do:
                    find first b-LCevent where b-LCevent.kritcode = 'AccNum' no-lock no-error.
                    if avail b-LCevent then do:
                        find current b-LCevent exclusive-lock no-error.
                        b-LCevent.value1 = v-collacc.
                        b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                        find current b-LCevent no-lock no-error.
                        displ b-LCevent.value1 with frame f1_LCeventh.
                    end.
                end.
                else do:
                    find first b-LCevent where b-LCevent.kritcode = 'AccNum' no-lock no-error.
                    if avail b-LCevent then do:
                        find current b-LCevent exclusive-lock no-error.
                        b-LCevent.value1 = ''.
                        b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                        displ t-LCevent.value1 with frame f1_LCeventh.
                    end.
                end.
            end.
        end.
/*---------------------------------------------------------------------------------------------*/
        if t-LCevent.kritcode = 'CurCode' and int(trim(t-LCevent.value1)) <>  v-crc then do:
           v-crcold = v-crc.
           v-crc =  int(trim(t-LCevent.value1)).
           do i = 1 to num-entries('InsTo202,InsTo756,SCor202'):
            find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = entry(i,'InsTo202,InsTo756,SCor202') no-lock no-error.
            if avail b-lcevent then do:
                find current b-lcevent exclusive-lock no-error.
                b-lcevent.value1 = ''.
                b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                find current b-lcevent no-lock no-error.
            end.
           end.
        end.

        if t-LCevent.kritcode = 'AccInsOp' then do:
            frame f1_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f1_LCeventh.
            update t-LCevent.value1 with frame f1_LCeventh.
            v-accopt = t-LCevent.value1.
            if v-accopt = 'A' then do:
               find first b-LCevent where b-LCevent.LC = s-lc and b-LCevent.kritcode = 'AccIns' no-lock no-error.
               if avail b-LCevent and b-LCevent.value1 <> '' then do:
                  find first swibic where swibic.bic = b-LCevent.value1 no-lock no-error.
                  if not avail swibic then do:
                     find current b-LCevent exclusive-lock no-error.
                     b-LCevent.value1 = ''.
                     b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                     find current b-LCevent no-lock no-error.
                  end.
               end.
            end.
        end.

        if t-LCevent.kritcode = 'AccIns' /*and t-LCevent.value1 <> ''*/ then do:
            if v-accopt = 'A' then do:
                frame f2_LCeventh:row = b_event:focused-row + 3.
                displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
                update t-LCevent.value1 with frame f2_LCeventh.
            end.
            if v-accopt = 'B' then do:
                frame f1_LCeventh:row = b_event:focused-row + 3.
                displ  t-LCevent.DataName t-LCevent.value1 with frame f1_LCeventh.
                update t-LCevent.value1 format "x(35)" with frame f1_LCeventh.
            end.
            if v-accopt = 'D' then do:
               {editor_update.i
                    &var    = "t-LCevent.value1"
                    &frame  = "fr4"
                    &framep = "column 36 row 5 overlay no-labels width 45. frame fr4:row = b_event:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines  = "4"
                    &num_down  = "4"
               }
            end.
        end.

        if t-LCevent.kritcode = 'BenInsOp' then do:
            frame f1_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f1_LCeventh.
            update t-LCevent.value1 with frame f1_LCeventh.
            if t-LCevent.value1 = 'B' then t-LCevent.value1 = 'D'.
            v-benopt = t-LCevent.value1.

            if v-benopt = 'A' then do:
               find first b-LCevent where b-LCevent.LC = s-lc and b-LCevent.kritcode = 'BenIns' no-lock no-error.
               if avail b-LCevent and b-LCevent.value1 <> '' then do:
                  find first swibic where swibic.bic = b-LCevent.value1 no-lock no-error.
                  if not avail swibic then do:
                     find current b-LCevent exclusive-lock no-error.
                     b-LCevent.value1 = ''.
                     b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                     find current b-LCevent no-lock no-error.
                  end.
               end.
            end.
        end.

        if t-LCevent.kritcode = 'BenIns' /*and t-LCevent.value1 <> ''*/ then do:
            if v-benopt = 'A' then do:
                frame f2_LCeventh:row = b_event:focused-row + 3.
                displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
                update t-LCevent.value1 with frame f2_LCeventh.
            end.

            if v-benopt = 'D' then do:
               {editor_update.i
                    &var    = "t-LCevent.value1"
                    &frame  = "fr5"
                    &framep = "column 36 row 5 overlay no-labels width 45. frame fr5:row = b_event:focused-row /*+ 2*/"
                    &chars_in_line  = "35"
                    &num_lines  = "4"
                    &num_down  = "4"
               }
            end.
        end.

        if (lookup(t-LCevent.kritcode,'Intermid,InsTo202') > 0
        or (t-LCevent.kritcode = 'AccIns' and v-accopt = 'A') or (t-LCevent.kritcode = 'BenIns' and v-benopt = 'A'))
        and t-LCevent.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCevent.value1 no-lock no-error.
            if avail swibic then t-LCevent.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).

        open query q_LC for each t-LCevent no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_event:refresh().
    end.
end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_event do:
    i = 0.
    for each t-LCevent no-lock:

        i = i + 1.
        find first LCeventh where LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number  and LCeventh.kritcode = t-LCevent.kritcode exclusive-lock no-error.
        if not avail LCeventh then create LCeventh.

        buffer-copy t-LCevent to LCeventh.
        find current LCeventh no-lock no-error.
    end.
    if i > 0 then do:
        message " Saved!!! " view-as alert-box information.
        if v-opt = 'no' then do:
            find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number  and lceventh.kritcode = 'ArpAcc' no-lock no-error.
            if not avail lceventh or v-crc <> v-crcold then do:
                if not avail lceventh then do:
                    create lceventh.
                    assign lceventh.lc       = s-lc
                           lceventh.event    = s-event
                           lceventh.number   = s-number
                           lceventh.kritcode = 'ArpAcc'
                           lceventh.bank     = s-ourbank.
                end.
                find current lceventh exclusive-lock.
                find first txb where txb.bank = lc.bank no-lock no-error.
                if not avail txb then return.
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                    run lcarp.p (v-crc, output v-arp).
                if connected ("txb") then disconnect "txb".
                lceventh.value1 = v-arp.
                find current lceventh no-lock no-error.
            end.
        end.
    end.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCevent no-lock use-index idx_sort.

if s-sts = 'NEW' then enable all with frame f_event.
else enable b_event with frame f_event.

wait-for window-close of current-window or choose of bsave.
