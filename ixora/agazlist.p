/* agazlist.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Астана ГАЗ - список платежей
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        База в г. Астана, 3.2.10.1 и 3.1.5.1    
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.06.2003 kanat Добавил печать чека при создании платежа
        09/06/2003 kanat Добавил автоматичекую печать чека КС при приеме кивтанции
*/

{get-dep.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

define variable docdnum as int.
define variable docuid as char.
define buffer tcommonpl for commonpl.
                 
def shared var g-today as date.

def input parameter alldoc as logical.
def input parameter selgrp   as integer.

def var rid as rowid.
def var sigma as char.
def var sigmacnt as integer format ">>>>>>9".
def var sigmas1 as decimal format ">>>,>>>,>>9.99".
def var sigmas2 as decimal format ">>>,>>>,>>9.99".
def var sigmast as decimal format ">>>,>>>,>>9.99".

def var s_rid as char.
def var s_payment as char.

def var dat as date.
define stream s1.

def var crlf as char.
crlf = chr(10).

dat = g-today.

update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

DEFINE QUERY q1 FOR commonpl .
def browse b1
    query  q1 no-lock 
    display 
        string(get-dep(uid, dat),">9") label "РК"    format "99" 
        commonpl.service               label "Куда"  format "x(10)" 
        commonpl.dnum                  label "No"    format ">>>>9" 
        commonpl.fio                   label "ФИО"   format "x(20)"
        commonpl.adr                   label "Адрес" format "x(20)"
        commonpl.Sum                   label "Сумма" format ">>>>>>9.99"
        with 14 down title "Платежи Газовой Ассоциации г.Астана" no-labels. 

DEFINE BUTTON bedt LABEL "Просм/Измен".        
DEFINE BUTTON bnew LABEL "Новый".
DEFINE BUTTON bbks LABEL "БКС".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bacc LABEL "Итог".

def frame f1 
    b1 
    skip
    space(12) 
    bedt
    bnew
    bbks
    bdel
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        selgrp = commonpl.grp.
        run agaz-in (dat, false, rowid(commonpl), selgrp).
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
        run agaz-in (dat, true, rowid(commonpl), selgrp).


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
                (alldoc or uid = userid("bank")) and deluid = ?
                and commonpl.grp = selgrp no-lock use-index datenum.
            reposition q1 to rowid to-rowid(return-value).
            b1:refresh().
            b1:select-row(CURRENT-RESULT-ROW("q1")). 
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
       TITLE "Внимание" UPDATE choice as logical.
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

             &where = " commonpl.grp = selgrp and commonpl.type = tcommonpl.type and commonpl.service = tcommonpl.service and commonpl.accnt = tcommonpl.accnt and commonpl.counter = tcommonpl.counter "
            }
            
            FIND commonpl WHERE ROWID(commonpl) = rid EXCLUSIVE-LOCK.
            assign 
                commonpl.deluid = userid('bank')
                commonpl.deltime = time.

            open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
                        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ?
                        and commonpl.grp = selgrp no-lock use-index datenum.
            b1:refresh().
          end.
        end case.    
    end.
    end.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
    sigma = ''.
    sigmacnt = 0.
    sigmast = 0.
    sigmas1 = 0.
    sigmas2 = 0.
    output stream s1 to commitog.img.

    for each commonls where commonls.visible = yes and commonls.grp = selgrp and commonls.txb = seltxb
             no-lock use-index type break by commonls.arp :
     IF FIRST-OF(commonls.arp) THEN do:

       FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
                               commonpl.arp = commonLS.arp and
                              (alldoc or commonpl.uid = userid("bank")) and
                               commonpl.deluid = ? and 
                               commonpl.grp = selgrp no-lock:
        ACCUMULATE commonpl.sum (TOTAL COUNT).
        ACCUMULATE commonpl.comsum (TOTAL).
        ACCUMULATE commonpl.comsum + commonpl.sum (TOTAL COUNT).
       END.

       sigmast  = sigmast  + (accum total commonpl.comsum + commonpl.sum).
       sigmas1  = sigmas1  + (accum total commonpl.sum).
       sigmas2  = sigmas2  + (accum total commonpl.comsum).
       sigmacnt = sigmacnt + (accum count commonpl.sum).

       if (accum count commonpl.sum) > 0 then
       sigma = sigma + crlf + "ARP: " + trim(commonLS.bn) + " " + commonLS.arp + crlf +
               "            Платежей: " + string(accum count commonpl.sum,">>>>>>>>>>>>>9") + crlf +
               "            Hа сумму: " + string(accum total commonpl.sum,">>>,>>>,>>9.99") + crlf +
               "            Комиссия: " + string(accum total commonpl.comsum,">>>,>>>,>>9.99") + crlf +
               "            Всего:    " + string(accum total commonpl.comsum + commonpl.sum,">>>,>>>,>>9.99") + crlf.

               
     end. /* first-of */

    end.

    sigma = sigma + crlf + "------------------------------------"  + crlf + crlf + 
            "Кол-во платежей: " + string(sigmacnt,">>>>>>>>>>>>>9")   + crlf + 
            "Hа сумму: " +        string(sigmas1, ">>>,>>>,>>9.99")  + crlf +
            "Комиссия: " + string(sigmas2,">>>,>>>,>>9.99")  + crlf +
            "Всего:    " + string(sigmast,">>>,>>>,>>9.99")  + crlf.

    put stream s1 unformatted sigma.
    output stream s1 close.

    find commonpl where rowid(commonpl) = rid no-error.

    run menu-prt( 'commitog.img' ).
end.

 open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and 
    (alldoc or commonpl.uid = userid("bank")) and commonpl.grp = selgrp and commonpl.deluid = ?
    no-lock use-index datenum.
 ENABLE all WITH centered FRAME f1.

 get last q1.
 reposition q1 to rowid rowid(commonpl) no-error.
 b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
/*     b1:refresh().*/

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
