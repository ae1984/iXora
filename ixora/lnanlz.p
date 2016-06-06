/* lnanlz.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Анализ кредитного портфеля в динамике
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-5-10
 * AUTHOR
        01.03.2003 marinav
 * CHANGES
        21.08.2003 marinav Добавлен расчет будущих процентов и реальных % ставок
        30.10.2003 marinav Изменен расчет реальной ставки по БД, в связи с графиками.
        08.12.03   nataly  заменен счет ГК 1439 -> 1428  в связи с переходом на новый ПС
        17.12.2003 nadejda - добавила pk0.i для перекомпиляции
        01.01.2004 nadejda - возможность выбора отчета консолидир/филиалы для головного офиса, филиалы видят только свой отчет
        02.04.2004 nadejda - добавлен вывод суммы выданных гарантий и провизий по ним
        08.04.2004 nadejda - Кузьмичев сказал провизии по гарантиям брать по счету 2874
        07/06/2004 madiyar - с мая 2004 провизии по гарантиям падают на счет 2875 (спец провизии). Выдаем сумму по 2874 и 2875 (на одном из
                             счетов все равно нуль)
                             Добавил в конец отчета таблицу с раскладом кредитного портфеля по признакам юр/физ и краткоср/долгоср
        13/07/2004 madiyar - Из-за разбивки на быстрые и остальные кредиты некорректно работало вычисление кол-ва заемщиков и кредитов
        10/08/2004 madiyar - Убрал из первой таблицы разбивку на быстрые и не быстрые
                             Добавил таблицу по количеству заемщиков и кредитов с разбивкой на юр, физ и быстрые
        03/09/2004 madiyar - Закомментировал кусок кода - вывод таблицы "Доход будущего месяца"
        06/09/2004 madiyar - Добавил строку "Динамика роста ссудного портфеля, долл США"
        23/09/2004 madiyar - Исправил ошибку - неправильно подсчитывалось кол-во кредитов
        01/10/2004 madiyar - теперь отчет формируется НА дату
        07/10/2004 madiyar - Курсы должны браться тоже НА дату (т.е. за предыдущую)
        14/10/2004 madiyar - Даты в динамике должны браться с привязкой к датам начала кварталов - не стал выдумывать мудреный алгоритм,
                             список дат формируется case'ом.
                             Провизии берутся фактически начисленные (и для таблицы в динамике, и для классификации).
        05/11/2004 madiyar - Кол-во кредитов в таблице по провизиям не совпадало с общим кол-вом кредитов в 1-ой таблице (из-за
                             записей с суммами по счетам ГК в таблице wrk) - исправил
        08/11/2004 madiyar - Исправил - курсы валют на старые даты
        29/11/2004 madiyar - Если отчет формируется не на 1ое число месяца - не выводится данные по провизиям
        14/03/2005 madiyar - Изменения в формате отчета
        17/03/2005 madiyar - Отчет грамм скривился, исправил
        29/03/2005 madiyar - Подтягивались неправильные курсы, исправил
        04/08/2005 madiyar - юр/физ - отдельно
                             добавил поле wrk.balans_prosr - просрочка ОД
                             выводится динамика доли классиф. категорий кредитов к кредитному портфелю (по сумме)
        08/08/2005 madiyar - если отчет не общий - не показывать лишние нули (по юр. или физ. лицам)
        11/08/2005 madiyar - добавил поле wrk.dolgosr, изменения в расчете средневзвешанной ставки
        15/08/2005 madiyar - мелкие исправления в формате вывода
        31/01/2006 madiyar - все в 5-ой таблице в долларах
        01/06/2006 madiyar - добавилась таблица по сегментации; no-undo
        06/06/2006 madiyar - в таблице по сегментации суммы по курсу в тенге
        11/08/2006 madiyar - выданные за период
        11/11/2009 madiyar - актуализировал
        13/11/2009 madiyar - выделил метрокредит, оптимизировал
*/

{mainhead.i}

{pk0.i}

def var i as integer no-undo.
def var j as integer no-undo.
def new shared var d1 as date no-undo.
def var crlf as char no-undo.
def var coun as int no-undo init 1.
def var cnt as decimal no-undo extent 9.
def var v-cif_90_92 like bank.lon.cif no-undo.
def var v-cif_rest like bank.lon.cif no-undo.
def var kolk as int no-undo extent 14.
def var kolz as int no-undo extent 6.
def var sumk as decimal no-undo extent 14.
def var sump as decimal no-undo extent 14.
def var prck as decimal no-undo extent 10.
def new shared var suma as decimal no-undo.
def var suma1 as decimal no-undo.
def var suma2 as decimal no-undo.
def var suma3 as decimal no-undo.
def var suma4 as decimal no-undo.

def var kred_kol as int no-undo extent 12.
def var kred_sum as deci no-undo extent 12.

def var prc as decimal no-undo extent 5.
def var srk as decimal no-undo extent 14.
def var vsrk as decimal no-undo init 0.

def new shared var krport as deci no-undo extent 6.
def var svald as decimal no-undo.
def var svalt as decimal no-undo.
def var svale as decimal no-undo.

def var mkol as integer no-undo extent 4.

def buffer b-crchis for bank.crchis.

prc[1] = 0. prc[2] = 0. prc[5] = 0.

def new shared temp-table wrk no-undo
    field datot  like bank.lon.rdt
    field cif    like bank.lon.cif
    field isGL   as logi
    field lon    like bank.lon.lon
    field segm   as char
    field name   like bank.cif.name
    field plan   like bank.lon.plan
    field sts    as char
    field grp    like bank.lon.grp
    field amoun  like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field balans1 like bank.lon.opnamt
    field balans2 like bank.lon.opnamt
    field balans_prosr like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field proc   like bank.lon.opnamt
    field duedt  like bank.lon.rdt
    field rez    like bank.lonstat.prc
    field srez   like bank.lon.opnamt
    field zalog  like bank.lon.opnamt
    field srok   as deci
    field dolgosr as logi
    index main is primary datot cif
    index datot datot
    index cif cif
    index segm segm.

def temp-table wrk1 no-undo
    field s1 as char
    field s2 as char
    field s3 as char
    field s4 as char
    field s5 as char
    field s6 as char.

def temp-table wrk2 no-undo
    field name   as char
    field v-sum  as deci
    field v-sum1 as deci
    field v-sum2 as deci
    field v-rate as deci
    index name name.

def temp-table wrksegm no-undo
    field code as char
    field name as char
    field dat  as date
    field sum  as deci
    field num  as integer
    index main is primary code dat.

