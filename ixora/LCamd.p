/*LCamd.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод основных критериев по изменеию аккредитива
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        30/11/2010 galina - добавила признак MT707
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        12/05/2011 id00810 - переход на pksysc, изменения в учете сумм, обработка реквизита ShipPer
        28/06/2011 id00810 - ошибка: при создании записей lcamendh не учитывался номер изменения lcamend
        03/08/2011 id00810 - изменение в подсчете текущей суммы LCamtcrA для PG
        03/10/2011 id00810 - проверка лимита
        03/02/2012 id00810 - ошибка: не заполнялось поле bank при создании/обновлении реквизитов LCamtcrA, DtAmend
*/
{global.i}
{LC.i}
def temp-table t-LCamd no-undo like LCamendh
    field showOrder    as integer
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    index idx_sort showOrder.


def shared var s-lc      like LC.LC.
def shared var v-cif     as char.
def shared var v-cifname as char.
def shared var s-lcprod  as char.
def shared var s-amdsts  like lcamend.sts.
def shared var s-lcamend like lcamend.lcamend.

def var v-crcname as char no-undo.
def var v-crc     as int  no-undo.
def var v-lcsum   as deci no-undo.
def var v-sp      as char no-undo.
def var i         as int  no-undo.
def var v-chose   as logi no-undo.
def var v-errMsg  as char no-undo.
def var v-nlim    as int  no-undo.
def var v-lim     as deci no-undo.
def var v-limv    as deci no-undo.
def var v-limcrc  as int  no-undo.


{LCvalid.i}
def temp-table wrk no-undo
  field id  as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCamd.
def var v-rid as rowid.

define browse b_amd query q_LC
       displ t-LCamd.dataName     format "x(37)"
             t-LCamd.dataValueVis format "x(65)"
             with 25 down overlay no-label title " AMEND ".
def button bsave label "SAVE".
def buffer b-lcamd for t-LCamd.
define frame f_amd b_amd help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

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

