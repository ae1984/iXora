/* lnloss.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Отчет - расшифровка счетов 713014 и 713040 (13 и 14 уровни lon - од и %%, списанные в убыток)
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
        05/10/2004 madiar
 * CHANGES
        18/10/2004 madiar - добавил колонку "Сумма на тек. счете"
        01/12/2004 madiar - добавил 2 колонки по списанным штрафам
        28/02/2005 madiar - вынес расчетную часть в lnloss2.p
        22/04/2005 madiar - вместо lon.gua - программа кредитования (сегмент)
*/

{mainhead.i}

def new shared temp-table wrk
  field bank        as   char
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field crc         like lon.crc
  field sdtod       as   date init ?
  field sumod       as   deci
  field sumodkzt    as   deci
  field sdtprc      as   date init ?
  field sumprc      as   deci
  field sumprckzt   as   deci
  field sdtpen      as   date init ?
  field sumpen      as   deci
  field curacc      as   deci
  field segm        as   char   
  index ind is primary bank cif.

def var itogod as deci.
def var itogprc as deci.
def var itogpen as deci.
def var usrnm as char.
def stream rep.

def var dat as date.
dat = g-today.
update dat label ' Отчет на дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.

message " Формируется отчет ... ".

{r-brfilial.i &proc = "lnloss2(dat)"}

output stream rep to lnloss.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Долги, вознаграждение и штрафы, списанные в убыток (счета 713014, 713040, 713060)<BR>на " dat format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Код клиента</td>" skip
    "<td>Наименование клиента</td>" skip
    "<td>Ссудный счет</td>" skip
    "<td>Валюта</td>" skip
    "<td>Дата спис ОД</td>" skip
    "<td>Сумма спис ОД</td>" skip
    "<td>Сумма спис ОД (KZT)</td>" skip
    "<td>Дата спис %%</td>" skip
    "<td>Сумма спис %%</td>" skip
    "<td>Сумма спис %% (KZT)</td>" skip
    "<td>Дата спис штрафов</td>" skip
    "<td>Сумма спис штрафов</td>" skip
    "<td>Сумма на тек. счете</td>" skip
    "<td>Вид займа</td>" skip
    "</tr>" skip.

itogod = 0. itogprc = 0. itogpen = 0.
for each wrk no-lock break by wrk.bank by wrk.cif:
  
  find crc where crc.crc = wrk.crc no-lock.
  put stream rep unformatted
    "<tr>" skip
    "<td>" if first-of(wrk.cif) then wrk.cif else "" "</td>" skip
    "<td>" if first-of(wrk.cif) then wrk.klname else "" "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" crc.code "</td>" skip
    "<td>" wrk.sdtod format "99/99/9999" "</td>" skip
    "<td>" replace(string(wrk.sumod,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sumodkzt,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" wrk.sdtprc format "99/99/9999" "</td>" skip
    "<td>" replace(string(wrk.sumprc,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sumprckzt,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" wrk.sdtpen format "99/99/9999" "</td>" skip
    "<td>" replace(string(wrk.sumpen,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.curacc,"->>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" wrk.segm "</td>" skip
    "</tr>" skip.
  
  itogod = itogod + wrk.sumodkzt.
  itogprc = itogprc + wrk.sumprckzt.
  itogpen = itogpen + wrk.sumpen.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td></td>"
    "<td colspan=2>ИТОГО</td>" skip
    "<td></td><td></td><td></td>" skip
    "<td>" replace(string(itogod,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td></td><td></td>" skip
    "<td>" replace(string(itogprc,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td></td>" skip
    "<td>" replace(string(itogpen,">>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td></td><td></td></tr>" skip.

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin lnloss.htm excel.