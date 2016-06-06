/* wplist.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       ИВЦ/Алсеко/Водоканал/АПК - список платежей
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
*/

/* wplist.p
 * Модуль
     Коммунальные платежи
 * Назначение
     Процедура приема платежей ИВЦ / Алсеко / Водоканал / АПК
 * Применение

 * Вызов
     
 * Пункты меню    
     п. 3.2.10.5.1 Прием платежей ИВЦ / Алсеко / Водоканал / АПК
 * Автор
     pragma
 * Дата создания:
     27.06.03
 * Изменения
     24.07.03 kanat Добавил обработку платежей АПК
     22.09.2003 sasco Удалять платежи могут только менеджеры из sysc."COMDEL".chval 
     24.09.2003 sasco сделал запись причины удаления через comdelpay.i 
     10.02.2005 kanat Переделал формирвоание списка платежей
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{get-dep.i}
{comm-com.i}

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid.
def var dat as date.
def var selgrp as integer.

def var s_rid as char.
def var s_payment as char.
def var s_operation as char.

define variable docdnum as int.
define variable docuid as char.

define buffer tcommonpl for commonpl.

dat = g-today.

update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

find first commonpl where commonpl.txb = seltxb and date = dat and
    (grp = 5 or grp = 6 or grp = 7)
    no-lock no-error.
if not available commonpl then current-value(w_p_seq) = 0.

DEFINE QUERY q1 FOR commonpl.

def browse b1 
    query q1 no-lock 
    display 
        commonpl.DATE label "Дата"
                      format "99/99/99" 
        string(get-dep(commonpl.uid, dat),"99")
               format "99"
        left-trim(string(commonpl.dnum,">>>>9"))
                  format "x(5)" label "No" 
/*        commonpl.counter format "999999" label "Тел."  */
        commonpl.accnt format "9999999" label "Счет" 
        sum format ">>>>>>9.99" label "Сумма" 
        commonpl.comsum format ">9.99" label "Комиссия"
        commonpl.comsum + commonpl.sum
                 format ">,>>>,>>>,>>9.99" label "~ Всего" 
        with 14 down title "Платежи" no-labels. 



DEFINE BUTTON bedt  LABEL "Просм/Измен".
DEFINE BUTTON bnew  LABEL "Новый".
DEFINE BUTTON bbks  LABEL "БКС".
DEFINE BUTTON bdel  LABEL "Удалить".
/*
DEFINE BUTTON bprn  LABEL "Ордер".
DEFINE BUTTON bkvt  LABEL "Квитанция".
*/
DEFINE BUTTON bacc  LABEL "Итог".

def frame f1 
    b1 
    skip
    space(12)
    bedt 
    bnew
    bbks
    bdel
/*    bprn
    bkvt  */
    space(5)
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        selgrp = commonpl.grp.
        run wpin (dat, false, rowid(commonpl), selgrp). 
        b1:refresh().
   end.


ON CHOOSE OF bbks IN FRAME f1
    do:

    s_rid = string(commonpl.dnum).

    if commonpl.grp = 5 then
    s_operation = "Услуги ИВЦ".

    if commonpl.grp = 6 then
    s_operation = "Услуги Алсеко".

    if commonpl.grp = 7 then
    s_operation = "Услуги Водоканала".

    if commonpl.grp = 8 then
    s_operation = "Услуги АПК".

  s_payment = s_rid + "#" + s_operation + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".

  run bks(s_payment,"NO").
  b1:refresh().

    end.



ON CHOOSE OF bnew IN FRAME f1
    do:

        do while true:
           run comm-grp(output selgrp).
           if selgrp > 0 then leave.
           else if selgrp = -1 then return.
        end.

        run wpin (dat, true, rowid(commonpl), selgrp).


    if return-value <> "" then do:
    find first commonpl where rowid(commonpl) = to-rowid(return-value) no-lock no-error.
    if avail commonpl then do:
    s_rid = string(commonpl.dnum).
    if commonpl.grp = 5 then
    s_operation = "Услуги ИВЦ".
    if commonpl.grp = 6 then
    s_operation = "Услуги Алсеко".
    if commonpl.grp = 7 then
    s_operation = "Услуги Водоканала".
    if commonpl.grp = 8 then
    s_operation = "Услуги АПК".
    s_payment = s_rid + "#" + s_operation + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".
    run bks(s_payment,"NO").
    end.
    end.


        if return-value <> "" then do:
            open query q1 for each commonpl where commonpl.txb = seltxb and date = dat and 
            (alldoc or commonpl.uid = userid("bank")) and
            commonpl.deluid = ? and commonpl.grp = selgrp
            no-lock use-index datenum.
            get last q1.
            reposition q1 to rowid to-rowid(return-value) no-error.
            b1:refresh().
        end.
    end.

