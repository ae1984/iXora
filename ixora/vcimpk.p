/* vcimpk.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по задолжникам до 10тыс. на дату - отсутствуют ГТД (экспорт/импорт)
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
        04.11.2004 saltanat
 * CHANGES
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
         06,04,2011 дамир - просто исправил ошибки.ненужная программа
*/

{vc.i}

{global.i}
{comm-txb.i}

def var v-reptype as char init 'i'.
def new shared var s-vcourbank as char.
def new shared temp-table t-dolgs
    field cif like cif.cif
    field namefil as char
    field depart as integer
    field cifname as char
    field contract like vccontrs.contract
    field ctdate as date
    field ctnum as char
    field ctei as char
    field ncrc like ncrc.crc
    field sumcon as decimal init 0
    field sumusd as decimal init 0
    field sumdolg as decimal init 0
    field lcnum as char
    field days as integer
    field cifrnn as char
    field cifokpo as char
    field ctterm  as char
    field cardnum as char
    field carddt as char
    field srokrep as decimal
    index main is primary cifname cif ctdate ctnum contract.

def var v-days as integer.
def var v-title as char.
def var v-filename as char init "vcdolggtd.htm".
def var v-cursusd as deci.

if v-reptype = "e" then v-title = "ЭКСПОРТ".
else v-title = "ИМПОРТ".

{vcrepdt.i " ЗАДОЛЖНИКИ ПО ПРЕДОСТАВЛЕНИЮ ГТД (" + v-title + ") "}

s-vcourbank = comm-txb().

/* расчеты во временную таблицу */
/* коннект к текущему банку */
find txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password).

run vcrepdpldat (s-vcourbank, 0, v-dtb, v-dte, v-closed, '2').

if connected ("txb") then disconnect "txb".

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte.
else v-days = 120.

/* выдача отчета в HTML */
def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i
 &stream = " stream vcrpt "
 &title = "Задолжники по поставке товара"
 &size-add = "x-"
}

v-title = "ПОСТАВКЕ ТОВАРА<BR>КОНТРАКТЫ ПО ".
if v-reptype = "e" then
  v-title = v-title + "ЭКСПОРТУ<BR><BR>сумма проплат превышает сумму ГТД<BR>".
else
  v-title = v-title + "ИМПОРТУ<BR><BR>сумма проплат превышает сумму ГТД<BR>Приложение 14, строки 3, 14 по импорту<BR>".

{vcrepdout.i
 &title = ""
 &rslccell = "&nbsp;"
 &days120 = " false "
 &sumdolg = " v-reptype = 'i' "
 &cln = " true "
 &ei = " v-reptype = 'i' "
}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.


