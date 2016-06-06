/*lccharg3.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод критериев платежа по комиссиям External Charges
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
        17/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    07/04/2011 id00810 - уточнены реквизиты Benpay,Client,ClCode для разных продуктов
    18/04/2011 id00810 - перекомпиляция
    22/07/2011 id00810 - добавлены новые виды оплат комиссий
*/

{global.i}
{LC.i}

def shared var s-lc      like LC.LC.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.
def shared var s-event   like lcevent.event.
def shared var s-number  like lcevent.number.
def shared var s-sts     like lcevent.sts.
def var v-crc   as int  no-undo.
def var v-lcsum as deci no-undo.
def var i       as int  no-undo.
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

define browse b_event query q_LC
       displ t-LCevent.dataName  format "x(37)"
             t-LCevent.dataValueVis format "x(65)"
             with 32 down overlay no-label title " External Charges ".
def button bsave label "SAVE".

define frame f_event b_event help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose    as logi no-undo init yes.
def var v-errMsg   as char no-undo.
def var v-accopt   as char no-undo.
def var v-benopt   as char no-undo.
def var v-amtcom   as deci no-undo.
def var v-tax      as deci no-undo.
def var v-amttax   as deci no-undo.
def var v-amtpay   as deci no-undo.
def var v-comptype as char no-undo.
def var v-cor      as logi no-undo init yes.
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
       v-benopt  = ''
       v-crc     = 0.

find first lcevent where lcevent.bank = s-ourbank and lcevent.lc = s-lc and lcevent.event = s-event and lcevent.number = s-number no-lock no-error.
if not avail lcevent then return.

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'ComPType' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-comptype = LCeventh.value1.

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'ComAmt' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-amtcom = deci(LCeventh.value1).

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'CoR' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-cor = if lookup(LCeventh.value1,'yes,y,да,д,0') > 0 then yes else no.

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'ComPTax' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-tax = deci(LCeventh.value1).

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'AccInsOp' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-accopt = LCeventh.value1.

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'BenInsOp' no-lock no-error.
if avail LCeventh and LCeventh.value1 <> '' then v-benopt = LCeventh.value1.

find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'CurCode' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-crc = int(lceventh.value1).
else do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).
end.

