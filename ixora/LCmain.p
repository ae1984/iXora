/*LCmain.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод основных критериев аккредитива
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        10/09/2010 galina - явно указала ширину фреймов fr1,fr2
        05/10/2010 galina - поправила определение даты
                            редактировать может только тот, кто завел аккредитив
        07/10/2010 galina - перекомпиляция
        25/11/2010 galina - перекомпеляция
        30/11/2010 galina - добавила признак MT700
        06/12/2010 galina - убрала проверку на пользователя, который заводил аккредитив
        05/01/2011 id00810 - обновление переменных для фрейма frlc
        26/01/2011 id00810 - для импортной гарантии
        28/02/2011 id00810 - убрала проверку валюты для счета комиссии ComAcc
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        20/04/2011 id00810 - для резервного аккредитива SBLC
        13/07/2011 id00810 - новые реквизиты: 'MT760' -  для PG , 'ArpAcc' - для всех
        29/07/2011 id00810 - новый реквизит DepAcc для PG
        15/08/2011 id00810 - добавлено MT720, объединены опции Main,Shipment, Other Details
        08/09/2011 id00810 - уточнен формат полей во фреймах f2_LCh, f2_LCh3
        29/09/2011 id00810 - новые реквизиты 'NLim'(для лимита), 1CB*(для выгрузки в ПКБ))
        18/10/2011 id00810 - если статус не FIN,CLS,CNL, то реквизиты DtIs,Date равны текущей дате
        24/10/2011 id00810 - Advthrou - опция D - не отображалось значение реквизита
        27/10/2011 id00810 - возможность выбора номера лимита и соотв.проверка суммы(f-provlim)
        17/01/2012 id00810 - добавлена новая переменная s-fmt
        07/06/2012 Lyubov  - добавила КОД, КБЕ, КНП
        18.06.2012 Lyubov  - дата вводится по формату dd:mm:yyyy
        06.02.2013 dmitriy - добавление Partial Covered при выборе залога, поля Covered и Uncovered
        07/03/2013 sayat(id01143) - ТЗ 1707 от 07/02/2013 добавлено поле "Страна бенефициара"(1CBbcntr - 278)
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013 отключено использование полй для ПКБ ((1CB) - 216,217,278,218,219,220)
                                    перенесены в другую программу 1cbmain (п.м. 14-11)
        09/09/2013 galina - добавила редактирование полей PLAD и PDAD
        18.11.2013 Lyubov  - ТЗ 2125, добавила obligation validity
        21.11.2013 Lyubov  - ТЗ 1363, добавила критерий forte confirmation

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
def shared var v-lcdtexp  as date format '99/99/9999'.
def shared var v-oblval   as date format '99/99/9999'.
def shared var s-lcprod   as char.
def shared var s-lccor    like lcswt.lccor.
def shared var s-corsts   like lcswt.sts.
def shared var s-fmt      as char.
def var v-crcname  as char no-undo.
def var v-crc      as int  no-undo.
def var v-priz     as char no-undo.
def var v-sp       as char no-undo.
def var v-arp      as char no-undo.
def var i          as int  no-undo.
def var v-chose    as logi no-undo.
def var v-errMsg   as char no-undo.
def var v-advopt   as char no-undo.
def var v-720      as logi no-undo.
def var v-per      as int  no-undo.
def var v-amt      as deci no-undo.
def var v-1cb      as logi no-undo.
def var v-cover    as char no-undo.
def var v-nlim     as int  no-undo.
def var v-limsum1  as deci no-undo.
def var v-limsum2  as deci no-undo.
def var v-lim      as deci no-undo.
def var v-limv     as deci no-undo.
def var v-limcrc   as int  no-undo.
def var cover      as char no-undo.
def var v-covered as char.
def var v-uncovered as char.
def var v-forcon   as logi no-undo.

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
             with 25 down overlay no-label title " MAIN ".
def button bsave label "SAVE".
def buffer b-lcmain for t-LCmain.
def buffer b-lch for lch.
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
    t-LCmain.value1   format "x(35)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_LCh3
    t-LCmain.dataName format "x(37)"
    t-LCmain.value1   format "x(65)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_LCh1
    t-LCmain.dataName format "x(35)"
    t-LCmain.value1   format "x(1)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_LCh2
    t-LCmain.dataName format "x(35)"
    t-LCmain.value1   format "x(1)" validate(validh(t-LCmain.kritcode,t-LCmain.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

function f-provlim returns logi.
    v-lim = 0.
    find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = v-nlim no-lock no-error.
    if not avail lclimit then return no.
    for each lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.jh > 0 no-lock.
        if substr(lclimitres.dacc,1,2) = '61' then v-lim = v-lim + lclimitres.amt.
        else v-lim = v-lim - lclimitres.amt.
    end.
    if v-lim = 0 then do:
        message "No limit available!" view-as alert-box error.
        return no.
    end.
    find first lclimith where lclimith.bank = lclimit.bank and lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lccrc' no-lock no-error.
    if avail lclimith and lclimith.value1 ne '' then v-limcrc = int(lclimith.value1).

    find first b-lcmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
    if avail b-lcmain then v-crc = int(b-lcmain.value1).
    if v-crc = v-limcrc then v-limv = v-lim.
    else do:
        find first crc where crc.crc = v-limcrc no-lock no-error.
        if avail crc then v-limv = v-lim * crc.rate[1].
        find first crc where crc.crc = v-crc no-lock no-error.
        if avail crc then v-limv = round(v-limv / crc.rate[1],2).
    end.
    if v-amt > v-limv then do:
        message "The value " + string(v-amt,'>>>>>>>>>9.99') + "(Amount with Percent Credit Amount Tolerance)  must be =< " + trim(string(v-limv,'>>>>>>>>>9.99')) + "(Limit)!"  view-as alert-box error.
        return no.
    end.
    return yes.
end function.

find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
if avail lch and lch.value1 <> '' then v-crc = int(lch.value1).

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'AdvThOpt' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-advopt = LCh.value1.

find first LCh where LCh.LC = s-lc and LCh.kritcode = '1cbyes' no-lock no-error.
if avail LCh and LCh.value1 = '01' then v-1cb = yes.

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'Cover' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-cover = LCh.value1.

/* dmitriy ------*/
find first LCh where LCh.LC = s-lc and LCh.kritcode = 'CovAmt' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-covered = LCh.value1.

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'UncAmt' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-uncovered = LCh.value1.
/*---------------*/

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'forcon' no-lock no-error.
if avail LCh and LCh.value1 = 'yes' then v-forcon = yes.

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'NLim' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-nlim = int(LCh.value1).

