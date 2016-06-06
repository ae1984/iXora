/* lcpfdet.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Ввод основных критериев (IMLC: Post Finance Details )
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-1-13 - Post Finance Details
 * AUTHOR
        20/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
{LC.i}
def temp-table t-lcevt no-undo like lceventh
    field showOrder    as int
    field dataName     as char
    field dataSpr      as char
    field dataValueVis as char
    index idx_sort showOrder.

def shared var s-lc       like lc.lc.
def shared var v-cif      as char.
def shared var v-cifname  as char.
def shared var s-lcprod   as char.
def shared var s-event    like lcevent.event.
def shared var s-number   like lcevent.number.
def shared var s-sts      like lcevent.sts.
def shared var v-lcdtexp  as date.
def shared var v-lcsumcur as deci.

def var v-sp       as char no-undo.
def var v-crcname  as char no-undo.
def var v-crc      as int  no-undo.
def var v-rate     as deci no-undo.
def var v-marg     as deci no-undo.

/*
def var v-lcsum    as deci no-undo.
def var v-sp       as char no-undo.
def var v-nf       as char no-undo.
def var v-accopt   as char no-undo.
def var v-accoptr  as char no-undo.
def var v-accoptb  as char no-undo.*/
def var v-chose    as logi no-undo.
def var v-errMsg   as char no-undo.
/*def var v-rekv     as char no-undo init 'PlcExp,Benef,PerAmt,MaxCrAmt,AdAmCov,AvlWith,By,DrfAt,Drawee,AppRule,MPayDet,DefPayD'.
def var v-rekv1    as char no-undo init 'BankRef,CreditN,DtIs,IssBank'.*/
{LCvalid.i}

def temp-table wrk no-undo
  field id  as int
  field txt as char
  index idx is primary id.

def var i as integer no-undo.

define query q_LC for t-lcevt.
def var v-rid as rowid.

define browse b_evt query q_LC
       displ t-lcevt.dataName     format "x(37)"
             t-lcevt.dataValueVis format "x(65)"
             with 25 down overlay no-label title ' POST FINANCE DETAILS '.
def button bsave label "SAVE".
def buffer b-lcevt    for t-lcevt.
def buffer b-lceventh for lceventh.
def buffer b-lcevent  for lcevent.
define frame f_evt b_evt help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.

on "end-error" of frame f_evt do:
    if s-sts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_evt.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_lceventh
    t-lcevt.dataName format "x(37)"
    t-lcevt.value1   format "x(35)" validate(validh(t-lcevt.kritcode,t-lcevt.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.
define frame fd_lceventh
    t-lcevt.dataName format "x(37)"
    t-lcevt.value1   format "99/99/9999" validate(validh(t-lcevt.kritcode,t-lcevt.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'rate' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-rate = deci(lceventh.value1).

find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'margin' no-lock no-error.
if avail lceventh and lceventh.value1 <> '' then v-marg = deci(lceventh.value1).

find first pksysc where pksysc.sysc = s-lcprod + '_' + s-event no-lock no-error.
if not avail pksysc then return.
v-sp = pksysc.chval.

empty temp-table t-lcevt.
i = 1.
do i = 1 to num-entries(v-sp):
    find first LCkrit where LCkrit.showorder = int(entry(i,v-sp)) no-lock no-error.
    if not avail LCkrit then next.
    create t-lcevt.
    assign
        t-lcevt.lc        = s-lc
        t-lcevt.event     = s-event
        t-lcevt.number    = s-number
        t-lcevt.kritcode  = LCkrit.dataCode
        t-lcevt.showOrder = i
        t-lcevt.dataName  = LCkrit.dataName
        t-lcevt.dataSpr   = LCkrit.dataSpr.

    if t-lcevt.kritcode = 'AdvBank' then t-lcevt.dataName = 'Financing Bank'.

    find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = LCkrit.dataCode no-lock no-error.
    if avail lceventh then buffer-copy lceventh except lceventh.lc to t-lcevt.
    else do:
        if lookup(t-lcevt.kritcode,'CreditN,ApplCode,lcCrc,Amount,AdvBank') > 0 then do:
            find first lch where lch.lc = s-lc and lch.kritcode = t-lcevt.kritcode no-lock no-error.
            if avail lch then t-lcevt.value1 = lch.value1.
        end.
        if t-lcevt.kritcode = 'base' then t-lcevt.value1 = '360'.
        t-lcevt.bank = s-ourbank.
    end.
    t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode,t-lcevt.value1).
end.

on "enter" of b_evt in frame f_evt do:
    if s-sts <> 'NEW' then return.
    if avail t-lcevt then do:
        if lookup(t-lcevt.kritcode,'CreditN,ApplCode,lcCrc,Amount,AdvBank,AllFRate,Base') > 0 then return.

        b_evt:set-repositioned-row(b_evt:focused-row, "always").
        v-rid = rowid(t-lcevt).

        if lookup(t-lcevt.kritcode,'StartDt,EndDt,NextPDt') = 0 then do:
            frame f2_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame f2_lceventh.
            update t-lcevt.value1 with frame f2_lceventh.
        end.
        else do:
            frame fd_lceventh:row = b_evt:focused-row + 3.
            displ t-lcevt.dataName t-lcevt.value1 with frame fd_lceventh.
            update t-lcevt.value1 with frame fd_lceventh.
        end.

        if t-lcevt.kritcode = 'Rate' then do:
            v-rate = deci(t-lcevt.value1).
            find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'AllFrate' no-lock no-error.
            if avail b-lcevt then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = string(v-rate + v-marg).
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
        end.

        if t-lcevt.kritcode = 'Margin' then do:
             v-marg = deci(t-lcevt.value1).
             find first b-lcevt where b-lcevt.LC = s-lc and b-lcevt.kritcode = 'AllFrate' no-lock no-error.
             if avail b-lcevt then do:
                find current b-lcevt exclusive-lock no-error.
                b-lcevt.value1 = string(v-rate + v-marg).
                b-lcevt.dataValueVis = getVisual(b-lcevt.kritcode, b-lcevt.value1).
                find current b-lcevt no-lock no-error.
            end.
        end.

        t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode, t-lcevt.value1).

        open query q_LC for each t-lcevt no-lock use-index idx_sort.
        reposition q_LC to rowid v-rid no-error.
        b_evt:refresh().
    end.
end.
on help of t-lcevt.value1 in frame f2_lceventh do:

    find first LCkrit where LCkrit.dataCode = t-lcevt.kritcode  no-lock no-error.
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
            t-lcevt.value1 = codfr.code.
            t-lcevt.dataValueVis = getVisual(t-lcevt.kritcode, t-lcevt.value1).
            displ t-lcevt.value1 with frame f2_lceventh.
        end.
    end.
end.

def var v-chkMess as char no-undo.
on choose of bsave in frame f_evt do:
    i = 0.
    for each t-lcevt no-lock:

        i = i + 1.
        find first lceventh where lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = t-lcevt.kritcode exclusive-lock no-error.
        if not avail lceventh then create lceventh.

        buffer-copy t-lcevt to lceventh.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.
open query q_LC for each t-lcevt no-lock use-index idx_sort.

if s-sts = 'NEW' then enable all with frame f_evt.
else enable b_evt with frame f_evt.

wait-for window-close of current-window or choose of bsave.
