/*LCship.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ввод дополнительных критериев аккредитива
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
        10/09/2010 galina - явно указала ширину фреймов fr1,fr2,fr3
                            поправила поле AppRule
        05/10/2010 galina - поправила определение даты
                            редактировать может только тот, кто завел аккредитив
        25/11/2010 galina - перекомпеляция
        06/12/2010 galina - убрала проверку на пользователя, который заводил аккредитив
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        20/04/2011 id00810 - для резервного аккредитива SBLC
*/

{LC.i}
define shared var g-ofc    like ofc.ofc.
define shared var g-today as date.
def shared var s-lc like LC.LC.
def shared var v-cif as char.
def shared var v-cifname as char.
def shared var v-lcsts as char.
def shared var s-lcprod as char.
/*def shared var s-lccor  like lcswt.lccor.
def shared var s-corsts like lcswt.sts.
*/
def var v-crcname as char.
def var v-crc as int.
def var v-title as char init ' SHIPMENT '.
def var v-priz  as char init 's'.
def var i as integer.
def var k as integer.
{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCship.
def var v-rid as rowid.

define browse b_LC query q_LC
       displ t-LCship.dataName  format "x(37)"
             t-LCship.dataValueVis format "x(65)"
             with 12 down overlay no-label title v-title.
def button bsave label "SAVE".
def buffer b-LCship for t-LCship.
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 111 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.

on "end-error" of b_LC in frame f_LC do:
    if v-lcsts = 'NEW' then do:
        message 'Do you want to save changes?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ATTENTION !"
        update v-chose.
        if v-chose then apply 'choose' to bsave in frame f_LC.
        else hide all no-pause.
    end.
    else hide all no-pause.
end.

define frame f2_LCh
    t-LCship.dataName format "x(37)"
    t-LCship.value1 format "x(65)" validate(validh(t-LCship.kritcode,t-LCship.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

define frame f2_LCh3
    t-LCship.dataName format "x(37)"
    t-LCship.value1 format "x(35)" validate(validh(t-LCship.kritcode,t-LCship.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


empty temp-table t-LCship.
if s-lcprod = 'sblc' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
    if avail lch and lch.value1 <> '' then do:
        v-title = ' INSTRUCTIONS '.
        if lch.value1 = 'mt760' then v-priz = 'i'.
    end.
end.

for each LCkrit where LCkrit.LCtype = 'I' and LCkrit.priz = v-priz no-lock:
    create t-LCship.
    t-LCship.LC = s-lc.
    t-LCship.kritcode = LCkrit.dataCode.
    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then buffer-copy LCh except LCh.LC to t-LCship.
    else do:
        if t-LCship.kritcode = 'AppRule' then t-LCship.value1 = if v-priz = 's' then 'UCP LATEST VERSION' else 'OTHR/SEE FIELD 77C'.
        t-LCship.bank = s-ourbank.
    end.
    t-LCship.dataValueVis = getVisual(t-LCship.kritcode,t-LCship.value1).

    assign t-LCship.showOrder = LCkrit.showOrder
           t-LCship.dataName = LCkrit.dataName
           t-LCship.dataSpr = LCkrit.dataSpr.
end.


on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.
    /*if lc.rwho <> g-ofc then do:
        message 'The letter of credit has been registered by another user! You have no permissions to edit it!' view-as alert-box.
        return.
    end.*/

    if avail t-LCship then do:
        if lookup(t-LCship.kritcode,'AppRule') > 0 then return.
        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCship).

        if  lookup(t-LCship.kritcode,'ParShip,TrnShip') > 0 then do:
            frame f2_LCh3:row = b_LC:focused-row + 3.
            displ t-LCship.dataName  t-LCship.value1 with frame f2_LCh3.
            update t-LCship.value1 with frame f2_LCh3.
        end.
        if  lookup(t-LCship.kritcode,'LDtShip,PlcCharg,PclFD') > 0 then do:
            frame f2_LCh:row = b_LC:focused-row + 3.
            displ t-LCship.dataName  t-LCship.value1 with frame f2_LCh.
            update t-LCship.value1 with frame f2_LCh.
        end.

        if t-LCship.kritcode = "Charges" then do:

           {editor_update.i
                &var    = "t-LCship.value1"
                &frame  = "fr1"
                &framep = "column 42 row 5 overlay no-labels width 45. frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.
        if t-LCship.kritcode = "PerPres" then do:

           {editor_update.i
                &var    = "t-LCship.value1"
                &frame  = "fr2"
                &framep = "column 42 row 5 overlay no-labels width 45. frame fr2:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "4"
                &num_down  = "4"
            }
        end.

        if lookup(t-LCship.kritcode,'DesGood,DocReq,AddCond') > 0 then do:

           {editor_update.i
                &var    = "t-LCship.value1"
                &frame  = "fr3"
                &framep = "column 37 row 5 overlay no-labels width 75. frame fr3:row = b_LC:focused-row + 2"
                &chars_in_line  = "65"
                &num_lines  = "100"
                &num_down  = "10"
            }
        end.

        if t-LCship.kritcode = "DetGar" then do:

            {editor_update.i
                &var    = "t-LCship.value1"
                &frame  = "fr4"
                &framep = "column 36 row 5 overlay no-labels width 75. frame fr4:row = b_LC:focused-row + 2"
                &chars_in_line  = "65"
                &num_lines  = "150"
                &num_down  = "30"
            }
        end.

        if t-LCship.kritcode = "StoRInf" then do:

            {editor_update.i
                &var    = "t-LCship.value1"
                &frame  = "fr5"
                &framep = "column 36 row 5 overlay no-labels width 45. frame fr5:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.

        t-LCship.dataValueVis = getVisual(t-LCship.kritcode, t-LCship.value1).

        open query q_LC for each t-LCship no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCship.value1 in frame f2_LCh3 do:

    find first LCkrit where LCkrit.dataCode = t-LCship.kritcode no-lock no-error.
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
            t-LCship.value1 = codfr.code.
            t-LCship.dataValueVis = getVisual(t-LCship.kritcode, t-LCship.value1).
            displ t-LCship.value1 with frame f2_LCh.
        end.
    end.

end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_LC do:
    i = 0.
    for each t-LCship no-lock:
        i = i + 1.
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCship.kritcode exclusive-lock no-error.
        if not avail LCh then create LCh.
        buffer-copy t-LCship to LCh.
        /*if t-LCship.kritcode = 'MT799' and t-LCship.value1 = 'yes' and s-lccor = 0 then do:
            find last LCswt where LCswt.LC = s-LC and LCswt.mt = 'I799' no-lock no-error.
            if avail LCswt then s-lccor = LCswt.LCcor + 1.
            else s-lccor = 1.
            create lcswt.
            assign lcswt.lc     = lc.lc
                   lcswt.LCtype = lc.lctype
                   lcswt.ref    = s-lc
                   lcswt.sts    = 'NEW'
                   lcswt.mt     = 'I799'
                   lcswt.fname2 = 'I799' + replace(trim(s-lc),'/','-') + '_' + string(s-lccor,'99999')
                   lcswt.mt     = 'I799'
                   lcswt.rdt    = g-today
                   lcswt.LCcor  = s-lccor.
            s-corsts = 'NEW'.
        end.*/
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.
end.

open query q_LC for each t-LCship no-lock use-index idx_sort.
if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.


wait-for window-close of current-window or choose of bsave.