define frame f1_LCamendh
    t-LCamd.dataName format "x(37)"
    t-LCamd.value1 format "x(16)" validate(validh(t-LCamd.kritcode,t-LCamd.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCamd.

v-crc = 0.
find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).

find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
if avail lch and trim(lch.value1) <> '' then v-nlim = int(lch.value1).

find first pksysc where pksysc.sysc = s-lcprod + '_amd' no-lock no-error.
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

    find first LCamendh where LCamendh.bank = s-ourbank and LCamendh.LC = s-lc and LCamendh.LCamend = s-lcamend and LCamendh.kritcode = LCkrit.dataCode no-lock no-error.

    if t-LCamd.kritcode = 'LCamtcrA' and s-amdsts = 'new' then do:
         v-lcsum = 0.
         find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
         if avail lch and trim(lch.value1) <> '' then do:
            v-lcsum = deci(lch.value1).
            if s-lcprod = 'imlc' or s-lcprod = 'sblc' then do:
                 /*учитываем суммы amendment*/
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
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsum = v-lcsum - lceventres.amt.
                 end.
            end.
            else do:
                 /*учитываем суммы amendment*/
                 for each lcamendres where lcamendres.lc = s-lc and (lcamendres.dacc = '605561' or lcamendres.dacc = '605562' or lcamendres.cacc = '605561' or lcamendres.cacc = '605562') and lcamendres.jh > 0 no-lock:
                     find first jh where jh.jh = lcamendres.jh no-lock no-error.
                     if not avail jh then next.
                     if lcamendres.dacc = '605561' or lcamendres.dacc = '605562' then v-lcsum = v-lcsum + lcamendres.amt.
                     else v-lcsum = v-lcsum - lcamendres.amt.
                 end.

                 /*учитываем суммы payment*/
                 for each lcpayres where lcpayres.lc = s-lc and (lcpayres.dacc = '655561' or lcpayres.dacc = '655562') and lcpayres.jh > 0 no-lock:
                     find first jh where jh.jh = lcpayres.jh no-lock no-error.
                     if avail jh then v-lcsum = v-lcsum - lcpayres.amt.
                 end.
                 /*учитываем суммы event */
                 for each lceventres where lceventres.lc = s-lc and (lceventres.dacc = '655561' or lceventres.dacc = '655562') and lceventres.jh > 0 no-lock:
                     find first jh where jh.jh = lceventres.jh no-lock no-error.
                     if avail jh then v-lcsum = v-lcsum - lceventres.amt.
                 end.
            end.
         end.
         t-LCamd.value1 = string(v-lcsum).
    end.
    else do:
        if avail LCamendh then do:
            if t-LCamd.kritcode = 'DtAmend' and s-amdsts <> 'FIN' then t-LCamd.value1 = string(g-today,'99/99/9999').
            else buffer-copy LCamendh except LCamendh.LC to t-LCamd.
        end.
        else do:
            if t-LCamd.kritcode = 'LCamtA' then do:
                 find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
                 if avail lch and trim(lch.value1) <> '' then  t-LCamd.value1 = lch.value1.
            end.
            if t-LCamd.kritcode = 'CrcA' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.

            if t-LCamd.kritcode = 'DtAmend' then t-LCamd.value1 = string(g-today,'99/99/9999').
            if t-LCamd.kritcode = 'InstTo' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'AdvBank' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.
            if t-LCamd.kritcode = 'SendRef' or t-LCamd.kritcode = 'TRNum' then t-LCamd.value1 = s-lc.
            if t-LCamd.kritcode = 'NumAmend' then t-LCamd.value1 = string(s-lcamend,'99').
            if t-LCamd.kritcode = 'StoRInf' then t-LCamd.value1 = 'BENCON'.
            if t-LCamd.kritcode = 'BenAmd' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'Benef' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.
            if t-LCamd.kritcode = 'NewDtEx' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'DtExp' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.
            if t-LCamd.kritcode = 'PerAmtT' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'PerAmt' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.

            if t-LCamd.kritcode = 'MT707' then t-LCamd.value1 = 'YES'.

            if t-LCamd.kritcode = 'SeqTot' then t-LCamd.value1 = '1/1'.
            if t-LCamd.kritcode = 'DtIsReq' then do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'Date' no-lock no-error.
                if avail lch then t-LCamd.value1 = lch.value1.
            end.
        end.
    end.
    if t-LCamd.kritcode ='InstTo' and t-LCamd.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCamd.value1 no-lock no-error.
        if avail swibic then t-LCamd.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else  t-LCamd.dataValueVis = getVisual(t-LCamd.kritcode,t-LCamd.value1).
    t-LCamd.bank = s-ourbank.

end.

on "enter" of b_amd in frame f_amd do:
    if s-amdsts <> 'NEW' then return.

    if avail t-LCamd then do:
        if lookup(t-LCamd.kritcode,'DtAmend,InstTo,SendRef,NumAmend,StoRInf,NewAmt,LCamtA,LCamtcrA,CrcA,SeqTot,TRNum,DtIsReq') > 0 then return.
        if t-LCamd.kritcode = 'DecAmt' and v-lcsum = 0 then return.
        if t-LCamd.kritcode = 'PerAmtT' then do:
             find first lch where lch.lc = s-lc and lch.kritcode = 'PerAmt' no-lock no-error.
             if (not avail lch) or (lch.value1 = '') then return.

             find first b-lcamd where b-LCamd.kritcode = 'NewAmt' no-lock no-error.
             if avail b-lcamd and trim(b-lcamd.value1) = '' then  return.
        end.

        if t-LCamd.kritcode = 'DecAmt' and t-lcamd.value1 <> '' then do:
             find first b-lcamd where b-LCamd.kritcode = 'IncAmt' no-lock no-error.
             if avail b-lcamd and trim(b-lcamd.value1) <> '' then return.

             if deci(t-lcamd.value1) >= deci(v-lcsum) then do:
                message "The value in field Decrease of Amount must be less than letter of credit Amount!".
                return.
             end.
        end.

        if t-LCamd.kritcode = 'IncAmt' then do:
             find first b-lcamd where b-LCamd.kritcode = 'DecAmt' no-lock no-error.
             if avail b-lcamd and b-lcamd.value1 <> '' then return.
        end.

        b_amd:set-repositioned-row(b_amd:focused-row, "always").
        v-rid = rowid(t-LCamd).
        if  t-LCamd.kritcode = 'Narrat' then do:
            {editor_update.i
             &var    = "t-LCamd.value1"
             &frame  = "fr1"
             &framep = "column 42 row 5 overlay no-labels width 60. frame fr1:row = b_amd:focused-row + 2"
             &chars_in_line  = "50"
             &num_lines  = "35"
             &num_down  = "10"
            }
        end.

        if  t-LCamd.kritcode = 'BenAmd' then do:
            {editor_update.i
                &var    = "t-LCamd.value1"
                &frame  = "fr2"
                &framep = "column 42 row 5 overlay no-labels width 45. frame fr2:row = b_amd:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "4"
                &num_down  = "4"
            }
        end.
        if  t-LCamd.kritcode = 'AmendDet' then do:
            {editor_update.i
             &var    = "t-LCamd.value1"
             &frame  = "fr3"
             &framep = "column 35 row 5 overlay no-labels width 75. frame fr3:row = b_amd:focused-row + 2"
             &chars_in_line  = "65"
             &num_lines  = "150"
             &num_down  = "10"
            }
        end.

        if  t-LCamd.kritcode = 'ShipPer' then do:
            {editor_update.i
             &var    = "t-LCamd.value1"
             &frame  = "fr4"
             &framep = "column 35 row 5 overlay no-labels width 75. frame fr3:row = b_amd:focused-row + 2"
             &chars_in_line  = "65"
             &num_lines  = "6"
             &num_down  = "6"
            }
        end.

        if t-LCamd.kritcode = 'ReceRef' then do:
            frame f1_LCamendh:row = b_amd:focused-row + 3.
            displ t-LCamd.dataName t-LCamd.value1 with frame f1_LCamendh.
            update t-LCamd.value1 with frame f1_LCamendh.
        end.

        if lookup(t-LCamd.kritcode,"Narrat,BenAmd,ReceRef,AmendDet,ShipPer") = 0 then do:

            frame f2_LCamendh:row = b_amd:focused-row + 3.
            displ t-LCamd.dataName t-LCamd.value1 with frame f2_LCamendh.
            update t-LCamd.value1 with frame f2_LCamendh.

            if t-LCamd.kritcode = 'DecAmt' then do:
                if trim(t-lcamd.value1) <> '' then do:
                    find first b-lcamd where b-LCamd.kritcode = 'NewAmt' no-lock no-error.
                    if avail b-lcamd then do:
                        if deci(t-lcamd.value1) > v-lcsum then t-lcamd.value1 = ''.
                        else do:
                            b-lcamd.value1 = string(v-lcsum - deci(t-lcamd.value1)).
                            b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                        end.
                    end.
                end.
                else do:
                    find first b-lcamd where b-LCamd.kritcode = 'NewAmt' no-lock no-error.
                    if avail b-lcamd then do:
                        b-lcamd.value1 = ''.
                        b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                    end.

                    find first b-lcamd where b-LCamd.kritcode = 'PerAmtT' no-lock no-error.
                    if avail b-lcamd then do:
                        b-lcamd.value1 = ''.
                        b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                    end.
                end.
            end.

            if t-LCamd.kritcode = 'IncAmt' then do:
                if trim(t-lcamd.value1) <> '' then do:
                    if v-nlim > 0 then do:
                        v-lim = 0.
                        find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = v-nlim no-lock no-error.
                        if not avail lclimit then do:
                           message "No limit available!" view-as alert-box error.
                           t-lcamd.value1 = ''.
                           return.
                        end.
                        for each lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.jh > 0 no-lock.
                            if substr(lclimitres.dacc,1,2) = '61' then v-lim = v-lim + lclimitres.amt.
                            else v-lim = v-lim - lclimitres.amt.
                        end.
                        if v-lim = 0 then do:
                            message "No limit available!" view-as alert-box error.
                            t-lcamd.value1 = ''.
                            return.
                        end.
                        find first lclimith where lclimith.bank = lclimit.bank and lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lccrc' no-lock no-error.
                        if avail lclimith and lclimith.value1 ne '' then v-limcrc = int(lclimith.value1).

                        find first b-lcamd where b-LCamd.kritcode = 'lcCrc' no-lock no-error.
                        if avail b-lcamd then v-crc = int(b-lcamd.value1).
                        if v-crc = v-limcrc then v-limv = v-lim.
                        else do:
                            find first crc where crc.crc = v-limcrc no-lock no-error.
                            if avail crc then v-limv = v-lim * crc.rate[1].
                            find first crc where crc.crc = v-crc no-lock no-error.
                            if avail crc then v-limv = round(v-limv / crc.rate[1],2).
                        end.
                        if deci(t-lcamd.value1) > v-limv then do:
                            message "The value " + t-lcamd.value1 + "(Increase of Amount)  must be =< " + trim(string(v-limv,'>>>>>>>>>9.99')) + "(Limit)!"  view-as alert-box error.
                            t-lcamd.value1 = ''.
                            return.
                        end.
                    end.
                    find first b-lcamd where b-LCamd.kritcode = 'NewAmt' no-lock no-error.
                    if avail b-lcamd then b-lcamd.value1 = string(v-lcsum + deci(t-lcamd.value1)).
                    b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                end.
                else do:
                    find first b-lcamd where b-LCamd.kritcode = 'NewAmt' no-lock no-error.
                    if avail b-lcamd then do:
                        b-lcamd.value1 = ''.
                        b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                    end.

                    find first b-lcamd where b-LCamd.kritcode = 'PerAmtT' no-lock no-error.
                    if avail b-lcamd then do:
                        b-lcamd.value1 = ''.
                        b-LCamd.dataValueVis = getVisual(b-LCamd.kritcode, b-LCamd.value1).
                    end.
                end.
            end.
        end.

        if t-LCamd.kritcode ='InstTo' and t-LCamd.value1 <> '' then do:
            find first swibic where swibic.bic = t-LCamd.value1 no-lock no-error.
            if avail swibic then t-LCamd.dataValueVis = swibic.bic + ' - ' + swibic.name.
        end.
        else t-LCamd.dataValueVis = getVisual(t-LCamd.kritcode, t-LCamd.value1).

        open query q_LC for each t-LCamd no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_amd:refresh().
    end.
end.
on help of t-LCamd.value1 in frame f2_LCamendh do:
if lookup(t-LCamd.kritcode,'AdvBank,AvlWith,Drawee,CollAcc,ComAcc') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCamd.kritcode  no-lock no-error.
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
                t-LCamd.value1 = codfr.code.
                t-LCamd.dataValueVis = getVisual(t-LCamd.kritcode, t-LCamd.value1).
                displ t-LCamd.value1 with frame f2_LCamendh.
            end.
        end.
    end.
end.

def var v-chkMess as char no-undo.
on choose of bsave in frame f_amd do:
    i = 0.
    for each t-LCamd no-lock:

        i = i + 1.
        find first LCamendh where LCamendh.bank = s-ourbank and LCamendh.LC = s-lc and lcamendh.lcamend = s-lcamend and LCamendh.kritcode = t-LCamd.kritcode exclusive-lock no-error.
        if not avail LCamendh then create LCamendh.

        buffer-copy t-LCamd to LCamendh.
        find current LCamendh no-lock no-error.

    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCamd no-lock.

if s-amdsts = 'NEW' then enable all with frame f_amd.
else enable b_amd with frame f_amd.

wait-for window-close of current-window or choose of bsave.




