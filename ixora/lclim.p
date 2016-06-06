/*lclim.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Limits - ввод критериев
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14.7.1.1
 * AUTHOR
        19/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
def shared var s-cif       as char.
def shared var s-number    as int.
def shared var v-cifname   as char.
def shared var v-limsts    as char.
def shared var v-limsumcur as deci.
def shared var v-limsumorg as deci.
def shared var v-limcrc1   as char.
def shared var v-limcrc2   as char.
def shared var v-limdtexp  as date.
def shared var s-ourbank   as char no-undo.
def var v-chose   as logi no-undo.
def var v-errMsg  as char no-undo.
def var i         as int  no-undo.
def var v-amt     as deci no-undo.
def var v-dt      as date no-undo.
def temp-table t-lclimit no-undo like lclimith
    field showOrder    as integer
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    index idx_sort showOrder.

def buffer b-lclimit for t-lclimit.

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_lim for t-lclimit.
def var v-rid as rowid.

find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = s-cif and lclimit.number = s-number no-lock no-error.
if not avail lclimit then return.

define browse b_limit query q_lim
       displ t-lclimit.dataName     format "x(37)"
             t-lclimit.dataValueVis format "x(65)"
             with 32 down overlay no-label title ' Limits '.
def button bsave label "SAVE".

define frame f_limit b_limit help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

function getVisual returns char (input p-dataCode as char, input p-value as char).
    def var res as char no-undo.
    res = p-value.
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        if trim(LCkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = LCkrit.dataSpr and codfr.code = p-value no-lock no-error.
            if avail codfr then res = p-value + ' - ' + codfr.name[1].
        end.
        else do:
            if LCkrit.dataType = 'd' and p-value <> '' then res = string(date(p-value),"99/99/9999") no-error.
            if LCkrit.dataType = 'r' and p-value <> '' then res = trim(string(deci(p-value),"zzz,zzz,zzz,zz9.99")) no-error.
            else res = p-value.
        end.
    end.
    return res.
end function.

function validkrtype returns logi (input p-dataCode as char, input p-value as char).
    def var res  as logi no-undo init yes.
    def var v-dt as date no-undo.
    def var v-i  as int  no-undo.
    def var v-r  as deci no-undo.
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        case LCkrit.dataType:
            when 'i' then do:
                v-i = integer(p-value) no-error.
                if error-status:error then res = no.
                if res then do:
                    v-r = round(deci(p-value),2).
                    if v-r <> v-i then  res = no.
                end.
            end.
            when 'r' then do:
                v-r = deci(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'd' then do:
                v-dt = date(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'l' then do:
                if lookup(p-value, 'yes,no') = 0 then res = no.
            end.
        end case.
    end.
    return res.
end function.


function validh returns logi (input p-dataCode as char, input p-value as char, output p-errMsg as char).
    def var res as logi no-undo init yes.
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        if p-value <> '' then do:
            if trim(LCkrit.dataSpr) <> '' then do:
                find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = p-value no-lock no-error.
                if not avail codfr then assign res = no p-errMsg = "There is no such a value in the reference!".
            end.
            else do:
                res = validkrtype(p-dataCode,p-value).
                if not res then p-errMsg = "The incorrect value has been entered!".
            end.
        end.
    end.
    return res.
end function.

on "end-error" of frame f_limit do:
    if v-limsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_limit.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2-lclimith
    t-lclimit.dataName format "x(37)"
    t-lclimit.value1 format "x(65)" validate(validh(t-lclimit.kritcode,t-lclimit.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.
define frame fd-lclimith
    t-lclimit.dataName format "x(37)"
    v-dt               format "99/99/9999" validate(validh(t-lclimit.kritcode,t-lclimit.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.
define frame fr-lclimith
    t-lclimit.dataName format "x(37)"
    v-amt              format "zzz,zzz,zzz,zz9.99" validate(validh(t-lclimit.kritcode,t-lclimit.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


/*find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = 'amount' no-lock no-error.
if avail lclimith then v-amt = deci(lclimith.value1) no-error.*/

empty temp-table t-lclimit.

