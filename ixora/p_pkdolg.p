/* p_pkdolg.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Задолжники по потребкредитам (кроме БД)
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
        15/03/2005 madiyar
 * CHANGES
        19/03/2005 madiyar - исправил ошибку - не попадали кредиты без просрочек по ОД и %, но со штрафами
        23/03/2005 madiyar - переставил колонки; округление платежа и штрафов вверх до целых
        08/06/2005 madiyar - полностью переделал отчет - скопировал из отчета по задолжникам 4-4-3-9
        09/08/2005 madiyar - добавил колонки "Выд. сумма" и "Остаток ОД"
        02.09.2005 marinav - PUSH отчет
        01/11/2005 madiyar - добавил внебаланс
        02/11/2005 madiyar - внебалансовые кредиты отсеивались, исправил
        13/02/2006 madiyar - дни просрочки - из londebt; перенес заполнение londebt (run lndebtr) из p_pkcash.p сюда
        16/05/2006 madiyar - немножко оптимизировал
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/


{mainhead.i}
{push.i}

def var coun as int no-undo init 1.
define variable datums as date format '99/99/9999' label 'На'.

datums = vdt. /* PUSH - параметр */
/*datums = g-today.*/

def temp-table wrk no-undo
    field lon      like bank.lon.lon
    field cif      like bank.lon.cif
    field name     like bank.cif.name
    field segm     as   char
    field rdt      like bank.lon.rdt
    field duedt    like bank.lon.rdt
    field opnamt   like bank.lon.opnamt
    field balans   like bank.lon.opnamt
    field crc      like bank.lon.crc
    field prem     like bank.lon.prem
    field bal1     like bank.lon.opnamt
    field dt1      as   inte
    field bal2     like bank.lon.opnamt
    field dt2      as   inte
    field bal3     like bank.lon.opnamt
    field bal16    as   deci
    field bal13    as   deci
    field bal14    as   deci
    field bal30    as   deci
    field iod      as   deci
    field iprc     as   deci
    field is-kik   as   logi
    field is-today as   logi
    field day      as   integer
    index ind1 is-kik crc bal3
    index ind2 is-today crc bal3.

def var v-am0 as decimal no-undo init 0.
def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.
def var v-am16 as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.

def var v-bal as deci no-undo extent 3.
def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
def var bilance as decimal no-undo format '->,>>>,>>>,>>9.99'.
define variable bilancepl as decimal no-undo format '->,>>>,>>9.99'.
def var tempdt as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var prosr_od as deci no-undo.
def var is-pogtoday as logi no-undo.
def var dat_wrk as date no-undo.
find last cls where cls.whn < datums and cls.del no-lock no-error.
dat_wrk = cls.whn.

/* Группы кредитов для исключения (юр.лица и БД) */
def var lst_non as char no-undo init ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_non <> '' then lst_non = lst_non + ','.
    lst_non = lst_non + string(longrp.longrp).
  end.
end.
lst_non = lst_non + ",90,92".

run lndebtr.

