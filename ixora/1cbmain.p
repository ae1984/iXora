/*1cbmain.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод критериев аккредитива/гарантии для ПКБ и Кредитный Регистр
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
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013
 * BASES
        BANK COMM
 * CHANGES

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
def var v-covered   as char.
def var v-uncovered as char.
def var v-lcdtdog   as date format '99/99/9999'.

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
    /*if v-lcsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else hide all no-pause.
    end.
    else*/
    apply 'choose' to bsave in frame f_LC.
    hide all no-pause.
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

v-sp = '216,217,278,218,219,220,280,279,282,281,284,283'.


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
        buffer-copy LCh except LCh.LC to t-LCmain.
    end.
    /*
    if t-LCmain.kritcode = '1CBclas' then do:
        if t-LCmain.value1 = '' and v-1cb and v-cover = '0' then t-LCmain.value1 = '1'.
    end.
    if t-LCmain.kritcode = '1CBctype' then do:
        if t-LCmain.value1 = '' and v-1cb and v-cover = '0' then t-LCmain.value1 = '10'.
    end.
    if t-LCmain.kritcode = '1CBccrc' then do:
        if t-LCmain.value1 = '' and v-1cb and v-cover = '0' then t-LCmain.value1 = string(v-crc).
    end.
    if t-LCmain.kritcode = '1CBcval' then do:
        if t-LCmain.value1 = '' and v-1cb then do:
            if v-cover = '0' then t-LCmain.value1 = string(v-amt).
            else if v-cover = '2' then t-LCmain.value1 = v-covered.
        end.
    end.
    */
    t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode,t-LCmain.value1).
end.

on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' and v-lcsts <> 'FIN' then return.
    /*if v-lcsts = 'FIN' and v-cover = '0' then return.*/
    find first LC where LC.lc = s-lc no-lock no-error.

    if avail t-LCmain then do:

        if v-lcsts = 'FIN' and v-cover = '1' and lookup(t-LCmain.kritcode,'1cbyes,1cbclas,1cbctype,1cbcval,1cbccrc,1cbbcntr') = 0 then return.

        if lookup(t-LCmain.kritcode,"DtDog,DtDSDog,DtCDog") = 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName t-LCmain.value1 with frame f2_LCh.
            update t-LCmain.value1 with frame f2_LCh.
        end.
        else do:
            v-lcdtdog = date(t-LCmain.value1).
            frame f2_LCh1:row = b_LC:focused-row + 3.
            displ t-LCmain.dataName v-lcdtdog with frame f2_LCh1.
            update v-lcdtdog with frame f2_LCh1.
            if v-lcdtdog = ? then t-LCmain.value1 = ''.
            else t-LCmain.value1 = string(v-lcdtdog, '99/99/9999').
        end.

        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCmain).

        /*
        if t-LCmain.kritcode = '1CByes' then do:
            if t-LCmain.value1 = '01' then do:
                v-1cb = yes.
                if v-cover = '0' then do:
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
                    find first b-LCmain where b-LCmain.kritcode = '1CBcval' no-lock no-error.
                    if avail  b-LCmain and deci(b-lcmain.value1) <> v-amt then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-amt).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                    find first b-LCmain where b-LCmain.kritcode = '1CBccrc' no-lock no-error.
                    if avail  b-LCmain and integer(b-lcmain.value1) <> v-crc then do:
                        find current b-LCmain exclusive-lock no-error.
                        b-LCmain.value1 = string(v-crc).
                        b-LCmain.dataValueVis = getVisual(b-LCmain.kritcode, b-LCmain.value1).
                        find current b-LCmain no-lock no-error.
                    end.
                end.
            end.
        end.
        */
        t-LCmain.dataValueVis = getVisual(t-LCmain.kritcode, t-LCmain.value1).

        open query q_LC for each t-LCmain no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCmain.value1 in frame f2_LCh do:
    if lookup(t-LCmain.kritcode,'InstTo,AdvBank,AvlWith,Drawee,CollAcc,ComAcc,DepAcc,IssBank,ReimBnk,AdvThrou') = 0 then do:
        find first LCkrit where LCkrit.dataCode = t-LCmain.kritcode and LCkrit.LCtype = 'I' no-lock no-error.
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

        find current LCh no-lock no-error.
        if lch.kritcode = 'Amount' and trim(lch.value1) <> ''
        then assign v-lcsumcur = deci(lch.value1)
                    v-lcsumorg = deci(lch.value1).
        if lch.kritcode = 'peramt' and lch.value1 ne '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then assign v-lcsumorg = v-lcsumorg + (v-lcsumorg * (v-per / 100))
                                     v-lcsumcur = v-lcsumorg.

        end.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.
end.

open query q_LC for each t-LCmain no-lock.

/*if v-lcsts = 'NEW' or (v-lcsts = 'FIN' and v-cover = '1') then*/ enable all with frame f_LC.
/*else enable b_LC with frame f_LC.*/

wait-for window-close of current-window or choose of bsave.
