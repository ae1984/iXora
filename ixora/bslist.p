/* bslist.p	
 * MODULE
      Коммунальные платежи 
 * DESCRIPTION
     Прием платежей Базис-телеком
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
     
 * AUTHOR
        09/04/07 id00004
 * CHANGES
        06.07.2007 id00004 добавил проверку по параметру type
*/


{get-dep.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid.
def var dat as date.
def var selgrp as integer init 9. /* Определяем номер группы в таблице commonls */

define variable docdnum as int.
define variable docuid as char.

def var s_rid as char.
def var s_payment as char.



dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

define buffer tcommonpl for commonpl.

define variable candel as log.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.



def var totalt as dec.

find first commonpl where txb = seltxb and date = dat and grp = selgrp no-lock no-error.
if not available commonpl then current-value(kztd) = 0.

DEFINE QUERY q1 FOR commonpl.

def browse b1 
    query q1 no-lock 
    display 
        commonpl.DATE label "Дата" format "99/99/99" 
        left-trim(string(commonpl.dnum,">>>>>>>9")) format "x(5)" label "No" 
        commonpl.fioadr format "x(15)" label "Сч. изв." 
        sum format ">>>>>>9.99" label "Сумма" 
        commonpl.comsum format ">,>>9.99" label "Ком-ия" 
        commonpl.comsum + commonpl.sum format ">,>>>,>>>,>>9.99" label "Всего" 
        with 14 down title "Платежи Базис-телеком" no-labels. 

DEFINE BUTTON bedt  LABEL "Просм/Измен".
DEFINE BUTTON bnew  LABEL "Новый".
DEFINE BUTTON bbks  LABEL "БКС".
DEFINE BUTTON bdel  LABEL "Удалить".
DEFINE BUTTON bprn  LABEL "Ордер".
DEFINE BUTTON bkvt  LABEL "Квитанция".
DEFINE BUTTON bacc  LABEL "Итог".

def frame f1 
    b1 
    skip
    space(12)
    bedt 
    bnew
    bbks
    bdel
    bprn
/*    bkvt  */
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        run bscin (dat, false, rowid(commonpl)).              
        b1:refresh().
   end.


ON CHOOSE OF bbks IN FRAME f1
    do:

    s_rid = string(commonpl.dnum).

s_payment = s_rid + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".

  run bks(s_payment,"NO").
  b1:refresh().

    end.



ON CHOOSE OF bnew IN FRAME f1
    do:
        run bscin (dat, true, rowid(commonpl)).


  if return-value <> "" then do:
  find first commonpl where rowid(commonpl) = to-rowid(return-value) no-lock no-error.
  if avail commonpl then do:
  s_rid = string(commonpl.dnum).
  s_payment = s_rid + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".
  run bks(s_payment,"NO").
  end.
  end.



        if return-value <> "" then do:
        open query q1 for each commonpl where txb = seltxb and date = dat and 
        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ?
        and commonpl.grp = selgrp and commonpl.type = 18  no-lock use-index datenum.
        get last q1.
        reposition q1 to rowid to-rowid(return-value) no-error.
        b1:refresh().
        end.
    end.

ON CHOOSE OF bdel IN FRAME f1
do:
/*
if not candel then message "Вы не можете удалить платеж!" view-as alert-box title 'ВНИМАНИЕ'.
else do:
*/
    if commonpl.rmzdoc <> ? then
        message "Сначала удалите платеж " commonpl.rmzdoc.
    else 
    if commonpl.comdoc <> ? then
        message "Сначала удалите транзакцию " commonpl.comdoc.
    else
    if commonpl.prcdoc <> ? then
        message "Сначала удалите транзакцию " commonpl.prcdoc.
    else
    if commonpl.joudoc <> ? then 
        message "Сначала удалите документ " commonpl.joudoc " в журнале операций".
    else do:
    MESSAGE "Удалить документ N " + string(commonpl.dnum) + " ? "
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Платеж Казахтелеком" UPDATE choice as logical.
        case choice:
          when true then do transaction:

            rid = rowid(commonpl).
            find tcommonpl where rowid (tcommonpl) = rid no-lock no-error.

            docdnum = commonpl.dnum.
            docuid = commonpl.uid.

            {comdelpay.i
             &tbl = "commonpl"
             &tbldate = "date"
             &tbluid = "uid"
             &tbldnum = "dnum"
             &tblwhy = "delwhy"
             &tblwdnum = "deldnum"
             &tbldeluid = "deluid"
             &tbldeldate = "deldate"

             &whylist = "2,4"

             &tblrnn = "rnn"
             &tblsum = "sum"
             
             &exceptRNN = " chval dnum cretime edate etim euid "
             &exceptALL = " chval dnum cretime edate etim euid "
             &exceptSUM = " chval dnum cretime edate etim euid sum comsum "

             &wherebuffer = " commonpl.type = buftable.type and buftable.grp = selgrp and commonpl.cretime < buftable.cretime "

             &whereSum = " commonpl.sum <> buftable.sum and 
                           commonpl.fioadr = buftable.fioadr and
                           commonpl.accnt = buftable.accnt and
                           commonpl.counter = buftable.counter "
             
             &whereRNN = " TRUE "
             
             &whereAll = " TRUE "
             
             &olddate = "dat"
             &oldtxb = "seltxb"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " commonpl.grp = selgrp and commonpl.type = tcommonpl.type and commonpl.sum = tcommonpl.sum and commonpl.counter = tcommonpl.counter and commonpl.rnn = tcommonpl.rnn "
            }
            
            FIND commonpl WHERE ROWID(commonpl) = rid EXCLUSIVE-LOCK.
            assign 
                commonpl.deluid = userid('bank')
                commonpl.deltime = time.

            release commonpl.
            open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ?
            and commonpl.grp = selgrp and commonpl.type = 18 no-lock use-index datenum.
            b1:refresh(). 
          end.
        end case.    
    end.
/*
end.
*/
end.

ON CHOOSE OF bprn IN FRAME f1
    do:
        if commonpl.comsum > 0 then do:
            find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and commonls.type = 18 no-lock no-error.
            if avail commonls then
            run bscprn (string(rowid(commonpl)), commonls.kod, commonls.kbe, commonls.knp).
        end.
    end.
    
ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and commonpl.type = 18 and 
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock:
            ACCUMULATE sum (TOTAL COUNT).
        END.
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and commonpl.type = 18 and
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock:
            ACCUMULATE commonpl.comsum (TOTAL).
        END.
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and commonpl.type = 18 and
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock:
            ACCUMULATE commonpl.comsum + sum (TOTAL COUNT).
        END.
        totalt=(accum total commonpl.sum).

        MESSAGE "Количество платежей: " (accum count commonpl.sum) skip 
                "Hа сумму: " totalt skip
                "Комиссия: " (accum total commonpl.comsum) skip
                "Всего:    " (accum total commonpl.comsum + sum) skip

           VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
           TITLE "Платежи Tелеком" .
    find commonpl where rowid(commonpl) = rid.
end.
/*
ON CHOOSE OF bkvt IN FRAME f1
    do:
        run kztckvit(string(rowid(commonpl))).
    end.
*/
open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and commonpl.type = 18 and
    (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock use-index datenum.

ENABLE all WITH centered FRAME f1.

b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
