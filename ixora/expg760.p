/*expg760.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод/редактирование основных критериев EXPG
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
        20/12/2010 id00810 (на основе lcmain.p)
 * BASES
        BANK COMM
 * CHANGES
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        13/12/2011 id00810 - возможность заполнить поле Date, если оно пустое после импорта свифта
        18.06.2012 Lyubov  - дата вводится по формату dd:mm:yyyy
        21.06.2012 Lyubov  - увеличила поле Benef на 15 символов
        18.07.2012 Lyubov  - исправлен формат даты поля date при выводе
*/
{global.i}
{LC.i}

def shared var s-lc like LC.LC.
def shared var v-cif        as char.
def shared var v-lcsts      as char.
def shared var v-lcsumcur   as deci.
def shared var v-lcsumorg   as deci.
def shared var v-lccrc1     as char.
def shared var v-lccrc2     as char.
def shared var v-lcdtexp    as date format '99/99/9999'.
def var v-crcname as char.
def var v-crc     as int.
def var v-lc      like lc.lc.
def var v-cif1    as char.
def var v-handle  as logi.
def var i         as int.
def buffer b-lc for lc.
{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCmain.
def var v-rid as rowid.

define browse b_LC query q_LC
       displ t-LCmain.dataName  format "x(37)"
             t-LCmain.dataValueVis format "x(65)"
             with 25 down overlay no-label title " MT760 ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmain.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose  as logi init yes.
def var v-chose1 as logi.
def var v-errMsg as char no-undo.
def var v-bank   as char.

assign v-lc   = s-lc
       v-cif1 = v-cif.
on "end-error" of frame f_LC do:
    if v-lcsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else do:
            if v-cif <> v-cif1 then v-cif = v-cif1.
            hide all no-pause.
        end.
    end.
    else hide all no-pause.
end.

define frame f2_LCh
    t-LCmain.dataName format "x(37)"
    t-LCmain.value1   format "x(65)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_LCh1
    t-LCmain.dataName format "x(35)"
    t-LCmain.value1   format "x(1)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_cif
    v-cif format "x(65)" validate(can-find(cif where cif.cif = v-cif no-lock),'Enter applicant code!')
    with width 65 no-label overlay column 42 no-box.


find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' no-lock no-error.
if not avail lch then v-handle = yes.

find first pksysc where pksysc.sysc = 'expg_adv' no-lock no-error.
if not avail pksysc then return.

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
        t-LCmain.dataSpr   = LCkrit.dataSpr.

    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then do:
        if t-LCmain.kritcode = 'DtAdv' and v-lcsts <> 'FIN' then t-LCmain.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCh except LCh.LC to t-LCmain.
    end.
    else do:
        if t-LCmain.kritcode = 'BankRef' then t-LCmain.value1 = s-lc.
        if t-LCmain.kritcode = 'BenCode' and v-cif <> '' then t-LCmain.value1 = v-cif.
        t-LCmain.bank = s-ourbank.
    end.
    if t-LCmain.kritcode = 'Sender'and t-LCmain.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else t-LCmain.dataValueVis = if lookup(t-LCmain.kritcode,'DetGar,StoRInf') > 0 then replace(t-LCmain.value1,chr(1),'')
                                                                            else getVisual(t-LCmain.kritcode,t-LCmain.value1).
    if t-LCmain.kritcode = 'Date' then do:
        find first LCh where LCh.LC = s-lc and LCh.kritcode = 'Date' no-lock no-error.
        if avail lch then do:
            t-LCmain.value1 = string(date(lch.value1),'99/99/9999').
            t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
        end.
    end.

end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:

        if lookup(t-LCmain.kritcode,'SeqTot,TrNum,AppRule,FurId,StoRInf') > 0 and not v-handle then return.
        if t-LCmain.kritcode = 'Date' and t-LCmain.value1 ne '' and not v-handle then return.
        if lookup(t-LCmain.kritcode,'BenCode,CollAcc,ComAcc') > 0 and s-ourbank = 'TXB00' then return.
        if t-LCmain.kritcode = 'BenCode' and  v-cif <> '' then return.
        if t-LCmain.kritcode = 'BankRef' and  t-LCmain.value1 <> 'EXPG00000/10' then return.
        if t-LCmain.kritcode = 'CoGarRef' then do:
            find first b-lcmain where b-LCmain.kritcode = 'CoGarDet' no-lock no-error.
            if not avail b-lcmain or b-lcmain.value1 = 'no' then return.
        end.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if lookup(t-LCmain.kritcode,'DtExp,Date,DtAdv') > 0 then do:
            v-lcdtexp = date(t-LCmain.value1).
            frame f2_LCh1:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName v-lcdtexp with frame f2_LCh1.
            update v-lcdtexp with frame f2_LCh1.
            t-LCmain.value1 = string(v-lcdtexp, '99/99/9999').
        end.

        if  t-LCmain.kritcode = 'Benef' then do:
            {editor_update.i
                &var    = "t-LCmain.value1"
                &frame  = "fr1"
                &framep = "column 42 row 5 overlay no-labels width 60 . frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "50"
                &num_lines  = "4"
                &num_down  = "4"
            }
        end.

        if  t-LCmain.kritcode = 'Princ' then do:
            {editor_update.i
                &var    = "t-LCmain.value1"
                &frame  = "fr12"
                &framep = "column 42 row 5 overlay no-labels width 45 . frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "4"
                &num_down  = "4"
            }
        end.

        if lookup(t-LCmain.kritcode,'DetGar') > 0 then do:
            if not v-handle and t-LCmain.value1 <> '' then do:
                empty temp-table wrk.
                do i = 1 to num-entries(t-LCmain.value1,chr(1)):
                    create wrk.
                    wrk.id = i.
                    wrk.txt = entry(i,t-LCmain.value1,chr(1)).
                end.

                {itemlist.i
                        &file = "wrk"
                        &frame = "column 38 row 25  scroll 1 10 down width 71 no-labels overlay title ' Details of Guarantee ' "
                        &where = " true "
                        &flddisp = " wrk.id format '>>9' wrk.txt format 'x(65)' "
                        &chkey = "id"
                        &chtype ="integer"
                        &set = "1"
                        &index  = "idx"
                        &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
            end.
            else do:
                {editor_update.i
                 &var    = "t-LCmain.value1"
                 &frame  = "fr10"
                 &framep = "column 38 row 25 overlay no-labels width 75. frame fr1:row = b_LC:focused-row + 2"
                 &chars_in_line  = "65"
                 &num_lines  = "150"
                 &num_down  = "10"
            }

            end.
        end.

        if lookup(t-LCmain.kritcode,'StoRInf') > 0 then do:
            if not v-handle and t-LCmain.value1 <> '' then do:
                empty temp-table wrk.
                do i = 1 to num-entries(t-LCmain.value1,chr(1)):
                    create wrk.
                    wrk.id = i.
                    wrk.txt = entry(i,t-LCmain.value1,chr(1)).
                end.

                {itemlist.i
                        &file = "wrk"
                        &frame = "column 38 row 25  scroll 1 6 down width 41 overlay title ' Sender to Reciever Information ' "
                        &where = " true "
                        &flddisp = " wrk.id format '>>9' wrk.txt format 'x(35)' "
                        &chkey = "id"
                        &chtype ="integer"
                        &set = "2"
                        &index  = "idx"
                        &end = "if keyfunction(lastkey) = 'end-error' then return."
                }
            end.
            else do:
                {editor_update.i
                    &var    = "t-LCmain.value1"
                    &frame  = "fr11"
                    &framep = "column 38 row 25 overlay no-labels width 45. frame fr1:row = b_LC:focused-row + 2"
                    &chars_in_line  = "35"
                    &num_lines  = "6"
                    &num_down  = "6"
                }
            end.

        end.

        if t-LCmain.kritcode = 'BenCode' then do:
            frame f2_cif:row = b_LC:focused-row + 3.
            /*frame f2_cif:row = frame f2_LCh:row.*/
            update v-cif  with frame f2_cif.
            display v-cif  with frame f2_cif.
            pause 0.
            t-LCmain.value1 = v-cif.
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
        end.

        if lookup(t-LCmain.kritcode,'Benef,BenCode,DetGar,StoRInf,DtExp,Date,DtAdv') = 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
        end.

        if t-LCmain.kritcode = 'BankRef' then do:
            find first b-lc where b-lc.lc =  trim(t-LCmain.value1) no-lock no-error.
            if avail b-lc then do:
               message trim(t-LCmain.value1) + " already exits!".
               t-LCmain.value1 = ''.
            end.
            else v-lc = t-LCmain.value1.
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

        if t-LCmain.kritcode = 'lcCrc' then do:
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
        end.

        t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).

        open query q_LC for each t-LCmain no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCmain.value1 in frame f2_LCh do:
    if t-LCmain.kritcode = 'Sender' then do:
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
    if lookup(t-LCmain.kritcode,'CollAcc,ComAcc') = 0 then do:
       find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &set = "codfr"
                    &file = "codfr"
                    &frame = "row 7 centered scroll 1 20 down width 91 overlay "
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
   if s-ourbank = 'TXB00' then do:
        message 'Do you want to pass this EXPG to filial?'  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose1.
        if v-chose1 then do:
            if v-lc = 'EXPG00000/10' then do:
                message "It's impossible to pass EXPG to filial! You need to correct Bank's Reference!"  view-as alert-box error.
                v-chose1 = no.
            end.
            else do:
                {sel-filial.i}.
                find txb where txb.consolid = true and txb.txb = v-select - 2 no-lock no-error.
                v-bank = txb.bank.
            end.
          end.
    end.
    i = 0.
    for each t-LCmain no-lock:

        i = i + 1.
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCmain.kritcode exclusive-lock no-error.
        if not avail LCh then create LCh.

        buffer-copy t-LCmain to LCh.
        if v-lc <> s-lc then lch.lc = v-lc.
        if v-chose1 then lch.bank = v-bank.
        /*   if v-lc <> s-lc then lch.lc = v-lc.
        end.*/
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
        if lookup(t-LCmain.kritcode,'DtExp,Date,DtAdv') > 0 and lch.value1 <> ?
        then v-lcdtexp = date(lch.value1).
    end.
    if v-lc <> s-lc then do:
         find first LC where LC.lc = s-lc exclusive-lock no-error.
         if avail lc then do:
            lc.lc = v-lc.
            /*s-lc = v-lc.*/
            find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' no-lock no-error.
            if avail lch then do:
                find first lcswt where lcswt.fname2 = trim(lch.value1) no-lock no-error.
                if avail lcswt then do:
                    find current lcswt exclusive-lock no-error.
                    lcswt.lc = v-lc.
                    find current lcswt no-lock no-error.
                end.
                find current lch exclusive-lock no-error.
                lch.lc = v-lc.
            end.
            find current lc no-lock no-error.
            s-lc = v-lc.
         end.
    end.
    if v-chose1 then do:
        find first LC where LC.lc = s-lc exclusive-lock no-error.
        if avail lc then lc.bank = v-bank.
        find current LC no-lock no-error.
        find first lch where lch.lc = s-lc and lch.kritcode = 'fname2' exclusive-lock no-error.
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




