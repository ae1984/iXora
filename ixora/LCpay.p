/*LCpay.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод критериев платежа
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
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
    25/11/2010 galina - учитываем увеличения и уменьшения суммы amendment
    10/02/2011 id00810 - обработка критериев AccInsOp, BenInsOp
    01/03/2011 id00810 - уточнение формата критериев AccIns, BenIns
    02/03/2011 id00810 - для непокрытых сделок
    18/04/2011 id00810 - перекомпиляция
    30/05/2011 id00810 - обработка критерия PType
    17/06/2011 id00810 - обработка критерия AccType
    29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
    02/11/2011 id00810 - учет значения реквизита PerAmt при определении LCamtcur
    06/01/2012 id00810 - новый тип платежа Payment (uncovered deals - client's funds)
    17/01/2012 id00810 - изменлось значение реквизита fmt
    03/04/2012 id00810 - корректировка счетов для PG (ptype = 1,2)
*/

{global.i}
{LC.i}

def shared var s-lc      like lc.lc.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.
def shared var s-paysts  like lcpay.sts.
def shared var s-lcpay   like lcpay.lcpay.

def var v-crc     as int  no-undo.
def var v-collacc as char no-undo.
def var v-depacc  as char no-undo.
def var v-lcsum   as deci no-undo.
def var i         as int  no-undo.
def var v-per     as int  no-undo.
def var v-clacc   as char no-undo.
def var v-crcname as char no-undo.

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
def var v-chose   as logi no-undo init yes.
def var v-errMsg  as char no-undo.
def var v-accopt  as char no-undo.
def var v-benopt  as char no-undo.
def var v-usl     as char no-undo.
def var v-cover   as char no-undo.
def var v-ptype   as char no-undo.
def var v-acctype as char no-undo.
def var v-priz    as char no-undo.
def var v-text    as char no-undo.
def var v-gar     as logi no-undo.

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
    t-LCpay.value1 format "x(65)" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f1_LCpayh
    t-LCpay.dataName format "x(37)"
    t-LCpay.value1 format "x(16)" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f3_LCpayh
    t-LCpay.dataName format "x(37)"
    t-LCpay.value1 format "x(50)" validate(validh(t-LCpay.kritcode,t-LCpay.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCpay.
assign v-collacc = ''
       v-accopt = ''
       v-benopt  = ''
       v-crc     = 0.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.
if s-lcprod = 'pg' then v-gar = yes.

find first lch where lch.lc = s-lc and lch.kritcode = 'cover' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-cover = lch.value1.

find first lch where lch.lc = s-lc and lch.kritcode = 'CollAcc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-collacc = lch.value1.

find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-depacc = lch.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'AccInsOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-accopt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'BenInsOp' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-benopt = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'PType' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-ptype = LCpayh.value1.

find first LCpayh where lcpayh.bank = s-ourbank and LCpayh.LC = s-lc and LCpayh.LCpay = s-lcpay and LCpayh.kritcode = 'AccType' no-lock no-error.
if avail LCpayh and LCpayh.value1 <> '' then v-acctype = LCpayh.value1.

find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).

if s-lcprod = 'sblc' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
    if avail lch and lch.value1 <> '' then v-priz = if lch.value1 = '700' then 'm' else 'g'.
end.

if v-crc = 1 then find first pksysc where pksysc.sysc = 'imlc_pay1' no-lock no-error.
else find first pksysc where pksysc.sysc = 'imlc_pay' no-lock no-error.
if not avail pksysc then return.

if v-crc = 1 then v-benopt = 'A'.

i = 1.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCpay.
    t-LCpay.LC = s-lc.
    t-LCpay.LCpay = s-lcpay.
    t-LCpay.kritcode = LCkrit.dataCode.
    assign t-LCpay.showOrder = i
           t-LCpay.dataName  = LCkrit.dataName
           t-LCpay.dataSpr   = LCkrit.dataSpr
           t-LCpay.bank      = s-ourbank.
    if t-LCpay.kritcode = 'BenIns'  then t-LCpay.dataname = 'Beneficiary Institution'.
    if t-LCpay.kritcode = 'CollAcc' then t-LCpay.dataname = "Client's Account".

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

        if t-LCpay.kritcode = 'VDate' then t-LCpay.value1 = string(g-today,'99/99/9999').
        if t-LCpay.kritcode = 'DtNar' then t-LCpay.value1 = string(g-today,'99/99/9999').
        if t-LCpay.kritcode = 'KOD' then t-LCpay.value1 = '14'.
        if t-LCpay.kritcode = 'KBE' then t-LCpay.value1 = if v-crc = 1 then '14' else '24'.
        if t-LCpay.kritcode = 'TRNum' then t-LCpay.value1 = caps(s-lc).
        if t-LCpay.kritcode = 'Numpay' then t-LCpay.value1 = string(s-lcpay,'99').

        if t-LCpay.kritcode = 'Benpay' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
            if avail lch then t-LCpay.value1 = lch.value1.
        end.
        if t-LCpay.kritcode = 'ClCode' then do:
            if s-lcprod = 'imlc' or v-priz = 'm' then find first lch where lch.lc = s-lc and lch.kritcode = 'ApplCode' no-lock no-error.
            else if s-lcprod = 'pg' or v-priz = 'g' then find first lch where lch.lc = s-lc and lch.kritcode = 'PrCode' no-lock no-error.
            if avail lch then t-LCpay.value1 = lch.value1.
        end.
        if t-LCpay.kritcode = 'Client' then do:
            if s-lcprod = 'imlc' or v-priz = 'm' then find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
            else if s-lcprod = 'pg' or v-priz = 'g' then find first lch where lch.lc = s-lc and lch.kritcode = 'Princ' no-lock no-error.
            if avail lch then t-LCpay.value1 = lch.value1.
        end.

        if t-LCpay.kritcode = 'PTax' and v-collacc <> '' then t-LCpay.value1 = 'NO'.

        if t-LCpay.kritcode = 'MT202' then t-LCpay.value1 = if v-crc = 1 then 'NO' else 'YES'.
        if t-LCpay.kritcode = 'MT756' then t-LCpay.value1 = if v-crc = 1 then 'NO' else 'YES'.

        if t-LCpay.kritcode = 'CurCode' then do:
            find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
            if avail lch then t-LCpay.value1 = lch.value1.
        end.

    end.

    if t-LCpay.kritcode = 'LCamtcur' then do:
         v-lcsum = 0.
         find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
         if avail lch and trim(lch.value1) <> '' then do:
            v-lcsum = deci(lch.value1).
            find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
            if avail lch and lch.value1 ne '' then do:
                v-per = int(entry(1,lch.value1, '/')).
                if v-per > 0 then v-lcsum = v-lcsum + (v-lcsum * (v-per / 100)).
             end.
            /*учитываем увеличения и уменьшения суммы amendment*/
            for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
                find first jh where jh.jh = lcamendres.jh no-lock no-error.
                if not avail jh then next.

                if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum = v-lcsum + lcamendres.amt.
                if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsum = v-lcsum - lcamendres.amt.
            end.
            /*учитываем суммы payment*/
            for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                find first jh where jh.jh = lcpayres.jh no-lock no-error.
                if avail jh then v-lcsum = v-lcsum - lcpayres.amt.
            end.
            /* учитываем суммы event */
            for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
                find first jh where jh.jh = lceventres.jh no-lock no-error.
                if avail jh then v-lcsum = v-lcsum - lceventres.amt.
            end.
         end.
         t-LCpay.value1 = string(v-lcsum).
    end.

    case t-LCpay.kritcode:
        when 'InsTo756' or when 'InsTo202' or when 'AccIns' or when 'RCor' or when 'SCor756' then do:
            if (t-LCpay.kritcode = 'AccIns' and v-accopt = 'A') or t-LCpay.kritcode <> 'AccIns' then do:
                find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
                if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.

            end.
            if t-LCpay.kritcode = 'AccIns' and v-accopt <> 'A' then t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode,t-LCpay.value1).
        end.

        when 'BenIns' then do:
            if v-benopt = 'A' then do:
                if v-crc > 1 then do:
                    find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
                    if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
                end.
                else do:
                    find first bankl where bankl.bank = t-LCpay.value1 no-lock no-error.
                    if avail bankl then t-LCpay.dataValueVis = bankl.bank + ' - ' + bankl.name.
                end.
            end.
            else t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode,t-LCpay.value1).
        end.

        otherwise t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode,t-LCpay.value1).
    end case.
