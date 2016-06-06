/* taxlist.p
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       Список налоговых платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.4.1, 3.1.5.3.1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     20.06.2003 kanat Добавил печать чека при создании платежа
     22.09.2003 sasco Удалять платежи могут только менеджеры из sysc."COMDEL".chval
     24.09.2003 sasco сделал запись причины удаления через comdelpay.i
     08.10.2003 sasco откорректировал удаление платежей
     14.10.2003 sasco убрал сравнение при удалении по полям comcode, chval
     29.12.03 kanat платежи за 31.12.2003 не отправляются
     29.01.04 kanat увеличил формат выводимых сумм.
     17/06/2004 kanat печать квитанции производится только после создания записи в БД
     27/07/2006 u00568 Evgeniy - исправил ошибку - печать БКС ещё и по кассиру.
     28/07/2006 u00568 Evgeniy - добавил отправителя и получателя в БКС
*/

{get-dep.i}
{comm-txb.i}
{getfromrnn.i}

def var ourbank as char no-undo.
def var ourcode as integer no-undo.
ourbank = comm-txb().
ourcode = comm-cod().
                 
define variable docdnum as int.
define variable docuid as char.

define variable candel as log.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid no-undo.
def var dat as date no-undo.
dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

if dat = 12/31/2003 then do:
message "Идите домой ..." view-as alert-box title "Happy New Year".
return.
end.


def var totalt as dec no-undo.

def buffer btax for tax.
def var cdate as date no-undo.
def var ctime as int no-undo.
def var ctxb as int no-undo.
def var cdnum as int no-undo.
def var cuid as char no-undo.
def var crnn as char no-undo.
def var crnnnk as char no-undo.
def var ccreated as int no-undo.
def var i as int no-undo.
def var newdnum as int no-undo.


def var s_payment as char.
def var s_rid as char.
def var s_dnum_payment as char.
def var d_rowid as decimal.
def var i_docnum as integer.
def var s_budget as char.
def var i_kbknum as integer.
def var i_comtxb as integer.
def var i_comuid as char.
def var i_comrnn as char.
define var fioadr1 as char no-undo.


DEFINE QUERY q1 FOR tax.
def browse b1
    query q1 no-lock
    display
        string(get-dep(comm.tax.uid, dat),">9") format "99" label "РК"
        comm.tax.dnum label "No" format ">>>>>9"
        comm.tax.rnn label "РНН"
        comm.tax.kb format "999999" label "КБК   "
        comm.tax.Sum format ">>>>>>>>>>9.99" label "Сумма"
        comm.tax.comsum format ">>>>>>>9.99" label "Комиссия"
        comm.tax.comsum + sum format ">>>>>>>>>>9.99" label "~ Всего"
        with 14 down title "Налоговые платежи" no-labels.

DEFINE BUTTON bedt LABEL "См/Изм".
DEFINE BUTTON bnew LABEL "Новый".
DEFINE BUTTON bbks LABEL "БКС".
DEFINE BUTTON bdel LABEL "Удал".
DEFINE BUTTON bprn LABEL "Ордер".
DEFINE BUTTON bkvt LABEL "Извещ".
define button tnsbtn  label "Спр.т/н".
DEFINE BUTTON bacc LABEL "Итог".
DEFINE BUTTON bdnum LABEL "НомДок".

def frame f1
    b1
    skip
    bedt
    bnew
    bbks
    bdel
    bprn
    bkvt
    tnsbtn
    bdnum
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        run taxin(dat, false, rowid(comm.tax), alldoc).
        if return-value <> "" then do:
        open query q1 for each comm.tax where comm.tax.date = dat and
        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ?
        and comm.tax.txb = ourcode no-lock use-index datenum.
        get last q1.
        reposition q1 to rowid to-rowid(return-value) no-error.
        end.
        b1:refresh().
    end.


ON CHOOSE OF bbks IN FRAME f1 do:
  s_payment = ''.
  i_docnum = comm.tax.dnum.
  i_kbknum = comm.tax.kb.
  i_comtxb = comm.tax.txb.
  i_comuid = comm.tax.uid.
  i_comrnn = comm.tax.rnn.
  fioadr1 = getfioadr1(tax.rnn).
  if fioadr1 = '' then fioadr1 = tax.chval[1].
  find first taxnk where taxnk.rnn = tax.rnn_nk no-lock no-error.
  for each comm.tax where comm.tax.dnum = i_docnum
                      and comm.tax.date = dat
                      and comm.tax.txb = i_comtxb
                      and comm.tax.uid = i_comuid
                      and comm.tax.rnn = i_comrnn
                      and tax.duid = ?
                    no-lock.
    find first budcodes where budcodes.code = comm.tax.kb no-lock no-error.
    if avail budcodes then
      s_budget = budcodes.name.
    else
      s_budget = "Другие платежи в бюджет".
    s_payment = s_payment + string(tax.dnum) + "#" + s_budget + "#" + string(tax.sum) + "#" + string(tax.comsum) + "#" + "0" + "#" + "KZT" + "|".
  end.
  if avail taxnk then
    s_budget = "NO" + "#" + taxnk.rnn  + "#" + trim(taxnk.name) + "#" + i_comrnn + "#" + fioadr1.
  else
    s_budget = "NO".
  s_payment = right-trim(s_payment,"|").
  run bks(s_payment,s_budget).
  s_dnum_payment = "".
  s_payment = s_dnum_payment.
  b1:refresh().
