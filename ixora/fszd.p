/* fszd.p
 * MODULE
        СБ
 * DESCRIPTION
        Отчет FS_ЗД "Банковские займы по виду обеспечения"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.8.2.12
 * AUTHOR
        01/11/2011 dmitriy
 * BASES
        BANK COMM
 * CHANGES
        05/03/2012 dmitriy - дата по умолчанию равна первому числу месяца
*/

{global.i}
def new shared var s-dat as date no-undo format '99/99/9999'.
def new shared var txbname as char.

def var i as integer init 1.

def var res as deci extent 8.
def var rescrc as deci extent 8.
def var nonres as deci extent 8.
def var nonrescrc as deci extent 8.

def new shared temp-table wrk
    field branch as integer
    field k2res as deci
    field k2rescrc as deci
    field k2nonres as deci
    field k2nonrescrc as deci

    field k3res as deci
    field k3rescrc as deci
    field k3nonres as deci
    field k3nonrescrc as deci

    field k4res as deci
    field k4rescrc as deci
    field k4nonres as deci
    field k4nonrescrc as deci

    field k5res as deci
    field k5rescrc as deci
    field k5nonres as deci
    field k5nonrescrc as deci

    field k6res as deci
    field k6rescrc as deci
    field k6nonres as deci
    field k6nonrescrc as deci.

def var loan as char extent 9.
    loan[1] = "Банковские займы  (под залог недвижимости)".
    loan[2] = "Банковские займы под залог вклада, в том числе:".
    loan[3] = "     банковские займы под залог вклада, предоставленные по кредитным карточкам".
    loan[4] = "Банковские займы, предоставленные под гарантию и (или)  поручительство,  в том числе: ".
    loan[5] = "     гарантии Правительства Республики Казахстан".
    loan[6] = "Банковские займы под другое обеспечение".
    loan[7] = "Многозалоговые ".
    loan[8] = "Бланковые ".
    loan[9] = "Итого займов".


s-dat = date(month(today), 1, year(today)).
update s-dat label ' Дата ' format '99/99/9999' with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "fszd-2"}

  define stream m-out.
  output stream m-out to fszd.html.

  put stream m-out "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

  put stream m-out "<table
                     border=""0""
                     cellpadding=""0""
                     cellspacing=""0""
                     style=""border-collapse: collapse""
                   >"
                 skip.

  put stream m-out "<tr align=""right""><td>Приложение 4 к Правилам" "<br>"
                   "представления отчетности банками" "<br>"
                   "второго уровня Республики Казахстан"

                   "</td></tr><br><br>"
                 skip(2).

  put stream m-out  unformatted "<tr align=""center""><td>Банковские займы по виду обеспечения" "<br>"
                    v-bankname "<br>"
                   "по состоянию на " s-dat format "99.99.9999"

                   "</td></tr><br><br>"
                 skip(2).
  put stream m-out "<br><br><tr></tr>".


  put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse" ">" skip
                  "<tr style=""font:bold" "" ">"
                  "<td rowspan=""2"" colspan=""2"" valign=""top"" align=""center"">Банковские займы</td>"
                  "<td colspan=""2""  align=""center"">Банковские займы резидентам" "<br>" " Республики Казахстан" "</td>"
                  "<td colspan=""2""  align=""center"">Банковские займы нерезидентам" "<br>" "Республики Казахстан" "</td>"
                  "<td colspan=""2""  valign=""top"" align=""center"">Всего</td>"
                  "</tr>"

                  "<td  valign=""top"" align=""center"">Всего</td>"
                  "<td  align=""center"">Из них в " "<br>" "иностранной" "<br>" "валюте" "</td>"
                  "<td  valign=""top"" align=""center"">Всего</td>"
                  "<td  align=""center"">Из них в " "<br>" "иностранной" "<br>" "валюте" "</td>"
                  "<td  valign=""top"" align=""center"">Всего</td>"
                  "<td  align=""center"">Из них в " "<br>" "иностранной" "<br>" "валюте" "</td>"
                  "</tr>"

                  "<td  colspan=""2""  align=""center"">А</td>"
                  "<td  align=""center"">1</td>"
                  "<td  align=""center"">2</td>"
                  "<td  align=""center"">3</td>"
                  "<td  align=""center"">4</td>"
                  "<td  align=""center"">5</td>"
                  "<td  align=""center"">6</td>"
                  "</tr>".

