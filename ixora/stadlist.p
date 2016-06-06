/* stadlist.p
 * MODULE
        Коммунальные платежи (платежи станций диагностики)
 * DESCRIPTION
        Процедура регистрации платежей станций диагностики
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        В базе по г. Уральск 3.2.10.3 и 3.1.5.3, в базе по г. Астана 3.2.10.3 и 3.1.5.3, в базе по г. Алматы 3.2.10.7 и 3.1.5.6
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.06.2003 kanat Добавил печать чека из пункта меню БКС
        22.09.2003 sasco Удалять платежи могут только менеджеры из sysc."COMDEL".chval
        24.09.2003 sasco сделал запись причины удаления через comdelpay.i
        14.10.2003 sasco убрал сравнение при удалении по полям comcode, chval
        08.12.2003 kanat добавил новую шаренную переменную docnumber по вводу абонентских лицевых счетов для г. Уральска
        08.12.2003 kanat добавил новую шаренную переменную dockts для номеров КТС по таможенным платежам
        09.06.2004 kanat переделал метод refresh при принятии платежей - раньше форма всегда выдавала ошибки ?!
        17/06/2004 kanat печать квитанции производится только после создания записи в БД
        04.08.04 saltanat - добавлено передача параметров в процедуру stadprn (rids, KOd, KBe, KNp)
        12/07/2005 kanat изменил формат вывода комиссий на экран
        16.11.2005 suchkov - закомментировал один счет по просьбе Патем Сеитовны
        16/01/2006 u00568 Evgeniy - по тз 198  if rnnbn = "600700022288" отменить печать квитанции и извещения для
                   РГП "Центр по недвижимости по г. Алматы", переделал BKS.p (добавил отправителя и получателя)
        20.10.2006 u00568 Evgeniy - устарела программа stadkvit2.p
*/

{get-dep.i}

{comm-txb.i}
def var seltxb as int no-undo.
seltxb = comm-cod().
                 
def var KOd_ as char.
def var KBe_ as char.
def var KNp_ as char.

def shared var g-today as date.
def input parameter alldoc as logical.
def input parameter igrp   as integer.
def var newdnum as int no-undo.

define variable docdnum as int.
define variable docuid as char.

def var rid as rowid no-undo.
def var sigma as char no-undo.
def var sigmacnt as integer format ">>>>>>9" no-undo.
def var sigmas1 as decimal format ">>>,>>>,>>9.99" no-undo.
def var sigmas2 as decimal format ">>>,>>>,>>9.99" no-undo.
def var sigmast as decimal format ">>>,>>>,>>9.99" no-undo.

def var s_rid as char.
def var s_payment as char.

define stream s1.

def var crlf as char no-undo.
crlf = chr(10).

def new shared var dat as date.
def new shared var rnnValid   as logical initial false.
def new shared var doctype as int format ">9".
def new shared var docfio  as char format "x(30)".
def new shared var docadr  as char format "x(50)".
def new shared var docfioadr as char format "x(80)".
def new shared var docbik  as integer format "999999999".
def new shared var dociik  as integer format "999999999".
def new shared var dockbk  as char format "x(6)".
def new shared var docbn   as char.
def new shared var docbank as char.
def new shared var dockbe  as char format "x(2)".
def new shared var dockod  as char format "x(2)".
def new shared var docrnn   as char format "x(12)".
def new shared var docrnnnk as char format "x(12)".
def new shared var docrnnbn as char format "x(12)".
def new shared var docnpl   as char format "x(120)".
def new shared var docgrp   as integer.
def new shared var doctgrp  as integer.
def new shared var docarp   as char    format "x(10)".
def new shared var docnum   as integer  format ">>>>>>>9".
def new shared var docsum    as decimal init 0.
def new shared var doccomsum as decimal init 0.
def new shared var docprc    as integer  format "9.9999" init 0. /* Процент с АРП */
def new shared var bsdate    as date.
def new shared var esdate    as date.
def new shared var selgrp    as integer.
def new shared var docnumber as char.
def new shared var dockts as char.

selgrp = igrp.
def buffer tcommonpl for commonpl.

dat = g-today.

update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec.