find first LCh where LCh.LC = s-lc and LCh.kritcode = 'Amount' no-lock no-error.
if avail lch and lch.value1 <> '' then do:
    v-amt = deci(lch.value1).
    find first LCh where LCh.LC = s-lc and LCh.kritcode = 'PerAmt' no-lock no-error.
    if avail lch and lch.value1 <> '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then v-amt = v-amt + (v-amt * (v-per / 100)).
    end.
end.

empty temp-table t-LCmain.

if s-lcprod = 'imlc'    then do:
    if s-fmt = '700' or s-fmt = '' then v-priz = 'm,s,o'.
    else do:
        v-720 = yes.
        find first pksysc where pksysc.sysc = 'imlc720' no-lock no-error.
        if not avail pksysc then return.
        else v-sp = pksysc.chval.
    end.
end.
else if s-lcprod = 'pg' then v-priz = 'g,i'.
else v-priz = if s-fmt = '700' then 'm,s,o' else 'g,i'.

if v-priz ne '' then
for each LCkrit where LCkrit.LCtype = 'I' and lookup(LCkrit.priz,v-priz) > 0 no-lock:
    v-sp = if v-sp = '' then string(lckrit.showorder) else v-sp + ',' + string(lckrit.showorder).
end.
if s-lcprod = 'sblc' then v-sp = v-sp + ',' + '183'.

if lookup('13',v-sp) > 0 then v-sp = replace(v-sp,',13,',',13,215,').
if lookup('128',v-sp) > 0 then v-sp = replace(v-sp,',128,',',128,215,').

/*if not v-720 then v-sp = v-sp + ',' + '216,217,278,218,219,220'.*/

if not v-720 then do:
    v-sp = replace(v-sp,',12,',',12,76,256,78,').         /*EKNP*/
    v-sp = replace(v-sp,'276,277,','').                   /*Covered/Uncovered amt*/
    v-sp = replace(v-sp,',215,',',276,277,215,').           /*EKNP*/
end.
if s-lcprod = 'pg' then v-sp = replace(v-sp,',122,',',122,76,256,78,'). /*EKNP*/
if s-lcprod = 'pg' then v-sp = replace(v-sp,',119,',',119,257,'). /*Forte Confirmation*/