end.

on help of t-LCpay.value1 in frame f2_LCpayh do:

    if lookup(t-LCpay.kritcode,'InsTo756,RCor,Intermid,AccIns') > 0 then do:
        if t-LCpay.kritcode <> 'AccIns' or (t-LCpay.kritcode = 'AccIns' and v-accopt = 'A') then do:
            run swiftfind(output t-LCpay.value1).

            find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
            if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        displ t-LCpay.value1 with frame f2_LCpayh.

    end.
    if t-LCpay.kritcode = 'BenIns' then do:
        if v-benopt = 'A' then do:
            if v-crc > 1 then do:
                run swiftfind(output t-LCpay.value1).
                find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
                if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
            end.
            else do:
                run h_bnk(output t-LCpay.value1).
                find first bankl where bankl.bank = t-LCpay.value1 no-lock no-error.
                if avail bankl then t-LCpay.dataValueVis = bankl.bank + ' - ' + bankl.name.
            end.
            displ t-LCpay.value1 with frame f2_LCpayh.
        end.
    end.
    if lookup(t-LCpay.kritcode,'InsTo202,SCor756') > 0 then do:

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
            t-LCpay.value1 = LCswtacc.swift.

            find first swibic where swibic.bic = t-LCpay.value1 no-lock no-error.
            if avail swibic then t-LCpay.dataValueVis = swibic.bic + ' - ' + swibic.name.
            displ t-LCpay.value1 with frame f2_LCpayh.
    end.
    if lookup(t-LCpay.kritcode,'SCor202') > 0 then do:

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
            t-LCpay.value1 = LCswtacc.accout.
            find first LCswtacc where LCswtacc.accout = t-LCpay.value1 no-lock no-error.
            if avail LCswtacc then t-LCpay.dataValueVis = t-LCpay.value1.
            displ t-LCpay.value1 with frame f2_LCpayh.

    end.
    if lookup(t-LCpay.kritcode,'CollAcc') > 0 then do:
        {itemlist.i
         &set = "acc"
         &file = "aaa"
         &findadd = "find first crc where crc.crc = aaa.crc no-lock no-error. v-crcname = ''. if avail crc then v-crcname = crc.code. "
         &frame = "row 6 centered scroll 1 20 down width 40 overlay "
         &where = " aaa.cif = v-cif and aaa.sta <> 'C' and substr(string(aaa.gl),1,4) = '2203' and aaa.crc = v-crc "
         &flddisp = " aaa.aaa label 'Account' format 'x(20)' v-crcname label 'Currency' "
         &chkey = "aaa"
         &index  = "aaa-idx1"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCpay.value1 = aaa.aaa.
         displ t-LCpay.value1 with frame f2_LCpayh.

    end.

    if lookup(t-LCpay.kritcode,'InsTo756,SCor202,RCor,Intermid,AccIns,BenIns,InsTo202,SCor756') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCpay.kritcode no-lock no-error.
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

        if lookup(t-LCpay.kritcode,'TRNum,ClCode,Client,AccType,AccNum,CurCode,Transp,NumPay,KOD,KNP,KBE') > 0 then return.
        if v-cover = '0' and lookup(t-LCpay.kritcode,'PTax,AmtTax') > 0 then return.
        /*if v-ptype <> '4' and lookup(t-LCpay.kritcode,'AccType,AccNum') > 0 then return.*/

        /*if v-crc = 1 and lookup(t-LCpay.kritcode,'InsTo202,InsTo756,SCor202,SCor756,RCor,Intermid,AccIns,SRInf202,SRInf756') > 0 then next.*/
        /*if v-crc = 1 and lookup(t-LCpay.kritcode,'InsTo202,InsTo756,SCor756,SCor202,RCor,Intermid,AccIns,SRInf202,SRInf756,MT202,MT756') > 0 then next.*/
        b_pay:set-repositioned-row(b_pay:focused-row, "always").
        v-rid = rowid(t-LCpay).

        if t-LCpay.kritcode = 'PType' then do:
            frame f2_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
            update t-LCpay.value1 with frame f2_LCpayh.
            v-text = ''.
            if s-lcprod ne 'imlc' and t-LCpay.value1 = '5' then v-text = 'Incorrect Payment Type for ' + s-lcprod + '!'.
            if v-cover = '1' and (t-LCpay.value1 = '1' or t-LCpay.value1 = '4') then v-text = 'Incorrect Payment Type for uncovered '  + s-lcprod + '!'.
            else if v-cover = '0' and (t-LCpay.value1 = '2' or t-LCpay.value1 = '3' or t-LCpay.value1 = '5') then v-text = 'Incorrect Payment Type for covered '  + s-lcprod + '!'.
            if v-text ne '' then do:
               message v-text view-as alert-box error.
               t-lcpay.value1 = ''.
               t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode, t-LCpay.value1).
               return.
            end.
            if v-ptype <> t-LCpay.value1 then do:
                v-ptype = t-LCpay.value1.
                find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'AccType' no-lock no-error.
                if avail b-lcpay then do:
                    find current b-lcpay exclusive-lock.
                    b-lcpay.value1 = ''.
                    if v-ptype ne '5' then do:
                        if s-lcprod = 'pg' then v-acctype = if v-ptype <> '2' then '10' else '11'.
                        else v-acctype = if v-ptype <> '2' and v-ptype <> '3' then '5' else '7'.
                        find first codfr where codfr.codfr = 'lcacctype'
                                           and codfr.code  = v-acctype
                        no-lock no-error.
                        if avail codfr then b-lcpay.value1 = codfr.code.
                    end.
                    else do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'AccPayGl' no-lock no-error.
                        if not avail lch or lch.value1 = '' then do:
                            message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
                            t-lcpay.value1 = ''.
                            t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode, t-LCpay.value1).
                            return.
                        end.
                        find first codfr where codfr.codfr = 'lcacctype'
                                           and codfr.name[1] begins lch.value1
                        no-lock no-error.
                        if avail codfr then b-lcpay.value1 = codfr.code.
                    end.
                    find current b-lcpay no-lock no-error.
                    b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                end.
                find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'AccNum' no-lock no-error.
                if avail b-lcpay then do:
                    find current b-lcpay exclusive-lock.
                    b-lcpay.value1 = ''.
                    if (v-ptype = '2' and not v-gar) or v-ptype = '3' and avail codfr then b-lcpay.value1 = substr(codfr.name[1],1,6).
                    else if v-ptype <> '5' then do:
                            if not v-gar then b-lcpay.value1 = v-collacc.
                            else do:
                                find first sysc where sysc.sysc = 'pgarp' + substr(codfr.name[1],1,6) no-lock no-error.
                                if avail sysc then do:
                                    if num-entries(sysc.chval) >= v-crc then b-lcpay.value1 = entry(v-crc,sysc.chval).
                                    else do:
                                        message "The value pgarp" + substr(codfr.name[1],1,6) +  " in SYSC is empty!" view-as alert-box error.
                                        t-LCpay.value1 = ''.
                                    end.
                                end.
                                if  b-lcpay.value1 = '' then do:
                                    message "The value pgarp" + substr(codfr.name[1],1,6) +  " in SYSC is empty!" view-as alert-box error.
                                    t-LCpay.value1 = ''.
                                end.
                            end.
                    end.
                    else do:
                        find first lch where lch.lc = s-lc and lch.kritcode = 'AccPay' no-lock no-error.
                        if not avail lch or lch.value1 = '' then do:
                            message 'There is no deal for ' + s-lc + '!' view-as alert-box error.
                            t-lcpay.value1 = ''.
                            t-LCpay.dataValueVis = getVisual(t-LCpay.kritcode, t-LCpay.value1).
                            return.
                        end.
                        b-lcpay.value1  = lch.value1.
                    end.
                    find current b-lcpay no-lock no-error.
                    b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                end.
                if v-ptype = '4' or v-ptype = '5' then do:
                    find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'MT202' no-lock no-error.
                    if avail b-lcpay then do:
                        find current b-lcpay exclusive-lock.
                        b-lcpay.value1 = 'NO'.
                        find current b-lcpay no-lock no-error.
                        b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                    end.
                    find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'MT756' no-lock no-error.
                    if avail b-lcpay then do:
                        find current b-lcpay exclusive-lock.
                        b-lcpay.value1 = 'NO'.
                        find current b-lcpay no-lock no-error.
                        b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                    end.
                end.
                find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'KNP' no-lock no-error.
                if avail b-lcpay then do:
                    find current b-lcpay exclusive-lock.
                    b-lcpay.value1 = if s-lcprod = 'pg' then '182' else if v-ptype = '4' then '181' else '710'.
                    find current b-lcpay no-lock no-error.
                    b-LCpay.dataValueVis = getVisual(b-LCpay.kritcode, b-LCpay.value1).
                end.


            end.
        end.

        if t-LCpay.kritcode = 'PTax' or t-LCpay.kritcode = 'AmtTax' then do:
            find first b-lcpay where b-lcpay.lc = s-lc and b-lcpay.lcpay = s-lcpay and b-LCpay.kritcode = 'PType' no-lock no-error.
            if not avail b-lcpay or b-lcpay.value1 = '' or b-lcpay.value1 <> '4' then return.
        end.

        if  lookup(t-LCpay.kritcode,'SRInf202,SRInf756,StoRInf') > 0 then do:
            {editor_update.i
                &var    = "t-LCpay.value1"
                &frame  = "fr1"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr1:row = b_pay:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.

        if t-LCpay.kritcode = 'RRef' then do:
            frame f1_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f1_LCpayh.
            update t-LCpay.value1 format 'x(16)' with frame f1_LCpayh.
        end.

        if lookup(t-LCpay.kritcode,'Agreem,VDate') > 0 then do:
            frame f3_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f3_LCpayh.
            update t-LCpay.value1 with frame f3_LCpayh.
        end.

        if lookup(t-LCpay.kritcode,"Agreem,RRef,SRInf202,SRInf756,AccIns,BenIns,StoRInf,PType,AccType,AccNum") = 0 then do:
            frame f2_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
            update t-LCpay.value1 with frame f2_LCpayh.

        end.

        if t-LCpay.kritcode = 'AccInsOp' then do:
             frame f1_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f1_LCpayh.
            update t-LCpay.value1 with frame f1_LCpayh.
            t-LCpay.value1 = caps(t-LCpay.value1).
            v-accopt = t-LCpay.value1.
            if v-accopt = 'A' then do:
               find first b-LCpay where b-LCpay.LC = s-lc and b-LCpay.kritcode = 'AccIns' no-lock no-error.
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
        end.

        if t-LCpay.kritcode = 'AccIns' /*and t-LCpay.value1 <> ''*/ then do:
            if v-accopt = 'A' then do:
                frame f2_LCpayh:row = b_pay:focused-row + 3.
                displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
                update t-LCpay.value1 with frame f2_LCpayh.
            end.
            if v-accopt = 'B' then do:
                frame f1_LCpayh:row = b_pay:focused-row + 3.
                displ  t-LCpay.DataName t-LCpay.value1 with frame f1_LCpayh.
                update t-LCpay.value1 format "x(35)" with frame f1_LCpayh.
            end.
            if v-accopt = 'D' then do:
               {editor_update.i
                    &var    = "t-LCpay.value1"
                    &frame  = "fr4"
                    &framep = "column 36 row 5 overlay no-labels width 45. frame fr4:row = b_pay:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines  = "4"
                    &num_down  = "4"
               }
            end.
        end.

        if t-LCpay.kritcode = 'BenInsOp' then do:
            frame f1_LCpayh:row = b_pay:focused-row + 3.
            displ t-LCpay.dataName t-LCpay.value1 with frame f1_LCpayh.
            update t-LCpay.value1 with frame f1_LCpayh.
            t-LCpay.value1 = caps(t-LCpay.value1).
            if t-LCpay.value1 = 'B' then t-LCpay.value1 = 'D'.
            v-benopt = t-LCpay.value1.

            if v-benopt = 'A' then do:
               find first b-LCpay where b-LCpay.LC = s-lc and b-LCpay.kritcode = 'BenIns' no-lock no-error.
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
        end.

        if t-LCpay.kritcode = 'BenIns' /*and t-LCpay.value1 <> ''*/ then do:
            if v-benopt = 'A' then do:
                frame f2_LCpayh:row = b_pay:focused-row + 3.
                displ t-LCpay.dataName t-LCpay.value1 with frame f2_LCpayh.
                update t-LCpay.value1 with frame f2_LCpayh.
            end.

            if v-benopt = 'D' then do:
               {editor_update.i
                    &var    = "t-LCpay.value1"
                    &frame  = "fr5"
                    &framep = "column 36 row 5 overlay no-labels width 45. frame fr5:row = b_pay:focused-row /*+ 2*/"
                    &chars_in_line  = "35"
                    &num_lines  = "4"
                    &num_down  = "4"
               }
            end.
        end.

        if (lookup(t-LCpay.kritcode,'InsTo756,RCor,Intermid,InsTo202,SCor756') > 0
        or (t-LCpay.kritcode = 'AccIns' and v-accopt = 'A') or (t-LCpay.kritcode = 'BenIns' and v-benopt = 'A'))
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

