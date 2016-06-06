/* asu-lst.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
        Астана Су Арнасы - список платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.4 (Астана)
 * AUTHOR
        2001 sasco
 * CHANGES
        20.06.2003 kanat Добавил печать чека при создании платежа
*/


{get-dep.i}
{comm-txb.i}

def shared var g-today as date.
def input parameter alldoc as logical.
def var igrp   as integer init 7.

def var seltxb as int.
seltxb = comm-cod().

define buffer tcommonpl for commonpl.

define variable docdnum as int.
define variable docuid as char.

def var rid as rowid.
def var sigma as char.
def var sigmacnt as integer format "99999999".
def var sigmas1 as decimal format ">>>,>>>,>>9.99".
def var sigmas2 as decimal format ">>>,>>>,>>9.99".
def var sigmast as decimal format ">>>,>>>,>>9.99".

def var s_rid as char.
def var s_payment as char.
def var s_service as char.

define stream s1.

def var crlf as char.
crlf = chr(10).

def new shared var dat as date.
def new shared var aValid   as logical initial false.
def new shared var doctype    as int format ">9".
def new shared var docfio     as char format "x(18)".
def new shared var docadr     as char format "x(45)".
def new shared var docstreet  as char format "x(30)".
def new shared var dochouse   as char format "x(10)".
def new shared var docflat    as char format "x(5)".
def new shared var docfioadr  as char format "x(63)".
def new shared var docbik     as integer format "999999999".
def new shared var dociik     as integer format "999999999".
def new shared var dockbk     as char format "x(6)".
def new shared var docbn      as char.
def new shared var docbank    as char.
def new shared var dockbe     as char format "x(2)".
def new shared var dockod     as char format "x(2)".
def new shared var docrnn     as char format "x(12)".
def new shared var docrnnnk   as char format "x(12)".
def new shared var docrnnbn   as char format "x(12)".
def new shared var docnpl     as char format "x(120)".
def new shared var docgrp     as integer.
def new shared var doctgrp    as integer.
def new shared var docarp     as char    format "x(10)".
def new shared var docnum     as integer  format "99999999".
def new shared var docsum     as decimal init 0.
def new shared var doccomsum  as decimal init 0.
def new shared var docprc     as integer  format "9.9999" init 0. /* Процент с АРП */
def new shared var bsdate     as date.
def new shared var esdate     as date.
def new shared var selgrp     as integer init 7.  /* Водоканал */
def new shared var doccnter   as integer. /* Последние показания счетчика */
def new shared var docaccnt   as integer format ">>>>>>>>>9".
def new shared var docSERV    as char FORMAT "x(3)".

selgrp = igrp.

dat = g-today.

update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

DEFINE QUERY q1 FOR commonpl .
def browse b1
    query q1 no-lock 
    display 
        string(get-dep(uid, dat),">9") label "РК"   format "99" 
/*        commonpl.service               label "Код"   format "x(3)"  */
        commonpl.dnum                  label "No"   format ">>>>>>9" 
        commonpl.valid                 no-label     format " /*" 
        commonpl.accnt                 label "Счет" format "99999999"
/*        commonpl.npl                   label "Назначение платежа" format "x(30)" */
        commonpl.sum                   label "Сумма"   format ">>>,>>>,>>9.99"
        commonpl.comsum                label "Комиссия" format ">>>,>>>,>>9.99"
        with 14 down title "Астана Су Арнасы" no-labels. 

DEFINE BUTTON bedt LABEL "Просм/Измен".        
DEFINE BUTTON bnew LABEL "Новый".
DEFINE BUTTON bacc LABEL "БКС".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bbks LABEL "Итог".

def frame f1 
    b1 
    skip
    space(2)
    bedt
    bnew
    bbks
    bdel
    space(2)
    bacc.