for each lon where lon.grp <> 90 and lon.grp <> 92 no-lock:

     if lon.opnamt = 0 then next.

     if lookup(trim(string(lon.grp)),lst_non) > 0 then next.

     run lonbalcrc('lon',lon.lon,datums,"16",yes,1,output v-am16).
     run lonbalcrc('lon',lon.lon,datums,"13",yes,lon.crc,output v-bal[1]).
     run lonbalcrc('lon',lon.lon,datums,"14",yes,lon.crc,output v-bal[2]).
     run lonbalcrc('lon',lon.lon,datums,"30",yes,1,output v-bal[3]).

     dlong = lon.duedt.
     if lon.ddt[5] <> ? then dlong = lon.ddt[5].
     if lon.cdt[5] <> ? then dlong = lon.cdt[5].

     if dlong > lon.duedt and dlong > datums and v-am16 <= 0 and v-bal[1] <= 0 and v-bal[2] <= 0 and v-bal[3] <= 0 then next. /* если есть пролонгация, дата пролонгации еще впереди и нет штрафов - пропускаем */
     is-pogtoday = no.

     v-am0 = 0. v-am1 = 0. v-am2 = 0. v-am3 = 0. prosr_od = 0.
     /* просрочка % */
     find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0
         and lnsci.fpn = 0 and lnsci.f0 > 0 and lnsci.idat > dat_wrk and lnsci.idat <= datums no-lock no-error.

     if avail lnsci then do:
       is-pogtoday = yes.
       find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 9 no-lock no-error.
       if avail trxbal then v-am1 = trxbal.dam - trxbal.cam.
       find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 10 no-lock no-error.
       if avail trxbal then v-am1 = v-am1 + trxbal.dam - trxbal.cam.
       v-am0 = v-am1.
       find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 2 no-lock no-error.
       if avail trxbal then v-am0 = v-am0 + trxbal.dam - trxbal.cam.
       if (lnsci.idat <> datums) and (lon.plan <> 3 and lon.plan <> 4) then do:
         run atl-dat (lon.lon,lnsci.idat,output bilance).
         run day-360(lnsci.idat,datums - 1,lon.basedy,output dn1,output dn2).
         v-am0 = v-am0 - dn1 * bilance * lon.prem / lon.basedy / 100.
         if v-am0 < 0 then v-am0 = 0.
       end.
     end.
     else do:
       find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 9 no-lock no-error.
       if avail trxbal then v-am1 = trxbal.dam - trxbal.cam.
       find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 10 no-lock no-error.
       if avail trxbal then v-am1 = v-am1 + trxbal.dam - trxbal.cam.
       v-am0 = v-am1.
     end.

     /* просрочка ОД */

     run atl-dat (lon.lon,datums,output bilance). /* фактич остаток ОД */

     bilancepl = 0.   /* За тек день по графику погашения (ВКЛЮЧАЯ сегодня!) */
     for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0
         and lnsch.fpn = 0 and lnsch.f0 > 0 and lnsch.stdat <= datums no-lock:
        bilancepl = bilancepl + lnsch.stval.
     end.

     v-am2 = lon.opnamt - bilancepl. /* остаток долга по графику */
     if v-am2 < 0 then v-am2 = 0.
     v-am3 = bilance - v-am2. /* просрочка ОД */
     if v-am3 < 0 then v-am3 = 0.

     /* чистая просрочка (уровень 7) - для расчета дней просрочки */
     find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.lev = 7 no-lock no-error.
     if avail trxbal then prosr_od = trxbal.dam - trxbal.cam.

     find first lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0
                                and lnsch.stdat > dat_wrk and lnsch.stdat <= datums no-lock no-error.
     if not avail lnsch then v-am3 = prosr_od.
     else is-pogtoday = yes.

     if not (v-am0 > 0 or v-am3 > 0 or v-am16 > 0 or v-bal[1] > 0 or v-bal[2] > 0 or v-bal[3] > 0) then next.

     find first londebt where londebt.lon = lon.lon no-lock no-error.
     if avail londebt then assign dayc1 = londebt.days_od dayc2 = londebt.days_prc.

     /* Если пролонгация закончилась, то гасить все что есть на 1 и 2 уровнях */
     if dlong > lon.duedt and dlong <= datums then do:
       /* просрочка ОД */
       v-am3 = bilance.
       if v-am3 > 0 then dayc1 = datums - dlong. else dayc1 = 0.
       /* просрочка % */
       run lonbalcrc('lon',lon.lon,datums,"2,9,10",yes,lon.crc,output v-am0).
       if v-am0 > 0 then dayc2 = datums - dlong. else dayc2 = 0.
     end.

     find cif where cif.cif = lon.cif no-lock.
     create wrk.
            wrk.lon = lon.lon.
            wrk.cif = lon.cif.
            wrk.name = trim(cif.name).
            wrk.rdt = lon.rdt.
            wrk.duedt = dlong.
            wrk.opnamt = lon.opnamt.
            wrk.balans = bilance.
            wrk.crc = lon.crc.
            wrk.prem = lon.prem.
            wrk.bal1 = v-am3. /* полная просрочка ОД */
            wrk.dt1 = dayc1.
            wrk.bal2 = v-am0. /* полная просрочка %% */
            wrk.dt2 = dayc2.
            wrk.bal3 = v-am3 + v-am0 + v-bal[1] + v-bal[2].
            wrk.is-today = is-pogtoday.
            wrk.bal16 = v-am16.
            wrk.bal13 = v-bal[1].
            wrk.bal14 = v-bal[2].
            wrk.bal30 = v-bal[3].
            wrk.day = lon.day.

     find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnsegm' no-lock no-error.
     if avail sub-cod then wrk.segm = sub-cod.ccode.
     else do:
       message " Не указан сегмент кредита, клиент " + lon.cif + ", сс.счет " + lon.lon view-as alert-box buttons ok title " Ошибка! ".
     end.

     run lonbalcrc('lon',lon.lon,datums,"20",yes,lon.crc,output wrk.iod).
     run lonbalcrc('lon',lon.lon,datums,"22",yes,lon.crc,output wrk.iprc).

     find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "kdkik" no-lock no-error.
     if avail sub-cod then do:
       if sub-cod.ccode = '01' then do:
         wrk.is-kik = yes.
         wrk.bal1 = wrk.balans.
       end.
     end.

