/* convcrc.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25/02/04 nataly добавлены кросс-конвертации типа USD-KZT, KZT-USD, EUR-KZT, KZT-EUR
        29/07/2004 dpuchkov поменял местами надписи на кнопках USD->EUR и EUR->USD т.к они работают неверно.
        18/08/2004 dpuchkov изменил надпись при отображении курса.
        13/03/08   marinav - изменены надписи фрейма convcrc
        26/10/2010 k.gitalov добавил USD->RUB RUB->USD EUR->RUB RUB->EUR
        11.11.2010 k.gitalov добавил GBP USD->GBP GBP->USD EUR->GBP GBP->EUR RUB->GBP GBP->RUB
        15.05.2012 k.gitalov добавил валюту ZAR по сз от 14.05.2012
        09.07.2012 damir - добавил валюту CAD по сз от 14.05.2012.
*/

/*
 7 Шведская крона            40.0000          1      2  SEK  23/08/2011 H
 8 Австралийский доллар     120.0000          1      2  AUD  23/08/2011 H
 9 Швейцарский франк         80.0000          1      2  CHF  23/08/2011 H
*/

{global.i}


def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define button b1   label '  USD   '.
define button b2   label '  EUR   '.
define button b3   label '  RUR   '.
define button b_6  label '  GBP   '.
define button b_7  label '  SEK   '.
define button b_8  label '  AUD   '.
define button b_9  label '  CHF   '.
define button b_10 label '  ZAR   '.
define button b_11 label '  CAD   '.

define button b5  label 'EUR->USD' /*   'USD->EUR'*/.
define button b6  label 'USD->KZT'.
define button b7  label 'KZT->USD'.
define button b8  label 'EUR->KZT'.
define button b9  label 'KZT->EUR'.
define button b10 label 'USD->EUR'  /* 'EUR->USD'*/ .
define button b11 label 'USD->RUB'.
define button b12 label 'RUB->USD'.
define button b13 label 'EUR->RUB'.
define button b14 label 'RUB->EUR'.
define button b15 label 'USD->GBP'.
define button b16 label 'GBP->USD'.
define button b17 label 'EUR->GBP'.
define button b18 label 'GBP->EUR'.
define button b19 label 'RUB->GBP'.
define button b20 label 'GBP->RUB'.

define button b_21  label 'USD->SEK'.
define button b_22  label 'SEK->USD'.
define button b_23  label 'USD->AUD'.
define button b_24  label 'AUD->USD'.
define button b_25  label 'USD->CHF'.
define button b_26  label 'CHF->USD'.
define button b_x10 label 'ZAR->USD'.
define button b_x11 label 'USD->ZAR'.
define button b_x12 label 'CAD->USD'.
define button b_x13 label 'USD->CAD'.

/*
CrossCreate(v-cre,'usd','sek').
CrossCreate(v-cre,'sek','usd').
CrossCreate(v-cre,'usd','aud').
CrossCreate(v-cre,'aud','usd').
CrossCreate(v-cre,'usd','chf').
CrossCreate(v-cre,'chf','usd').
*/

define button b4 label 'Выход'.

define variable d1 like crc.rate[1] label ''.
define variable d2 like crc.rate[1] label ''.
define variable d3 like crc.rate[1] label ''.
define variable d4 like crc.rate[1] label ''.


define variable d5  like crc.rate[1] label ''. /*EUR-USD*/
define variable d10 like crc.rate[1] label ''. /*USD-EUR*/
define variable d6  like crc.rate[1] label ''. /*USD-KZT*/
define variable d7  like crc.rate[1] label ''. /*KZT-USD*/
define variable d8  like crc.rate[1] label ''. /*EUR-KZT*/
define variable d9  like crc.rate[1] label ''. /*KZT-EUR*/

define variable d11 like crc.rate[1] label ''. /*USD->RUB*/
define variable d12 like crc.rate[1] label ''. /*RUB->USD*/
define variable d13 like crc.rate[1] label ''. /*EUR->RUB*/
define variable d14 like crc.rate[1] label ''. /*RUB->EUR*/