def new shared temp-table wrkvyd no-undo
    field datot like lon.rdt
    field segm as char
    field name as char
    field sum as deci
    field kol as integer
    index main is primary segm datot.

crlf = chr(10) + chr(13).
    /*для долларов*/
       cnt[1] = 0.   /*заявленная*/
       cnt[2] = 0.   /*реальная*/
       cnt[3] = 0.   /*провизия*/
   /*для тенге*/
       cnt[4] = 0.
       cnt[5] = 0.
       cnt[6] = 0.
   /*для ЕВРО*/
       cnt[7] = 0.
       cnt[8] = 0.
       cnt[9] = 0.


d1 = g-today.
update d1 label " Отчет на дату" format "99/99/9999"
                  skip with side-label row 5 centered frame dat .

/* 11/10/2004 madiyar */
def new shared var dates as date no-undo extent 6.
def var bsum as deci no-undo extent 6.
def var bnum as integer no-undo extent 6.
def var bdat as date no-undo.
def var vmonth as int no-undo.
def var vyear as int no-undo.
dates[1] = d1.
bdat = d1.
if day(d1) <> 1 then do:
  vmonth = month(d1) + 1.
  vyear = year(d1).
  if vmonth = 13 then do: vmonth = 1. vyear = vyear + 1. end.
  bdat = date(vmonth, 1, vyear).