DEFINE QUERY q1 FOR commonpl .
def browse b1
    query q1 no-lock
    display
        commonpl.dnum                  label "No" format ">>>>>9"
        commonpl.rnn                   label "РНН" format "x(12)"
        commonpl.npl                   label "Назначение платежа" format "x(10)"
        commonpl.Sum                   label "Сумма" format ">>>>>>9.99"
        commonpl.comSum                label "Ком." format ">>>>9.99"
        commonpl.comsum + sum          label "~ Всего" format ">>>>>9.99"
        with 14 down /* title "Платежи"*/ no-labels no-box.

DEFINE BUTTON bedt LABEL "Cм/Изм.".
DEFINE BUTTON bnew LABEL "Новый".
DEFINE BUTTON bbks LABEL "БКС".
DEFINE BUTTON bdel LABEL "Удал.".
DEFINE BUTTON bprn LABEL "Ордер.".
DEFINE BUTTON bkvt LABEL "Извещ.".
DEFINE BUTTON bdnum LABEL "НомДок".
DEFINE BUTTON bacc LABEL "Итог".

def frame f1
    b1
    skip
    "  __________________________________________________________________________" skip(1)
    "  "
    bedt
    bnew
    bbks
    bdel
    bprn
    bkvt
    bdnum
    bacc.



ON CHOOSE OF bedt IN FRAME f1
    do:
        run stadin(dat, false, rowid(commonpl)).
        b1:refresh().
    end.


ON CHOOSE OF bbks IN FRAME f1
    do:
      /*14/01/06 u00568 Evgeniy*/
      /*s_rid = string(commonpl.dnum).*/
      /*s_payment = s_rid + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".*/
      find first commonls where commonls.rnnbn = commonpl.rnnbn no-lock no-error. do:
        if avail commonls then
          s_rid = commonls.bn.
        else
          s_rid = "".
      end.
      s_payment = string(commonpl.dnum) + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT" .
      run bks(s_payment,"NO" + "#" + commonpl.rnnbn + "#" + s_rid + "#" + commonpl.rnn + "#" + commonpl.fioadr ).
      s_rid = string(commonpl.dnum).
      /*run bks(s_rid,"NO").*/
      b1:refresh().
    end.


ON CHOOSE OF bnew IN FRAME f1
do:
  if true then do:
    run stadin(dat, true, rowid(commonpl)).
    if return-value <> "" then do:
      open query q1 for each commonpl where commonpl.txb = seltxb
                                        and date = dat
                                        and (alldoc or commonpl.uid = userid("bank"))
                                        and commonpl.deluid = ?
                                        and commonpl.grp = selgrp
                                  no-lock use-index datenum.
      get last q1.
      reposition q1 to rowid to-rowid(return-value) no-error.
      b1:refresh().
      find first commonpl where rowid(commonpl) = to-rowid(substring(return-value,1,10)) no-lock no-error. do:
        /*u00568 16/01/2006*/
        if commonpl.rnnbn = "600700022288" then  do:
          APPLY "CHOOSE" TO bbks IN FRAME f1.
        end. else
          run stadkvit(return-value).
        /*
        if commonpl.arp = "010904705" or
            commonpl.arp = "000076575" or
            commonpl.arp = "010904514" or
            commonpl.arp = "010904307" or*/
