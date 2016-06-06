/* penslist.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Пенсионные платежи
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        13/01/05 kanat
 * CHANGES
        19/01/05 kanat - вывод КНП в квитанции
        24/01/05 kanat - добавил обязательный ввод месяца и года
        29/03/05 kanat - добавил новую варенную переменную docphone для обязательного заполнения номеров телефонов
        23/02/06 suchkov - исправлена ошибка с параметрами в lookup
        14/04/06 u00600 - добавила ФИО и дату, удалила назначение платежа в соответствии с ТЗ ї240 от 10.02.06
        30/06/06 u00568 Evgeniy - по тз 369 пенсионные платежи отправляем в ГЦВП + оптимизация
        05/07/06 u00568 Evgeniy - исправил кнопку <Итог>
        07/07/06 u00568 Evgeniy - исправил реестр, вместо ФИО  поставил ФИО+АДР
        15/08/06 u00568 Evgeniy - оптимизил отчет
*/

{get-dep.i}
{comm-txb.i}

def var seltxb as int no-undo.
seltxb = comm-cod().
                 
def shared var g-today as date.
def input parameter alldoc as logical.
def input parameter igrp   as integer.
def input parameter is_it_pens as integer. /*0 - платежи в ГЦВП*/ /*1 - платежи в пенсионный фонд*/

def var newdnum as int no-undo.

define variable docdnum as int no-undo.
define variable docuid as char no-undo.

def var rid as rowid no-undo.
def var sigma as char no-undo.
def var sigmacnt as integer format ">>>>>>9" no-undo.
def var sigmas1 as decimal format ">>>,>>>,>>9.99" no-undo.
def var sigmas2 as decimal format ">>>,>>>,>>9.99" no-undo.
def var sigmast as decimal format ">>>,>>>,>>9.99" no-undo.

def var s_rid as char no-undo.
def var s_payment as char no-undo.

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

def new shared var docknp   as char format "x(3)".

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

def new shared var doctypegrp as integer format "99". /* месяц для соц. отчислений */
def new shared var doccounter as integer format "9999". /* год для соц. отчислений */

def new shared var docphone as char format "x(20)".

def var KOd_ as char no-undo.
def var KBe_ as char no-undo.
def var KNp_ as char no-undo.

def var v-patem as char no-undo.

def var lis_it_pens as logical no-undo.

lis_it_pens  = is_it_pens = 1.

selgrp = igrp.
def buffer tcommonpl for commonpl.


find first sysc where sysc.sysc = "PATEM" no-lock no-error.
if avail sysc then
v-patem = sysc.chval.
else
v-patem = "".


dat = g-today.

update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

def var totalt as dec no-undo.
def var browse_title as char no-undo.

if lis_it_pens then
  browse_title = 'Пенсионные платежи'.
else
  browse_title = 'Социальные отчисления'.

DEFINE QUERY q1 FOR commonpl.
def browse b1
    query q1 no-lock
    display
        commonpl.date                  label "Дата" format "99/99/99" /*23/03/06 u00600*/
        commonpl.dnum                  label "No" format ">>>>>9"
        commonpl.rnn                   label "РНН" format "999999999999"  /*"x(12)"*/
/*        commonpl.npl                   label "Назн.платежа" format "x(11)"*/ /*15*/
        commonpl.fioadr                label "Ф.И.О" format "x(12)"  /*23/03/06 - u00600*/
        commonpl.Sum                   label "Сумма" format ">>>>>>9.99"
        commonpl.comSum                label "Ком." format ">>>9.99"
        commonpl.comsum + commonpl.Sum label "Всего" format ">>>>>>9.99"
        with 12 down title browse_title no-labels .

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
        if dat >= g-today then
        run pensin(dat, false, rowid(commonpl), is_it_pens).
        else
        message "Данная операция невозможна" view-as alert-box title "".

        b1:refresh().
    end.


