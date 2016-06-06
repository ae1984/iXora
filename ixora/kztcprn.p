/* kztcprn.p
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
        04.08.04 saltanat - Добавлено вывод на печать KOd_, KBe_, KNp_.
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

OUTPUT TO commonpl.prn.

find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
rid = substring(rid, 11).
tpsum = commonpl.sum.
tsum = if commonpl.comsum > 0 then commonpl.comsum else 0.
ttsum = tsum.

put unformatted
    "                     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1)
    space(62) commonpl.date format "99/99/9999" skip
    fill("=", 72) format "x(72)" skip
    "ВАЛЮТА                               ПРИХОД                  РАСХОД" skip
    fill("-", 72) format "x(72)" skip
    "Тенге                      "
    tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip.
    do while rid ne "":
        find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10))
            no-lock no-error.
        rid = substring(rid, 11).
        tsum = if commonpl.comsum > 0 then commonpl.comsum else 0.
        put unformatted
        "                           "
        tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip.
        ttsum = ttsum + tsum.
        tpsum = tpsum + commonpl.sum.
    end.
if v-bin then
  put unformatted
    "              ИТОГО ПРИХОД "
     ttsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Услуги банка." skip
    "Внес: " skip
    "Адрес: " skip
    "ИИН: " skip
    "Подпись: " skip(1)
    "КОД = " KOd_
    "     КБе = " KBe_
    "     КНП = " KNp_ skip
    fill("=", 72) format "x(72)" skip(2).

else
  put unformatted
    "              ИТОГО ПРИХОД "
     ttsum format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Назначение: Услуги банка." skip
    "Внес: " skip
    "Адрес: " skip
    "РНН: " skip
    "Подпись: " skip(1)
    "КОД = " KOd_
    "     КБе = " KBe_
    "     КНП = " KNp_ skip
    fill("=", 72) format "x(72)" skip(2).

output close.

MESSAGE "Всего платежей на сумму: " + string(tpsum) +
    " Комиссия: " + string(ttsum) + " Итого: " + string(tpsum + ttsum)
VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
TITLE "Сумма".


unix silent prit commonpl.prn.
/*
run menu-prt("commonpl.prn").
*/