/*LCotherD.p
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
        10/09/2010 galina - явно указала ширину фреймов fr1,fr2
        05/10/2010 galina - поправила определение даты
                            редактировать может только тот, кто завел аккредитив
        11/10/2010 galina - возможность ввода наименования банка в поля AdvThrou,ReimBnk
        25/11/2010 galina - добавила новый критерий AdvThOpt
        06/12/2010 galina - убрала проверку на пользователя, который заводил аккредитив
        26/01/2011 id00810 - для импортной гарантии
        07/04/2011 id00810 - перекомпиляция
        18/04/2011 id00810 - перекомпиляция
        20/04/2011 id00810 - для резервного аккредитива SBLC
*/

{LC.i}
define shared var g-today as date.
define shared var g-ofc    like ofc.ofc.
def shared var s-lc like LC.LC.
def shared var v-cif as char.
def shared var v-cifname as char.
def shared var v-lcsts as char.
def shared var s-lcprod as char.

def var v-crcname as char.
def var v-crc as int.
def var i as integer.
def var v-title as char.
def var v-priz  as char.

{LCvalid.i}

def temp-table wrk no-undo
  field id as integer
  field txt as char
  index idx is primary id.

define query q_LC for t-LCotherD.
def var v-rid as rowid.

if s-lcprod = 'imlc' then assign v-title = ' OTHER DETAILS ' v-priz = 'o'.
else if s-lcprod = 'pg' then assign v-title = ' INSTRUCTIONS ' v-priz = 'i'.
else do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'fmt' no-lock no-error.
    if avail lch and lch.value1 <> '' then do:
        if lch.value1 = 'mt700' then assign v-title = ' OTHER DETAILS ' v-priz = 'o'.
        else return.
    end.
end.
define browse b_LC query q_LC
       displ t-LCotherD.dataName  format "x(37)"
             t-LCotherD.dataValueVis format "x(65)"
             with 5 down overlay no-label title v-title.