end.
case month(bdat):
  when 1 then do:
    dates[2] = date(12,1,year(bdat) - 1).
    dates[3] = date(11,1,year(bdat) - 1).
    dates[4] = date(10,1,year(bdat) - 1).
    dates[5] = date(7,1,year(bdat) - 1).
    dates[6] = date(1,1,year(bdat) - 1).
  end.
  when 2 then do:
    dates[2] = date(1,1,year(bdat)).
    dates[3] = date(12,1,year(bdat) - 1).
    dates[4] = date(10,1,year(bdat) - 1).
    dates[5] = date(7,1,year(bdat) - 1).
    dates[6] = date(1,1,year(bdat) - 1).
  end.
  when 3 then do:
    dates[2] = date(2,1,year(bdat)).
    dates[3] = date(1,1,year(bdat)).
    dates[4] = date(10,1,year(bdat) - 1).
    dates[5] = date(7,1,year(bdat) - 1).
    dates[6] = date(1,1,year(bdat) - 1).
  end.
  when 4 then do:
    dates[2] = date(3,1,year(bdat)).
    dates[3] = date(2,1,year(bdat)).
    dates[4] = date(1,1,year(bdat)).
    dates[5] = date(10,1,year(bdat) - 1).
    dates[6] = date(7,1,year(bdat) - 1).
  end.
  when 5 then do:
    dates[2] = date(4,1,year(bdat)).
    dates[3] = date(3,1,year(bdat)).
    dates[4] = date(2,1,year(bdat)).
    dates[5] = date(1,1,year(bdat)).
    dates[6] = date(10,1,year(bdat) - 1).
  end.
  when 6 then do:
    dates[2] = date(5,1,year(bdat)).
    dates[3] = date(4,1,year(bdat)).
    dates[4] = date(3,1,year(bdat)).
    dates[5] = date(2,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 7 then do:
    dates[2] = date(6,1,year(bdat)).
    dates[3] = date(5,1,year(bdat)).
    dates[4] = date(4,1,year(bdat)).
    dates[5] = date(3,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 8 then do:
    dates[2] = date(7,1,year(bdat)).
    dates[3] = date(6,1,year(bdat)).
    dates[4] = date(5,1,year(bdat)).
    dates[5] = date(4,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 9 then do:
    dates[2] = date(8,1,year(bdat)).
    dates[3] = date(7,1,year(bdat)).
    dates[4] = date(6,1,year(bdat)).
    dates[5] = date(4,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 10 then do:
    dates[2] = date(9,1,year(bdat)).
    dates[3] = date(8,1,year(bdat)).
    dates[4] = date(7,1,year(bdat)).
    dates[5] = date(4,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 11 then do:
    dates[2] = date(10,1,year(bdat)).
    dates[3] = date(9,1,year(bdat)).
    dates[4] = date(7,1,year(bdat)).
    dates[5] = date(4,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
  when 12 then do:
    dates[2] = date(11,1,year(bdat)).
    dates[3] = date(10,1,year(bdat)).
    dates[4] = date(7,1,year(bdat)).
    dates[5] = date(4,1,year(bdat)).
    dates[6] = date(1,1,year(bdat)).
  end.
end.
/* 11/10/2004 madiyar - end*/

def var v-sel as integer no-undo init 0.
run sel2 ("Выбор :", " 1. Физические лица | 2. Юридические лица | 3. Метрокредит | 4. Общий | 5. Выход ", output v-sel).
if (v-sel < 1) or (v-sel > 4) then return.

{r-brfilial.i &proc = "lnanlz2 (d1,v-sel)"}
/* 01.04.2004 nadejda - {r-branch.i &proc = "lnanlz2(d1)"}*/
/*run lnanlz1(input d1).*/

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.rdt < d1 no-lock no-error.
find last b-crchis where b-crchis.crc = 3 and b-crchis.rdt < d1 no-lock no-error.
def var rates_d as deci no-undo extent 2.
rates_d[1] = bank.crchis.rate[1].
rates_d[2] = b-crchis.rate[1].

for each wrk where wrk.datot = d1 break by wrk.cif.

   if wrk.lon = "" then next.

   if wrk.cif <> v-cif_rest and wrk.crc = 1 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolz[1] = kolz[1] + 1.
       if wrk.sts = '0' then mkol[1] = mkol[1] + 1.
       else mkol[3] = mkol[3] + 1.
   end.
   if wrk.cif <> v-cif_rest and wrk.crc = 2 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolz[2] = kolz[2] + 1.
       if wrk.sts = '0' then mkol[1] = mkol[1] + 1.
       else mkol[3] = mkol[3] + 1.
   end.
   if wrk.cif <> v-cif_rest and wrk.crc = 3 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolz[5] = kolz[5] + 1.
       if wrk.sts = '0' then mkol[1] = mkol[1] + 1.
       else mkol[3] = mkol[3] + 1.
   end.

   if wrk.cif <> v-cif_90_92 and wrk.crc = 1 and (wrk.grp = 90 or wrk.grp = 92) then  kolz[3] = kolz[3] + 1.
   if wrk.cif <> v-cif_90_92 and wrk.crc = 2 and (wrk.grp = 90 or wrk.grp = 92) then  kolz[4] = kolz[4] + 1.
   if wrk.cif <> v-cif_90_92 and wrk.crc = 3 and (wrk.grp = 90 or wrk.grp = 92) then  kolz[6] = kolz[6] + 1.

   if wrk.grp = 90 or wrk.grp = 92 then v-cif_90_92 = wrk.cif.
   else v-cif_rest = wrk.cif.

   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.

    if wrk.crc = 2 then do:
       cnt[2] = cnt[2] + wrk.balans.
       cnt[3] = cnt[3] + wrk.srez.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       prc[4] = prc[4] + wrk.balans * wrk.srok.
    end.
    if wrk.crc = 1 then do:
       cnt[5] = cnt[5] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.
    end.
    if wrk.crc = 3 then do:
       cnt[8] = cnt[8] + wrk.balans.
       cnt[9] = cnt[9] + wrk.srez.
       prc[5] = prc[5] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans * b-crchis.rate[1] / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans * b-crchis.rate[1] / bank.crchis.rate[1] * wrk.srok.
    end.

svald = cnt[2] + cnt[5] / bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1].
svalt = cnt[2] * bank.crchis.rate[1] + cnt[5] + cnt[8] * b-crchis.rate[1].
svale = cnt[2] * bank.crchis.rate[1] / b-crchis.rate[1] + cnt[5] / b-crchis.rate[1] + cnt[8].

    /* по кредитам */
    if wrk.crc = 1 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolk[1] = kolk[1] + 1.
       sumk[1] = sumk[1] + wrk.balans.
       if wrk.sts = '0' then mkol[2] = mkol[2] + 1.
       else mkol[4] = mkol[4] + 1.
    end.
    if wrk.crc = 2 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolk[2] = kolk[2] + 1.
       sumk[2] = sumk[2] + wrk.balans.
       if wrk.sts = '0' then mkol[2] = mkol[2] + 1.
       else mkol[4] = mkol[4] + 1.
    end.
    if wrk.crc = 3 and wrk.grp <> 90 and wrk.grp <> 92 then do:
       kolk[5] = kolk[5] + 1.
       sumk[5] = sumk[5] + wrk.balans.
       if wrk.sts = '0' then mkol[2] = mkol[2] + 1.
       else mkol[4] = mkol[4] + 1.
    end.
    /* по экспрессам */
    if wrk.crc = 1 and (wrk.grp = 90 or wrk.grp = 92) then do:
       kolk[3] = kolk[3] + 1.
       sumk[3] = sumk[3] + wrk.balans.
    end.
    if wrk.crc = 2 and (wrk.grp = 90  or wrk.grp = 92) then do:
       kolk[4] = kolk[4] + 1.
       sumk[4] = sumk[4] + wrk.balans.
    end.
    if wrk.crc = 3 and (wrk.grp = 90 or wrk.grp = 92) then do:
       kolk[6] = kolk[6] + 1.
       sumk[6] = sumk[6] + wrk.balans.
    end.

    /* 07/06/2004 madiyar - подготовка данных для таблицы с разбивкой на юр/физ, краткоср/долгоср */
    if wrk.crc = 1 and wrk.sts = '0' and not(wrk.dolgosr) then do:
       kred_kol[1] = kred_kol[1] + 1.
       kred_sum[1] = kred_sum[1] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts = '0' and not(wrk.dolgosr) then do:
       kred_kol[2] = kred_kol[2] + 1.
       kred_sum[2] = kred_sum[2] + wrk.balans.
    end.
    if wrk.crc = 3 and wrk.sts = '0' and not(wrk.dolgosr) then do:
       kred_kol[3] = kred_kol[3] + 1.
       kred_sum[3] = kred_sum[3] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts <> '0' and not(wrk.dolgosr) then do:
       kred_kol[4] = kred_kol[4] + 1.
       kred_sum[4] = kred_sum[4] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts <> '0' and not(wrk.dolgosr) then do:
       kred_kol[5] = kred_kol[5] + 1.
       kred_sum[5] = kred_sum[5] + wrk.balans.
    end.
    if wrk.crc = 3 and wrk.sts <> '0' and not(wrk.dolgosr) then do:
       kred_kol[6] = kred_kol[6] + 1.
       kred_sum[6] = kred_sum[6] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts = '0' and wrk.dolgosr then do:
       kred_kol[7] = kred_kol[7] + 1.
       kred_sum[7] = kred_sum[7] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts = '0' and wrk.dolgosr then do:
       kred_kol[8] = kred_kol[8] + 1.
       kred_sum[8] = kred_sum[8] + wrk.balans.
    end.
    if wrk.crc = 3 and wrk.sts = '0' and wrk.dolgosr then do:
       kred_kol[9] = kred_kol[9] + 1.
       kred_sum[9] = kred_sum[9] + wrk.balans.
    end.
    if wrk.crc = 1 and wrk.sts <> '0' and wrk.dolgosr then do:
       kred_kol[10] = kred_kol[10] + 1.
       kred_sum[10] = kred_sum[10] + wrk.balans.
    end.
    if wrk.crc = 2 and wrk.sts <> '0' and wrk.dolgosr then do:
       kred_kol[11] = kred_kol[11] + 1.
       kred_sum[11] = kred_sum[11] + wrk.balans.
    end.
    if wrk.crc = 3 and wrk.sts <> '0' and wrk.dolgosr then do:
       kred_kol[12] = kred_kol[12] + 1.
       kred_sum[12] = kred_sum[12] + wrk.balans.
    end.

end. /* for each wrk */


define stream m-out.
output stream m-out to rpt.html.

put stream m-out unformatted
            "<html><head><title>METROCOMBANK</title>" skip
            "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
            "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted
            "<tr align=""center""><td><h3>Анализ кредитного портфеля на " string(d1)
            if v-sel = 1 then " (физические лица)" else ""
            if v-sel = 2 then " (юридические лица)" else ""
            if v-sel = 3 then " (Метрокредит)" else ""
            if v-sel = 4 then " (весь портфель)" else ""
            "</h3></td></tr><br>" skip.

put stream m-out unformatted "<tr><td><b>" v-bankname "</b></td></tr><br>" skip.

svald = cnt[2] + cnt[5] / bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1].
svalt = cnt[2] * bank.crchis.rate[1] + cnt[5] + cnt[8] * b-crchis.rate[1].
svale = cnt[2] * bank.crchis.rate[1] / b-crchis.rate[1] + cnt[5] / b-crchis.rate[1] + cnt[8].


put stream m-out unformatted
         "<br><tr><td><table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
         "<tr style=""font:bold"">"
         "<td align=""center""></td>"
         "<td align=""center"">USD/KZT</td>"
         "<td align=""center"">" replace(trim(string(rates_d[1],'>>>>9.99')),'.',',') "</td>"
         "</tr>" skip
         "<tr style=""font:bold"">"
         "<td align=""center""></td>"
         "<td align=""center"">EUR/KZT</td>"
         "<td align=""center"">" replace(trim(string(rates_d[2],'>>>>9.99')),'.',',') "</td>"
         "</tr></table>" skip.

put stream m-out unformatted
         "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
         "<tr style=""font:bold"">"
         "<td align=""center""></td>"
         "<td align=""center"">Сумма</td>"
         "</tr>" skip.

put stream m-out unformatted
         "<tr><td><b> КРЕДИТНЫЙ ПОРТФЕЛЬ, KZT</b></td>"
         "<td align=""right""><b> " replace(trim(string(svalt,'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "</tr>" skip.

put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b> КРЕДИТНЫЙ ПОРТФЕЛЬ, USD</b></td>"
         "<td align=""right""><b> " replace(trim(string(svald,'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "</tr>" skip.

put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b> КРЕДИТНЫЙ ПОРТФЕЛЬ, EUR</b></td>"
         "<td align=""right""><b> " replace(trim(string(svale,'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "</table></td></tr>" skip.

put stream m-out unformatted
         "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
         "<tr align=""left"">"
         "<td><b></b></td>"
         "<td align=""center""><b>Кол-во заемщиков</b></td>"
         "<td align=""center""><b>Кол-во кредитов</b></td>"
         "</tr>" skip.

if (v-sel = 2) or (v-sel = 4) then
  put stream m-out unformatted
         "<tr align=""left"">"
         "<td><b>Юридические лица</b></td>"
         "<td align=""center"">" mkol[1] format ">>>>>9" "</td>"
         "<td align=""center"">" mkol[2] format ">>>>>9" "</td>"
         "</tr>" skip.

if (v-sel = 1) or (v-sel = 4) then
  put stream m-out unformatted
         "<tr align=""left"">"
         "<td><b>Физические лица</b></td>"
         "<td align=""center"">" mkol[3] format ">>>>>9" "</td>"
         "<td align=""center"">" mkol[4] format ">>>>>9" "</td>"
         "</tr>" skip.

if (v-sel = 3) or (v-sel = 4) then
  put stream m-out unformatted
         "<tr align=""left"">"
         "<td><b>Метрокредит</b></td>"
         "<td align=""center"">" kolz[3] + kolz[4] + kolz[6] format ">>>>>9" "</td>"
         "<td align=""center"">" kolk[3] + kolk[4] + kolk[6] format ">>>>>9" "</td>"
         "</tr>" skip.

put stream m-out unformatted
         "<tr align=""left"">"
         "<td><b>Всего</b></td>"
         "<td align=""center""><b>" mkol[1] + mkol[3] + kolz[3] + kolz[4] + kolz[6] format ">>>>>9" "</b></td>"
         "<td align=""center""><b>" mkol[2] + mkol[4] + kolk[3] + kolk[4] + kolk[6] format ">>>>>9" "</b></td>"
         "</tr>"
         "</table></td></tr>" skip.

put stream m-out unformatted
         "<br><br><br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
         "<tr align=""left"">"
         "<td><b> В ДОЛЛАРАХ США</b></td>"
         "<td align=""center""><b>" kolz[2] "</td> "
         "<td align=""center""><b>" kolk[2] "</b></td>"
         "<td align=""right""><b> " replace(trim(string(sumk[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "<td align=""right""><i> " replace(trim(string(sumk[2] / svald * 100,'>>9.99')),'.',',') "</i></td> "
         "</tr>" skip.

put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b>В ТЕНГЕ</b></td>"
         "<td align=""center""><b>" kolz[1] "</td> "
         "<td align=""center""><b>" kolk[1] "</b></td>"
         "<td align=""right""><b> " replace(trim(string(sumk[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "<td align=""right""><i> " replace(trim(string(sumk[1] / svalt * 100,'>>9.99')),'.',',') "</i></td> "
         "</tr>" skip.

put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b>В ЕВРО</b></td>"
         "<td align=""center""><b>" kolz[5] "</td> "
         "<td align=""center""><b>" kolk[5] "</b></td>"
         "<td align=""right""><b> " replace(trim(string(sumk[5],'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "<td align=""right""><i> " replace(trim(string(sumk[5] / svale * 100,'>>9.99')),'.',',') "</i></td> "
         "</tr>" skip.

if (v-sel = 3 or v-sel = 4) and sumk[4] > 0 then
  put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b>Метрокредит (USD)</b></td>"
         "<td align=""center""><b>" kolz[4] format ">>>>>9" "</td> "
         "<td align=""center""><b>" kolk[4] format ">>>>>9" "</b></td>"
         "<td align=""right""><b> " replace(trim(string(sumk[4],'>>>>>>>>>>>9.99')),'.',',') "</b></td> "
         "<td align=""right""><i> " replace(trim(string(sumk[4] / svald * 100,'>>9.99')),'.',',') "</i></td> "
         "</tr>" skip.

if (v-sel = 3 or v-sel = 4) and sumk[3] > 0 then
  put stream m-out unformatted
         "<br><tr align=""left"">"
         "<td><b>Метрокредит</b></td>"
         "<td align=""center""><b>" kolz[3] format ">>>>>9" "</td>"
         "<td align=""center""><b>" kolk[3] format ">>>>>9" "</b></td>"
         "<td align=""right""><b> " replace(trim(string(sumk[3],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
         "<td align=""right""><i> " replace(trim(string(sumk[3] / svalt * 100,'>>9.99')),'.',',') "</i></td>"
         "</tr>" skip.

put stream m-out unformatted "</table></td></tr>" skip.

/* таблица по провизиям не нужна, если не начало месяца */
if day(d1) = 1 then do:

    def temp-table wrk_pr
      field id as int
      field cat as char
      field perc as char
      field num as int extent 6
      field bal as deci extent 6
      field prov as deci extent 6
      index idx is primary id.

    create wrk_pr. assign wrk_pr.id = 1 wrk_pr.cat = "Стандартные" wrk_pr.perc = "0%".
    create wrk_pr. assign wrk_pr.id = 2 wrk_pr.cat = "Сомнительные 1 категории" wrk_pr.perc = "5%".
    create wrk_pr. assign wrk_pr.id = 3 wrk_pr.cat = "Сомнительные 2 категории" wrk_pr.perc = "10%".
    create wrk_pr. assign wrk_pr.id = 4 wrk_pr.cat = "Сомнительные 3 категории" wrk_pr.perc = "20%".
    create wrk_pr. assign wrk_pr.id = 5 wrk_pr.cat = "Сомнительные 4 категории" wrk_pr.perc = "25%".
    create wrk_pr. assign wrk_pr.id = 6 wrk_pr.cat = "Сомнительные 5 категории" wrk_pr.perc = "50%".
    create wrk_pr. assign wrk_pr.id = 7 wrk_pr.cat = "Безнадежные" wrk_pr.perc = "100%".

    def var s-num as int extent 7.
    def var s-bal as deci extent 7.
    def var s-prov as deci extent 7.
    def var all_num as integer.
    def var all_prov as deci.

    coun = 6.
    for each wrk no-lock break by wrk.datot:

      if first-of(wrk.datot) then do:
        s-num = 0. s-bal = 0. s-prov = 0.
      end.

      if wrk.lon <> "" then do:

        if wrk.rez < 2 then do: /* стандартные */
          s-num[1] = s-num[1] + 1.
          s-prov[1] = s-prov[1] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[1] = s-bal[1] + wrk.balans.
            when 2 then s-bal[1] = s-bal[1] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[1] = s-bal[1] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 5 then do: /* Сомнительные 1 категории */
          s-num[2] = s-num[2] + 1.
          s-prov[2] = s-prov[2] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[2] = s-bal[2] + wrk.balans.
            when 2 then s-bal[2] = s-bal[2] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[2] = s-bal[2] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 10 then do: /* Сомнительные 2 категории */
          s-num[3] = s-num[3] + 1.
          s-prov[3] = s-prov[3] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[3] = s-bal[3] + wrk.balans.
            when 2 then s-bal[3] = s-bal[3] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[3] = s-bal[3] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 20 then do: /* Сомнительные 3 категории */
          s-num[4] = s-num[4] + 1.
          s-prov[4] = s-prov[4] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[4] = s-bal[4] + wrk.balans.
            when 2 then s-bal[4] = s-bal[4] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[4] = s-bal[4] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 25 then do: /* Сомнительные 4 категории */
          s-num[5] = s-num[5] + 1.
          s-prov[5] = s-prov[5] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[5] = s-bal[5] + wrk.balans.
            when 2 then s-bal[5] = s-bal[5] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[5] = s-bal[5] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 50 then do: /* Сомнительные 5 категории */
          s-num[6] = s-num[6] + 1.
          s-prov[6] = s-prov[6] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[6] = s-bal[6] + wrk.balans.
            when 2 then s-bal[6] = s-bal[6] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[6] = s-bal[6] + wrk.balans * b-crchis.rate[1].
          end case.
        end.
        if wrk.rez = 100 then do: /* Безнадежные */
          s-num[7] = s-num[7] + 1.
          s-prov[7] = s-prov[7] + wrk.srez.
          case wrk.crc:
            when 1 then s-bal[7] = s-bal[7] + wrk.balans.
            when 2 then s-bal[7] = s-bal[7] + wrk.balans * bank.crchis.rate[1].
            when 3 then s-bal[7] = s-bal[7] + wrk.balans * b-crchis.rate[1].
          end case.
        end.

      end. /* if wrk.lon <> "" */

      if last-of(wrk.datot) then do:
        for each wrk_pr:
          wrk_pr.num[coun] = s-num[wrk_pr.id].
          wrk_pr.bal[coun] = s-bal[wrk_pr.id].
          wrk_pr.prov[coun] = s-prov[wrk_pr.id].
        end.
        coun = coun - 1.
      end.

    end. /* for each wrk */

    put stream m-out unformatted
           "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
           "<tr style=""font:bold"">" skip
           "<td align=""center"" rowspan=""2""></td>" skip
           "<td align=""center"" rowspan=""2""></td>" skip
           "<td align=""center"" rowspan=""2"">Кол-во кредитов<br>" d1 format "99/99/9999" "</td>" skip
           "<td align=""center"" rowspan=""2"">Сумма займа, тенге<br>" d1 format "99/99/9999" "</td>" skip
           "<td align=""center"" rowspan=""2"">Сумма провизий, тенге<br>" d1 format "99/99/9999" "</td>" skip
           "<td align=""center"" colspan=""6"">Доля в портфеле</td></tr>" skip
           "<tr style=""font:bold"">" skip.

    do i = 1 to 6:
      put stream m-out unformatted "<td align=""center"">" dates[i] format "99/99/9999" "</td>" skip.
    end.

    put stream m-out unformatted "</tr>" skip.

    for each wrk_pr no-lock:

        put stream m-out unformatted
             "<tr align=""left"">" skip
             "<td><b>" wrk_pr.cat "</b></td>" skip
             "<td align=""center""><i>" wrk_pr.perc "</i></td>" skip
             "<td align=""center""><b>" wrk_pr.num[1] format ">>>>>>>9" "</b></td>" skip
             "<td align=""right""><b> " replace(trim(string(wrk_pr.bal[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>" skip
             "<td align=""right""><b> " replace(trim(string(wrk_pr.prov[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>" skip.

        do i = 1 to 6:
           put stream m-out unformatted "<td align=""right""><i>" replace(trim(string(wrk_pr.bal[i] / krport[i] * 100,'>>9.99')),'.',',') "</i></td>" skip.
        end.

        put stream m-out unformatted "</tr>" skip.

        all_num = all_num + wrk_pr.num[1].
        all_prov = all_prov + wrk_pr.prov[1].

    end.

    put stream m-out unformatted
             "<tr align=""left"">" skip
             "<td><b>Всего</b></td>" skip
             "<td></td>" skip
             "<td align=""center""><b>" all_num format ">>>>>>>9" "</b></td>" skip
             "<td></td>" skip
             "<td align=""right""><b> " replace(trim(string(all_prov,'>>>>>>>>>>>9.99')),'.',',') "</b></td>" skip
             "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td>" skip
             "</tr>" skip
             "</table></td></tr>" skip.

end. /* if day(d1) = 1 */

/*********************/


i = 1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.
 create wrk1.

 /* гарантии */
 create wrk1.
 create wrk1.
 create wrk1.

def var prosr as deci.

for each wrk use-index datot break by wrk.datot desc .

    if first-of(wrk.datot) then do:
       cnt[2]  = 0. cnt[3]  = 0. cnt[5]  = 0. cnt[6]  = 0. cnt[8]  = 0. cnt[9]  = 0.  prc[1] = 0. prc[2] = 0. prc[4] = 0. prc[3] = 0.
       find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.rdt < wrk.datot no-lock no-error.
       find last b-crchis where b-crchis.crc = 3 and b-crchis.rdt < wrk.datot no-lock no-error.
       suma = 0.
       suma1 = 0.
       suma2 = 0.
       /* просрочка */
       prosr = 0.
       /* гарантии и провизии по ним */
       suma3 = 0.
       suma4 = 0.
    end.

    /* подготовка таблички по сегментации кредитов */
    if wrk.lon <> '' then do:
      find first wrksegm where wrksegm.code = wrk.segm and wrksegm.dat = wrk.datot no-error.
      if not avail wrksegm then do:
        create wrksegm.
        wrksegm.code = wrk.segm.
        find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
        if avail codfr then wrksegm.name = codfr.name[1].
        wrksegm.dat = wrk.datot.
      end.
      wrksegm.num = wrksegm.num + 1.
      if wrk.crc = 1 then wrksegm.sum = wrksegm.sum + wrk.balans.
      else
      if wrk.crc = 2 then wrksegm.sum = wrksegm.sum + wrk.balans * bank.crchis.rate[1].
      else
      if wrk.crc = 3 then wrksegm.sum = wrksegm.sum + wrk.balans * b-crchis.rate[1].
    end.

    if wrk.isGL then do:
        if wrk.cif = "1403" then suma1 = suma1 + wrk.amoun.  /* посчитаем карточки */
        if wrk.cif = "199995" then suma = suma + wrk.amoun.  /* посчитаем активы */
        if wrk.cif = "1428" then suma2 = suma2 - wrk.amoun.  /* посчитаем провизии */
        /* гарантии и провизии по ним */
        if wrk.cif = "655500" then suma3 = suma3 + wrk.amoun.
        if wrk.cif = "287400" or wrk.cif = "287500" then suma4 = suma4 + wrk.amoun.
    end.

    if not(wrk.isGL) then do:
        if wrk.crc = 1 then do:
           cnt[5] = cnt[5] + wrk.balans.
           if wrk.grp = 90 or wrk.grp = 92 then prc[2] = prc[2] + wrk.amoun * wrk.prem.
           else prc[2] = prc[2] + wrk.balans * wrk.prem.
           prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.
           prosr = prosr + wrk.balans_prosr. /* в тенге */
        end.
        if wrk.crc = 2 then do:
           cnt[2] = cnt[2] + wrk.balans.
           prc[1] = prc[1] + wrk.balans * wrk.prem.
           prc[4] = prc[4] + wrk.balans * wrk.srok.
           prosr = prosr + wrk.balans_prosr * bank.crchis.rate[1]. /* в тенге */
        end.
        if wrk.crc = 3 then do:
           cnt[8] = cnt[8] + wrk.balans.
           prc[3] = prc[3] + wrk.balans * wrk.prem.
           prc[4] = prc[4] + wrk.balans * b-crchis.rate[1] / bank.crchis.rate[1] * wrk.srok.
           prosr = prosr + wrk.balans_prosr * b-crchis.rate[1]. /* в тенге */
        end.
    end.

    if last-of(wrk.datot) then do:
      cnt[5] = cnt[5] + suma1.
      find first wrk1.
      if i = 1 then do:
         wrk1.s1 = string(wrk.datot). find next wrk1.
         wrk1.s1 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]). find next wrk1.
         wrk1.s1 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100). find next wrk1.
         wrk1.s1 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s1 = string(suma2 / (cnt[5]  + cnt[2] *  bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s1 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s1 = string(prc[1] / cnt[2]). find next wrk1.
         wrk1.s1 = string(prc[2] / cnt[5]). find next wrk1.
         wrk1.s1 = string(prc[3] / cnt[8]). find next wrk1.
         wrk1.s1 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.

         /* гарантии */
         wrk1.s1 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s1 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s1 = string(suma4 / suma3 * 100).
      end.
      if i = 2 then do:
         wrk1.s2 = string(wrk.datot). find next wrk1.
         wrk1.s2 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]). find next wrk1.
         wrk1.s2 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100). find next wrk1.
         wrk1.s2 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s2 = string(suma2 / (cnt[5] + cnt[2] *  bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s2 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s2 = string(prc[1] / cnt[2]). find next wrk1.
         wrk1.s2 = string(prc[2] / cnt[5]). find next wrk1.
         wrk1.s2 = string(prc[3] / cnt[8]). find next wrk1.
         wrk1.s2 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.
         /* гарантии */
         wrk1.s2 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s2 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s2 = string(suma4 / suma3 * 100).
      end.
      if i = 3 then do:
         wrk1.s3 = string(wrk.datot). find next wrk1.
         wrk1.s3 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]). find next wrk1.
         wrk1.s3 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100). find next wrk1.
         wrk1.s3 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s3 = string(suma2 / (cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s3 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s3 = string(prc[1] / cnt[2]). find next wrk1.
         wrk1.s3 = string(prc[2] / cnt[5]). find next wrk1.
         wrk1.s3 = string(prc[3] / cnt[8]). find next wrk1.
         wrk1.s3 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.
         /* гарантии */
         wrk1.s3 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s3 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s3 = string(suma4 / suma3 * 100).
      end.
      if i = 4 then do:
         wrk1.s4 = string(wrk.datot). find next wrk1.
         wrk1.s4 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]). find next wrk1.
         wrk1.s4 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100). find next wrk1.
         wrk1.s4 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s4 = string(suma2 / (cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s4 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s4 = string(prc[1] / cnt[2]) . find next wrk1.
         wrk1.s4 = string(prc[2] / cnt[5]) . find next wrk1.
         wrk1.s4 = string(prc[3] / cnt[8]) . find next wrk1.
         wrk1.s4 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.
         /* гарантии */
         wrk1.s4 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s4 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s4 = string(suma4 / suma3 * 100).
      end.
      if i = 5 then do:
         wrk1.s5 = string(wrk.datot). find next wrk1.
         wrk1.s5 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]). find next wrk1.
         wrk1.s5 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100). find next wrk1.
         wrk1.s5 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s5 = string(suma2 / (cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s5 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s5 = string(prc[1] / cnt[2]). find next wrk1.
         wrk1.s5 = string(prc[2] / cnt[5]). find next wrk1.
         wrk1.s5 = string(prc[3] / cnt[8]). find next wrk1.
         wrk1.s5 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.
         /* гарантии */
         wrk1.s5 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s5 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s5 = string(suma4 / suma3 * 100).
      end.
      if i = 6 then do:
         wrk1.s6 = string(wrk.datot). find next wrk1.
         wrk1.s6 = string(cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1]) . find next wrk1.
         wrk1.s6 = string((cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) / suma * 100) . find next wrk1.
         wrk1.s6 = string(suma2 / bank.crchis.rate[1]). find next wrk1.
         wrk1.s6 = string(suma2 / (cnt[5] + cnt[2] * bank.crchis.rate[1] + cnt[8] * b-crchis.rate[1]) * 100). find next wrk1.
         wrk1.s6 = string(prosr / bank.crchis.rate[1]). find next wrk1.
         wrk1.s6 = string(prc[1] / cnt[2]). find next wrk1.
         wrk1.s6 = string(prc[2] / cnt[5]). find next wrk1.
         wrk1.s6 = string(prc[3] / cnt[8]). find next wrk1.
         wrk1.s6 = string(prc[4] / (cnt[5] / bank.crchis.rate[1] + cnt[2] + cnt[8] * b-crchis.rate[1] / bank.crchis.rate[1])). find next wrk1.
         /* гарантии */
         wrk1.s6 = string(suma3 / bank.crchis.rate[1]). find next wrk1.
         /* провизии по гарантиям */
         wrk1.s6 = string(suma4 / bank.crchis.rate[1]). find next wrk1.
         /* % провизии от выданных гарантий */
         wrk1.s6 = string(suma4 / suma3 * 100).
      end.
      i = i + 1.
    end.

end.

/* дорисовываем колонки, которых возможно нет */
def var clist as char.
for each wrksegm no-lock:
  if lookup(wrksegm.code,clist) = 0 then do:
    if clist <> '' then clist = clist + ','.
    clist = clist + wrksegm.code.
  end.
end.
do i = 1 to 6:
  do j = 1 to num-entries(clist):
    find first wrksegm where wrksegm.code = entry(j,clist) and wrksegm.dat = dates[i] no-error.
    if not avail wrksegm then do:
      create wrksegm.
      wrksegm.code = entry(j,clist).
      find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrksegm.code no-lock no-error.
      if avail codfr then wrksegm.name = codfr.name[1].
      wrksegm.dat = dates[i].
    end.
  end.
end.
clist = ''.
for each wrkvyd no-lock:
  if lookup(wrkvyd.segm,clist) = 0 then do:
    if clist <> '' then clist = clist + ','.
    clist = clist + wrkvyd.segm.
  end.
end.
do i = 1 to 6:
  do j = 1 to num-entries(clist):
    find first wrkvyd where wrkvyd.segm = entry(j,clist) and wrkvyd.datot = dates[i] no-error.
    if not avail wrkvyd then do:
      create wrkvyd.
      wrkvyd.segm = entry(j,clist).
      find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrkvyd.segm no-lock no-error.
      if avail codfr then wrkvyd.name = codfr.name[1].
      wrkvyd.datot = dates[i].
    end.
  end.
end.

find first wrk1.

put stream m-out unformatted
                  "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td align=""center""></td><td></td>"
                  "<td align=""center"">" date(wrk1.s1) "</td>"
                  "<td align=""center"">" date(wrk1.s2) "</td>"
                  "<td align=""center"">" date(wrk1.s3) "</td>"
                  "<td align=""center"">" date(wrk1.s4) "</td>"
                  "<td align=""center"">" date(wrk1.s5) "</td>"
                  "<td align=""center"">" date(wrk1.s6) "</td>"
                  "</tr>" skip.

find next wrk1.
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Ссудный портфель, долл США</b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "</tr>" skip.
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Динамика роста ссудного портфеля, долл США</b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1) - deci(wrk1.s2),'->>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2) - deci(wrk1.s3),'->>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3) - deci(wrk1.s4),'->>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4) - deci(wrk1.s5),'->>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5) - deci(wrk1.s6),'->>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">&nbsp;-</td>"
                 "</tr>" skip.
find next wrk1.
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Ссудный портфель, % от активов</b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>9.99')),'.',',') "</td>"
                 "</tr>" skip.
find next wrk1.

if day(d1) = 1 then
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Провизии, долл США</b></td>"
                 "<td align=""center""> </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "</tr>" skip.
find next wrk1.

if day(d1) = 1 then
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Доля провизии, % от ссудного портфеля </b></td>"
                 "<td align=""center""> </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>9.99')),'.',',') "</td>"
                "</tr>" skip.
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td><b> Просроченная задолженность, долл США</b></td>"
                 "<td align=""center""> </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "</tr>" skip.
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td valign=""center"" rowspan=3><b> Средневзвешенная ставка</b></td>"
                 "<td align=""center""> USD </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>9.99')),'.',',') "</td>"
                 "</tr>" skip.
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td align=""center""> KZT </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>9.99')),'.',',') "</td>"
                 "</tr>" skip.
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td align=""center""> EUR </td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>9.99')),'.',',') "</td>"
                 "</tr>" skip.
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Средневзвешенный срок портфеля (дней) </b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "</tr>" skip.


/* гарантии */
find next wrk1.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Выданные гарантии, долл США</b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "</tr>" skip.

find next wrk1.

if day(d1) = 1 then
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Провизии по внебалансовым обязательствам, долл США</b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "</tr>" skip.

find next wrk1.

if day(d1) = 1 then
put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td ><b> Доля провизии, % от выданных гарантий  </b></td>"
                 "<td align=""center""></td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s1),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s2),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s3),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s4),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s5),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "<td align=""center"">" replace(trim(string(deci(wrk1.s6),'>>>>>>>>>>>9.99')),'.',',') "</td>"
                 "</tr>" skip.

put stream m-out unformatted "</table></td></tr>" skip.

/* сегментация */
bsum = 0. bnum = 0.
put stream m-out unformatted
                  "<br><br><tr><td>Динамика роста выданных кредитов<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td></td>" skip.
do i = 1 to 6:
  put stream m-out unformatted "<td align=""center"" colspan=""2"">" dates[i] "</td>" skip.
end.

for each wrksegm no-lock break by wrksegm.code by wrksegm.dat desc:

  if first-of(wrksegm.code) then do:
      i = 1.
      put stream m-out unformatted
                 "</tr>" skip
                 "<td>" wrksegm.name "</td>" skip.
  end.
  put stream m-out unformatted
       "<td>" replace(trim(string(wrksegm.sum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td>" wrksegm.num "</td>" skip.
  bsum[i] = bsum[i] + wrksegm.sum.
  bnum[i] = bnum[i] + wrksegm.num.
  i = i + 1.

end. /* for each wrksegm */

put stream m-out unformatted "</tr>" skip.

put stream m-out unformatted
                  "<tr style=""font:bold"">" skip
                  "<td>ИТОГО</td>" skip.
do i = 1 to 6:
  put stream m-out unformatted
      "<td>" replace(trim(string(bsum[i],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td>" bnum[i] "</td>" skip.
end.

put stream m-out unformatted "</tr></table></td></tr>" skip.

/* за период */

bsum = 0. bnum = 0.
put stream m-out unformatted
                  "<br><br><tr><td>Динамика роста выданных кредитов за период<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td></td>" skip.
do i = 1 to 6:
  put stream m-out unformatted "<td align=""center"" colspan=""2"">" dates[i] "</td>" skip.
end.

for each wrkvyd no-lock break by wrkvyd.segm by wrkvyd.datot desc:

  if first-of(wrkvyd.segm) then do:
      i = 1.
      put stream m-out unformatted
                 "</tr>" skip
                 "<td>" wrkvyd.name "</td>" skip.
  end.
  put stream m-out unformatted
       "<td>" replace(trim(string(wrkvyd.sum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
       "<td>" wrkvyd.kol "</td>" skip.
  bsum[i] = bsum[i] + wrkvyd.sum.
  bnum[i] = bnum[i] + wrkvyd.kol.
  i = i + 1.

end. /* for each wrkvyd */

put stream m-out unformatted "</tr>" skip.

put stream m-out unformatted
                  "<tr style=""font:bold"">" skip
                  "<td>ИТОГО</td>" skip.
do i = 1 to 6:
  put stream m-out unformatted
      "<td>" replace(trim(string(bsum[i],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
      "<td>" bnum[i] "</td>" skip.
end.

put stream m-out unformatted "</tr></table></td></tr>" skip.


def var bb as deci extent 2.
bb[1] = kred_sum[1] + kred_sum[2] * rates_d[1] + kred_sum[3] * rates_d[2] + kred_sum[7] + kred_sum[8] * rates_d[1] + kred_sum[9] * rates_d[2].
bb[2] = kred_sum[4] + kred_sum[5] * rates_d[1] + kred_sum[6] * rates_d[2] + kred_sum[10] + kred_sum[11] * rates_d[1] + kred_sum[12] * rates_d[2].

put stream m-out unformatted
     "<br><br><br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" crlf
     "<tr style=""font:bold"">"
     "<td bgcolor=""#C0C0C0"" align=""center""></td>"
     "<td bgcolor=""#C0C0C0"" align=""center"">Валюта кредита</td>"
     "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во кредитов</td>"
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
     "<td bgcolor=""#C0C0C0"" align=""center"">Сумма в KZT</td>"
     "<td bgcolor=""#C0C0C0"" align=""center"">Доля в портфеле</td></tr>" skip.

if (v-sel = 2) or (v-sel = 4) then do:
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td rowspan=3><b> Краткосрочные кредиты юридических лиц</b></td>"
     "<td align=""center""><b> KZT</b></td>"
     "<td align=""center""><b>" kred_kol[1] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[1] / svalt * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> USD</b></td>"
     "<td align=""center""><b>" kred_kol[2] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[2] * rates_d[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[2] / svald * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> EUR</b></td>"
     "<td align=""center""><b>" kred_kol[3] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[3],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[3] * rates_d[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[3] / svale * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td rowspan=3><b> Долгосрочные кредиты юридических лиц</b></td>"
     "<td align=""center""><b> KZT</b></td>"
     "<td align=""center""><b>" kred_kol[7] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[7],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[7],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[7] / svalt * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> USD</b></td>"
     "<td align=""center""><b>" kred_kol[8] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[8],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[8] * rates_d[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[8] / svald * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> EUR</b></td>"
     "<td align=""center""><b>" kred_kol[9] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[9],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[9] * rates_d[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[9] / svale * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr></table>" skip.
  put stream m-out unformatted
     "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
     "<tr style=""font:bold"">"
     "<td></td><td></td><td></td><td></td>"
     "<td align=""right"">" replace(trim(string(bb[1],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
     "</table>"
     "</tr>" skip.
end.

if (v-sel = 1) or (v-sel = 3) or (v-sel = 4) then do:
  put stream m-out unformatted
     "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
     "<tr align=""left"">"
     "<td rowspan=3><b> Краткосрочные кредиты физических лиц</b></td>"
     "<td align=""center""><b> KZT</b></td>"
     "<td align=""center""><b>" kred_kol[4] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[4],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[4],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[4] / svalt * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> USD</b></td>"
     "<td align=""center""><b>" kred_kol[5] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[5],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[5] * rates_d[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[5] / svald * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> EUR</b></td>"
     "<td align=""center""><b>" kred_kol[6] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[6],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[6] * rates_d[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[6] / svale * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td rowspan=3><b> Долгосрочные кредиты физических лиц</b></td>"
     "<td align=""center""><b> KZT</b></td>"
     "<td align=""center""><b>" kred_kol[10] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[10],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[10],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[10] / svalt * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> USD</b></td>"
     "<td align=""center""><b>" kred_kol[11] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[11],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[11] * rates_d[1],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[11] / svald * 100,'>>9.99')),'.',',') "</i></td> "
     "</tr>" skip.
  put stream m-out unformatted
     "<br><tr align=""left"">"
     "<td align=""center""><b> EUR</b></td>"
     "<td align=""center""><b>" kred_kol[12] "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[12],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><b> " replace(trim(string(kred_sum[12] * rates_d[2],'>>>>>>>>>>>9.99')),'.',',') "</b></td>"
     "<td align=""right""><i> " replace(trim(string(kred_sum[12] / svale * 100,'>>9.99')),'.',',') "</i></td> "
     "</table>" skip.
  put stream m-out unformatted
     "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
     "<tr style=""font:bold"">"
     "<td></td><td></td><td></td><td></td>"
     "<td align=""right"">" replace(trim(string(bb[2],'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
     "</table>"
     "</tr>" skip.
end.

put stream m-out unformatted "</body></html>" .
output stream m-out close.

hide message no-pause.

unix silent cptwin rpt.html excel.