find first pksysc where pksysc.sysc = 'lclimit' no-lock no-error.
if not avail pksysc then return.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.
    create t-lclimit.
    assign t-lclimit.showOrder = i
           t-lclimit.cif       = s-cif
           t-lclimit.number    = s-number.
           t-lclimit.kritcode  = LCkrit.dataCode.
    assign t-lclimit.dataName  = LCkrit.dataName
           t-lclimit.dataSpr   = LCkrit.dataSpr
           t-lclimit.bank      = s-ourbank.

    if t-lclimit.kritcode = 'Narrat' then t-lclimit.dataName = 'Credit Committee minutes extract'.
    find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = LCkrit.dataCode no-lock no-error.
    if avail lclimith then buffer-copy lclimith except lclimith.cif to t-lclimit.
    else do:
        if t-lclimit.kritcode = 'Date'   then t-lclimit.value1 = string(g-today,'99/99/9999').
        if t-lclimit.kritcode = 'ClCode' then t-lclimit.value1 = s-cif.
        if t-lclimit.kritcode = 'Client' then t-lclimit.value1 = v-cifname.
        if t-lclimit.kritcode = 'Revolv' then t-lclimit.value1 = 'NO'.
    end.
    t-lclimit.dataValueVis = getVisual(t-lclimit.kritcode,t-lclimit.value1).
end.

on help of t-lclimit.value1 in frame f2-lclimith do:
    find first LCkrit where LCkrit.dataCode = t-lclimit.kritcode no-lock no-error.
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
            t-lclimit.value1 = codfr.code.
            t-lclimit.dataValueVis = getVisual(t-lclimit.kritcode, t-lclimit.value1).
            displ t-lclimit.value1 with frame f2-lclimith.
        end.
    end.
end.

on "enter" of b_limit in frame f_limit do:
    if v-limsts <> 'NEW' then return.
    if avail t-lclimit then do:
        if lookup(t-lclimit.kritcode,'ClCode,Client') > 0 then return.

        b_limit:set-repositioned-row(b_limit:focused-row, "always").
        v-rid = rowid(t-lclimit).

        if t-lclimit.kritcode = 'Date' or t-lclimit.kritcode = 'DtExp' then do:
            v-dt = date(t-lclimit.value1).
            frame fd-lclimith:row = b_limit:focused-row + 3.
            displ t-lclimit.dataName v-dt with frame fd-lclimith.
            update v-dt  with frame fd-lclimith.
            t-lclimit.value1 = string(v-dt,'99/99/9999').
        end.
        else if t-lclimit.kritcode = 'Amount' then do:
            v-amt = deci(t-lclimit.value1).
            frame fr-lclimith:row = b_limit:focused-row + 3.
            displ t-lclimit.dataName v-amt with frame fr-lclimith.
            update v-amt with frame fr-lclimith.
            t-lclimit.value1 = string(v-amt).
        end.
        else do:
            frame f2-lclimith:row = b_limit:focused-row + 3.
            displ t-lclimit.dataName t-lclimit.value1 with frame f2-lclimith.
            update t-lclimit.value1 with frame f2-lclimith.
        end.

        t-lclimit.dataValueVis = getVisual(t-lclimit.kritcode, t-lclimit.value1).

        open query q_lim for each t-lclimit no-lock use-index idx_sort.
        reposition q_lim to rowid v-rid no-error.
        b_limit:refresh().
    end.
end.

on choose of bsave in frame f_limit do:
    i = 0.
    for each t-lclimit no-lock:
        i = i + 1.
        find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number  and lclimith.kritcode = t-lclimit.kritcode exclusive-lock no-error.
        if not avail lclimith then create lclimith.

        buffer-copy t-lclimit to lclimith.
        find current lclimith no-lock no-error.
    end.
    if i > 0 then do:
        find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = 'Amount' no-lock no-error.
        if avail lclimith and lclimith.value1 <> ''
        then assign v-limsumcur = deci(lclimith.value1)
                    v-limsumorg = deci(lclimith.value1).
        find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = 'lcCrc' no-lock no-error.
        if avail lclimith and lclimith.value1 <> '' then do:
           find first crc where crc.crc = int(trim(lclimith.value1)) no-lock no-error.
           if avail crc then assign v-limcrc1 = crc.code v-limcrc2 = crc.code.
        end.
        find first lclimith where lclimith.cif = s-cif and lclimith.number = s-number and lclimith.kritcode = 'DtExp' no-lock no-error.
        if avail lclimith and lclimith.value1 <> '' then  v-limdtexp = date(lclimith.value1).

        message " Saved!!! " view-as alert-box information.
    end.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.
end.

open query q_lim for each t-lclimit no-lock use-index idx_sort.

if v-limsts = 'NEW' then enable all with frame f_limit.
else enable b_limit with frame f_limit.

wait-for window-close of current-window or choose of bsave.
