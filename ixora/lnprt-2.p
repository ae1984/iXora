/* lnprt-2.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
       Построение графика аннуитетной схемы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-1-2 Календари
 * AUTHOR
        04.09.2003 marinav
 * CHANGES
        30/07/2004 madiar - добавил итоговые суммы и убрал текст
        11/03/2005 madiar - по старым записям в графике - реально погашенные суммы
        13/08/2010 aigul - изменила шрифт и тип вывода цифр
        11.03.2011 aigul - в связи сдвигами для праздников изменила вычисление последней даты
        21.04.2011 aigul - исправила подсчет процентов для произвольной суммы
*/

{global.i}

/*def var AtlSum like lnsch.stval.
def var begsum like lnsch.stval.
def var begsumN like lnsch.stval.*/

def var sum1 as deci.
def var sum2 as deci.
define variable dn1 as integer.
define variable dn2 as decimal.
define var prevdt as date.
define var t_od as deci.
define var t_proc as deci.
def shared var v-sum3 as decimal.
def temp-table  wrk
    field nn     as integer
    field days   as integer
    field stdat  as date
    field begs   as deci
    field od     as deci
    field proc   as deci
    field ends   as deci.
def var i as int.
def shared var s-lon like lnsch.lnn.
def shared var v-pdt as date.

find first lon where lon.lon = s-lon no-lock.
/*begsum = lon.opnamt.
begsumN = begsum.*/
for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock:
    i = i + 1.
    if lnsci.f0 = 1 then prevdt = lon.rdt.

    create wrk.
    wrk.nn    = lnsci.f0.
    wrk.stdat = lnsci.idat.

    /*  run atl-dat1(s-lon, wrk.stdat - 1, 3, output AtlSum).
      if begsum <> AtlSum then assign begsumN = AtlSum begsum = AtlSum.
     */
    if v-sum3 <> 0 then do:
         find first lnscg where lnscg.lng = lon.lon and lnscg.f0 > - 1 and lnscg.fpn = 0 and lnscg.flp > 0 no-lock no-error.
         if avail lnscg then wrk.begs = lnscg.paid.

        /*if i = 1 then wrk.begs = lon.opnamt.*/
        if lnsci.idat = v-pdt then wrk.begs = v-sum3.
        if lnsci.idat <> v-pdt and i <> 1 then wrk.begs = sum2.


    end.
    if v-sum3 = 0 then do:
        if prevdt = lon.rdt then sum1 = lon.opnamt.
        else sum1 = sum2.
        wrk.begs = sum1.
    end.
    find first lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 and
               lnsch.stdat = lnsci.idat no-lock no-error.
    if avail lnsch then  wrk.od = lnsch.stval.

    /*if lnsci.idat < g-today then do:
      run lonbalcrc('lon',lon.lon,lnsci.idat,"1,7",yes,lon.crc,output sum2).
      wrk.od = sum1 - sum2.
    end.
    else do:
      if prevdt < g-today then do:
        for each lnsch where lnsch.lnn = s-lon and lnsch.flp > 0 and lnsch.stdat > prevdt and lnsch.stdat < g-today no-lock:
          wrk.od = wrk.od +*/ /*lnsch.paid*/ /*lnsch.stval.
        end.
      end.
      sum2 = wrk.begs - wrk.od.
    end.*/
    sum2 = wrk.begs - wrk.od.

    wrk.proc = lnsci.iv-sc.
    wrk.ends = sum2.

   /* если это первый платеж*/
       run day-360(prevdt,lnsci.idat - 1,360,output dn1,output dn2).
       wrk.days = dn1.
       prevdt = lnsci.idat.

end.

find first cmp no-lock no-error.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"
                 "<STYLE TYPE=""text/css"">" skip

                 "body, H4, H3 ~{margin-top:0pt; margin-bottom:0pt~}" skip
                 "</STYLE></head><body>" skip.

put stream m-out "<table WIDTH=600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse""
style=""font-size:15px; font-family:Times New Roman;"">".
put stream m-out "<tr align=""center""><td><h4>" cmp.name format 'x(79)' "</h4></td></tr>".
put stream m-out "<tr align=""center""><td><h4>Приложение N 1</h4></td></tr>".

find first cif where cif.cif = lon.cif no-lock no-error.

put stream m-out "<tr align=""center""><td><br><br><h4> ГРАФИК ПЛАТЕЖЕЙ</h4><br><br></td></tr>".
put stream m-out "<tr align=""left""><td><h4> ФИО заемщика     : " cif.name format 'x(60)' "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Сумма кредита    : " lon.opnamt format '>>>,>>>,>>9.99' " </h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Процентная ставка: " lon.prem format ">9.99%" "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Дата выдачи кредита : " lon.rdt "</h4></td></tr>".
put stream m-out "<tr align=""left""><td><h4> Дата погашения кредита : " lon.duedt "</h4></td></tr>".

       put stream m-out "<tr><td><table width=""100%""border=""1"" cellpadding=""0"" cellspacing=""0""
           style=""font-size:16px; font-family:Times New Roman;"">"
           "<tr align=""center""  bgcolor=""#C0C0C0"" style=""font:bold"">"
           "<td>N<br>платежа</td>"
           "<td>Дата<br>погашения</td>"
           "<td>Кол-во<br>дней<br>поль-<br>зования<br>кредитом</td>"
           "<td>Сумма<br>кредита<br>на начало<br>периода</td>"
           "<td>Основной<br>долг</td>"
           "<td>Проценты</td>"
           "<td>Платеж<br>за период</td>"
           "<td>Сумма<br>кредита<br>на конец<br>периода</td></tr>" skip.

t_od = 0. t_proc = 0.
for each wrk .
       put stream m-out unformatted "<tr align=""right"" style=""font-size:16px; font-family:Times New Roman;"">"
               "<td>~&nbsp~;" wrk.nn format '>>>9' "~&nbsp~;</td>"
               "<td align=""center"">" wrk.stdat "</td>"
               "<td>" wrk.days format '>>>9' "</td>"
               "<td>" replace(replace(trim(string(wrk.begs, "->>>,>>>,>>>,>>9.99")),","," "),".",",") "</td>"
               "<td>" replace(replace(trim(string(wrk.od, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
               "<td>" replace(replace(trim(string(wrk.proc, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
               "<td>" replace(replace(trim(string(wrk.od + wrk.proc, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
               "<td>" replace(replace(trim(string(wrk.ends, "->>>,>>>,>>>,>>9.99")),","," "),".",",") "</td></tr>" skip.
       t_od = t_od + wrk.od.
       t_proc = t_proc + wrk.proc.
end.

put stream m-out unformatted
       "<tr align=""right"" style=""font:bold"" style=""font-size:16px; font-family:Times New Roman;"">"
       "<td colspan=""4"" align=""left"">ИТОГО</td>"
       "<td>" replace(replace(trim(string(t_od, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td>" replace(replace(trim(string(t_proc, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td>" replace(replace(trim(string(t_od + t_proc, "->>>,>>>,>>>,>>9.99")),","," "),".",",")  "</td>"
       "<td></td></tr>" skip.

put stream m-out "</font></table></tr>".

put stream m-out "</table></body></html>".


output stream m-out close.

unix silent cptwin rpt.html excel.


