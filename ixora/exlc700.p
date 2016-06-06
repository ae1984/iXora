/*exlc700.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод/редактирование основных критериев EXLC
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
        11/02/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        18/02/2011 id00810 - уточнение форматов для EXlC
        06/09/2011 id00810 - MT720
        13/01/2012 id00810 - уточнение реквизитов для EXSBlC
        06/02/2012 id00810 - уточнение значений реквизита AdvBy
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
def shared var s-fmt      as char.
def var v-crcname as char no-undo.
def var v-crc     as int  no-undo.
def var i         as int  no-undo.
def var v-fmt     as char no-undo.
def var v-sp      as char no-undo.
def var v-chose1  as logi no-undo.
def var v-handle  as logi no-undo.
def var v-fmt1    as char no-undo init '700'.
def var v-fmt2    as char no-undo.
def var v-chose   as logi no-undo init yes.
def var v-errMsg  as char no-undo.
def var v-bank    as char no-undo.

{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmain.
def var v-rid as rowid.

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'fname2' no-lock no-error.
if not avail lch then v-handle = yes.

/*find first LCh where LCh.LC = s-lc and LCh.kritcode = 'fmt' no-lock no-error.
if not avail lch then do:
    s-fmt2   = if s-lcprod = 'exlc' then '710' else '760' .
    message 'Select ' + s-lcprod + ' format: MT' + s-fmt1 + ' (yes) or MT' + s-fmt2 + ' (no)!' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' ATTENTION !'
    update v-chose1.

    create lch.
    assign lch.lc       = s-lc
           lch.kritcode = 'fmt'
           lch.value1   = if v-chose1 then '700' else '760'
           lch.bank     = s-ourbank.
end.
s-fmt = lch.value1.*/

define browse b_LC query q_LC
       displ t-LCmain.dataName     format "x(37)"
             t-LCmain.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MT" + s-fmt + " ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmain.
def buffer b-lch    for lch.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

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

define frame f2_LCh3
    t-LCmain.dataName format "x(37)"
    t-LCmain.value1   format "x(35)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 74 no-label overlay column 4 no-box.
define frame f2_cif
    v-cif format "x(65)" validate(can-find(cif where cif.cif = v-cif no-lock),'Enter applicant code!')
    with width 65 no-label overlay column 42 no-box.

if s-fmt = '700' then find first pksysc where pksysc.sysc = 'exlc_adv' no-lock no-error.
else if s-fmt = '710' then find first pksysc where pksysc.sysc = 'exlc_adv710' no-lock no-error.
else if s-fmt = '760' then find first pksysc where pksysc.sysc = 'expg_adv' no-lock no-error.
else return.

if not avail pksysc then return.
v-sp = pksysc.chval.

if s-lcprod = 'exsblc' and s-fmt = '760' then v-sp = v-sp + ',254'.

