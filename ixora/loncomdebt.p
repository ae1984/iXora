/*loncomdebt.p
 * MODULE
       Кредиты 
 * DESCRIPTION
        Задолженность по комиссии за ведение счета по рефинансированным и конвертированным кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        13/03/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        18/03/2009 galina - перекомпиляция
        19/03/2009 galina - перекомпиляция
*/
{global.i}

def new shared temp-table t-com
  field cif like lon.cif
  field name as char
  field crc like crc.code
  field com as deci
  field com_kzt as deci
  field lon like lon.lon
  field lontype as char
  field city as char.

def stream m-out. 
def var i as integer.


{r-brfilial.i &proc = "loncomdebt_txb (g-today,txb.bank,txb.info)"}

output stream m-out to loncomdebt.html.
{html-title.i
 &title = "Metrocombank" 
 &stream = "stream m-out" 
 &size-add = "x-"}

put stream m-out unformatted
 "<p align = ""center""><FONT size=""2"" face=""Arial""><b> Задолженность по комиссии за ведение счета за "  string(g-today,'99/99/9999')  "</b></fotxb.nt></p>" skip.
put stream m-out unformatted
  "<TABLE border=""1"" cellpadding=""10"" cellspacing=""0"">" skip.


put stream m-out unformatted
  "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
  "<td>№</td>" skip
  "<td>Код<br>клиента</td>" skip
  "<td>Наименование заемщика</td>" skip
  "<td>Валюта<br> кредита</td>" skip
  "<td>Задол-ть по<br>ком.<br>за вед.<br>счета в<br>тенге</td>" skip
  "<td>Задол-ть по<br>ком.<br>за вед. счета в<br>валюте<br>кредита</td>" skip
  "<td>Ссудный счет</td>" skip
  "<td>Вид кредита</td>" skip
  "<td>Регион</td></tr>" skip.

i= 0.
for each t-com no-lock:
  i = i + 1.
  put stream m-out unformatted
  "<TR align=""center"" valign=""center"">" skip
  "<td>"  i "</td>" skip
  "<td>" t-com.cif "</td>" skip
  "<td>" t-com.name  "</td>" skip
  "<td>" t-com.crc  "</td>" skip
  "<td>" replace(trim(string(t-com.com_kzt,'>>>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
  "<td>" replace(trim(string(t-com.com,'>>>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip
  "<td>" t-com.lon "</td>" skip
  "<td>" t-com.lontype "</td>" skip
  "<td>" t-com.city "</td></tr>" skip.
end.

put stream m-out unformatted "</table>" skip.


{html-end.i "stream m-out"}

output stream m-out close.

unix silent cptwin loncomdebt.html excel.
unix silent rm -f  loncomdebt.html.