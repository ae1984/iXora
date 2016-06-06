/* anzayav.p
 * MODULE
        Потребительские Кредиты - Сравнительный анализ обработанных заявок клиентов по программе "Быстрые деньги" за период
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
 * AUTHOR
        07/12/2004 madiyar
 * CHANGES
        10/12/2004 madiyar - подправил вывод итогов
        01/08/2005 madiyar - добавил данных для проверки
        30/03/2006 madiyar - сортировка списка
        30/05/2006 madiyar - в астане тоже разбрасываем по рко-шкам; no-undo
        28/09/2006 madiyar - раскладка по казпочтовым РУПСам
        29/09/2006 madiyar - немножко съехали итоги, подправил
        17/10/2006 madiyar - добавил караганду в список филиалов с рко-шками
        06/04/2007 madiyar - актуализация отчета для МКО
*/

{mainhead.i}

def new shared var anksts as integer no-undo extent 100.
def new shared var txb-rko as char no-undo init "TXB00".

def new shared temp-table wrk no-undo
   field bank as char
   field bankn as char
   field depart as int
   field departn as char
   field accepted as int
   field issued_f as int
   field issued as int extent 2
   field issued_sum as deci extent 2
   field rejected as int
   field disclaimed as int
   field aux as int extent 4
   field kp_point as char
   index main is primary bank depart kp_point.

def stream rep.
output stream rep to anzayav.htm.
def var usrnm as char no-undo.
def var itog as int no-undo extent 6.
def var itogp as int no-undo extent 6.
def var dat1 as date no-undo.
def var dat2 as date no-undo.
def var i as integer no-undo.

dat1 = g-today.
dat2 = g-today.

update dat1 label ' Укажите дату с ' format '99/99/9999' dat2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "anzayav2(dat1,dat2)"}

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
    "<center><b>Сравнительный анализ обработанных заявок клиентов<BR>за период с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Филиал / РКО</td>" skip
    "<td>РУПС</td>" skip
    "<td>Принято к<BR>рассмотрению</td>" skip
    "<td>Выдано из<BR>рассмотренных</td>" skip
    "<td>Выдано</td>" skip
    "<td>Выдано - сумма</td>" skip
    "<td>В т.ч. рассм-х<br>в этом месяце</td>" skip
    "<td>-||- сумма</td>" skip
    "<td>Отказано</td>" skip
    "<td>Не востребовано<BR>клиентом</td>" skip
    "</tr>" skip.

itog = 0.
for each wrk no-lock break by wrk.bank by wrk.depart by wrk.kp_point:
  
  if first-of(wrk.bank) then do:
    put stream rep unformatted "<tr><td colspan=6><b>" wrk.bankn "</b></td></tr>" skip.
    itogp = 0.
  end.
  
  put stream rep unformatted
      "<tr>" skip
      "<td>" wrk.departn "</td>" skip
      "<td>" wrk.kp_point "</td>" skip
      "<td>" wrk.accepted "</td>" skip
      "<td>" wrk.issued_f "</td>" skip
      "<td>" wrk.issued[1] "</td>" skip
      "<td>" replace(trim(string(wrk.issued_sum[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.issued[2] "</td>" skip
      "<td>" replace(trim(string(wrk.issued_sum[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
      "<td>" wrk.rejected "</td>" skip
      "<td>" wrk.disclaimed "</td>" skip
      "</tr>" skip.
  
  itogp[1] = itogp[1] + wrk.accepted.
  itogp[2] = itogp[2] + wrk.issued_f.
  itogp[3] = itogp[3] + wrk.issued[1].
  itogp[4] = itogp[4] + wrk.issued[2].
  itogp[5] = itogp[5] + wrk.rejected.
  itogp[6] = itogp[6] + wrk.disclaimed.
  
  
  
  if last-of(wrk.bank) then do:
    do i = 1 to 6: itog[i] = itog[i] + itogp[i]. end.
    if lookup(wrk.bank,txb-rko) > 0 then do:
      put stream rep unformatted
           "<tr style=""font:bold"">" skip
           "<td>Всего по " wrk.bankn "</td>" skip
           "<td></td>" skip
           "<td>" itogp[1] "</td>" skip
           "<td>" itogp[2] "</td>" skip
           "<td>" itogp[3] "</td>" skip
           "<td></td>" skip
           "<td>" itogp[4] "</td>" skip
           "<td></td>" skip
           "<td>" itogp[5] "</td>" skip
           "<td>" itogp[6] "</td>" skip
           "</tr>" skip.
    end.
  end.
  
end. /* for each wrk */

put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td>ИТОГО</td>" skip
    "<td></td>" skip
    "<td>" itog[1] "</td>" skip
    "<td>" itog[2] "</td>" skip
    "<td>" itog[3] "</td>" skip
    "<td></td>" skip
    "<td>" itog[4] "</td>" skip
    "<td></td>" skip
    "<td>" itog[5] "</td>" skip
    "<td>" itog[6] "</td>" skip
    "</tr>" skip.

put stream rep unformatted "</table><br>" skip.

do i = 1 to 100:
  if anksts[i] <> 0 then
    put stream rep unformatted "&nbsp;" string(i - 1,"99") " - " anksts[i] "<br>" skip.
end.

put stream rep unformatted "</body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin anzayav.htm excel.