end.


ON CHOOSE OF bnew IN FRAME f1
    do:
    if true then do:
        run taxin (dat, true, rowid(comm.tax), alldoc).

        if return-value <> "" then do:
        open query q1 for each comm.tax where comm.tax.date = dat and
        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ?
        and comm.tax.txb = ourcode no-lock use-index datenum.
        get last q1.
        reposition q1 to rowid to-rowid(return-value) no-error.
        b1:refresh().
        run taxkvit(return-value).
        end.
    end.
    end.
    
ON CHOOSE OF bdel IN FRAME f1 do:

/*
if not candel then message "Вы не можете удалить платеж!" view-as alert-box title 'ВНИМАНИЕ'.
else do:
*/

    if comm.tax.senddoc <> ? then
        message "Сначала удалите платеж " comm.tax.senddoc.
    else
    if comm.tax.comdoc <> ? then
        message "Сначала удалите транзакцию " comm.tax.comdoc.
    else
    if comm.tax.taxdoc <> ? then
        message "Сначала удалите документ " comm.tax.taxdoc " в журнале операций".
    else do:
    MESSAGE "Удалить?"
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Налоговый платеж" UPDATE choice as logical.
        case choice:
          when true then do transaction:
            rid = rowid(comm.tax).

            docdnum = tax.dnum.
            docuid = tax.uid.

            find btax where rowid(btax) = rid no-lock no-error.

            {comdelpay.i
             &tbl = "tax"
             &tbldate = "date"
             &tbluid = "uid"
             &tbldnum = "dnum"
             &tblwhy = "delwhy"
             &tblwdnum = "deldnum"
             &tbldeluid = "duid"
             &tbldeldate = "deldate"

             &whylist = "1,2,3,4"

             &tblrnn = "rnn"
             &tblsum = "sum"

             &exceptRNN = " chval dnum created edate etim euid valid rnn "
             &exceptALL = " chval dnum created edate etim euid "
             &exceptSUM = " chval dnum created edate etim euid sum comsum decval comcode "

             &wherebuffer = " tax.created < buftable.created "

             &whereSum   = " tax.rnn = buftable.rnn and
                             tax.rnn_nk = buftable.rnn_nk and
                             tax.kb = buftable.kb and
                             tax.sum <> buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "
             
             &whereRNN   = " tax.rnn <> buftable.rnn and
                             tax.rnn_nk = buftable.rnn_nk and
                             tax.kb = buftable.kb and
                             tax.sum = buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "
             
             &whereAll   = " tax.rnn = buftable.rnn and
                             tax.rnn_nk = buftable.rnn_nk and
                             tax.kb = buftable.kb and
                             tax.sum = buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "

             &olddate = "dat"
             &oldtxb = "ourcode"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " tax.rnn = btax.rnn and tax.rnn_nk = btax.rnn_nk and tax.created = btax.created  "
            }
            

            find first comm.tax where comm.tax.txb = btax.txb and
                                      comm.tax.date = btax.date and
                                      comm.tax.uid = btax.uid and
                                      comm.tax.created = btax.created and
                                      comm.tax.dnum = btax.dnum and
                                      comm.tax.rnn = btax.rnn and
                                      comm.tax.rnn_nk = btax.rnn_nk and
                                      comm.tax.duid = ?
                                      exclusive-lock no-error.
            find btax where rowid(btax) = rowid(comm.tax) no-lock no-error.
            assign cdate = btax.date
                   ctime = btax.created
                   cdnum = btax.dnum
                   ctxb  = btax.txb
                   cuid = btax.uid
                   crnn = btax.rnn
                   crnnnk = btax.rnn_nk
                   ccreated = btax.created
                   no-error.

            assign
                comm.tax.duid = userid('bank')
                comm.tax.deltime = time.

            do i = 2 to 5:
               find next comm.tax where comm.tax.txb = ctxb and
                                        comm.tax.date = cdate and
                                        comm.tax.uid = cuid and
                                        comm.tax.created = ctime and
                                        comm.tax.dnum = cdnum and
                                        comm.tax.rnn = crnn and
                                        comm.tax.rnn_nk = crnnnk and
                                        comm.tax.duid = ? and
                                        comm.tax.created = ccreated
                                        exclusive-lock no-error.
               if avail comm.tax then
               assign
                     comm.tax.duid = userid('bank')
                     comm.tax.deltime = time.
            end.

            release tax.

            open query q1 for each comm.tax where comm.tax.date = dat and
                        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ?
                        and comm.tax.txb = ourcode no-lock use-index datenum.
          end.
        end case.
    end.
    b1:refresh().
/*
end.
*/
end.

