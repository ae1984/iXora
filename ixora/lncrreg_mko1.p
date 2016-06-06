/* lncrreg_mko1.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Экспорт данных в Модернизированный Кредитный Регистр
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
        22/07/2013 Sayat(id01143) - ТЗ 1254 от 09/01/2012 "Касательно модернизации АИП «Кредитный Регистр»" (на основе lncrreg_mko)
 * BASES
        BANK COMM
 * CHANGES

*/

{mainhead.i}
{credreg1.i "new" }
def var dat as date.
def var dt1 as date.
def var dt2 as date.
def new shared var mesa as char.
def new shared var k as int.
k = 0.
mesa = ''.

def new shared var v-bik as char.
find first txb where txb.bank = "txb00" and txb.consolid no-lock no-error.
if avail txb then v-bik = txb.mfo.

dat = date(month(g-today),1,year(g-today)).
dt2 = dat - 1.
dt1 = date(month(dt2),1,year(dt2)).

update skip(1)
       dat label ' Дата отчета ' format '99/99/9999' validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip(1)
       dt1 label ' Период с    ' format '99/99/9999' validate (dt1 < g-today, " Дата должна быть раньше текущей! ")
       dt2 label ' по ' format '99/99/9999' validate (dt2 < g-today, " Дата должна быть раньше текущей! ") " " skip(1)
       with side-label row 5 centered frame dates title 'Модернизированный кредитный регистр'.

def new shared var rates as deci extent 20.
def new shared var crates as char extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt <= dt2 no-lock no-error.
  if avail crchis then assign rates[crc.crc] = crchis.rate[1] crates[crc.crc] = crchis.code.
  else assign rates[crc.crc] = crc.rate[1] crates[crc.crc] = crc.code.
end.

empty temp-table cr_wrk no-error.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    if lookup(comm.txb.bank,"txb16,txb01,txb02,txb04,txb06") > 0 then do:
        connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run lncrreg2_mko1 (dat,dt1,dt2).
    end.
end.
if connected ("txb") then disconnect "txb".

hide message no-pause.
message mesa view-as alert-box buttons ok.

run cr_send_xml.p (dat,dt1,dt2,'MKO').