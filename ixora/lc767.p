/* lc767.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Advice of amendment: ввод основных критериев по изменению EXPL/EXPG на основе МТ707/767
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
        10/05/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    02/06/2011 id00810 - v-handle - ввод реквизитов вручную (без SWIFT-сообщения)
    13/06/2011 id00810 - уточнен формат даты авизования
    06/02/2012 id00810 - новый реквизит ComAcc для charges, уточнение значений реквизита AdvBy
 */

{global.i}
{LC.i}
def temp-table t-LCamd no-undo like LCamendh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def shared var s-lc like LC.LC.
def shared var v-cif as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.

def var v-crcname as char.
def var v-crc as int.
def shared var s-amdsts  like lcamend.sts.
def shared var s-lcamend like lcamend.lcamend.
def shared var s-lccor   like lcswt.lccor.
def shared var s-corsts  like lcswt.sts.

def var v-lcsum as deci.
def var v-sp    as char.
def var v-nf    as char.
def var v-handle  as logi.

{LCvalid.i}
def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

def var i as integer no-undo.

define query q_LC for t-LCamd.
def var v-rid as rowid.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'fmt' no-lock no-error.
if avail lcamendh then v-nf = 'MT' + lcamendh.value1.
else v-nf = if s-lcprod = 'exlc' then 'MT707' else 'MT767'.

define browse b_amd query q_LC
       displ t-LCamd.dataName  format "x(37)"
             t-LCamd.dataValueVis format "x(65)"
             with 25 down overlay no-label title v-nf.
def button bsave label "SAVE".
def buffer b-lcamd for t-LCamd.
def buffer b-lcamendh for lcamendh.
define frame f_amd b_amd help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.

on "end-error" of frame f_amd do:
    if s-amdsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_amd.
        else hide all no-pause.

    end.
    else hide all no-pause.