define variable d15 like crc.rate[1] label ''. /*USD->GBP*/
define variable d16 like crc.rate[1] label ''. /*GBP->USD*/
define variable d17 like crc.rate[1] label ''. /*EUR->GBP*/
define variable d18 like crc.rate[1] label ''. /*GBP->EUR*/
define variable d19 like crc.rate[1] label ''. /*RUB->GBP*/
define variable d20 like crc.rate[1] label ''. /*GBP->RUB*/

define variable d_21  like crc.rate[1] label ''. /*USD->SEK*/
define variable d_22  like crc.rate[1] label ''. /*SEK->USD*/
define variable d_23  like crc.rate[1] label ''. /*USD->AUD*/
define variable d_24  like crc.rate[1] label ''. /*AUD->USD*/
define variable d_25  like crc.rate[1] label ''. /*USD->CHF*/
define variable d_26  like crc.rate[1] label ''. /*CHF->USD*/
define variable d_x10 like crc.rate[1] label ''. /*ZAR->USD*/
define variable d_x11 like crc.rate[1] label ''. /*USD->ZAR*/
define variable d_x12 like crc.rate[1] label ''. /*CAD->USD*/
define variable d_x13 like crc.rate[1] label ''. /*USD->CAD*/


define frame becrc
    skip(1)
    space(3) b1 skip
    space(3) b2 skip
    space(3) b3 skip
    space(3) b_6 skip
    space(3) b_7 skip
    space(3) b_8 skip
    space(3) b_9 skip
    space(3) b_10 skip
    space(3) b_11 skip
    space(3) b5 skip
    space(3) b10 skip
    space(3) b6  skip
    space(3) b7 skip
    space(3) b8 skip
    space(3) b9 skip
    space(3) b11 skip
    space(3) b12 skip
    space(3) b13 skip
    space(3) b14 skip
    space(3) b15 skip
    space(3) b16 skip
    space(3) b17 skip
    space(3) b18 skip
    space(3) b19 skip
    space(3) b20 skip
    space(3) b_21 skip
    space(3) b_22 skip
    space(3) b_23 skip
    space(3) b_24 skip
    space(3) b_25 skip
    space(3) b_26 skip
    space(3) b_x10 skip
    space(3) b_x11 skip
    space(3) b_x12 skip
    space(3) b_x13 skip
    space(4) b4
with centered row 2 title "Выберите валюту " .

define frame convcrc
 '                 Покупка  ' '     Продажа' skip
 'День в день  '   d3        d1 skip
 'На след.день '   d4        d2  with  side-label row 20 centered.

/*
function CheckVal returns log (input val as char , input des as char):
  find sysc where sysc.sysc = val no-lock no-error.
  if not avail sysc then
  do:
     create sysc.
     sysc.sysc = val.
     sysc.des = des.
     release sysc.
     return true.
  end.
  else return false.
end function.
*/

function SaveHistory returns log (input crc_str as char, input rate as deci).
   create comm.crchis2.
    comm.crchis2.crc_str = crc_str.
    comm.crchis2.rate = rate.
    comm.crchis2.who_cr = g-ofc.
    comm.crchis2.whn_cr = today.
    comm.crchis2.opday = g-today.
    comm.crchis2.time_cr = time.
    comm.crchis2.txb = s-ourbank.
    return true.
end function.