do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCmain.
    assign t-LCmain.LC        = s-lc
           t-LCmain.kritcode  = LCkrit.dataCode
           t-LCmain.showOrder = i
           t-LCmain.dataName  = LCkrit.dataName
           t-LCmain.dataSpr   = LCkrit.dataSpr
           t-LCmain.bank      = s-ourbank.
    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then do:
        if lookup(t-LCmain.kritcode,'DtIs,Date') > 0 and lookup(v-lcsts,'FIN,CLS,CNL') = 0 then t-LCmain.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCh except LCh.LC to t-LCmain.
    end.
    else do:
        if t-LCmain.kritcode = 'CreditN' or t-LCmain.kritcode = 'TRNum' or t-LCmain.kritcode = 'TransRef' then t-LCmain.value1 = s-lc.
        if t-LCmain.kritcode = 'ApplCode' or t-LCmain.kritcode = 'PrCode' then t-LCmain.value1 = v-cif.
        if t-LCmain.kritcode = 'SeqTot' then t-LCmain.value1 = '1/1'.
        if t-LCmain.kritcode = 'DtIs' or t-LCmain.kritcode = 'Date' then t-LCmain.value1 = string(g-today,'99/99/9999').
        if t-LCmain.kritcode = 'MT700' then t-LCmain.value1 = 'YES'.
        if t-LCmain.kritcode = 'MT799' then t-LCmain.value1 = 'YES'.
        if t-LCmain.kritcode = 'MT760' then t-LCmain.value1 = 'YES'.
        if t-LCmain.kritcode = 'ForCon' then t-LCmain.value1 = 'NO'.
        if t-LCmain.kritcode = 'AppRule' then t-LCmain.value1 = if lookup('i',v-priz) > 0 then 'OTHR/SEE FIELD 77C' else 'UCP LATEST VERSION'.

        if v-cover = '0' or v-cover = '2' then do:
            if t-LCmain.kritcode = 'KOD' then do:
                find cif where cif.cif = v-cif no-lock no-error.
                if avail cif then t-LCmain.value1 = substr(cif.geo,3,1).
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                if avail sub-cod then t-LCmain.value1 = t-LCmain.value1 + sub-cod.ccode.
            end.
            if t-LCmain.kritcode = 'KBEi' then t-LCmain.value1 = '14'.
            if t-LCmain.kritcode = 'KNP' then t-LCmain.value1 = '181'.
        end.
        if v-cover = '1' or v-cover = '' then do:
            if t-LCmain.kritcode = 'KOD' then  t-LCmain.value1 = ''.
            if t-LCmain.kritcode = 'KBEi' then t-LCmain.value1 = ''.
            if t-LCmain.kritcode = 'KNP' then t-LCmain.value1 = ''.
        end.

    end.
    if (lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,IssBank,ReimBnk') > 0 or (t-LCmain.kritcode = 'AdvThrou' and v-advopt = 'A')) and t-LCmain.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCmain.value1 no-lock no-error.
        if avail swibic then t-LCmain.dataValueVis = swibic.bic + ' - ' + swibic.name.
    end.
    else  t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' and v-lcsts <> 'FIN' then return.
    if v-lcsts = 'FIN' and v-cover = '0' then return.
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:

        if v-lcsts = 'FIN' and v-cover = '1' and lookup(t-LCmain.kritcode,'1cbyes,1cbclas,1cbctype,1cbcval,1cbccrc') = 0 then return.
        if lookup(t-LCmain.kritcode,'CreditN,TRNum,SendRef,ApplCode,PrCode,SeqTot,DtIs,Date,AppRule,KOD,KBEi,KNP') > 0 then return.

        if t-LCmain.kritcode = 'DtExp' then do:
            v-lcdtexp = date(t-LCmain.value1).
            frame f2_LCh1:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName v-lcdtexp with frame f2_LCh1.
            update v-lcdtexp with frame f2_LCh1.
            t-LCmain.value1 = string(v-lcdtexp, '99/99/9999').
        end.

        if t-LCmain.kritcode = 'PerAmt' then do:
            if v-priz ne '' then do:
                find first b-lcmain where b-LCmain.kritcode = 'ExAbout' no-lock no-error.
                if not avail b-lcmain or b-lcmain.value1 = '0' then return.
            end.
            else do:
                find first b-lcmain where b-LCmain.kritcode = 'MaxCrAmt' no-lock no-error.
                if avail b-lcmain then if b-lcmain.value1 ne '' then return.
            end.
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
        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        if t-LCmain.kritcode = 'OblValid' then do:
            find first b-lcmain where b-LCmain.kritcode = 'By' no-lock no-error.
            if not avail b-lcmain or b-lcmain.value1 <> '2' then return.
            else do:
                v-oblval = date(t-LCmain.value1).
                frame f2_LCh2:row = b_LC:focused-row + 3.
                displ t-LCmain.dataName v-oblval with frame f2_LCh2.
                update v-oblval with frame f2_LCh2.
                t-LCmain.value1 = string(v-oblval, '99/99/9999').
            end.
        end.

        if  lookup(t-LCmain.kritcode,'Applic,Princ,Benef,DefPayD,FirstBen,SecondBn,AdAmCov,MPayDet,DefPayD,PerPres') > 0 then do:
            {editor_update.i
                &var            = "t-LCmain.value1"
                &frame          = "fr1"
                &framep         = "column 42 row 5 overlay no-labels width 45. frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines      = "4"
                &num_down       = "4"
            }
        end.

        if  lookup(t-LCmain.kritcode,'PlcCharg,PclFD,PLAD,PDAD') > 0 then do:
            frame f2_LCh3:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName  t-LCmain.value1 with frame f2_LCh3.
            update t-LCmain.value1 with frame f2_LCh3.
        end.

        if lookup(t-LCmain.kritcode,'Charges,StoRInf') > 0  then do:
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

        if lookup(t-LCmain.kritcode,"DtExp,OblValid,DrfAt,DefPayD,Applic,Benef,FirstBen,SecondBn,AdAmCov,MPayDet,PerPres,DesGood,DocReq,AddCond,StoRInf,ShipPer,InsToBnk,LDtmain,PlcCharg,PclFD,AdvThrou") = 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
        end.

        if t-LCmain.kritcode = 'NLim' then do:
            v-nlim = int(t-lcmain.value1).
            if v-nlim > 0 and v-amt > 0 and not f-provlim() then do:
               t-LCmain.value1 = ''.
               return.
            end.
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

        if t-LCmain.kritcode = 'ExAbout' and t-LCmain.value1 = '0' then do:
            find first b-LCmain where b-LCmain.kritcode = 'PerAmt' exclusive-lock no-error.
            if avail  b-LCmain then do:
                find current b-lcmain exclusive-lock no-error.
                b-LCmain.value1 = ''.
                b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                find current b-lcmain no-lock no-error.
            end.
        end.

        if t-LCmain.kritcode = 'CollAcc' then do:
            find first aaa where aaa.aaa = trim(t-LCmain.value1) no-lock no-error.
            if avail aaa then do:
                find first b-LCmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
                if avail  b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = string(aaa.crc).
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'forcon' then do:
            v-forcon = if t-lcmain.value1 = 'yes' then yes else no.
            if v-forcon then do:
                find first b-LCmain where b-LCmain.kritcode = 'Comacc' no-lock no-error.
                if avail  b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'ComAcc' and not v-forcon then do:
            find first aaa where aaa.aaa = trim(t-LCmain.value1) no-lock no-error.
            if avail aaa then do:
                find first b-LCmain where b-LCmain.kritcode = 'Cover' no-lock no-error.
                if avail b-LCmain and b-LCmain.value1 = '1' then do:
                    find first b-LCmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
                    if avail  b-LCmain then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(aaa.crc).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'DepAcc' then do:
            find first aaa where aaa.aaa = trim(t-LCmain.value1) no-lock no-error.
            if avail aaa then do:
                find first b-LCmain where b-LCmain.kritcode = 'lcCrc' no-lock no-error.
                if avail  b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = string(aaa.crc).
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'Cover' then do:
            if t-LCmain.value1 = '1' then do:
                find first b-LCmain where b-LCmain.kritcode = 'Collacc' no-lock no-error.
                if avail  b-LCmain and b-LCmain.value1 <> '' then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
                if s-lcprod = 'pg' then do:
                    find first b-LCmain where b-LCmain.kritcode = 'DepAcc' no-lock no-error.
                    if avail  b-LCmain and b-LCmain.value1 <> '' then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = ''.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
                if v-forcon then do:
                    find first b-LCmain where b-LCmain.kritcode = 'Comacc' no-lock no-error.
                    if avail  b-LCmain and b-LCmain.value1 <> '' then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = ''.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
            else if v-1cb then do:
                find first b-LCmain where b-LCmain.kritcode = '1CBclas' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '1' then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '1'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
                find first b-LCmain where b-LCmain.kritcode = '1CBctype' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '10' then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '10'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
                find first b-LCmain where b-LCmain.kritcode = 'Amount' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '' then do:
                    v-amt = deci(b-lcmain.value1).
                    find first b-LCmain where b-LCmain.kritcode = 'PerAmt' no-lock no-error.
                    if avail  b-LCmain and b-lcmain.value1 <> '' then do:
                        v-per = int(entry(1,lch.value1, '/')).
                        if v-per > 0 then v-amt = v-amt + (v-amt * (v-per / 100)).
                    end.
                    find first b-LCmain where b-LCmain.kritcode = '1CBcval' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-amt then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-amt).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                    find first b-LCmain where b-LCmain.kritcode = '1CBccrc' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-crc then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-crc).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
        end.

       if t-LCmain.kritcode = 'Cover' then do:
            if t-LCmain.value1 = '0' then do:
                find cif where cif.cif = v-cif no-lock no-error.
                if avail cif then do:
                    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                    if avail sub-cod then do:
                        find first b-LCmain where b-LCmain.kritcode = 'KOD' no-lock no-error.
                        if avail b-LCmain then do:
                            find current b-LCmain exclusive-lock no-error.
                            b-LCmain.value1 = substr(cif.geo,3,1) + sub-cod.ccode.
                            b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        end.
                    end.
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KBEi' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '14'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KNP' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '181'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
            end.
            if t-LCmain.value1 = '1' or t-LCmain.value1 = '' then do:
                find first b-LCmain where b-LCmain.kritcode = 'KOD' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KBEi' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KNP' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = ''.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
            end.
           /* dmitriy --------------------------*/
            if t-LCmain.value1 = '2' then do:
                find cif where cif.cif = v-cif no-lock no-error.
                if avail cif then do:
                    find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                    if avail sub-cod then do:
                        find first b-LCmain where b-LCmain.kritcode = 'KOD' no-lock no-error.
                        if avail b-LCmain then do:
                            find current b-LCmain exclusive-lock no-error.
                            b-LCmain.value1 = substr(cif.geo,3,1) + sub-cod.ccode.
                            b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        end.
                    end.
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KBEi' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '14'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
                find first b-LCmain where b-LCmain.kritcode = 'KNP' no-lock no-error.
                if avail b-LCmain then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '181'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                end.
            end.
           /*-----------------------------------*/
        end.

        if t-LCmain.kritcode = 'lcCrc' then do:
            find first crc where crc.crc = int(trim(t-LCmain.value1)) no-lock no-error.
            if avail crc then do:
                v-crc = int(trim(t-LCmain.value1)).
                find first b-LCmain where b-LCmain.kritcode = 'CollAcc' no-lock no-error.
                if avail b-LCmain and trim(b-LCmain.value1) <> '' then do:
                    find first aaa where aaa.aaa = trim(b-LCmain.value1) no-lock no-error.
                    if avail aaa and crc.crc <> aaa.crc then do:
                        message "The currency of Collateral Debit Account shoud be the same with Currency Code!" view-as alert-box error.
                        t-LCmain.value1 = ''.
                        return.
                    end.
                end.
                if s-lcprod = 'pg' then do:
                    find first b-LCmain where b-LCmain.kritcode = 'DepAcc' no-lock no-error.
                    if avail b-LCmain and trim(b-LCmain.value1) <> '' then do:
                        find first aaa where aaa.aaa = trim(b-LCmain.value1) no-lock no-error.
                        if avail aaa and crc.crc <> aaa.crc then do:
                            message "The currency of Collateral Deposit Account shoud be the same with Currency Code!" view-as alert-box error.
                            t-LCmain.value1 = ''.
                            return.
                        end.
                    end.
                end.
                if v-nlim > 0 and v-amt > 0 and not f-provlim() then do:
                    t-LCmain.value1 = ''.
                    return.
                end.
                if v-1cb then do:
                    find first b-LCmain where b-LCmain.kritcode = '1CBccrc' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-crc then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-crc).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
        end.

        /* dmitriy --------------------------*/
        if t-LCmain.kritcode = 'CovAmt' then do:
            find cif where cif.cif = v-cif no-lock no-error.
            /*if avail cif then do:
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                if avail sub-cod then do:
                    find first b-LCmain where b-LCmain.kritcode = 'KOD' no-lock no-error.
                    if avail b-LCmain then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = substr(cif.geo,3,1) + sub-cod.ccode.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    end.
                end.
            end.*/
            find first b-LCmain where b-LCmain.kritcode = 'UncAmt' no-lock no-error.
            if avail b-LCmain then v-uncovered = b-LCmain.value1.

            find first b-LCmain where b-LCmain.kritcode = 'Amount' no-lock no-error.
            if avail b-LCmain then do:
                find current b-LCmain exclusive-lock no-error.
                b-LCmain.value1 = string(deci(t-LCmain.value1) + deci(v-uncovered)).
                b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
            end.
        end.

        if t-LCmain.kritcode = 'UncAmt' then do:
            find cif where cif.cif = v-cif no-lock no-error.
            /*if avail cif then do:
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek' no-lock no-error.
                if avail sub-cod then do:
                    find first b-LCmain where b-LCmain.kritcode = 'KOD' no-lock no-error.
                    if avail b-LCmain then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = substr(cif.geo,3,1) + sub-cod.ccode.
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    end.
                end.
            end.*/
            find first b-LCmain where b-LCmain.kritcode = 'CovAmt' no-lock no-error.
            if avail b-LCmain then v-covered = b-LCmain.value1.

            find first b-LCmain where b-LCmain.kritcode = 'Amount' no-lock no-error.
            if avail b-LCmain then do:
                find current b-LCmain exclusive-lock no-error.
                b-LCmain.value1 = string(deci(t-LCmain.value1) + deci(v-covered)).
                b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
            end.

            find first b-LCmain where b-LCmain.kritcode = 'NLim' no-lock no-error.
            if avail b-LCmain then do:
                find current b-LCmain exclusive-lock no-error.
                b-LCmain.value1 = t-LCmain.value1.
                b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
            end.
        end.
        /*-----------------------------------*/

        if t-LCmain.kritcode = 'Amount' and t-lcmain.value1 ne '' then do:
            v-amt = deci(t-lcmain.value1).
            find first b-LCmain where b-LCmain.kritcode = 'PerAmt' no-lock no-error.
            if avail  b-LCmain and b-lcmain.value1 <> '' then do:
                v-per = int(entry(1,lch.value1, '/')).
                if v-per > 0 then v-amt = v-amt + (v-amt * (v-per / 100)).
            end.
            if v-nlim > 0 and v-amt > 0 and not f-provlim() then do:
               t-LCmain.value1 = ''.
               return.
            end.
            if v-1cb then do:
                find first b-LCmain where b-LCmain.kritcode = '1CBcval' no-lock no-error.
                if avail  b-LCmain and deci(b-lcmain.value1) <> v-amt then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = string(v-amt).
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
            end.
        end.

        if t-LCmain.kritcode = 'PerAmt' and t-lcmain.value1 ne '' then do:
            v-per = int(entry(1,t-lcmain.value1, '/')).
            if v-per > 0 then do:
               find first b-LCmain where b-LCmain.kritcode = 'Amount' no-lock no-error.
               if avail  b-LCmain and b-lcmain.value1 <> '' then v-amt = deci(b-lcmain.value1).
               v-amt = v-amt + (v-amt * (v-per / 100)).
               if v-nlim > 0 and v-amt > 0 and not f-provlim() then do:
                t-LCmain.value1 = ''.
                return.
               end.
               if v-1cb then do:
                find first b-LCmain where b-LCmain.kritcode = '1CBcval' no-lock no-error.
                if avail  b-LCmain and deci(b-lcmain.value1) <> v-amt then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = string(v-amt).
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
               end.
           end.
        end.
        if lookup(t-LCmain.kritcode,"AdvThrou,ReimBnk,AdvThOpt") > 0 then do:
            if t-LCmain.kritcode = 'AdvThrou' and v-advopt <> 'A' then do:
                if v-advopt = 'B' then do:
                    frame f2_LCh:row = b_LC:focused-row + 3.
                    displ  t-LCmain.DataName t-LCmain.value1 with frame f2_LCh.
                    update t-LCmain.value1 format "x(35)" with frame f2_LCh.
                end.
                if v-advopt = 'D' then do:
                   {editor_update.i
                        &var            = "t-LCmain.value1"
                        &frame          = "fr7"
                        &framep         = "column 36 row 5 overlay no-labels width 45. frame fr7:row = b_LC:focused-row + 2"
                        &chars_in_line  = "35"
                        &num_lines      = "4"
                        &num_down       = "4"
                    }
                end.
            end.
            else do:
                frame f2_LCh:row = b_LC:focused-row + 3.
                displ  t-LCmain.DataName t-LCmain.value1 with frame f2_LCh.
                update t-LCmain.value1 /*format "x(35)"*/ with frame f2_LCh.
                if t-LCmain.kritcode = 'AdvThOpt' then do:
                v-advopt = t-LCmain.value1.
                    if v-advopt = 'A' then do:
                        find first b-LCmain where b-LCmain.LC = s-lc and b-LCmain.kritcode = 'AdvThrou' no-lock no-error.
                        if avail b-LCmain and b-LCmain.value1 <> '' then do:
                            find first swibic where swibic.bic = b-LCmain.value1 no-lock no-error.
                            if not avail swibic then do:
                                find current b-LCmain exclusive-lock no-error.
                                b-LCmain.value1 = ''.
                                b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                                find current b-LCmain no-lock no-error.
                            end.
                        end.
                    end.
                    if v-advopt = 'B' then do:
                        find first b-LCmain where b-LCmain.LC = s-lc and b-LCmain.kritcode = 'AdvThrou' no-lock no-error.
                        if avail b-LCmain and b-LCmain.value1 <> '' then do:
                            find current b-LCmain exclusive-lock no-error.
                            b-LCmain.value1 = substr(b-LCmain.value1,1,35).
                            b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                            find current b-LCmain no-lock no-error.

                        end.

                    end.
                end.
            end.
        end.
        if t-LCmain.kritcode = '1CByes' then do:
           if t-LCmain.value1 = '01' then do:
            v-1cb = yes.
            find first b-LCmain where b-LCmain.LC = s-lc and b-LCmain.kritcode = 'Cover' no-lock no-error.
            if avail b-LCmain and b-LCmain.value1 = '0' then do:
                find first b-LCmain where b-LCmain.kritcode = '1CBclas' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '1' then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '1'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
                find first b-LCmain where b-LCmain.kritcode = '1CBctype' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '10' then do:
                    find current b-LCmain exclusive-lock no-error.
                    b-LCmain.value1 = '10'.
                    b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                    find current b-LCmain no-lock no-error.
                end.
                find first b-LCmain where b-LCmain.kritcode = 'Amount' no-lock no-error.
                if avail  b-LCmain and b-lcmain.value1 <> '' then do:
                    v-amt = deci(b-lcmain.value1).
                    find first b-LCmain where b-LCmain.kritcode = 'PerAmt' no-lock no-error.
                    if avail  b-LCmain and b-lcmain.value1 <> '' then do:
                        v-per = int(entry(1,lch.value1, '/')).
                        if v-per > 0 then v-amt = v-amt + (v-amt * (v-per / 100)).
                    end.
                    find first b-LCmain where b-LCmain.kritcode = '1CBcval' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-amt then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-amt).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                    find first b-LCmain where b-LCmain.kritcode = '1CBccrc' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-crc then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-crc).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
           end.
        end.
        if (lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,IssBank,ReimBnk') > 0 or (t-LCmain.kritcode = 'AdvThrou' and v-advopt = 'A')) and t-LCmain.value1 <> '' then do:
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
    if lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,IssBank,ReimBnk') > 0 or (t-LCmain.kritcode = 'AdvThrou' and v-advopt = 'A') then do:
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

    if t-LCmain.kritcode = 'DepAcc' then do:
        {itemlist.i
         &set = "DepAcc"
         &file = "aaa"
         &findadd = "find first crc where crc.crc = aaa.crc no-lock no-error. v-crcname = ''. if avail crc then v-crcname = crc.code. "
         &frame = "row 6 centered scroll 1 20 down width 40 overlay "
         &where = " aaa.cif = v-cif and aaa.sta <> 'C' and substr(string(aaa.gl),1,4) = '2240' "
         &flddisp = " aaa.aaa label 'Account' format 'x(20)' v-crcname label 'Currency' "
         &chkey = "aaa"
         &index  = "aaa-idx1"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCmain.value1 = aaa.aaa.
         displ t-LCmain.value1 with frame f2_LCh.

    end.

    if t-LCmain.kritcode = 'NLim' then do:
        {itemlist.i
         &set = "NLim"
         &file = "lclimit"
         &findadd = " assign v-crcname = ''
                             v-limsum1 = 0
                             v-limsum2 = 0.
                    find first lclimith where lclimith.bank = lclimit.bank and lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'lccrc' no-lock no-error.
                    if avail lclimith and lclimith.value1 ne '' then do:
                        find first crc where crc.crc = int(lclimith.value1) no-lock no-error.
                        if avail crc then v-crcname = crc.code.
                    end.
                    find first lclimith where lclimith.bank = lclimit.bank and lclimith.cif = lclimit.cif and lclimith.number = lclimit.number and lclimith.kritcode = 'amount' no-lock no-error.
                    if avail lclimith and lclimith.value1 ne '' then v-limsum1 = deci(lclimith.value1).
                    for each lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.jh > 0 no-lock.
                        if substr(lclimitres.dacc,1,2) = '61' then v-limsum2 = v-limsum2 + lclimitres.amt.
                                                              else v-limsum2 = v-limsum2 - lclimitres.amt.
                    end.
                    "
         &frame = "row 6 centered scroll 1 20 down width 60 overlay "
         &where = " lclimit.cif = v-cif and lclimit.sts = 'FIN' "
         &flddisp = " lclimit.cif lclimit.number label 'N limit' format '>9' v-crcname label 'Currency' v-limsum1 label 'Original Amoumt' format '>>>,>>>,>>9.99' v-limsum2 label 'Rest Amount' format '>>>,>>>,>>9.99'"
         &chkey = "cif"
         &index  = "bcn"
         &end = "if keyfunction(lastkey) = 'end-error' then return."
         }
         t-LCmain.value1 = string(lclimit.number).
         displ t-LCmain.value1 with frame f2_LCh.

    end.

    if lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,CollAcc,ComAcc,DepAcc,IssBank,ReimBnk,AdvThrou') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode and LCkrit.LCtype = 'I' /*and LCkrit.priz = v-priz*/ no-lock no-error.
        if avail LCkrit and trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(LCkrit.dataSpr) no-lock no-error.
            if avail codfr then do:
                {itemlist.i
                    &set = "1"
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
        if lch.kritcode = 'MT799' and lch.value1 = 'yes' and s-lccor = 0 then do:
            assign s-lccor = 1 s-corsts = 'NEW'.
            create lcswt.
            assign lcswt.lc     = s-lc
                   lcswt.LCtype = 'I'
                   lcswt.ref    = s-lc
                   lcswt.sts    = 'NEW'
                   lcswt.mt     = 'I799'
                   lcswt.fname2 = 'I799' + replace(trim(s-lc),'/','-') + '_' + string(s-lccor,'99999')
                   lcswt.mt     = 'I799'
                   lcswt.rdt    = g-today
                   lcswt.LCcor  = s-lccor.

        end.
        find current LCh no-lock no-error.
        if lch.kritcode = 'Amount' and trim(lch.value1) <> ''
        then assign v-lcsumcur = deci(lch.value1)
                    v-lcsumorg = deci(lch.value1).
        if lch.kritcode = 'peramt' and lch.value1 ne '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                     v-lcsumcur = v-lcsumorg.

        end.

        if lch.kritcode = 'lcCrc' and trim(lch.value1) <> '' then do:
           find first crc where crc.crc = int(trim(lch.value1)) no-lock no-error.
           if avail crc then assign v-lccrc1 = crc.code v-lccrc2 = crc.code.
           if v-crc <> int(trim(lch.value1)) then do:
              v-crc = int(trim(lch.value1)).
              v-arp = ''.
              find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
              if avail sysc then if num-entries(sysc.chval) >= v-crc then v-arp = entry(v-crc,sysc.chval).
              if v-arp = '' then do:
                  message "The value LCARP in SYSC is empty! It's impossible to save the field 'Currency Code!" view-as alert-box error.
                  find current LCh exclusive-lock no-error.
                  lch.value1 = ''.
                  find current LCh no-lock no-error.
              end.
              else do:
                  find first b-LCh where b-LCh.LC = s-lc and b-LCh.kritcode = 'ArpAcc' no-lock no-error.
                  if not avail b-lch then create b-lch.
                  else find current b-LCh exclusive-lock no-error.
                  assign b-lch.lc       = s-lc
                         b-lch.bank     = s-ourbank
                         b-lch.kritcode = 'ArpAcc'
                         b-lch.value1   = v-arp.
                  find current b-lch no-lock no-error.
              end.
           end.
        end.
        if lch.kritcode = 'DtExp' and lch.value1 <> ?
        then v-lcdtexp = date(lch.value1).

        if lch.kritcode = 'OblValid' and lch.value1 <> ?
        then v-oblval = date(lch.value1).
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCmain no-lock.

if v-lcsts = 'NEW' or (v-lcsts = 'FIN' and v-cover = '1') then enable all with frame f_LC.
else enable b_LC with frame f_LC.

wait-for window-close of current-window or choose of bsave.
