/* mob-prn.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Печать ордера KCell / KMobile
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
        09/10/03 sasco счетчик квитанций
        19/12/03 kanat Будут печататься 2 приходных ордера как один
        01.01.2004 nadejda - изменила ставку НДС - брать из sysc
        13.04.2004 kanat - добавил печать комиссии в ордере
        04.08.2004 saltanat  добавила печать КОДа, КБЕ, КНП.
        25.04.2007 id00004 - убрал префикс банка.
        18/11/2011 evseev  - переход на ИИН/БИН
*/

{comm-txb.i}
{chbin.i}
def var seltxb as int.
seltxb = comm-cod().

def input parameter rid as char.
def input parameter KOd_ as char.
def input parameter KBe_ as char.
def input parameter KNp_ as char.

def var strsum as char.
def var tsum as decimal.
def var ttsum as decimal.

def var i as integer.
def var v-rem as char.
def var ourbank as char.
def var v-nds as decimal.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds = sysc.deval.

ourbank = comm-txb().

define variable ckv as int.

OUTPUT TO commonpl.prn.

find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.

/* sasco : счетчик квитанций */
if commonpl.uid = userid ("bank") then do:
  find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-error.
  if available commonpl then do:
     ckv = ?.
     ckv = integer (commonpl.chval[5]) no-error.
     if ckv = ? then ckv = 0.
     ckv = ckv + 1.
     commonpl.chval[5] = string (ckv, "zzz9").
  end.
end.

find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
rid = substring(rid, 11).
tsum = commonpl.sum.
ttsum = commonpl.comsum.

v-rem = 'Оплата за телефон 8-' + substr(commonpl.service,1,3) + '-' +
        string(commonpl.counter,"9999999") + ' от ' +  trim( commonpl.fio ) +
        '. Cумма ' + trim( string( tsum, '>>>,>>>,>>9.99' )) +
        ', в т.ч. НДС ' + trim( string( truncate( tsum / (1 + v-nds) * v-nds, 2 ), '>>>,>>>,>>9.99' )) + '.'.

/* kanat - 2 приходных ордера */

put unformatted
    "                     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1)
    commonpl.date format "99.99.9999" skip
    fill("=", 72) format "x(72)" skip
    "ВАЛЮТА                               ПРИХОД                  РАСХОД" skip
    fill("-", 72) format "x(72)" skip
    "   Сумма платежа           "
    tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip
    "   Комиссия банка          "
    ttsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip(1).
    do while rid ne "":
        find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
        rid = substring(rid, 11).
        tsum = if commonpl.comsum > 0 then commonpl.comsum else 0.
        put unformatted
        "                           "
        tsum format ">,>>>,>>>,>>9.99" space(20) "0.00" skip.
    end.

if v-bin then
put unformatted
    "              ИТОГО ПРИХОД "
    (tsum + ttsum) format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Внес: " commonpl.fio  skip
    "Адрес: " skip
    "ИИН: " commonpl.rnn skip
    "Подпись: " skip(1)
    "КОД: " KOd_
    "     КБе: " KBe_
    "     КНП: " KNp_ skip
    fill("=", 72) format "x(72)" skip
    substring(v-rem, 1,   72) skip
    substring(v-rem, 73,  77) skip
    substring(v-rem, 151, 77) skip(4).
else
put unformatted
    "              ИТОГО ПРИХОД "
    (tsum + ttsum) format ">,>>>,>>>,>>9.99" skip(2)
    "Менеджер:                 Контролер:         Кассир:" skip(2)
    "Внес: " commonpl.fio  skip
    "Адрес: " skip
    "РНН: " commonpl.rnn skip
    "Подпись: " skip(1)
    "КОД: " KOd_
    "     КБе: " KBe_
    "     КНП: " KNp_ skip
    fill("=", 72) format "x(72)" skip
    substring(v-rem, 1,   72) skip
    substring(v-rem, 73,  77) skip
    substring(v-rem, 151, 77) skip(4).

output close.

unix silent prit commonpl.prn.