end.
define frame f2_LCamendh
    t-LCamd.dataName format "x(37)"
    t-LCamd.value1 format "x(65)" validate(validh(t-LCamd.kritcode,t-LCamd.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'fname2' no-lock no-error.
if not avail lcamendh then v-handle = yes.

empty temp-table t-LCamd.

v-crc = 0.
find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).

if s-lcprod = 'exsblc' then find first pksysc where pksysc.sysc = 'exlc_advamd' no-lock no-error.
else find first pksysc where pksysc.sysc = s-lcprod + '_advamd' no-lock no-error.
if not avail pksysc then return.
v-sp = pksysc.chval.

empty temp-table t-LCamd.
i = 1.
do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCamd.
    assign
        t-LCamd.LC        = s-lc
        t-LCamd.LCamend   = s-lcamend
        t-LCamd.kritcode  = LCkrit.dataCode
        t-LCamd.showOrder = i
        t-LCamd.dataName  = LCkrit.dataName
        t-LCamd.dataSpr   = LCkrit.dataSpr.

    find first LCamendh where LCamendh.LC = s-lc and LCamendh.LCamend = s-lcamend and LCamendh.kritcode = LCkrit.dataCode no-lock no-error.
    if avail LCamendh then buffer-copy LCamendh except LCamendh.LC to t-LCamd.
    else do:
        if t-LCamd.kritcode = 'Applic' then do:
             find first lch where lch.lc = s-lc and lch.kritcode = 'Applic' no-lock no-error.
             if avail lch and trim(lch.value1) <> '' then  t-LCamd.value1 = lch.value1.
        end.
        if t-LCamd.kritcode = 'ComAcc'   then t-LCamd.dataName = "Client's Account".
        if t-LCamd.kritcode = 'NumAmend' then t-LCamd.value1 = string(s-lcamend,'99').
        if t-LCamd.kritcode = 'SeqTot'   then t-LCamd.value1 = '1/1'.
        if lookup(t-LCamd.kritcode,'RRef,ReceRef') > 0 then t-LCamd.value1 = s-lc.
        /*if t-LCamd.kritcode = 'DtAdvAmd' then t-LCamd.value1 = string(today,'99/99/9999').*/

        t-LCamd.bank = s-ourbank.
    end.

    if t-LCamd.kritcode ='Sender' and t-LCamd.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCamd.value1 no-lock no-error.
        if avail swibic then t-LCamd.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else t-LCamd.dataValueVis = if lookup(t-LCamd.kritcode,'AmendDet,StoRInf,Narrat,Applic,BenAmd') > 0
                                 then replace(t-LCamd.value1,chr(1),'') else getVisual(t-LCamd.kritcode,t-LCamd.value1).

end.

on "enter" of b_amd in frame f_amd do:
    if s-amdsts <> 'NEW' then return.

    if avail t-LCamd then do:
        if lookup(t-LCamd.kritcode,'Sender,SeqTot,TRNum,RRef,FurId,DtAmend,NumAmend,DtIsReq,lcCrc,IncAmt,DecAmt,PerAmtT,PlcCharg,PclFD,LDtShip,ShipPer') > 0 and not v-handle then return.

        if s-lcprod = 'exlc' and (t-LCamd.kritcode = 'NewDtEx' or t-LCamd.kritcode = 'NewAmt') and not v-handle then return.
        b_amd:set-repositioned-row(b_amd:focused-row, "always").
        v-rid = rowid(t-LCamd).
        if lookup(t-LCamd.kritcode,'AmendDet,StoRInf,Narrat,Applic,BenAmd') > 0 then do:
            if not v-handle  then do:
                if t-LCamd.value1 =  '' then return.
                empty temp-table wrk.
                do i = 1 to num-entries(t-LCamd.value1,chr(1)):
                    create wrk.
                    wrk.id = i.
                    wrk.txt = entry(i,t-LCamd.value1,chr(1)).
                end.
                if t-LCamd.kritcode = 'AmendDet' then do:
                {itemlist.i
                    &file = "wrk"
                    &frame = "column 39 row 17  scroll 1 10 down width 71 no-labels overlay title ' Details of Guarantee ' "
                    &where = " true "
                    &flddisp = " wrk.id format '>>9' wrk.txt format 'x(65)' "
                    &chkey = "id"
                    &chtype ="integer"
                    &set = "1"
                    &index  = "idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                    }
                end.
                else if t-LCamd.kritcode = 'Narrat' then do:
                {itemlist.i
                    &file = "wrk"
                    &frame = "column 39 row 17  scroll 1 10 down width 56 no-labels overlay title ' Narrative ' "
                    &where = " true "
                    &flddisp = " wrk.id format '>>9' wrk.txt format 'x(50)' "
                    &chkey = "id"
                    &chtype ="integer"
                    &set = "2"
                    &index  = "idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                    }
                end.
                else do:
                {itemlist.i
                    &file = "wrk"
                    &frame = "column 39 row 18  scroll 1 6 down width 41 no-labels overlay "
                    &where = " true "
                    &flddisp = " wrk.id format '>>9' wrk.txt format 'x(35)' "
                    &chkey = "id"
                    &chtype ="integer"
                    &set = "3"
                    &index  = "idx"
                    &end = "if keyfunction(lastkey) = 'end-error' then return."
                    }
               end.
            end.
            else do:
                if t-LCamd.kritcode = 'AmendDet' then do:
                    {editor_update.i
                        &var    = "t-LCamd.value1"
                        &frame  = "fr1"
                        &framep = "column 35 row 5 overlay no-labels width 75. frame fr1:row = b_amd:focused-row + 2"
                        &chars_in_line  = "65"
                        &num_lines  = "150"
                        &num_down  = "10"
                    }
                end.
                else if t-LCamd.kritcode = 'Narrat' then do:
                    {editor_update.i
                        &var    = "t-LCamd.value1"
                        &frame  = "fr2"
                        &framep = "column 42 row 5 overlay no-labels width 60. frame fr2:row = b_amd:focused-row + 2"
                        &chars_in_line  = "50"
                        &num_lines  = "35"
                        &num_down  = "10"
                    }
                end.
                else do:
                {editor_update.i
                        &var    = "t-LCamd.value1"
                        &frame  = "fr3"
                        &framep = "column 42 row 5 overlay no-labels width 45. frame fr3:row = b_amd:focused-row + 2"
                        &chars_in_line  = "35"
                        &num_lines  = "6"
                        &num_down  = "6"
                    }
                end.
            end.
        end.
        else do:
            frame f2_LCamendh:row = b_amd:focused-row + 3.
            displ t-LCamd.dataName t-LCamd.value1 with frame f2_LCamendh.
            update t-LCamd.value1 with frame f2_LCamendh.
        end.
        if t-LCamd.kritcode = 'AdvBy' and t-LCamd.value1 > '1' then do:
            t-LCamd.value1 = ''.
            return.
        end.
        t-LCamd.dataValueVis = getVisual(t-LCamd.kritcode, t-LCamd.value1).

        open query q_LC for each t-LCamd no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_amd:refresh().
    end.
end.
on help of t-LCamd.value1 in frame f2_LCamendh do:
    if t-LCamd.kritcode = 'Sender' then do:
        run swiftfind(output t-LCamd.value1).

        find first swibic where swibic.bic = t-LCamd.value1 no-lock no-error.
        if avail swibic then t-LCamd.dataValueVis = swibic.bic + ' - ' + swibic.name.
        displ t-LCamd.value1 with frame f2_LCamendh.
    end.
    if t-LCamd.kritcode = 'ComAcc' then do:
        {itemlist.i
         &set = "acc"
         &file = "aaa"
         &findadd = "find first crc where crc.crc = aaa.crc no-lock no-error. v-crcname = ''. if avail crc then v-crcname = crc.code. "
         &frame = "row 6 centered scroll 1 20 down width 40 overlay "
         &where = " aaa.cif = v-cif and aaa.sta <> 'C' and substr(string(aaa.gl),1,4) = '2203' and aaa.crc = 1 "
         &flddisp = " aaa.aaa label 'Account' format 'x(20)' v-crcname label 'Currency' "
         &chkey = "aaa"
         &index  = "aaa-idx1"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCamd.value1 = aaa.aaa.
         displ t-LCamd.value1 with frame f2_LCamendh.
    end.

    find first LCkrit where LCkrit.dataCode = t-LCamd.kritcode  no-lock no-error.
    if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
        find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
        if avail codfr then do:
            {itemlist.i
                &file = "codfr"
                &frame = "row 6 centered scroll 1 20 down width 91 overlay "
                &where = " codfr.codfr = trim(LCkrit.dataSpr) and codfr.code <> 'msc' and ((codfr.codfr = 'exlcadv' and codfr.code <= '1') or (codfr.codfr <> 'exlcadv' and true)) "
                &flddisp = " codfr.code label 'Code' format 'x(8)' codfr.name[1] label 'value' format 'x(80)' "
                &chkey = "code"
                &index  = "cdco_idx"
                &end = "if keyfunction(lastkey) = 'end-error' then return."
            }
            t-LCamd.value1 = codfr.code.
            t-LCamd.dataValueVis = getVisual(t-LCamd.kritcode, t-LCamd.value1).
            displ t-LCamd.value1 with frame f2_LCamendh.
        end.
    end.

end.

def var v-chkMess as char no-undo.
on choose of bsave in frame f_amd do:
    i = 0.
    for each t-LCamd no-lock:

        i = i + 1.
        find first LCamendh where LCamendh.LC = s-lc and LCamendh.LCamend = s-lcamend and LCamendh.kritcode = t-LCamd.kritcode exclusive-lock no-error.
        if not avail LCamendh then create LCamendh.

        buffer-copy t-LCamd to LCamendh.
        if lcamendh.kritcode = 'AdvBy' and lcamendh.value1 = '0' then do:
            find first b-lcamendh where b-lcamendh.lc = s-lc and b-lcamendh.lcamend = s-lcamend and b-lcamendh.kritcode = 'lccor' no-lock no-error.
            if not avail b-lcamendh then do:
                create lcswt.
                assign lcswt.lc     = s-lc
                       lcswt.LCtype = 'E'
                       lcswt.ref    = s-lc
                       lcswt.sts    = 'NEW'
                       lcswt.mt     = 'I799'
                       lcswt.fname2 = 'I799' + replace(trim(s-lc),'/','-') + '_' + string(s-lccor,'99999')
                       lcswt.mt     = 'I799'
                       lcswt.rdt    = g-today
                       lcswt.LCcor  = s-lccor.
                create b-lcamendh.
                assign b-lcamendh.lc       = s-lc
                       b-lcamendh.lcamend  = s-lcamend
                       b-lcamendh.kritcode = 'lccor'
                       b-lcamendh.value1   = string(s-lccor)
                       b-lcamendh.bank     = s-ourbank.
            end.
        end.
        find current LCamendh no-lock no-error.

    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.
open query q_LC for each t-LCamd no-lock use-index idx_sort.

if s-amdsts = 'NEW' then enable all with frame f_amd.
else enable b_amd with frame f_amd.

wait-for window-close of current-window or choose of bsave.