ON CHOOSE OF bprn IN FRAME f1
    do:
/*        if comm.tax.comsum > 0 then  */
            run taxprn (string(rowid(comm.tax))).
    end.

ON CHOOSE OF bkvt IN FRAME f1
    do:
        run taxkvit (string(rowid(comm.tax))).
    end.

ON CHOOSE OF tnsbtn IN FRAME f1
    do:
        run taxprtns (string(rowid(comm.tax))).
    end.


def var luid as char.
def var ldnum as int.
def var ltime as int.
def var lcount as int.
def var lrnn as char.


ON CHOOSE OF bdnum IN FRAME f1
do:
   if not avail tax then return.
   if tax.taxdoc <> ? then do:
      message "Не могу редактировать номер документа!~nСначала отмените зачисление на транзитный счет"
      view-as alert-box title "".
      return.
   end.
   newdnum = tax.dnum.
   update newdnum format "zzzzzz9" label "Новый номер платежного поручения"
          with side-labels centered row 5 overlay frame dnum_fr.
   hide frame dnum_fr.
   if can-find (first btax where btax.txb = tax.txb and btax.date = tax.date and btax.dnum = newdnum no-lock) then do:
      message "Не могу присвоить номер платежа!~nТакой номер уже есть в системе"
      view-as alert-box title "".
      return.
   end.
   rid = rowid(comm.tax).

   find btax where rowid(btax) = rid no-lock no-error.
   find first comm.tax where comm.tax.txb = btax.txb and
                             comm.tax.date = btax.date and
                             comm.tax.uid = btax.uid and
                             comm.tax.created = btax.created and
                             comm.tax.dnum = btax.dnum and
                             comm.tax.rnn = btax.rnn and
                             comm.tax.rnn_nk = btax.rnn_nk and
                             comm.tax.created = btax.created and
                             comm.tax.duid = ?
                             exclusive-lock no-error.
   find btax where rowid(btax) = rowid(comm.tax) no-lock no-error.
   assign cdate = btax.date
          ctime = btax.created
          cdnum = btax.dnum
          ctxb  = btax.txb
          cuid = btax.uid
          crnn = btax.rnn
          crnnnk = btax.rnn_nk
          ccreated = btax.created
          no-error.

   assign comm.tax.dnum = newdnum.

   do i = 2 to 5:
      find next comm.tax where comm.tax.txb = ctxb and
                               comm.tax.date = cdate and
                               comm.tax.uid = cuid and
                               comm.tax.created = ctime and
                               comm.tax.dnum = cdnum and
                               comm.tax.rnn = crnn and
                               comm.tax.rnn_nk = crnnnk and
                               comm.tax.duid = ? and
                               comm.tax.created = ccreated
                               exclusive-lock no-error.
      if avail comm.tax then
      assign comm.tax.dnum = newdnum.
   end.
   release comm.tax.

   open query q1 for each comm.tax where comm.tax.date = dat and
               (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ?
               and comm.tax.txb = ourcode no-lock use-index datenum.
   b1:refresh().
end.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(comm.tax).
    lcount = 0.
    ldnum = -1.
    ltime = 0.
    luid = "".
    lrnn = "".
    FOR each comm.tax where comm.tax.date = dat and comm.tax.txb = ourcode and
        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ? no-lock
        by comm.tax.uid by comm.tax.dnum by comm.tax.created by comm.tax.rnn:
        ACCUMULATE comm.tax.sum (TOTAL COUNT).
        ACCUMULATE comm.tax.comsum + sum (TOTAL COUNT).
        ACCUMULATE comm.tax.comsum (TOTAL).
        if comm.tax.uid <> luid or comm.tax.dnum <> ldnum or comm.tax.created <> ltime and comm.tax.rnn <> lrnn
        then assign luid = comm.tax.uid
                    ldnum = comm.tax.dnum
                    ltime = comm.tax.created
                    lrnn = comm.tax.rnn
                    lcount = lcount + 1.
    END.
/*    FOR each comm.tax where comm.tax.date = dat and comm.tax.txb = ourcode and
        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ? no-lock:
        ACCUMULATE comm.tax.comsum (TOTAL).
    END.
    FOR each comm.tax where comm.tax.date = dat and comm.tax.txb = ourcode and
        (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ? no-lock:
        ACCUMULATE comm.tax.comsum + sum (TOTAL COUNT).
    END. */
    totalt=(accum total comm.tax.sum).
    MESSAGE "Количество квитанций: " /* (accum count comm.tax.sum) */ lcount skip
            "Hа сумму: " totalt skip
            "Комиссия: " (accum total comm.tax.comsum) skip
            "Всего:    " (accum total comm.tax.comsum + sum) skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Налоговые платежи" .
    find comm.tax where rowid(comm.tax) = rid no-lock.
    
end.

open query q1 for each comm.tax where comm.tax.date = dat and
    (alldoc or comm.tax.uid = userid("bank")) and comm.tax.duid = ? and comm.tax.txb = ourcode
    no-lock by comm.tax.dnum.

ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