if v-crc = 1 then find first pksysc where pksysc.sysc = 'extch_pay1' no-lock no-error.
else find first pksysc where pksysc.sysc = 'extch_pay' no-lock no-error.
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
    if t-LCevent.kritcode = 'SCor202' and (v-comptype = '2' or v-comptype = '4') then t-LCevent.dataname = 'Correspondent Bank'.


    find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number and LCeventh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCeventh then do:
        if t-LCevent.kritcode = 'VDate' and s-sts <> 'FIN' then t-LCevent.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCeventh except LCeventh.LC to t-LCevent.
    end.
    else do:
        if t-LCevent.kritcode = 'VDate' then t-LCevent.value1 = string(g-today,'99/99/9999').
        if t-LCevent.kritcode = 'KOD' then t-LCevent.value1 = '14'.
        if t-LCevent.kritcode = 'KBE' then t-LCevent.value1 = if v-crc = 1 then '14' else '24'.

        if t-LCevent.kritcode = 'TRNum' then t-LCevent.value1 = caps(s-lc).
        if t-LCevent.kritcode = 'Numpay' then t-LCevent.value1 = string(s-number,'99').
        if t-LCevent.kritcode = 'MT756' then t-LCevent.value1 = 'YES'.

        if t-LCevent.kritcode = 'Benpay' then do:
            if s-lcprod = 'imlc' or s-lcprod = 'pg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            else if s-lcprod = 'exlc' then find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            else if s-lcprod = 'expg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.
        if t-LCevent.kritcode = 'ClCode' then do:
            if s-lcprod = 'imlc' then find first lch where lch.lc = s-lc and lch.kritcode = 'ApplCode' no-lock no-error.
            else if s-lcprod = 'pg' then find first lch where lch.lc = s-lc and lch.kritcode = 'PrCode' no-lock no-error.
            else if s-lcprod = 'exlc' or s-lcprod = 'expg' then find first lch where lch.lc = s-lc and lch.kritcode = 'BenCode' no-lock no-error.

            if avail lch then t-LCevent.value1 = lch.value1.

        end.
        if t-LCevent.kritcode = 'Client' then do:
            if s-lcprod = 'imlc' then find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            else if s-lcprod = 'pg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
            else if s-lcprod = 'exlc' or s-lcprod = 'expg' then find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.

            if avail lch then t-LCevent.value1 = lch.value1.
        end.

        if t-LCevent.kritcode = 'CurCode' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then t-LCevent.value1 = lch.value1.
        end.

    end.

    case t-LCevent.kritcode:
        when 'InsTo756' or when 'InsTo202' or when 'AccIns' or when 'RCor' or when 'SCor756' then do:
            if (t-LCevent.kritcode = 'AccIns' and v-accopt = 'A') or t-LCevent.kritcode <> 'AccIns' then do:
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
    if lookup(t-LCevent.kritcode,'InsTo756,RCor,Intermid,AccIns') > 0 then do:
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
    if lookup(t-LCevent.kritcode,'InsTo202,SCor756') > 0 then do:

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
    if lookup(t-LCevent.kritcode,'SCor202,CorBank') > 0 then do:

            {itemlist.i
            &file = "LCswtacc"
            &set = "fr2"
            &frame = "row 6 centered scroll 1 20 down width 91 overlay "
            &where = " LCswtacc.crc = v-crc and LCswtacc.swift <> ''"
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

    if lookup(t-LCevent.kritcode,'InsTo756,SCor202,RCor,Intermid,AccIns,BenIns,InsTo202,SCor756') = 0 then do:
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
        if lookup(t-LCevent.kritcode,'NumPay,TRNum,ClCode,Client,ComPTax,AmtTax,TPAmt,AmtRP,KOD,BenPay') > 0 then return.
        if v-crc > 1 and lookup(t-LCevent.kritcode,'PAmt,BenPay') > 0 then return.
        if v-comptype = '2' and lookup(t-LCevent.kritcode,'ComPType,RRef,VDate,CurCode,ComAmt,KBE,KNP,SCor202') =  0 then return.
        if v-comptype = '4' and lookup(t-LCevent.kritcode,'ComPType,RRef,VDate,CurCode,ComAmt,KBE,KNP,SCor202,CoR') =  0 then return.
      /*  if v-comptype = '5' and lookup(t-LCevent.kritcode,'ComPType,RRef,VDate,CurCode,ComAmt,KBE,KNP') =  0 then return.*/
        b_event:set-repositioned-row(b_event:focused-row, "always").
        v-rid = rowid(t-LCevent).

       if t-LCevent.kritcode = 'ComPType' then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 with frame f2_LCeventh.
            v-comptype =  t-LCevent.value1.

            if v-crc = 1 and v-comptype <> '1' and v-comptype <> '3' then do:
               message "This Payment Type is not available for this Currency Code!" view-as alert-box error.
               t-LCevent.value1 = ''. v-comptype = ''. leave.
            end.

            if v-crc > 1  then do:
                if (v-comptype = '3' or v-comptype = '4') then do:
                    find first lch where  lch.lc = s-lc and lch.kritcode = 'cover' no-lock no-error.
                    if not avail lch or lch.value1 = '0' then do:
                        message "This Payment Type is available only for UNCOVERED LC!" view-as alert-box error.
                        t-LCevent.value1 = ''. v-comptype = ''.
                        leave.
                    end.
                end.
                if (v-comptype = '2' or v-comptype = '4') then do:
                    find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = 'MT756' no-lock no-error.
                    if avail b-lcevent then do:
                        find current b-lcevent exclusive-lock no-error.
                        b-lcevent.value1 = 'NO'.
                        find current b-lcevent no-lock no-error.
                    end.
                end.
            end.
            find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = 'ComPTax' no-lock no-error.
            if avail b-lcevent then do:
                find current b-lcevent exclusive-lock no-error.
                b-lcevent.value1 = if v-comptype  = '1' and v-cor then '0'  else if v-comptype  = '1' and not v-cor then '20'
                              else if (v-comptype  = '3' or v-comptype  = '4') and v-cor then '10' else if (v-comptype  = '3' or v-comptype  = '4') and not v-cor then '15' else '0'.                            .
                b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                find current b-lcevent no-lock no-error.
                v-tax    = deci(trim(b-LCevent.value1)).
                v-amttax = round((v-amtcom * v-tax) / 100,2).
                v-amtpay = v-amtcom - v-amttax.
                do i = 1 to num-entries('AmtTax,PAmt,TPAmt,AmtRP'):
                    find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = entry(i,'AmtTax,PAmt,TPAmt,AmtRP') no-lock no-error.
                    if avail b-lcevent then do:
                        find current b-lcevent exclusive-lock no-error.
                        b-lcevent.value1 = if i = 1 then string(v-amttax) else if i = 3 then string(v-amtcom) else string(v-amtpay).
                        b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                        find current b-lcevent no-lock no-error.
                    end.
                end.
            end.
       end.

       if  lookup(t-LCevent.kritcode,'SRInf202,SRInf756,SToRInf') > 0 then do:
            {editor_update.i
                &var    = "t-LCevent.value1"
                &frame  = "fr1"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr1:row = b_event:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }

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

        if lookup(t-LCevent.kritcode,"RRef,SRInf202,SRInf756,SToRInf,AccIns,BenIns") = 0 then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 with frame f2_LCeventh.
        end.

        if t-LCevent.kritcode = 'CurCode' and int(trim(t-LCevent.value1)) <>  v-crc then do:
           v-crc =  int(trim(t-LCevent.value1)).
           do i = 1 to num-entries('InsTo202,InsTo756'):
            find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = entry(i,'InsTo202,InsTo756') no-lock no-error.
            if avail b-lcevent then do:
                find current b-lcevent exclusive-lock no-error.
                b-lcevent.value1 = ''.
                b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                find current b-lcevent no-lock no-error.
            end.
           end.
        end.

        if t-LCevent.kritcode = 'ComAmt' and deci(trim(t-LCevent.value1)) <>  v-amtcom then do:
            v-amtcom = deci(trim(t-LCevent.value1)).
            t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).
            v-amttax = round((v-amtcom * v-tax) / 100,2).
            v-amtpay = v-amtcom - v-amttax.
            do i = 1 to num-entries('AmtTax,PAmt,TPAmt,AmtRP'):
                find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = entry(i,'AmtTax,PAmt,TPAmt,AmtRP') no-lock no-error.
                if avail b-lcevent then do:
                    find current b-lcevent exclusive-lock no-error.
                    b-lcevent.value1 = if i = 1 then string(v-amttax) else if i = 3 then string(v-amtcom) else string(v-amtpay).
                    b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                    find current b-lcevent no-lock no-error.
                end.
            end.
        end.

        if t-LCevent.kritcode = 'CoR' then do:
            v-cor = if lookup(t-LCevent.value1,'yes,y,да,д,0') > 0 then yes else no.
            t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).
            find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = 'ComPTax' no-lock no-error.
            if avail b-lcevent then do:
                find current b-lcevent exclusive-lock no-error.
                b-lcevent.value1 = if v-comptype  = '1' and v-cor then '0'  else if v-comptype  = '1' and not v-cor then '20'
                              else if (v-comptype  = '3' or v-comptype  = '4') and v-cor then '10' else if (v-comptype  = '3' or v-comptype  = '4') and not v-cor then '15' else '0'.                            .
                b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                find current b-lcevent no-lock no-error.
                v-tax    = deci(trim(b-LCevent.value1)).
                v-amttax = round((v-amtcom * v-tax) / 100,2).
                v-amtpay = v-amtcom - v-amttax.
                do i = 1 to num-entries('AmtTax,PAmt,TPAmt,AmtRP'):
                    find first b-lcevent where b-lcevent.lc = s-lc and b-lcevent.event = s-event and b-lcevent.number = s-number and b-LCevent.kritcode = entry(i,'AmtTax,PAmt,TPAmt,AmtRP') no-lock no-error.
                    if avail b-lcevent then do:
                        find current b-lcevent exclusive-lock no-error.
                        b-lcevent.value1 = if i = 1 then string(v-amttax) else if i = 3 then string(v-amtcom) else string(v-amtpay).
                        b-LCevent.dataValueVis = getVisual(b-LCevent.kritcode, b-LCevent.value1).
                        find current b-lcevent no-lock no-error.
                    end.
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

        if (lookup(t-LCevent.kritcode,'InsTo756,RCor,Intermid,InsTo202,SCor756') > 0
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
        find first LCeventh where lceventh.bank = lcevent.bank and LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number  and LCeventh.kritcode = t-LCevent.kritcode exclusive-lock no-error.
        if not avail LCeventh then create LCeventh.

        buffer-copy t-LCevent to LCeventh.
        find current LCeventh no-lock no-error.

    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCevent no-lock.

if s-sts = 'NEW' then enable all with frame f_event.
else enable b_event with frame f_event.

wait-for window-close of current-window or choose of bsave.



