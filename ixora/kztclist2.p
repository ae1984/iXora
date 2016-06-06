/* kztclist.p
 * MODULE
      Коммунальные платежи 
 * DESCRIPTION
     Прием платежей Казахтелеком
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        kztcown.p, kztcall.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
     п.3.2.10.1 или 3.1.5.1 Казахтелеком 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     20.06.2003 kanat    - Добавил печать чека при создании платежа
     13.07.2003 kanat    - Вместо номера телефона и лицевого счета показывается только счет - извещение
     22.09.2003 sasco    - Удалять платежи могут только менеджеры из sysc."COMDEL".chval
     24.09.2003 sasco    - сделал запись причины удаления через comdelpay.i
     01.19.2004 kanat    - увеличил формат вывода номеров квитанций
     18.04.2004 kanat    - добавил вывод комиссии в спсике платежей 
     04.08.2004 saltanat - добавила передачу KOd, KBe, KNp в процедуру kztcprn.p
     01/09/2005 kanat    - добавил прием платежей АО Казактелеком в филиале г. Астана
     31.07.2006 dpuchkov - убрал комиссию 50 тг для сервисных точек
     08.09.2006 dpuchkov - запрет на удаление платежей. Только через АлматыТелеком
     13.09.2006 dpuchkov - добавил кнопку извещение.
     21.09.2006 dpuchkov - добавил кнопку биллинг
*/


{get-dep.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid.
def var dat as date.
def var selgrp as integer init 3. /* Определяем номер группы в таблице commonls */

define variable docdnum as int.
define variable docuid as char.

def var s_rid as char.
def var s_payment as char.

def buffer b-syss13 for sysc.

find last b-syss13 where b-syss13.sysc = 'KAZT13' no-lock no-error.
if avail b-syss13 then do:
   if b-syss13.chval = userid("bank") then do:
      alldoc = True.
   end.
end.





if seltxb = 1 then 
   selgrp = 10.

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
        with 14 down title "Платежи Казахтелеком" no-labels. 

DEFINE BUTTON bedt  LABEL "Просм/Измен".
DEFINE BUTTON bnew  LABEL "Новый".
DEFINE BUTTON bbks  LABEL "БКС".
DEFINE BUTTON bdel  LABEL "Удалить".
DEFINE BUTTON bprn  LABEL "Ордер".
DEFINE BUTTON bkvt  LABEL "Извещение".
DEFINE BUTTON bacc  LABEL "Итог".
DEFINE BUTTON bof   LABEL "Биллинг".

def frame f1 
    b1 

    bedt 
    bnew
    bbks
    bdel
    bprn
    bkvt  
    bacc 
    bof.

ON CHOOSE OF bof IN FRAME f1
    do:
       MESSAGE "Изменить параметр?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Внимание" UPDATE q_ch as logical.
       if q_ch = True then do:
          def var v_pass as char.
          update v_pass label "Введите пароль" format "x(5)"  with frame kk side-labels centered row 8.
          if v_pass = "***" then do:
             find last sysc where sysc.sysc = "ONL" no-error.
             if avail sysc then do: 
                sysc.chval = "". 
                message "Биллинговая система ОТКЛЮЧЕНА". pause.
             end.
          end. else
          if v_pass = "###" then do:
             find last sysc where sysc.sysc = "ONL" no-error.
             if avail sysc then do: 
                sysc.chval = "1". 
                message "Биллинговая система ВКЛЮЧЕНА". pause.
             end.
          end. else
          do:
             message "Неверный пароль". pause.
          end.
       end.
    end.


ON CHOOSE OF bedt IN FRAME f1
    do:
        run kztcin2(dat, false, rowid(commonpl)).              
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
        run kztcin2 (dat, true, rowid(commonpl)).


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
        and commonpl.grp = selgrp no-lock use-index datenum.
        get last q1.
        reposition q1 to rowid to-rowid(return-value) no-error.
        b1:refresh().
        end.
    end.

ON CHOOSE OF bdel IN FRAME f1
do:


    message "Удаление транзакции невозможно, необходимо письмо в АлматыТелеком!" . pause.
    return.


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
            and commonpl.grp = selgrp no-lock use-index datenum.
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
            find first commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock no-error.
            if avail commonls then
            run kztcprn (string(rowid(commonpl)), commonls.kod, commonls.kbe, commonls.knp).
        end.
    end.
    
ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and 
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock:
            ACCUMULATE sum (TOTAL COUNT).
        END.
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and
            (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock:
            ACCUMULATE commonpl.comsum (TOTAL).
        END.
        FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and
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

ON CHOOSE OF bkvt IN FRAME f1
    do:
/*        run stadkvit3(string(rowid(commonpl))).*/
/*      run kztckvit(string(rowid(commonpl))). */
    end.

open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and
    (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock use-index datenum.

ENABLE all WITH centered FRAME f1.

b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