end.




find first cmp no-lock no-error.
define stream rep.
output stream rep to value(vfname).

put stream rep unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.


put stream rep unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>Задолженность по ссудным счетам клиентов на " string(datums) "<BR>".
put stream rep unformatted "(Физические лица)".

put stream rep unformatted "</h3></td></tr><br><br>" skip.

       put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td>П/п</td>"
                  "<td>Код заемщика</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>К оплате<BR>(без штрафов)</td>"
                  "<td>Валюта</td>"
                  "<td>Штрафы KZT</td>"
                  "<td>Внебаланс<BR>(штрафы KZT)</td>"
                  "<td>Дней просрочки</td>"
                  "<td>Просрочка ОД</td>"
                  "<td>Просрочка %</td>"
                  "<td>Индекс ОД</td>"
                  "<td>Индекс %%</td>"
                  "<td>Внебаланс<BR>(ОД)</td>"
                  "<td>Внебаланс<BR>(%)</td>"
                  "<td>День<BR>расчета</td>"
                  "<td>Сс счет</td>"
                  "<td>Выд. сумма</td>"
                  "<td>Остаток ОД</td>" skip.

/* Все остальные кредиты */

  coun = 1.
  for each wrk no-lock break by wrk.segm by wrk.crc.

        if first-of(wrk.segm) then do:
          find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
          if avail codfr then put stream rep unformatted "<tr><td colspan=13 bgcolor=""#9BCDFF""><b>" codfr.name[1] "</b></td></tr>" skip.
          else put stream rep unformatted "<tr><td colspan=13 bgcolor=""#9BCDFF""><b>-- ошибка! сегмент не найден --</b></td></tr>" skip.
        end.

        find crc where crc.crc = wrk.crc no-lock no-error.
        put stream rep unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>" skip
               "<td align=""left"">" wrk.cif "</td>" skip
               "<td align=""left"">" wrk.name "</td>" skip
               "<td>" replace(trim(string(wrk.bal3 + wrk.iod + wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""left"">" crc.code "</td>" skip
               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" maximum(wrk.dt1,wrk.dt2) format '->>>9' "</td>" skip
               "<td>" replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td align=""center"">" wrk.day "</td>" skip
               "<td>&nbsp;" wrk.lon "</td>" skip
               "<td>" replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "</tr>".
        coun = coun + 1.

  end. /* for each wrk */

put stream rep "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

vres = yes. /* успешное формирование файла */
/*
unix silent cptwin pkdolg.htm excel.
*/

pause 0.