/*          commonpl.arp = "010904404" or    suchkov - по просьбе Патем Сеитовны   */
            /*commonpl.arp = "250904829" or*/   /* Для филиала в г. Уральск - Управление Водоканала */
            /*commonpl.arp = "250904324" or*/   /* О А О Жайыктеплоэнерго */
            /*commonpl.arp = "250904227" or*/   /* Р К П Спецавтобаза */
            /*commonpl.arp = "250904625" then do:
          run stadkvit2(return-value).
        end.
        else
          run stadkvit(return-value).
          */
      end.
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
       TITLE "Налоговый платеж" UPDATE choice as logical.
        case choice:
          when true then do transaction:
            rid = rowid(commonpl).

            docdnum = commonpl.dnum.
            docuid = commonpl.uid.

            find tcommonpl where rowid(tcommonpl) = rid no-lock no-error.

            {comdelpay.i 
             &tbl = "commonpl"
             &tbldate = "date"
             &tbluid = "uid"
             &tbldnum = "dnum"
             &tblwhy = "delwhy"
             &tblwdnum = "deldnum"
             &tbldeluid = "deluid"
             &tbldeldate = "deldate"

             &whylist = "1,2,3,4"

             &tblrnn = "rnn"
             &tblsum = "sum"
             
             &exceptRNN = " chval dnum cretime edate etim euid rnn valid fio adr fioadr "
             &exceptALL = " chval dnum cretime edate etim euid "
             &exceptSUM = " chval dnum cretime edate etim euid sum comsum comcode "

             &wherebuffer = " buftable.grp = selgrp and buftable.type = commonpl.type and commonpl.cretime < buftable.cretime "

             &whereSUM   = " commonpl.rnn = buftable.rnn and
                             commonpl.rnnbn = buftable.rnnbn and
                             commonpl.kb = buftable.kb and
                             commonpl.counter = buftable.counter and
                             commonpl.z = buftable.z and
                             commonpl.valid = buftable.valid and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum <> buftable.sum
                           "
             
             &whereRNN   = " commonpl.rnn <> buftable.rnn and
                             commonpl.rnnbn = buftable.rnnbn and
                             commonpl.kb = buftable.kb and
                             commonpl.counter = buftable.counter and
                             commonpl.z = buftable.z and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum = buftable.sum
                           "
             &whereALL   = " commonpl.rnn = buftable.rnn and
                             commonpl.rnnbn = buftable.rnnbn and
                             commonpl.kb = buftable.kb and
                             commonpl.counter = buftable.counter and
                             commonpl.z = buftable.z and
                             commonpl.valid = buftable.valid and
                             commonpl.fioadr = buftable.fioadr and
                             commonpl.sum = buftable.sum
                           "
             &olddate = "dat"
             &oldtxb = "seltxb"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " commonpl.grp = selgrp and commonpl.type = tcommonpl.type and commonpl.sum = tcommonpl.sum and commonpl.cretime = tcommonpl.cretime and commonpl.rnn = tcommonpl.rnn "
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
          end.
        end case.
    end.
end. /* bdel */


ON CHOOSE OF bdnum IN FRAME f1
do:
   if not avail commonpl then return.
   if commonpl.joudoc <> ? or commonpl.rmzdoc <> ? then do:
      message "Не могу редактировать номер документа!~nСначала отмените зачисление на транзитный счет"
      view-as alert-box title "".
      return.
   end.
   newdnum = commonpl.dnum.
   update newdnum format "zzzzzz9" label "Новый номер платежного поручения"
          with side-labels centered row 5 overlay frame dnum_fr.
   hide frame dnum_fr.
   find first tcommonpl where tcommonpl.txb = commonpl.txb and tcommonpl.date = commonpl.date and tcommonpl.dnum = newdnum and
                              tcommonpl.grp = commonpl.grp no-lock no-error.
   if avail tcommonpl then do:
      message "Не могу присвоить номер платежа!~nТакой номер уже есть в системе"
      view-as alert-box title "".
      return.
   end.
   find current commonpl exclusive-lock no-error.
   if not avail commonpl then return.
   assign comm.commonpl.dnum = newdnum.
   release comm.commonpl.
   open query q1 for each commonpl where commonpl.txb = seltxb and commonpl.date = dat and
              (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? and commonpl.grp = selgrp
              no-lock use-index datenum.
   b1:refresh().
end.



ON CHOOSE OF bprn IN FRAME f1
    do:
        if commonpl.comsum > 0 then do:
                find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
                                          commonls.type = commonpl.type no-lock no-error.

                /* saltanat запоминаем КОД, КБЕ, КНП для передачи на печать */
                if avail commonls then do:
                assign
                        KOd_ = commonls.kod
                        KBe_ = commonls.kbe
                        KNp_ = commonls.knp
                no-error.
                run stadprn(string(rowid(commonpl)), KOd_, KBe_, KNp_).
                end.
        end.
    end.

ON CHOOSE OF bkvt IN FRAME f1
    do:
        run stadkvit(string(rowid(commonpl))).
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

    for each commonls where commonls.txb = seltxb and commonls.visible = yes and commonls.grp = selgrp
             no-lock use-index type break by commonls.arp :
     IF FIRST-OF(commonls.arp) THEN do:

       FOR each commonpl where commonpl.txb = seltxb and commonpl.date = dat and commonpl.arp = commonLS.arp and
        (alldoc or commonpl.uid = userid("bank")) and commonpl.deluid = ? and
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
       sigma = sigma + crlf + "ARP: " + commonLS.arp + crlf +
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
