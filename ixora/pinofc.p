/* pinofc.p
 * MODULE
       ДРР
 * DESCRIPTION
       Перенос кассиров из СПФ в другое СПФ
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        30/09/04 kanat
 * CHANGES
*/

{get-dep.i}
{ppoint_select.i}
{global.i}
{sysc.i}

def var v-ofc as char format "x(35)".
def var v-depname as char format "x(35)".
def var v-depcod as integer.
def var v-choice as logical.
def var v-point as integer.
def var v-temp-dep as integer.
def var v-profit as char.
def var v-tn as char.
define var v-dcode as char init "1,2,3,4,35,36,37". 
define var v-cashier-fio as char format "x(35)" init ''.

define frame sf  
               v-ofc         label "Логин кассира"        help "F2 - ВЫБОР" skip
               v-cashier-fio label "ФИО кассира"          skip
               v-depname     label "СПФ (куда направить)" help "F2 - ВЫБОР" skip
               with side-labels centered.

on return of v-ofc in frame sf
do:
    v-ofc = v-ofc:screen-value.
    find first ofc where ofc.ofc = trim(v-ofc) no-lock no-error.   
    if avail ofc then
    v-cashier-fio = ofc.name.
    displ v-cashier-fio with frame sf.
end.

on help of v-depname in frame sf 
do:
        run select_ppoint.
        if return-value <> "" then do:
            find first ppoint where ppoint.depart = integer(return-value) no-lock no-error.
            v-depname = trim(ppoint.name).
            v-depcod = ppoint.depart.
            displ v-depname with frame sf.
        end.
end.

update v-ofc v-depname with frame sf.

    v-temp-dep = get-dep(v-ofc, g-today).
    if v-temp-dep = v-depcod then do:
    message "Неверное СПФ" view-as alert-box title "Внимание".
    undo, retry.
    end.

    if lookup(string(v-temp-dep), v-dcode) > 0 then do:
    message "Неверный кассир" view-as alert-box title "Внимание".
    undo, retry.
    end.

    if trim(v-cashier-fio) = '' then do:
    message "Неверный логин" view-as alert-box title "Внимание".
    return.
    end.

    MESSAGE "Перевести кассира " v-cashier-fio "(" v-ofc ") в " skip 
             v-depname " ?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
    TITLE "Внимание" UPDATE v-choice.

    if v-choice then 
   
do transaction:
    find first point no-lock no-error.
    v-point = point.point.

    find first ofc where ofc.ofc = trim(v-ofc) exclusive-lock no-error.
    if avail ofc then do:
    find ofchis where ofchis.ofc = ofc.ofc and ofchis.regdt = g-today exclusive-lock no-error.
    if available ofchis then do:
      ofchis.point = v-point.
      ofchis.dep = v-depcod.
    end.
    else do:
      create ofchis.
      assign ofchis.ofc = ofc.ofc
             ofchis.point = v-point
             ofchis.dep = v-depcod
             ofchis.regdt = g-today.
    end.
    ofc.regno = v-point * 1000 + v-depcod.
    end.

    v-profit = get-sysc-cha("PCRKO") + string(v-depcod, '99').

    find first ofc-tn where ofc-tn.ofc = trim(v-ofc) no-lock no-error.
    if avail ofc-tn then v-tn = ofc-tn.tn.
                    else v-tn = "".

    find ofcprofit where ofcprofit.ofc = ofc.ofc and ofcprofit.profitcn = v-profit and
         ofcprofit.regdt = g-today exclusive-lock no-error.

    if not avail ofcprofit then do:
      create ofcprofit.
      assign ofcprofit.ofc = v-ofc
             ofcprofit.profit = v-profit
             ofcprofit.regdt = g-today
             ofcprofit.tn = v-tn.
    end.
    assign ofcprofit.tn =  v-tn
           ofcprofit.tim = time
           ofcprofit.who = g-ofc.

    ofc.titcd = v-profit.

    release ofcprofit.
    release ofchis.
    release ofc.
end.

    else do:
    return.
    end.






