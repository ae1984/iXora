/*exlc710.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод/редактирование полей МТ710
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
        15/02/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        06/09/2011 id00810 - MT720
        17/01/2012 id00810 - добавлена переменная s-fmt
*/
{global.i}
{LC.i}

def shared var s-lc    like lc.lc.
def shared var v-cif   as char.
def shared var v-lcsts as char.
def shared var s-fmt   as char.
def var v-crc     as int  no-undo.
def var v-crcname as char no-undo.
def var i         as int  no-undo.
def var v-fmt     as char no-undo.
{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmain.
def var v-rid as rowid.

/* find first LCh where LCh.LC = s-lc and LCh.kritcode = 'fmt' no-lock no-error.
if not avail lch then return.
*/
if s-fmt = '760' then return.

find first lch where lch.lc = s-lc and lch.kritcode = 'Advby' no-lock no-error.
if not avail lch or lch.value1 = '' then do:
    message 'Field "Advise by" is compulsory to complete!' view-as alert-box error.
    return.
end.
else do:
    if lch.value1 = '1' then do:
        message 'Your choice in the field "Advise by" is not SWIFT!' view-as alert-box error.
        return.
    end.
    else v-fmt = lch.value1.
end.

define browse b_LC query q_LC
       displ t-LCmain.dataName  format "x(37)"
             t-LCmain.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MT" + v-fmt + " ".
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
define frame f2_LCh3
    t-LCmain.dataName format "x(37)"
    t-LCmain.value1   format "x(35)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 74 no-label overlay column 4 no-box.

define frame f2_cif
    v-cif format "x(65)" validate(can-find(cif where cif.cif = v-cif no-lock),'Enter applicant code!')
    with width 65 no-label overlay column 42 no-box.


if v-fmt = '710' then find first pksysc where pksysc.sysc = 'exlc_adv710' no-lock no-error.
                 else find first pksysc where pksysc.sysc = 'imlc720' no-lock no-error.
if not avail pksysc or pksysc.chval = '' then return.

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
    else do:
        if t-LCmain.kritcode = 'BenCode' and v-cif <> '' then t-LCmain.value1 = v-cif.
        if t-LCmain.kritcode = 'TransRef' then t-LCmain.value1 = s-lc.
        if t-LCmain.kritcode = 'FirstBen' then do:
            find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'Applic' no-lock no-error.
            if avail b-lch then t-LCmain.value1 = b-lch.value1.
        end.
        if t-LCmain.kritcode = 'SecondBn' then do:
            find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'Benef' no-lock no-error.
            if avail b-lch then t-LCmain.value1 = b-lch.value1.
        end.
        if t-LCmain.kritcode = 'StoRInf' then do:
            find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'StoRi710' no-lock no-error.
            if avail b-lch then t-LCmain.value1 = b-lch.value1.
        end.
    end.
    if t-LCmain.kritcode = 'FormC710' and t-LCmain.value1 = '' then do:
        find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'FormCred' no-lock no-error.
        if avail b-lch then t-LCmain.value1 = b-lch.value1 + ' WITHOUT OUR CONFIRMATION'.

    end.
    if lookup(t-LCmain.kritcode,'Sender,InsTo710,IssBank,InstTo') > 0 and t-LCmain.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else t-LCmain.dataValueVis = if index(t-LCmain.value1,chr(1)) > 0 then replace(t-LCmain.value1,chr(1),'')
                                                                        else getVisual(t-LCmain.kritcode,t-LCmain.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:

        if lookup(t-LCmain.kritcode,'Applic,Benef,BenCode,Cover,CollAcc,ComAcc,ExAbout,AdAmtCov,DrfAt,Drawee,MPayDet,DefPayD,DesGood,DocReq,AddCond,Charges,PerPres,InstoBnk,StoRI710,InsTo710,IssBank,InstTo,FormDCrT,FormDCrC') = 0 then return.
        if lookup(t-LCmain.kritcode,'BenCode,CollAcc,ComAcc') > 0 and s-ourbank = 'TXB00' then return.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if lookup(t-LCmain.kritcode,'Applic,Benef,AdAmtCov,DrfAt,Drawee,MPayDet,DefPayD,DesGood,DocReq,AddCond,Charges,PerPres,InstoBnk') > 0 and t-LCmain.value1 <> '' then do:
            empty temp-table wrk.
            do i = 1 to num-entries(t-LCmain.value1,chr(1)):
                create wrk.
                wrk.id = i.
                wrk.txt = entry(i,t-LCmain.value1,chr(1)).
            end.

            {itemlist.i
                &file = "wrk"
                &frame = "column 39 row 17  scroll 1 10 down width 71 no-labels overlay /*title ' Applicant '*/ "
                &where = " true "
                &flddisp = " wrk.id format '>>9' wrk.txt format 'x(65)' "
                &chkey = "id"
                &chtype ="integer"
                &set = "1"
                &index  = "idx"
                &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
        end.

        if  t-LCmain.kritcode = 'StoRI710' then do:
            {editor_update.i
                &var    = "t-LCmain.value1"
                &frame  = "fr1"
                &framep = "column 42 row 5 overlay no-labels width 45 . frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.
         if t-LCmain.kritcode = 'BenCode' then do:
            frame f2_cif:row = b_LC:focused-row + 3.
            update v-cif  with frame f2_cif.
            display v-cif  with frame f2_cif.
            pause 0.
            t-LCmain.value1 = v-cif.
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
        end.
        if lookup(t-LCmain.kritcode,'BenCode') = 0 then do:

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

        if lookup(t-LCmain.kritcode,'InsTo710,IssBank,InstTo') >  0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
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

    if lookup(t-LCmain.kritcode,'InsTo710,IssBank,InstTo') > 0 then do:
        run swiftfind(output t-LCmain.value1).

        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-LCmain.value1 with frame f2_LCh.

    end.

    if lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,CollAcc,ComAcc,DepAcc,IssBank,ReimBnk,InsTo710') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode and LCkrit.LCtype = 'I' /*and LCkrit.priz = v-priz*/ no-lock no-error.
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
    end.
    if i > 0 then message " Saved!!! " view-as alert-box information.

    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmain no-lock use-index idx_sort.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.