ON CHOOSE OF bedt IN FRAME f1
    do:
        run asu-in (dat, false, rowid(commonpl)).              
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
    if true then do:
        close query q1.
        run asu-in (dat, true, rowid(commonpl)).



    if return-value <> "" then do:
    find first commonpl where rowid(commonpl) = to-rowid(return-value) no-lock no-error.
    if avail commonpl then do:
    s_rid = string(commonpl.dnum).
    s_payment = s_rid + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".
    run bks(s_payment,"NO").
    end.
    end.



        if return-value <> "" then do:
        open query q1 for each commonpl where commonpl.txb = seltxb and date = dat and 
        (alldoc or uid = userid("bank")) and deluid = ?
        and commonpl.grp = selgrp
        no-lock use-index datenum.
        get last q1.
        reposition q1 to rowid to-rowid(return-value). 
        b1:refresh().
        end.
    end.
    end.
    
ON CHOOSE OF bdel IN FRAME f1 do:

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
    MESSAGE "Удалить?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Астана Су Арнасы" UPDATE choice as logical.
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

             &whylist = "2,3,4"

             &tblrnn = "rnn"
             &tblsum = "sum"

             &exceptRNN = " chval dnum cretime edate etim euid "
             &exceptALL = " chval dnum cretime edate etim euid "
             &exceptSUM = " chval dnum cretime edate etim euid sum comsum "

             &wherebuffer = " commonpl.type = buftable.type and commonpl.grp = buftable.grp and commonpl.cretime < buftable.cretime "

             &whereSum   = " commonpl.rnn = buftable.rnn and 
                             commonpl.valid = buftable.valid and
                             commonpl.rnnbn = buftable.rnnbn and 
                             commonpl.kb = buftable.kb and 
                             commonpl.counter = buftable.counter and 
                             commonpl.service = buftable.service and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum <> buftable.sum and 
                             commonpl.accnt = buftable.accnt "
             
             &whereRNN = " TRUE "
             
             &whereAll =   " commonpl.rnn = buftable.rnn and 
                             commonpl.valid = buftable.valid and
                             commonpl.rnnbn = buftable.rnnbn and 
                             commonpl.kb = buftable.kb and 
                             commonpl.service = buftable.service and
                             commonpl.counter = buftable.counter and 
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum = buftable.sum and 
                             commonpl.accnt = buftable.accnt "
             
             &olddate = "dat"
             &oldtxb = "seltxb"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " commonpl.grp = selgrp and commonpl.type = tcommonpl.type and commonpl.sum = tcommonpl.sum and commonpl.accnt = tcommonpl.accnt and commonpl.fio = tcommonpl.fio "
            }

            FIND commonpl WHERE ROWID(commonpl) = rid EXCLUSIVE-LOCK.
            assign 
                commonpl.deluid = userid('bank')
                commonpl.deltime = time.
            release commonpl.

            open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
                        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ?
                        and commonpl.grp = selgrp
                        no-lock use-index datenum.
            b1:refresh().

          end.
        end case.    
    end.
    end.
/*
ON CHOOSE OF bprn IN FRAME f1
    do:
        if commonpl.comsum > 0 then 
            run stadprn(string(rowid(commonpl))).
    end.
*/
ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
    sigma = ''.
    sigmacnt = 0.
    sigmas1 = 0.

    for each commonls where commonls.txb = seltxb and commonls.visible = yes and commonls.grp = selgrp
             no-lock use-index type break by commonls.arp :
     IF FIRST-OF(commonls.arp) THEN do:

       FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.arp = commonLS.arp and
        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? and 
        commonpl.grp = selgrp no-lock:
        ACCUMULATE commonpl.sum (TOTAL COUNT).
       END.

       sigmas1  = sigmas1  + (accum total commonpl.sum).
       sigmacnt = sigmacnt + (accum count commonpl.sum).


       if (accum count commonpl.sum) > 0 then
       sigma = sigma + crlf + "ARP: " + commonLS.arp + crlf +
               "Платежей: " + string(accum count commonpl.sum,">>>>>>>>>>>>>9") + crlf +
               "Hа сумму: " + string(accum total commonpl.sum,">>>,>>>,>>9.99") + crlf .
               
     end. /* first-of */

    end.

    MESSAGE sigma skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE " Астана Су Арнасы ".

    find commonpl where rowid(commonpl) = rid no-error.
end.

 open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and 
    (alldoc or commonpl.uid = userid("bank")) and commonpl.grp = selgrp and commonpl.deluid = ?
    no-lock use-index datenum.
 ENABLE all WITH centered FRAME f1.

 get last q1.
 reposition q1 to rowid rowid(commonpl) no-error.
 b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
