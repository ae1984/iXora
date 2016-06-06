/* pensprn.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Формирование приходного кассового ордера
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        13/01/05 kanat
 * CHANGES
        29/03/2005 kanat - поменял скрипт кодировки
        27/09/2006 u00121 - печатался файл pmprd1.txt, а формировался pmprd.txt, теперь печатается pmprd.txt
        18/11/2011 evseev  - переход на ИИН/БИН
*/
{chbin.i}
def input parameter rid as char.
def input parameter KOd_ as char.
def input parameter KBe_ as char.
def input parameter KNp_ as char.

def var strsum as char.
def var tsum as decimal.
def var ttsum as decimal.
def var i as integer.
def var tpsum as deci initial 0.
def var stadfio as char init " ".
def var stadaddr as char init " ".
def var stadrnn as char init " ".


OUTPUT TO value("pmprd.txt").

find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10))
    no-lock no-error.
rid = substring(rid, 11).
tpsum = commonpl.sum.
tsum = if commonpl.comsum > 0 then commonpl.comsum else 0.
ttsum = tsum.

stadfio = trim (commonpl.fio).
stadaddr = trim (commonpl.adr).
stadrnn = trim (commonpl.rnn).

put unformatted
    "                     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1)
    space(62) commonpl.date format "99/99/9999" skip
    fill("=", 72) format "x(72)" skip
    "ВАЛЮТА - ТЕНГЕ                       ПРИХОД                  РАСХОД" skip
    fill("-", 72) format "x(72)" skip
    "   Сумма платежа           "
    tpsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip
    "   Комиссия банка          "
    tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip(1).
    do while rid ne "":
        find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10))
            no-lock no-error.
        rid = substring(rid, 11).
        tsum = if commonpl.comsum > 0 then commonpl.comsum else 0.
        put unformatted
        "   Сумма платежа           "
        commonpl.sum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip.
        put unformatted
        "   Комиссия банка          "
        tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip(1).
        ttsum = ttsum + tsum.
        tpsum = tpsum + commonpl.sum.
    end.
if v-bin then
put unformatted
    "              ИТОГО ПРИХОД "
     ttsum + tpsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Принятые платежи." skip
    "Внес: " stadfio skip
    "Адрес: " stadaddr skip
    "ИИН: " stadrnn skip
    "Подпись: " skip
    "КОД: " KOd_
    "     КБе: " KBe_
    "     КНП: " KNp_ skip
    fill("=", 72) format "x(72)" skip(10).
else
put unformatted
    "              ИТОГО ПРИХОД "
     ttsum + tpsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Принятые платежи." skip
    "Внес: " stadfio skip
    "Адрес: " stadaddr skip
    "РНН: " stadrnn skip
    "Подпись: " skip
    "КОД: " KOd_
    "     КБе: " KBe_
    "     КНП: " KNp_ skip
    fill("=", 72) format "x(72)" skip(10).

output close.


MESSAGE "Всего платежей на сумму: " + string(tpsum) +
    " Комиссия: " + string(ttsum) + " Итого: " + string(tpsum + ttsum)
VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
TITLE "".

/*unix silent un-dos pmprd.txt pmprd1.dos. 27/09/2006 u00121*/
unix silent prit pmprd.txt.





