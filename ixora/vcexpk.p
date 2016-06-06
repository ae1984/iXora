/* vcexpk.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по задолжникам до 10тыс. на дату - консигнация (экспорт)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15-3-6-6
 * AUTHOR
        04.11.2004 saltanat
 * CHANGES
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
         06,04,2011 дамир - просто исправил ошибки.ненужная программа
*/
{vc.i}

{global.i}
{comm-txb.i}

def var s-vcourbank as char.
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
def var v-filename as char init "vcdolgkons.htm".
def var v-title as char.

{vcrepdt.i " ЗАДОЛЖНИКИ ПО КОНСИГНАЦИИ "}

s-vcourbank = comm-txb().

/* расчеты во временную таблицу */
/* коннект к текущему банку */
find last txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password).

run vcrepdexdat (s-vcourbank, 0, v-dtb, v-dte, v-closed, '2').

if connected ("txb") then disconnect "txb".

/* выдача отчета в HTML */
def stream vcrpt.
output stream vcrpt to value(v-filename).

{html-title.i
 &stream = " stream vcrpt "
 &title = "Задолжники по консигнации"
 &size-add = "x-"
}

v-title = "КОНСИГНАЦИИ<BR><BR>сумма ГТД превышает сумму проплат<BR>Приложение 14, строки 3, 14 по экспорту<BR>".

find vcparams where vcparams.parcode = "dayerror" no-lock no-error.
if avail vcparams then v-days = vcparams.valinte.
else v-days = 120.

{vcrepdout.i
 &rslccell = "Последняя лицензия"
 &days120 = " false "
 &sumdolg = " false "
 &cln = " true "
 &ei = " true "
}

output stream vcrpt close.

unix silent value("cptwin " + v-filename + " iexplore").

pause 0.