on choose of b1,b2,b3,b_6,b_7,b_8,b_9,b_10,b_11 do:
    d1 = 0. d2 = 0. d3 = 0. d4 = 0.
    do:
        find sysc where sysc.sysc = 'ec'  + self:label no-lock no-error.
        if avail sysc then d1 = sysc.deval.
        find sysc where sysc.sysc = 'oc'  + self:label no-lock no-error.
        if avail sysc then d2 = sysc.deval.
        find sysc where sysc.sysc = 'erc' + self:label no-lock no-error.
        if avail sysc then d3 = sysc.deval.
        find sysc where sysc.sysc = 'orc' + self:label no-lock no-error.
        if avail sysc then d4 = sysc.deval.
        display d1 d2 d3 d4 with frame convcrc.
    end.

    update d3 d1 d4 d2 with frame convcrc.

    find sysc where sysc.sysc = 'ec'  + self:label exclusive-lock no-error.
    sysc.deval = d1. SaveHistory(sysc.sysc,sysc.deval).
    find sysc where sysc.sysc = 'oc'  + self:label exclusive-lock no-error.
    sysc.deval = d2. SaveHistory(sysc.sysc,sysc.deval).
    find sysc where sysc.sysc = 'erc' + self:label exclusive-lock no-error.
    sysc.deval = d3. SaveHistory(sysc.sysc,sysc.deval).
    find sysc where sysc.sysc = 'orc' + self:label exclusive-lock no-error.
    sysc.deval = d4. SaveHistory(sysc.sysc,sysc.deval).
    hide frame convcrc.
    release sysc.
end.

on choose of b10
do:
   find sysc where sysc.sysc = '2to3c' no-lock.
   d10 = decimal(sysc.chval).
   update d10 label 'Кросс-курс доллар-евро' format '9,999.9999' with side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to3c' exclusive-lock.
   sysc.chval = string(d10).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

on choose of b5
do:
   find sysc where sysc.sysc = '3to2c' no-lock.
   d5 = decimal(sysc.chval).
   update d5 label 'Кросс-курс евро-доллар' format '9,999.9999' with side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '3to2c' exclusive-lock.
   sysc.chval = string(d5).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

on choose of b6
do:
   find sysc where sysc.sysc = '2to1c' no-lock.
   d6 = decimal(sysc.chval).
   update d6 label 'Кросс-курс доллар-тенге' format '9,999.9999' with side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to1c' exclusive-lock.
   sysc.chval = string(d6).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

on choose of b7
do:
   find sysc where sysc.sysc = '1to2c' no-lock.
   d7 = decimal(sysc.chval).
   update d7 label 'Кросс-курс тенге-доллар' format '9,999.9999' with side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '1to2c' exclusive-lock.
   sysc.chval = string(d7).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

on choose of b8
do:
   find sysc where sysc.sysc = '3to1c' no-lock.
   d8 = decimal(sysc.chval).
   update d8 label 'Кросс-курс евро-тенге' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '3to1c' exclusive-lock.
   sysc.chval = string(d8).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

on choose of b9
do:
   find sysc where sysc.sysc = '1to3c' no-lock.
   d9 = decimal(sysc.chval).
   update d9 label 'Кросс-курс тенге-евро' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '1to3c' exclusive-lock.
   sysc.chval = string(d9).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.

/*****************************************************************************************************/
on choose of b11  /*USD->RUB*/
do:
   find sysc where sysc.sysc = '2to4c' no-lock.
   d11 = decimal(sysc.chval).
   update d11 label 'Кросс-курс доллар-рубли' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to4c' exclusive-lock.
   sysc.chval = string(d11).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
on choose of b12  /*RUB->USD*/
do:
   find sysc where sysc.sysc = '4to2c' no-lock.
   d12 = decimal(sysc.chval).
   update d12 label 'Кросс-курс рубли-доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '4to2c' exclusive-lock.
   sysc.chval = string(d12).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
on choose of b13  /*EUR->RUB*/
do:
   find sysc where sysc.sysc = '3to4c' no-lock.
   d13 = decimal(sysc.chval).
   update d13 label 'Кросс-курс евро-рубль' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '3to4c' exclusive-lock.
   sysc.chval = string(d13).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
on choose of b14  /*RUB->EUR*/
do:
   find sysc where sysc.sysc = '4to3c' no-lock.
   d14 = decimal(sysc.chval).
   update d14 label 'Кросс-курс рубль-евро' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '4to3c' exclusive-lock.
   sysc.chval = string(d14).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/