for each wrk no-lock:
    res[1] = res[1] + wrk.k2res.
    rescrc[1] = rescrc[1] + wrk.k2rescrc.
    nonres[1] = nonres[1] + wrk.k2nonres.
    nonrescrc[1] = nonrescrc[1] + wrk.k2nonrescrc.

    res[2] = res[2] + wrk.k3res.
    rescrc[2] = rescrc[2] + wrk.k3rescrc.
    nonres[2] = nonres[2] + wrk.k3nonres.
    nonrescrc[2] = nonrescrc[2] + wrk.k3nonrescrc.

    res[3] = 0.
    rescrc[3] = 0.
    nonres[3] = 0.
    nonrescrc[3] = 0.

    res[4] = res[4] + wrk.k6res.
    rescrc[4] = rescrc[4] + wrk.k6rescrc.
    nonres[4] = nonres[4] + wrk.k6nonres.
    nonrescrc[4] = nonrescrc[4] + wrk.k6nonrescrc.

    res[5] = 0.
    rescrc[5] = 0.
    nonres[5] = 0.
    nonrescrc[5] = 0.

    res[6] = res[6] + wrk.k4res.
    rescrc[6] = rescrc[6] + wrk.k4rescrc.
    nonres[6] = nonres[6] + wrk.k4nonres.
    nonrescrc[6] = nonrescrc[6] + wrk.k4nonrescrc.

    res[7] = 0.
    rescrc[7] = 0.
    nonres[7] = 0.
    nonrescrc[7] = 0.

    res[8] = res[8] + wrk.k5res.
    rescrc[8] = rescrc[8] + wrk.k5rescrc.
    nonres[8] = nonres[8] + wrk.k5nonres.
    nonrescrc[8] = nonrescrc[8] + wrk.k5nonrescrc.



end.

do i = 1 to 8:
         put stream m-out unformatted "<tr align=""right"" valign=""top"">"
                       "<td width=""110%"" align=""center"">" i "</td>"
                       "<td width=""100%"" align=""center"">" loan[i] "</td>"
                       "<td align=""right"">" res[i] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" rescrc[i] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" nonres[i] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" nonrescrc[i] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" res[i] + nonres[i] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" rescrc[i] + nonrescrc[i] format ">>>>>>>>>>>9.99" "</td>"
                       "</tr>" skip.
end.

         put stream m-out unformatted "<tr align=""right"" valign=""top"">"
                       "<td width=""110%"" align=""center"">9</td>"
                       "<td width=""100%"" align=""center"">" loan[9] "</td>"
                       "<td align=""right"">" res[1] + res[2] + res[3] + res[4] + res[5] + res[6] + res[7] + res[8] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" rescrc[1] + rescrc[2] + rescrc[3] + rescrc[4] + rescrc[5] + rescrc[6] + rescrc[7] + rescrc[8] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" nonres[1] + nonres[2] + nonres[3] + nonres[4] + nonres[5] + nonres[6] + nonres[7] + nonres[8] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" nonrescrc[1] + nonrescrc[2] + nonrescrc[3] + nonrescrc[4] + nonrescrc[5] + nonrescrc[6] + nonrescrc[7] + nonrescrc[8] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" res[1] + res[2] + res[3] + res[4] + res[5] + res[6] + res[7] + res[8] +
                                              nonres[1] + nonres[2] + nonres[3] + nonres[4] + nonres[5] + nonres[6] + nonres[7] + nonres[8] format ">>>>>>>>>>>9.99" "</td>"
                       "<td align=""right"">" rescrc[1] + rescrc[2] + rescrc[3] + rescrc[4] + rescrc[5] + rescrc[6] + rescrc[7] + rescrc[8] +
                                              nonrescrc[1] + nonrescrc[2] + nonrescrc[3] + nonrescrc[4] + nonrescrc[5] + nonrescrc[6] + nonrescrc[7] + nonrescrc[8] format ">>>>>>>>>>>9.99" "</td>"
                       "</tr>" skip.

 put stream m-out "</table>" skip.


 put stream m-out unformatted "<tr align=""left"" "">"
               "<td align=""left"">Председатель банка
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                Андроникашвили Г."  " <br><br></td>"
               "></tr>".
 put stream m-out unformatted "<tr align=""left"" "">"
               "<td align=""left"">Главный бухгалтер
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
               &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                Есбаева Ш.А."  " <br><br></td>"
               "</tr>".
 put stream m-out unformatted "<tr align=""left"" "">"
               "<td align=""left"">Дата подписания отчета &nbsp&nbsp&nbsp " s-dat format "99.99.9999" " <br><br></td>"
               "</tr>".

 put stream m-out "</body></html>" skip.


 output stream m-out close.
 unix silent cptwin fszd.html excel.exe.
 unix silent rm fszd.html.