def button bsave label "SAVE".
define frame f_LC b_LC help "<Enter>-Edit <F2>- Help"  skip bsave with width 110 row 3 /*overlay*/ no-box.
def var v-chose as logi init yes.
def var v-errMsg as char no-undo.
def var v-advopt as char.
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
    t-LCotherD.dataName format "x(37)"
    t-LCotherD.value1 format "x(65)" validate(validh(t-LCotherD.kritcode,t-LCotherD.value1, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.


define frame f3_LCh
    t-LCotherD.value1 view-as editor size 62 by 5
    with width 62 no-label overlay column 45 no-box.

empty temp-table t-LCotherD.

v-advopt = ''.
find first LCh where LCh.LC = s-lc and LCh.kritcode = 'AdvThOpt' no-lock no-error.
if avail LCh and LCh.value1 <> '' then v-advopt = LCh.value1.


for each LCkrit where LCkrit.LCtype = 'I' and LCkrit.priz = v-priz no-lock:
    create t-LCotherD.
    assign t-LCotherD.LC        = s-lc
           t-LCotherD.kritcode  = LCkrit.dataCode
           t-LCotherD.showOrder = LCkrit.showOrder
           t-LCotherD.dataName  = LCkrit.dataName
           t-LCotherD.dataSpr   = LCkrit.dataSpr.
    find first LCh where LCh.LC = s-lc and LCh.kritcode = LCkrit.dataCode no-lock no-error.

    if avail LCh then buffer-copy LCh except LCh.LC to t-LCotherD.
    else do:
        if t-LCotherD.kritcode = 'AppRule' then t-LCotherD.value1 = 'OTHR/SEE FIELD 77C' .
        t-LCotherD.bank = s-ourbank.
    end.
    if lookup(t-LCotherD.kritcode,'AdvThrou,ReimBnk') > 0 and t-LCotherD.value1 <> '' then do:
        find first swibic where swibic.bic = t-LCotherD.value1 no-lock no-error.
        if avail swibic then t-LCotherD.dataValueVis = swibic.bic + ' - ' + swibic.name.
        else t-LCotherD.dataValueVis = getVisual(t-LCotherD.kritcode,t-LCotherD.value1).
    end.
    else  t-LCotherD.dataValueVis = getVisual(t-LCotherD.kritcode,t-LCotherD.value1).

end.


on "enter" of b_LC in frame f_LC do:
    if v-lcsts <> 'NEW' then return.
    find first LC where LC.lc = s-lc no-lock no-error.
   /* if lc.rwho <> g-ofc then do:
        message 'The letter of credit has been registered by another user! You have no permissions to edit it!' view-as alert-box.
        return.
    end.*/

    if avail t-LCotherD then do:
        if t-LCotherD.kritcode = 'AppRule' then return.
        b_LC:set-repositioned-row(b_LC:focused-row, "always").
        v-rid = rowid(t-LCotherD).
        if t-LCotherD.kritcode = "StoRInf" then do:

            {editor_update.i
                &var    = "t-LCotherD.value1"
                &frame  = "fr1"
                &framep = "column 36 row 5 overlay no-labels width 45. frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "35"
                &num_lines  = "6"
                &num_down  = "6"
            }
        end.
        if t-LCotherD.kritcode = 'InstoBnk' then do:

           {editor_update.i
                &var    = "t-LCotherD.value1"
                &frame  = "fr2"
                &framep = "column 36 row 5 overlay no-labels width 75. frame fr2:row = b_LC:focused-row + 2"
                &chars_in_line  = "65"
                &num_lines  = "12"
                &num_down  = "12"
            }
        end.

        if t-LCotherD.kritcode = "DetGar" then do:

            {editor_update.i
                &var    = "t-LCotherD.value1"
                &frame  = "fr3"
                &framep = "column 36 row 5 overlay no-labels width 75. frame fr1:row = b_LC:focused-row + 2"
                &chars_in_line  = "65"
                &num_lines  = "150"
                &num_down  = "30"
            }
        end.

        if lookup(t-LCotherD.kritcode,"AdvThrou,ReimBnk,AdvThOpt") > 0 then do:
            if t-LCotherD.kritcode = 'AdvThrou' and v-advopt <> 'A' then do:
                if v-advopt = 'B' then do:
                    frame f2_LCh:row = b_LC:focused-row + 3.
                    displ  t-LCotherD.DataName t-LCotherD.value1 with frame f2_LCh.
                    update t-LCotherD.value1 format "x(35)" with frame f2_LCh.
                end.
                if v-advopt = 'D' then do:
                   {editor_update.i
                        &var    = "t-LCotherD.value1"
                        &frame  = "fr4"
                        &framep = "column 36 row 5 overlay no-labels width 45. frame fr3:row = b_LC:focused-row + 2"
                        &chars_in_line  = "35"
                        &num_lines  = "4"
                        &num_down  = "4"
                    }
                end.
            end.
            else do:

                frame f2_LCh:row = b_LC:focused-row + 3.
                displ  t-LCotherD.DataName t-LCotherD.value1 with frame f2_LCh.

                update t-LCotherD.value1 /*format "x(35)"*/ with frame f2_LCh.
                if t-LCotherD.kritcode = 'AdvThOpt' then do:
                v-advopt = t-LCotherD.value1.
                    if v-advopt = 'A' then do:
                        find first b-LCotherD where b-LCotherD.LC = s-lc and b-LCotherD.kritcode = 'AdvThrou' no-lock no-error.
                        if avail b-LCotherD and b-LCotherD.value1 <> '' then do:
                            find first swibic where swibic.bic = b-LCotherD.value1 no-lock no-error.
                            if not avail swibic then do:
                                find current b-LCotherD exclusive-lock no-error.
                                b-LCotherD.value1 = ''.
                                b-LCotherD.dataValueVis = getVisual(b-LCotherD.kritcode, b-LCotherD.value1).
                                find current b-LCotherD no-lock no-error.
                            end.
                        end.
                    end.
                    if v-advopt = 'B' then do:
                        find first b-LCotherD where b-LCotherD.LC = s-lc and b-LCotherD.kritcode = 'AdvThrou' no-lock no-error.
                        if avail b-LCotherD and b-LCotherD.value1 <> '' then do:
                            find current b-LCotherD exclusive-lock no-error.
                            b-LCotherD.value1 = substr(b-LCotherD.value1,1,35).
                            b-LCotherD.dataValueVis = getVisual(b-LCotherD.kritcode, b-LCotherD.value1).
                            find current b-LCotherD no-lock no-error.

                        end.

                    end.
                end.
            end.
        end.


        if lookup(t-LCotherD.kritcode,'AdvThrou,ReimBnk,AdvThOpt') > 0 and t-LCotherD.value1 <> '' then do:
            /*find first bankl where bankl.bank = t-LCotherD.value1 no-lock no-error.
            if avail bankl then t-LCotherD.dataValueVis = bankl.bank + ' - ' + bankl.name.*/
            find first swibic where swibic.bic = t-LCotherD.value1 no-lock no-error.
            if avail swibic then t-LCotherD.dataValueVis = swibic.bic + ' - ' + swibic.name.

            else t-LCotherD.dataValueVis = getVisual(t-LCotherD.kritcode,t-LCotherD.value1).
        end.
        else t-LCotherD.dataValueVis = getVisual(t-LCotherD.kritcode, t-LCotherD.value1).

        open query q_LC for each t-LCotherD no-lock.
        reposition q_LC to rowid v-rid no-error.
        b_LC:refresh().
    end.
end.

on help of t-LCotherD.value1 in frame f2_LCh do:
    if (t-LCotherD.kritcode = 'AdvThrou' and v-advopt = 'A') or (t-LCotherD.kritcode = 'ReimBnk') then do:

         run swiftfind(output t-LCotherD.value1).
         find first swibic where swibic.bic = t-LCotherD.value1 no-lock no-error.
         if avail swibic then t-LCotherD.dataValueVis = swibic.bic + ' - ' + swibic.name.

         displ t-LCotherD.value1 with frame f2_LCh.
    end.
    else do:
        find first LCkrit where LCkrit.dataCode = t-LCotherD.kritcode no-lock no-error.
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
                t-LCotherD.value1 = codfr.code.
                t-LCotherD.dataValueVis = getVisual(t-LCotherD.kritcode, t-LCotherD.value1).
                displ t-LCotherD.value1 with frame f2_LCh.
            end.
        end.
    end.
end.
def var v-chkMess as char no-undo.
on choose of bsave in frame f_LC do:
    i = 0.
    for each t-LCotherD no-lock:
        find first LCh where LCh.LC = s-lc and LCh.kritcode = t-LCotherD.kritcode exclusive-lock no-error.
        if not avail LCh then create LCh.
        buffer-copy t-LCotherD to LCh.
        i = i + 1.
    end.
    if i > 0 then  message " Saved!!! " view-as alert-box information.
    else message " No data to save " view-as alert-box information.
    hide all no-pause.

end.

open query q_LC for each t-LCotherD no-lock use-index idx_sort.

if v-lcsts = 'NEW' then enable all with frame f_LC.
else enable b_LC with frame f_LC.


wait-for window-close of current-window or choose of bsave.