ON CHOOSE OF bdel IN FRAME f1
do:
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
        message "Сначала удалите документ "
                commonpl.joudoc " в журнале операций".
    else do:
    MESSAGE "Удалить документ N " + string(commonpl.dnum) + " ? "
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Платежи" UPDATE choice as logical.
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

             &wherebuffer = " commonpl.type = buftable.type and commonpl.grp = buftable.grp and commonpl.cretime < buftable.cretime "

             &whereSum   = " commonpl.counter = buftable.counter and 
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum <> buftable.sum and 
                             commonpl.accnt = buftable.accnt "
             
             &whereRNN = " TRUE "
             
             &whereAll = " TRUE "
             

             &olddate = "dat"
             &oldtxb = "seltxb"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " commonpl.grp = tcommonpl.grp and commonpl.type = tcommonpl.type and commonpl.sum = tcommonpl.sum and commonpl.accnt = tcommonpl.accnt and commonpl.rnn = tcommonpl.rnn "
            }
            
            FIND commonpl WHERE ROWID(commonpl) = rid EXCLUSIVE-LOCK.
            assign 
                commonpl.deluid = userid('bank')
                commonpl.deltime = time.
            release commonpl.
            open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat 
                              and (alldoc or commonpl.uid = userid("bank"))
                              and commonpl.deluid = ?
                              and (commonpl.grp = 5 or
                                   commonpl.grp = 6 or
                                   commonpl.grp = 7 or 
                                   commonpl.grp = 8)
                              no-lock use-index datenum.
            b1:refresh(). 
          end.
        end case.    
    end.
end. /* bdel */

/*
ON CHOOSE OF bprn IN FRAME f1
    do:
        if commonpl.comsum > 0 then 
            run kztcprn(string(rowid(commonpl))).
    end.
*/

def stream s1.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
    def var sigma as char init ''.
    def var sigmacnt as int init 0.
    def var sigmast as decimal init 0.
    def var sigmas1 as decimal init 0.
    def var sigmas2 as decimal init 0.
    output stream s1 to commitog.img.

    for each commonls where commonls.txb = seltxb and commonls.visible = yes and
             (commonls.grp = 5 or commonls.grp = 6 or commonls.grp = 7 or commonls.grp = 8)
             no-lock use-index type break by commonls.arp:
     IF FIRST-OF(commonls.arp) THEN do:

       FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.arp = commonLS.arp and
        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? and
        commonpl.grp = commonls.grp no-lock:
        ACCUMULATE commonpl.sum (TOTAL COUNT).
        ACCUMULATE commonpl.comsum (TOTAL).
        ACCUMULATE commonpl.comsum + commonpl.sum (TOTAL COUNT).
       END.

       sigmast  = sigmast  + (accum total commonpl.comsum + commonpl.sum).
       sigmas1  = sigmas1  + (accum total commonpl.sum).
       sigmas2  = sigmas2  + (accum total commonpl.comsum).
       sigmacnt = sigmacnt + (accum count commonpl.sum).

       if (accum count commonpl.sum) > 0 then
       sigma = sigma + chr(10) +
               string(commonLS.bn,"x(20)") + 
               "ARP: " + commonLS.arp + chr(10) +
               "            Платежей: " + string(accum count commonpl.sum,">>>>>>>>>>>>>9") + chr(10) +
               "            Hа сумму: " + string(accum total commonpl.sum,">>>,>>>,>>9.99") + chr(10) +
               "            Комиссия: " + string(accum total commonpl.comsum,">>>,>>>,>>9.99") + chr(10) +
               "            Всего:    " + string(accum total commonpl.comsum + commonpl.sum,">>>,>>>,>>9.99") + chr(10).


     end. /* first-of */

    end.

    sigma = sigma + chr(10) + "------------------------------------"  + chr(10) + chr(10) +
            "Кол-во платежей: " + string(sigmacnt,">>>>>>>>>>>>>9")   + chr(10) +
            "Hа сумму: " +        string(sigmas1, ">>>,>>>,>>9.99")  + chr(10) +
            "Комиссия: " + string(sigmas2,">>>,>>>,>>9.99")  + chr(10) +
            "Всего:    " + string(sigmast,">>>,>>>,>>9.99")  + chr(10).

/*    MESSAGE sigma skip
            "------------------------------------" skip
            "Количество платежей: " sigmacnt  skip
            "Hа сумму:            " sigmas1 skip
            "Комиссия:            " sigmas2 skip
            "Всего:               " sigmast skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Налоговые платежи" .   */

    put stream s1 unformatted sigma.
    output stream s1 close.

    find commonpl where rowid(commonpl) = rid no-error.

    run menu-prt( 'commitog.img' ).
end.
    

/*
ON CHOOSE OF bkvt IN FRAME f1
    do:
        run kztckvit(string(rowid(commonpl))).
    end.
*/

open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat
and (commonpl.grp = 5 or commonpl.grp = 6 or commonpl.grp = 7 or commonpl.grp = 8)
and (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? no-lock use-index datenum.

ENABLE all WITH centered FRAME f1.

b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
