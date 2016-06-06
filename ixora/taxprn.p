/* taxprn.p
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
        24/04/06 u00568 Evgeniy - в getfromrnn.i функция getfioadr() - возвращает адрес и фио из таблицы рнн
        18/11/2011 evseev  - переход на ИИН/БИН
*/

{getfromrnn.i}
{chbin.i}
def input parameter rid as char.

def var i as integer.
def var taxfio as char init " ".
def var taxaddr as char init " ".

def var psum as deci initial 0.
def var csum as decimal initial 0.

def var tpsum as decimal initial 0.
def var tcsum as decimal initial 0.
def var totpsum as decimal init 0.
def var totcsum as decimal init 0.

def buffer btax for comm.tax.

OUTPUT TO tax.prn.

find first btax where rowid(btax) = to-rowid(substring(rid,1,10)) no-lock no-error.
if not avail btax then do:
   output close.
   return.
end.

find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
           comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.
if avail comm.tax then find btax where rowid(btax) = rowid(comm.tax) no-lock no-error.

rid = substring(rid, 11).

psum = comm.tax.sum.
csum = if comm.tax.comsum > 0 then comm.tax.comsum
                              else 0.
tpsum = psum.
tcsum = csum.

totpsum = tpsum.
totcsum = tcsum.

do i = 2 to 5:
find next comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
          comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and
          comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.
if avail comm.tax then do:
   psum = comm.tax.sum.
   csum = if comm.tax.comsum > 0 then comm.tax.comsum
                                 else 0.
   tpsum = tpsum + psum.
   tcsum = tcsum + csum.

   totpsum = totpsum + psum.
   totcsum = totcsum + csum.
end.
end.

find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
           comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.

find first comm.rnn where comm.rnn.trn = comm.tax.rnn no-lock no-error.
if avail comm.rnn then
do:
   release rnnu.
   taxfio = getfio(). /*getfromrnn.i*/

   taxaddr = str1 (rnn.post1) + ", " +
             str1 (rnn.dist1) + ", " +
             str1 (rnn.raj1) + ", " +
             getadr().  /*getfromrnn.i*/

end.

put unformatted
    "                     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1)
    space(62) comm.tax.date format "99/99/9999" skip
    fill("=", 72) format "x(72)" skip
    "ВАЛЮТА - ТЕНГЕ                       ПРИХОД                  РАСХОД" skip
    fill("-", 72) format "x(72)" skip
    "   Сумма платежа           "
    tpsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip
    "   Комиссия банка          "
    tcsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip(1).

    do while rid ne "":

        find first btax where rowid(btax) = to-rowid(substring(rid,1,10)) no-lock no-error.
        find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
                   comm.tax.uid = btax.uid and comm.tax.created = btax.created and
                   comm.tax.dnum = btax.dnum and comm.tax.rnn = btax.rnn no-lock no-error.
        find first btax where rowid(btax) = rowid(comm.tax) no-lock no-error.

        rid = substring(rid, 11).

        psum = comm.tax.sum.
        csum = if comm.tax.comsum > 0 then comm.tax.comsum else 0.
        tpsum = psum.
        tcsum = csum.
        totpsum = totpsum + psum.
        totcsum = totcsum + csum.

        do i = 2 to 5:
        find next comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
             comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and
             comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.
        if avail comm.tax then do:
           psum = comm.tax.sum.
           csum = if comm.tax.comsum > 0 then comm.tax.comsum else 0.
           tpsum = tpsum + psum.
           tcsum = tcsum + csum.
           totpsum = totpsum + psum.
           totcsum = totcsum + csum.
        end.
        end.

        put unformatted "   Сумма платежа           " tpsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip.
        put unformatted "   Комиссия банка          " tcsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip(1).

    end.

find first comm.tax where comm.tax.txb = btax.txb and comm.tax.date = btax.date and
           comm.tax.uid = btax.uid and comm.tax.rnn = btax.rnn and
           comm.tax.created = btax.created and comm.tax.dnum = btax.dnum no-lock no-error.

if v-bin then
put unformatted
    "              ИТОГО ПРИХОД " totpsum + totcsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Принятые платежи." skip
    "Внес: " taxfio skip
    "Адрес: " taxaddr skip
    "ИИН: " comm.tax.rnn format "x(12)" skip
    "Подпись: " skip
    fill("=", 72) format "x(72)" skip(2).
else
put unformatted
    "              ИТОГО ПРИХОД " totpsum + totcsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Принятые платежи." skip
    "Внес: " taxfio skip
    "Адрес: " taxaddr skip
    "РНН: " comm.tax.rnn format "x(12)" skip
    "Подпись: " skip
    fill("=", 72) format "x(72)" skip(2).
put unformatted chr(27) chr(64). /*чтобы после окончания печати по кнопке SET на принтере FX-890 адекватно выезжадл и заезжал отступ для отрыва*/
output close.

MESSAGE "Всего платежей на сумму: " + string(totpsum) +
        " Комиссия: " + string(totcsum) +
        " Итого: " + string(totpsum + totcsum)
VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
TITLE "Сумма".


unix silent prit tax.prn.
/*
run menu-prt.p("tax.prn").
*/

