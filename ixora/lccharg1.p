/*lccharg1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод критериев платежа по комиссиям Internal Charges (Chrgs at BNFs expense)
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
        12/08/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        02/11/2011 id00810 - переменная s-type(тип комиссии)
        14/12/2011 id00810 - 2 критерия: сумма с НДС и без НДС для s-type = '3'
        20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
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
def shared var s-type    as char.
def var v-crc     as int  no-undo.
def var i         as int  no-undo.
def var v-chose   as logi no-undo init yes.
def var v-errMsg  as char no-undo.
def var v-title   as char no-undo.
def var v-comcode as char no-undo.
{LCvalid.i}
def temp-table t-LCevent no-undo like LCeventh
    field showOrder    as integer
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    index idx_sort showOrder.

def buffer b-LCevent for t-LCevent.

def temp-table wrk no-undo
  field id  as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCevent.
def var v-rid as rowid.

find first codfr where codfr.codfr = 'lccomtype'
                   and codfr.code  = s-type
                   no-lock no-error.
if avail codfr then v-title = ' ' + codfr.name[1] + ' '.

define browse b_event query q_LC
       displ t-LCevent.dataName     format "x(37)"
             t-LCevent.dataValueVis format "x(65)"
             with 32 down overlay no-label title v-title.
def button bsave label "SAVE".

define frame f_event b_event help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

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
    t-LCevent.value1   format "x(65)" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame fd_LCeventh
    t-LCevent.dataName format "x(37)"
    t-LCevent.value1   format "99/99/9999" validate(validh(t-LCevent.kritcode,t-LCevent.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

empty temp-table t-LCevent.

find first LCeventh where lceventh.bank = s-ourbank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'CurCode' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-crc = int(lceventh.value1).
else do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).
end.
find first LCeventh where lceventh.bank = s-ourbank and LCeventh.LC = s-lc and lceventh.event = s-event and lceventh.number = s-number and LCeventh.kritcode = 'ComCode' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-comcode = lceventh.value1.

if s-type = '3' then find first pksysc where pksysc.sysc = 'intch_pay3' no-lock no-error.
else find first pksysc where pksysc.sysc = 'intch_pay' no-lock no-error.
if not avail pksysc then return.

do i = 1 to num-entries(pksysc.chval):
    find first LCkrit where LCkrit.showorder = int(entry(i,pksysc.chval)) no-lock no-error.
    if not avail LCkrit then next.
    create t-LCevent.
    assign t-LCevent.lc        = s-lc
           t-LCevent.event     = s-event
           t-LCevent.number    = s-number
           t-LCevent.kritcode  = LCkrit.dataCode
           t-LCevent.showOrder = i
           t-LCevent.dataName  = LCkrit.dataName
           t-LCevent.dataSpr   = LCkrit.dataSpr
           t-LCevent.bank      = s-ourbank.

    find first LCeventh where lceventh.bank = s-ourbank and LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number and LCeventh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCeventh then do:
        if t-LCevent.kritcode = 'VDate' and s-sts <> 'FIN' then t-LCevent.value1 = string(g-today,'99/99/9999').
        else buffer-copy LCeventh except LCeventh.LC to t-LCevent.
    end.
    else do:
        if t-LCevent.kritcode = 'VDate' then t-LCevent.value1 = string(g-today,'99/99/9999').
        if t-LCevent.kritcode = 'TRNum' then t-LCevent.value1 = caps(s-lc).
        if t-LCevent.kritcode = 'ClCode' then t-LCevent.value1 = v-cif.
        if t-LCevent.kritcode = 'ComCode' then assign t-LCevent.value1 = if s-type = '2' then if s-lcprod ne 'pg' then '970' else '966' else '9990'
                                                      v-comcode = t-LCevent.value1.
        if t-LCevent.kritcode = 'Client' then t-LCevent.value1 = v-cifname.
        if t-LCevent.kritcode = 'CurCode' then do:
            if s-type = '2' or s-type = '5' then t-LCevent.value1 = '1'.
            else do:
                find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
                if avail lch then t-LCevent.value1 = lch.value1.
            end.
        end.
    end.
    t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode,t-LCevent.value1).
    if t-LCevent.kritcode = 'ComCode' then do:
        if t-LCevent.value1 = '9990' then t-LCevent.dataValueVis = '9990 - Иные комиссии'.
        else do:
            find first tarif2 where tarif2.str5 = trim(t-LCevent.value1) /*tarif2.num  = substr(t-LCevent.value1,1,1) and tarif2.kod = substr(t-LCevent.value1,2,2)*/ and tarif2.stat = 'r' no-lock no-error.
            if avail tarif2 then t-LCevent.dataValueVis = t-LCevent.value1 + ' - ' + tarif2.pakalp.
        end.
    end.
end.

on "enter" of b_event in frame f_event do:
    if s-sts <> 'NEW' then return.

    if avail t-LCevent then do:
        if lookup(t-LCevent.kritcode,'TRNum,ClCode,Client,ComCode') > 0 then return.
        if t-LCevent.kritcode = 'CurCode' and (s-type = '2' or s-type = '5') then return.

        b_event:set-repositioned-row(b_event:focused-row, "always").
        v-rid = rowid(t-LCevent).

       if t-LCevent.kritcode = 'RRef' then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 format 'x(16)' with frame f2_LCeventh.
        end.

        if t-LCevent.kritcode = 'VDate' then do:
            frame fd_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame fd_LCeventh.
            update t-LCevent.value1 with frame fd_LCeventh.
        end.

        if lookup(t-LCevent.kritcode,'ComAmt,ComAmtI,ComAmtE,c') > 0 then do:
            frame f2_LCeventh:row = b_event:focused-row + 3.
            displ t-LCevent.dataName t-LCevent.value1 with frame f2_LCeventh.
            update t-LCevent.value1 with frame f2_LCeventh.
        end.

        t-LCevent.dataValueVis = getVisual(t-LCevent.kritcode, t-LCevent.value1).

        open query q_LC for each t-LCevent no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_event:refresh().
    end.
end.

on help of t-LCevent.value1 in frame f2_LCeventh do:
    if t-LCevent.kritcode = 'CurCode' then do:
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
on choose of bsave in frame f_event do:
    i = 0.
    for each t-LCevent no-lock:
        i = i + 1.
        find first LCeventh where lceventh.bank = s-ourbank and LCeventh.LC = s-lc and LCeventh.event = s-event and LCeventh.number = s-number  and LCeventh.kritcode = t-LCevent.kritcode exclusive-lock no-error.
        if not avail LCeventh then create LCeventh.
        buffer-copy t-LCevent to LCeventh.
    end.
    if i > 0 then message " Saved!!! " view-as alert-box information.
             else message " No data to save " view-as alert-box information.
    hide all no-pause.
end.

open query q_LC for each t-LCevent no-lock.

if s-sts = 'NEW' then enable all with frame f_event.
else enable b_event with frame f_event.

wait-for window-close of current-window or choose of bsave.