ON CHOOSE OF bbks IN FRAME f1
    do:

    if dat >= g-today then do:
    s_rid = string(commonpl.dnum).

s_payment = s_rid + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".

  run bks(s_payment,"NO").
  b1:refresh().

    end.
    else
    message "Данная операция невозможна" view-as alert-box title "".

    end.

ON CHOOSE OF bnew IN FRAME f1
    do:
    if dat >= g-today then do:
    if true then do:
        run pensin(dat, true, rowid(commonpl), is_it_pens).

     if return-value <> "" then do:
          run open_query_q1.
          if avail commonpl then do:
            get last q1.
            reposition q1 to rowid to-rowid(return-value) no-error.
            b1:refresh().
            run penskvit(return-value).
          end.
        end.
    end.
    end.
    else
    message "Данная операция невозможна" view-as alert-box title "".

    end.
    
ON CHOOSE OF bdel IN FRAME f1 do:

    if dat >= g-today then do:

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
       TITLE "" UPDATE choice as logical.
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
            run open_query_q1.
          end.
        end case.
    end.
    end.
    else
    message "Данная операция невозможна" view-as alert-box title "".

end. /* bdel */


ON CHOOSE OF bdnum IN FRAME f1
do:
   if dat >= g-today then do:
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
   assign  commonpl.dnum = newdnum.
   release  commonpl.
   run open_query_q1.
   end.
   else
   message "Данная операция невозможна" view-as alert-box title "".

   b1:refresh().

end.



ON CHOOSE OF bprn IN FRAME f1
    do:
   if dat >= g-today then do:
                find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and
                                          commonls.type = commonpl.type no-lock no-error.
                if avail commonls then do:
                assign
                        KOd_ = commonls.kod
                        KBe_ = commonls.kbe
                        KNp_ = commonls.knp
                no-error.
                message KOd_ KBe_ KNp_ view-as alert-box title "".
                run pensprn(string(rowid(commonpl)), KOd_, KBe_, KNp_).
                end.
   end.
   else
   message "Данная операция невозможна" view-as alert-box title "".
   end.

ON CHOOSE OF bkvt IN FRAME f1
    do:
   if dat >= g-today or lookup(userid("bank"),v-patem) <> 0 then
        run penskvit(string(rowid(commonpl))).
   else
   message "Данная операция невозможна" view-as alert-box title "".

    end.


ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(commonpl).
    sigma = ''.
    sigmacnt = 0.
    sigmast = 0.
    sigmas1 = 0.
    sigmas2 = 0.

    for each commonls where commonls.txb = seltxb and commonls.visible = no and commonls.grp = selgrp
             no-lock break by commonls.arp :
     IF FIRST-OF(commonls.arp) THEN do:

       FOR each commonpl where commonpl.txb = seltxb
                               and commonpl.date = dat
                               and commonpl.arp = commonLS.arp
                               and (alldoc or commonpl.uid = userid("bank"))
                               and commonpl.deluid = ?
                               and commonpl.grp = selgrp
                               and (alldoc or commonpl.abk = integer(lis_it_pens))
       no-lock:
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

    message sigma view-as alert-box title "".

    find commonpl where rowid(commonpl) = rid no-error.

end.

 run open_query_q1.
 ENABLE all WITH centered FRAME f1.

 get last q1.
 reposition q1 to rowid rowid(commonpl) no-error.
 b1:SET-REPOSITIONED-ROW(12, "CONDITIONAL").
/*     b1:refresh().*/

APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.


 procedure open_query_q1:
   open query q1 for each commonpl where
                 commonpl.txb = seltxb
                 and date = dat
                 and (alldoc or commonpl.uid = userid("bank"))
                 and commonpl.deluid = ?
                 and commonpl.grp = selgrp
                 and (alldoc or commonpl.abk = integer(lis_it_pens))
                no-lock use-index datenum.
 END PROCEDURE.