empty temp-table t-LCmain.
i = 1.
do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCmain.
    assign
        t-LCmain.LC        = s-lc
        t-LCmain.kritcode  = LCkrit.dataCode
        t-LCmain.showOrder = i
        t-LCmain.dataName  = LCkrit.dataName
        t-LCmain.dataSpr   = LCkrit.dataSpr.

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then do:
        if t-LCmain.kritcode = 'DtAdv' and v-lcsts <> 'FIN' then t-LCmain.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCh except LCh.LC to t-LCmain.
        if t-LCmain.kritcode = 'IssBank' and length(t-LCmain.value1) = 8 then t-LCmain.value1 = t-LCmain.value1 + 'XXX'.
    end.
    else do:
        if t-LCmain.kritcode = 'SeqTot'  then t-LCmain.value1 = '1/1'.
        if t-LCmain.kritcode = 'BankRef' then t-LCmain.value1 = s-lc.
        if t-LCmain.kritcode = 'BenCode' and v-cif <> '' then t-LCmain.value1 = v-cif.
        if t-LCmain.kritcode = 'IssBank' then do:
            find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'Sender' no-lock no-error.
            if avail b-lch then t-LCmain.value1 = b-lch.value1.
        end.
        if t-LCmain.kritcode = 'MT730' then t-LCmain.value1 = 'YES'.
        if t-LCmain.kritcode = 'MT768' then t-LCmain.value1 = 'YES'.
        t-LCmain.bank = s-ourbank.
    end.
    if lookup(t-LCmain.kritcode,'Sender,IssBank,AvlWith,ReimBnk') > 0 and t-LCmain.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        else t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
    end.
    else t-LCmain.dataValueVis = if index(t-LCmain.value1,chr(1)) > 0 then replace(t-LCmain.value1,chr(1),'')
                                                                        else getVisual(t-LCmain.kritcode,t-LCmain.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:
        if not v-handle and lookup(t-LCmain.kritcode,'AdvBy,DtAdv,BenCode,Cover,CollAcc,ComAcc,ExAbout,InsTo710') = 0 then return.
            /*if lookup(t-LCmain.kritcode,'Applic,Benef,AdAmCov,DrfAt,Drawee,MPayDet,DefPayD,DesGood,DocReq,AddCond,Charges,PerPres,InstoBnk,StoRInf,StoRI710') > 0 and t-LCmain.value1 =  '' then return.*/
        /*end.*/
        if lookup(t-LCmain.kritcode,'BenCode,CollAcc,ComAcc') > 0 and s-ourbank = 'TXB00' then return.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if lookup(t-LCmain.kritcode,'Applic,Benef,AdAmCov,DrfAt,Drawee,MPayDet,DefPayD,DesGood,DocReq,AddCond,Charges,PerPres,InstoBnk,StoRInf,StoRI710') > 0 and not v-handle then do:
            empty temp-table wrk.
            do i = 1 to num-entries(t-LCmain.value1,chr(1)):
                create wrk.
                wrk.id = i.
                wrk.txt = entry(i,t-LCmain.value1,chr(1)).
            end.

            {itemlist.i
                &file    = "wrk"
                &frame   = "column 39 row 17  scroll 1 10 down width 71 no-labels overlay /*title ' Applicant '*/ "
                &where   = " true "
                &flddisp = " wrk.id format '>>9' wrk.txt format 'x(65)' "
                &chkey   = "id"
                &chtype  ="integer"
                &set     = "1"
                &index   = "idx"
                &end     = "if keyfunction(lastkey) = 'end-error' then return."
                }
        end.
        else do:
            if  lookup(t-LCmain.kritcode,'Applic,Benef,AdAmCov,MPayDet,DefPayD,PerPres') > 0 then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr7"
                    &framep         = "column 42 row 5 overlay no-labels width 45. frame fr7:row = b_LC:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines      = "4"
                    &num_down       = "4"
                }
            end.

            if t-LCmain.kritcode = 'PerAmt' then do:
                find first b-lcmain where b-LCmain.kritcode = 'MaxCrAmt' no-lock no-error.
                if avail b-lcmain then if b-lcmain.value1 ne '' then return.
            end.

            if t-LCmain.kritcode = 'MaxCrAmt' then do:
                find first b-lcmain where b-LCmain.kritcode = 'PerAmt' no-lock no-error.
                if avail b-lcmain then if b-lcmain.value1 ne '' then return.
            end.

            if t-LCmain.kritcode = 'Drawee' then do:
                find first b-lcmain where b-LCmain.kritcode = 'By' no-lock no-error.
                if not avail b-lcmain or b-lcmain.value1 <> '3' then return.
            end.

            if t-LCmain.kritcode = 'DefPayD' then do:
                find first b-lcmain where b-LCmain.kritcode = 'By' no-lock no-error.
                if not avail b-lcmain or b-lcmain.value1 <> '2' then return.
            end.

            if  lookup(t-LCmain.kritcode,'Parmain,Trnmain') > 0 then do:
                frame f2_LCh3:row = b_LC:focused-row + 3.
                displ t-LCmain.dataName  t-LCmain.value1 with frame f2_LCh3.
                update t-LCmain.value1 with frame f2_LCh3.
            end.

            if  lookup(t-LCmain.kritcode,'LDtmain,PlcCharg,PclFD') > 0 then do:
                frame f2_LCh:row = b_LC:focused-row + 3.
                displ t-LCmain.dataName  t-LCmain.value1 with frame f2_LCh.
                update t-LCmain.value1 with frame f2_LCh.
            end.

            if lookup(t-LCmain.kritcode,'Charges,StoRInf,StoRI710') > 0  then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr2"
                    &framep         = "column 42 row 5 overlay no-labels width 45. frame fr2:row = b_LC:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines      = "6"
                    &num_down       = "6"
                }
            end.

            if lookup(t-LCmain.kritcode,'DesGood,DocReq,AddCond') > 0 then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr3"
                    &framep         = "column 37 row 5 overlay no-labels width 75. frame fr3:row = b_LC:focused-row + 2"
                    &chars_in_line  = "65"
                    &num_lines      = "100"
                    &num_down       = "10"
                }
            end.

            if lookup(t-LCmain.kritcode,'DrfAt') > 0 then do:
                find first b-lcmain where b-LCmain.kritcode = 'By' no-lock no-error.
                if not avail b-lcmain then return.
                if t-LCmain.kritcode ='DrfAt' and  b-lcmain.value1 <> '3' then return.
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr4"
                    &framep         = "column 42 row 5 overlay no-labels width 45. frame fr4:row = b_LC:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines      = "3"
                    &num_down       = "3"
                }
            end.

            if lookup(t-LCmain.kritcode,'ShipPer') > 0 then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr5"
                    &framep         = "column 37 row 5 overlay no-labels width 75. frame fr5:row = b_LC:focused-row + 2"
                    &chars_in_line  = "65"
                    &num_lines      = "6"
                    &num_down       = "6"
                }
            end.

            if lookup(t-LCmain.kritcode,'InsToBnk') > 0 then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr6"
                    &framep         = "column 37 row 5 overlay no-labels width 75. frame fr6:row = b_LC:focused-row + 2"
                    &chars_in_line  = "65"
                    &num_lines      = "12"
                    &num_down       = "12"
                }
            end.

            if t-LCmain.kritcode = "DetGar" then do:
                {editor_update.i
                    &var            = "t-LCmain.value1"
                    &frame          = "fr8"
                    &framep         = "column 37 row 5 overlay no-labels width 75. frame fr8:row = b_LC:focused-row + 2"
                    &chars_in_line  = "65"
                    &num_lines      = "150"
                    &num_down       = "10"
                }
            end.
            if t-LCmain.kritcode = 'By' then do:
                if t-LCmain.value1 <> '3' then do:
                    for each b-LCmain where lookup(b-LCmain.kritcode,'DrfAt,Drawee') > 0 exclusive-lock:
                        b-LCmain.value1 = ''.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    end.
                end.
                if t-LCmain.value1 <> '2' then do:
                    find first b-lcmain where b-LCmain.kritcode = 'DefPayD' no-lock no-error.
                    if avail b-lcmain then do:
                        find current b-lcmain exclusive-lock no-error.
                        b-LCmain.value1 = ''.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-lcmain no-lock no-error.
                    end.
                end.
            end.

            if t-LCmain.kritcode = 'ExAbout' then do:
                if t-LCmain.value1 = '0' then do:
                    find first b-LCmain where b-LCmain.kritcode = 'PerAmt' no-lock no-error.
                    if avail  b-LCmain then do:
                        find current b-lcmain exclusive-lock no-error.
                        b-LCmain.value1 = ''.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-lcmain no-lock no-error.
                    end.
                end.
            end.

            if t-LCmain.kritcode = 'PerAmt' then do:
                find first b-LCmain where b-LCmain.kritcode = 'ExAbout' no-lock no-error.
                if avail b-lcmain then
                    if b-lcmain.value1 = '0' then do:
                        t-LCmain.value1 = ''.
                        t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).
                        return.
                    end.
            end.
        end. /* else do */

        if t-LCmain.kritcode = 'BenCode' then do:
            frame f2_cif:row = b_LC:focused-row + 3.
            update v-cif  with frame f2_cif.
            display v-cif  with frame f2_cif.
            pause 0.
            t-LCmain.value1 = v-cif.
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
        end.

        if lookup(t-LCmain.kritcode,'BenCode,AdAmCov,DrfAt,DefPayD,StoRInf,StoRI710') = 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
        end.

        if t-LCmain.kritcode = 'CollAcc' then do:
            find first aaa where aaa.aaa = trim(t-LCmain.value1) no-lock no-error.
            if avail aaa then do:
                find first b-LCmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
                if avail  b-LCmain then do:
                    find first crc where crc.crc = int(trim(b-LCmain.value1)) no-lock no-error.
                    if avail crc and crc.crc <> aaa.crc then do:
                        message "The currency of Collateral Debit Account shoud be the same with Currency Code!".
                        t-LCmain.value1 = ''.
                    end.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'Cover' then do:
            if t-LCmain.value1 = '1' then do:
                find first b-LCmain where b-LCmain.kritcode = 'Collacc' no-lock no-error.
                if avail  b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        /*if t-LCmain.kritcode = 'lcCrc' then do:
           find first crc where crc.crc = int(trim(t-LCmain.value1)) no-lock no-error.
           if avail crc then do:
                find first b-LCmain where b-LCmain.kritcode = 'CollAcc' no-lock no-error.
                if avail b-LCmain and trim(b-LCmain.value1) <> '' then do:
                    find first aaa where aaa.aaa = trim(b-LCmain.value1) no-lock no-error.
                    if avail aaa and crc.crc <> aaa.crc then do:
                        message "The currency of Collateral Debit Account shoud be the same with Currency Code!".
                        t-LCmain.value1 = ''.
                    end.
                end.
           end.
        end.*/

        if t-LCmain.kritcode = 'AdvBy' and t-LCmain.value1 = '0' then do:
            t-LCmain.value1 = ''.
            return.
        end.

        if lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,IssBank,AdvThrou,ReimBnk') > 0 and t-LCmain.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
            if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).

        open query q_LC for each t-LCmain no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCmain.value1 in frame f2_LCh do:
    if lookup(t-LCmain.kritcode,'Sender,IssBank,AvlWith,Drawee,AdvThrou,ReimBnk,InsTo710') > 0 then do:
        run swiftfind(output t-LCmain.value1).

        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-LCmain.value1 with frame f2_LCh.

    end.

    if lookup(t-LCmain.kritcode,'CollAcc,ComAcc') > 0 then do:
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
    if lookup(t-LCmain.kritcode,'CollAcc,ComAcc,AvlWith') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &set = "codfr"
                    &file = "codfr"
                    &frame = "row 7 centered scroll 1 20 down width 91 overlay "
                    &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' and ((codfr.codfr = 'exlcadv' and codfr.code <> '0') or (codfr.codfr <> 'exlcadv' and true))"
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
   if s-ourbank = 'TXB00' then do:
        message 'Do you want to pass this EXLC to filial?'  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose1.
        if v-chose1 then do:
            {sel-filial.i}.
            find txb where txb.consolid = true and txb.txb = v-select - 2 no-lock no-error.
            v-bank = txb.bank.
        end.
    end.
    i = 0.
    for each t-LCmain no-lock:

        i = i + 1.
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCmain.kritcode exclusive-lock no-error.
        if not avail LCh then create LCh.

        buffer-copy t-LCmain to LCh.
        if v-chose1 then lch.bank = v-bank.

        find current LCh no-lock no-error.
        if lch.kritcode = 'BenCode' and trim(lch.value1) <> '' then do:
            find first LC where LC.LC = s-lc exclusive-lock no-error.
            if avail lc then lc.cif = trim(lch.value1).
            find current LC no-lock no-error.
        end.
        if lch.kritcode = 'Amount' and trim(lch.value1) <> ''
        then assign v-lcsumcur = deci(lch.value1)
                    v-lcsumorg = deci(lch.value1).
        if lch.kritcode = 'lcCrc' and trim(lch.value1) <> '' then do:
           find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
           if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
         end.
        if lch.kritcode = 'DtExp' and lch.value1 <> ?
        then v-lcdtexp = date(lch.value1).
    end.

    if v-chose1 then do:
        find first LC where LC.lc = s-lc exclusive-lock no-error.
        if avail lc then lc.bank = v-bank.
        find current LC no-lock no-error.
        find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' exclusive-lock no-error.
        if avail lch then lch.bank = v-bank.
        find current lch no-lock no-error.
        find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' exclusive-lock no-error.
        if avail lch then lch.bank = v-bank.
        find current lch no-lock no-error.
    end.
    if i > 0 then  do:
        if v-chose1 then message " Saved and Passed to Filial!!! " view-as alert-box information.
        else message " Saved!!! " view-as alert-box information.
    end.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmain no-lock use-index idx_sort.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.