/*****************************************************************************************************/
on choose of b20  /*GBP->RUB*/
do:
   find sysc where sysc.sysc = '6to4c' no-lock.
   d20 = decimal(sysc.chval).
   update d20 label 'Кросс-курс фунт стерлингов-рубль' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '6to4c' exclusive-lock.
   sysc.chval = string(d20).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b19  /*RUB->GBP*/
do:
   find sysc where sysc.sysc = '4to6c' no-lock.
   d19 = decimal(sysc.chval).
   update d19 label 'Кросс-курс рубль-фунт стерлингов' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '4to6c' exclusive-lock.
   sysc.chval = string(d19).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b18  /*GBP->EUR*/
do:
   find sysc where sysc.sysc = '6to3c' no-lock.
   d18 = decimal(sysc.chval).
   update d18 label 'Кросс-курс фунт стерлингов-евро' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '6to3c' exclusive-lock.
   sysc.chval = string(d18).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b17  /*EUR->GBP*/
do:
   find sysc where sysc.sysc = '3to6c' no-lock.
   d17 = decimal(sysc.chval).
   update d17 label 'Кросс-курс евро-фунт стерлингов' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '3to6c' exclusive-lock.
   sysc.chval = string(d17).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b16  /*GBP->USD*/
do:
   find sysc where sysc.sysc = '6to2c' no-lock.
   d16 = decimal(sysc.chval).
   update d16 label 'Кросс-курс фунт стерлингов-доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '6to2c' exclusive-lock.
   sysc.chval = string(d16).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b15  /*USD->GBP*/
do:
   find sysc where sysc.sysc = '2to6c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс доллар-фунт стерлингов' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to6c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_21  /*USD->SEK*/
do:
   find sysc where sysc.sysc = '2to7c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Доллар-Шведская крона' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to7c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_22  /*SEK->USD*/
do:
   find sysc where sysc.sysc = '7to2c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Шведская крона-Доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '7to2c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_23  /*USD->AUD*/
do:
   find sysc where sysc.sysc = '2to8c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Доллар-Австралийский доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to8c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_24  /*AUD->USD*/
do:
   find sysc where sysc.sysc = '8to2c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Австралийский доллар-Доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '8to2c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_25  /*USD->CHF*/
do:
   find sysc where sysc.sysc = '2to9c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Доллар-Швейцарский франк' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to9c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_26  /*CHF->USD*/
do:
   find sysc where sysc.sysc = '9to2c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Швейцарский франк-Доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '9to2c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_x10  /*ZAR->USD*/
do:
   find sysc where sysc.sysc = '10to2c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Южно-африканский ранд-Доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '10to2c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_x11  /*USD->ZAR*/
do:
   find sysc where sysc.sysc = '2to10c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Доллар-Южно-африканский ранд' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to10c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
/*****************************************************************************************************/
on choose of b_x12  /*CAD->USD*/
do:
   find sysc where sysc.sysc = '11to2c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Канадский доллар-Доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '11to2c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/
on choose of b_x13  /*USD->CAD*/
do:
   find sysc where sysc.sysc = '2to11c' no-lock.
   d15 = decimal(sysc.chval).
   update d15 label 'Кросс-курс Доллар-Канадский доллар' format '9,999.9999' with  side-label row 20 centered frame crossconv.
   find sysc where sysc.sysc = '2to11c' exclusive-lock.
   sysc.chval = string(d15).
   SaveHistory(sysc.sysc,decimal(sysc.chval)).
   hide frame crossconv.
   release sysc.
end.
/*****************************************************************************************************/

enable all with frame becrc.
wait-for WINDOW-CLOSE of current-window or choose of b4.
hide frame becrc.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if sysc.chval = "TXB00" then do:
    def var v-ans as logi.
    v-ans = false.
    message skip " Скопировать курсы на филиалы ?" skip(1) view-as alert-box buttons yes-no title "" update v-ans.
    if not v-ans then return.

    {r-branch.i &proc = "convcrc1 "}
end.



