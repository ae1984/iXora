/* mob-list.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
     20.06.2003 kanat Добавил печать чека при создании платежа 
     24.07.03 kanat Внес изменения в окно вывода платежей - увеличил формат для вывода номеров квитанций - выдавало ошибки
     22.09.2003 sasco Удалять платежи могут только менеджеры из sysc."COMDEL".chval
     24.09.2003 sasco сделал запись причины удаления через comdelpay.i
     29.06.2004 kanat добавил печать чека БКС после ввода платежа, при формировании проводок в Алмате он не печатается 
                      по jh.
     04.08.04 saltanat добавила передаваемые параметры для процедуры mob-prn(rids, KOd_, KBe_, KNp_).
     09.08.04 kanat - убрал проверку на commonpl.comdoc при удалении.
     24.04.2007 id00004 переделал зачисление на ARP счет.
*/

{get-dep.i}

{comm-txb.i}

def var KOd_ as char.
def var KBe_ as char.
def var KNp_ as char.

def var seltxb as int.
seltxb = comm-cod().

define variable docdnum as int.
define variable docuid as char.

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid.
def var dat as date.
def var selgrp as integer init 4. /* Определяем номер группы (K'CEll K-Mobile) commonls */
define buffer bc for commonpl.

def var s_rid as char.
def var s_payment as char.
def var s_service as char.

dat = g-today.
/*update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.*/

def var totalt as dec.

define variable candel as log.
def var totalcm as decimal.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.


/*
find first commonpl where date = dat and grp = selgrp no-lock no-error.
if not available commonpl then current-value(kztd) = 0.
*/

/*find last bc where bc.date = commonpl.date and use-index datenum no-lock no-error.
if avail bc then commonpl.dnum = bc.dnum + 1.
            else commonpl.dnum = 1.
*/
DEFINE QUERY q1 FOR commonpl.

def browse b1 
    query q1 no-lock 
    display 
        commonpl.DATE label "Дата" format "99/99/99" 
        string(get-dep(commonpl.uid, dat),"99") format "99" label "РК" 
        left-trim(string(commonpl.dnum,">>>>>>9")) format "x(10)" label "No" 
        commonpl.service format "999" label "Код" 
        commonpl.counter format "9999999" label "Тел." 
/*        commonpl.accnt format "9999999" label "Счет" */
        sum format ">>>>>>>9.99" label "Сумма" 
        comsum format ">>>>>>>9.99" label "Комиссия"
        with 14 down title "Платежи K'Cell/K-Mobile" no-labels. 

DEFINE BUTTON bedt  LABEL "Просмотр".
DEFINE BUTTON bnew  LABEL "Создать".
DEFINE BUTTON bbks  LABEL "БКС".
DEFINE BUTTON bdel  LABEL "Удалить".
DEFINE BUTTON bprn  LABEL "Ордер".
/*DEFINE BUTTON bkvt  LABEL "Квитанция".*/
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
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
     display
             commonpl.date         label "Дата" skip
             "Телефон: 8 " commonpl.service format "999" label "" 
             commonpl.counter      label ""  format "9999999" skip
             commonpl.fio          label "ФИО"      format "x(40)" skip 
/*             commonpl.accnt        label "Счет"     format ">>>999999"  skip */
             commonpl.sum          label "Сумма"    format ">,>>>,>>9.99" skip 
             commonpl.comsum       label "Комиссия" format ">,>>>,>>9.99"
            WITH side-labels centered . 
     pause.
     hide frame sfview.
    end.


ON CHOOSE OF bbks IN FRAME f1
    do:

    s_rid = string(commonpl.dnum).

    if commonpl.service = '777' then
    s_service = 'За услуги K-Mobile'.

    if commonpl.service = '701' then
    s_service = 'За услуги K-Cell'.

s_payment = s_rid + "#" + s_service + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".

  run bks(s_payment,"NO").
  b1:refresh().

    end.



ON CHOOSE OF bnew IN FRAME f1
    do:
        run mob-in (dat, true, rowid(commonpl)).

  if return-value <> "" and seltxb = 0 then do:
  find first commonpl where rowid(commonpl) = to-rowid(return-value) no-lock no-error.
  if avail commonpl then do:
  s_rid = string(commonpl.dnum).

    if commonpl.service = '777' then
    s_service = 'За услуги K-Mobile'.

    if commonpl.service = '701' then
    s_service = 'За услуги K-Cell'.

  s_payment = s_rid + "#" + s_service + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".
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
/*
if not candel then message "Вы не можете удалить платеж!" view-as alert-box title 'ВНИМАНИЕ'.
else do:
*/

    if commonpl.rmzdoc <> ? then
        message "Сначала удалите платеж " commonpl.rmzdoc.
    else 
/*
    if commonpl.comdoc <> ? then
        message "Сначала удалите транзакцию " commonpl.comdoc.
    else
*/
    if commonpl.prcdoc <> ? then
        message "Сначала удалите транзакцию " commonpl.prcdoc.
    else
    if commonpl.joudoc <> ? then 
        message "Сначала удалите документ " commonpl.joudoc " в журнале операций".
    else do:
    MESSAGE "Удалить документ N " + string(commonpl.dnum) + " ? "
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Платеж K'Cell/K-Mobile" UPDATE choice as logical.
        case choice:
          when true then do transaction:
            rid = rowid(commonpl).
            find bc where rowid(bc) = rid no-lock no-error.
  
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

             &whylist = "2,3,4"
             
             &tblrnn = "rnn"
             &tblsum = "sum"

             &exceptRNN = " chval dnum cretime edate etim euid "
             &exceptALL = " chval dnum cretime edate etim euid "
             &exceptSUM = " chval dnum cretime edate etim euid sum comsum "

             &wherebuffer = " buftable.grp = selgrp and commonpl.type = buftable.type and commonpl.cretime < buftable.cretime "

             &whereSum   = " commonpl.type = buftable.type and
                             commonpl.rnn = buftable.rnn and 
                             commonpl.rnnbn = buftable.rnnbn and 
                             commonpl.counter = buftable.counter and 
                             commonpl.service = buftable.service and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum <> buftable.sum  "
             
             &whereRNN = " TRUE "
             
             &whereAll =   " commonpl.type = buftable.type and
                             commonpl.rnn = buftable.rnn and 
                             commonpl.rnnbn = buftable.rnnbn and 
                             commonpl.counter = buftable.counter and 
                             commonpl.service = buftable.service and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum = buftable.sum "
             
            
             &olddate = "dat"
             &oldtxb = "seltxb"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " commonpl.grp = selgrp and commonpl.type = bc.type and commonpl.counter = bc.counter "
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
	find first commonls where commonls.txb = seltxb and commonls.grp = selgrp no-lock no-error.

	if avail commonls then do:

	/* Запоминаем значения КОДА, КБЕ, КНП */
	assign
	      KOd_ = commonls.kod
	      KBe_ = commonls.kbe
	      KNp_ = commonls.knp
	no-error.
      
        run mob-prn (string(rowid(commonpl)), KOd_, KBe_, KNp_).
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
        totalcm = (accum total commonpl.comsum).

        MESSAGE "Количество платежей: " (accum count commonpl.sum) skip 
                "Hа сумму: " totalt skip
                "Комиссия: " totalcm skip 
                "Всего:    " (totalt + totalcm) skip
                VIEW-AS ALERT-BOX MESSAGE BUTTONS OK TITLE "Платежи K'Cell/K-Mobile" .

    find commonpl where rowid(commonpl) = rid.
end.

open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.grp = selgrp and
    (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock use-index datenum.

ENABLE all WITH centered FRAME f1.

b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
