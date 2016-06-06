/* kdexpsp.p
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Список досье филиалов, направленных на рассмотрение в ГБ (к определенному эксперту)
 * RUN
        без параметров
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-7-11-x 
 * AUTHOR
        05/04/2004 madiar
 * CHANGES
    05/09/06   marinav - добавление индексов
        
*/

{mainhead.i}
{comm-txb.i}
define var s-ourbank as char.
s-ourbank = comm-txb().

if s-ourbank <> "TXB00" then return.

def var kdlonsts as char.
def var coun as int.
def var sumkr_usd as deci.
def var dt_str as char.
def stream rep.
def var usrnm as char.

message "Формируется отчет...".

case g-fname:
  when "kdexspkd" then kdlonsts = '25'.
  when "kdexspud" then kdlonsts = '30'.
  when "kdexsprm" then kdlonsts = '33'.
  when "kdexspkk" then kdlonsts = '36'.
  otherwise return.
end case.

output stream rep to kdexpsp.htm.

put stream rep unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE></TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 6" skip
   "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
  "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
  "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
  "<center><font size=+1><b>Список заявок на экспертизу</b></font><BR>" skip.
  
case kdlonsts:
  when '25' then put stream rep unformatted "Кредитный Департамент Головного Банка<BR><BR>" skip.
  when '30' then put stream rep unformatted "Юридический Департамент Головного Банка<BR><BR>" skip.
  when '33' then put stream rep unformatted "Риск-менеджер Головного Банка<BR><BR>" skip.
  when '36' then put stream rep unformatted "Кредитный Комитет Головного Банка<BR><BR>" skip.
end case.

put stream rep unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<col span=8>" skip
  "<tr>" skip
  "<td><center><b>пп</b></center></td>" skip
  "<td><center><b>Код<BR>заемщика</b></center></td>" skip
  "<td><center><b>Наименование заемщика</b></center></td>" skip
  "<td><center><b>Филиал</b><center></td>" skip
  "<td><center><b>Сумма кредита</b></center></td>" skip
  "<td><center><b>Валюта</b></center></td>" skip
  "<td><center><b>Сумма кредита<BR>(USD)</b><center></td>" skip
  "<td><center><b>Дата<BR>поступления</b></center></td>" skip
  "</tr>" skip.

coun = 1.

for each kdlon where kdlon.bank <> "TXB00" and kdlon.sts = kdlonsts no-lock:
  
  find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
  find first txb where txb.bank = kdlon.bank and consolid = yes no-lock no-error.
    
  if kdlon.crc <> 2 then do:
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = kdlon.crc no-lock no-error.
    if avail crchis then sumkr_usd = kdlon.amount * crchis.rate[1].
    find last crchis where crchis.rdt <= kdlon.regdt and crchis.crc = 2 no-lock no-error.
    if avail crchis then sumkr_usd = sumkr_usd / crchis.rate[1].
  end.
  else sumkr_usd = kdlon.amount.
  
  find first crc where crc.crc = kdlon.crc no-lock no-error.
  
  find first kdkrdt where kdkrdt.sumst <= sumkr_usd and kdkrdt.sumend > sumkr_usd no-lock no-error.
  dt_str = "-error-".
  case kdlonsts:
    when '25' then dt_str = string(kdlon.resdat[1]).
    when '30' then do:
                     find first kdaffil where kdaffil.kdcif = kdlon.kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '61' no-lock no-error.
                     if avail kdaffil then dt_str = string(kdaffil.whn).
                   end.
    when '33' then do:
                     find first kdaffil where kdaffil.kdcif = kdlon.kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '60' no-lock no-error.
                     if avail kdaffil then dt_str = string(kdaffil.whn).
                   end.
    when '36' then do:
                     if kdkrdt.daysrm <> 0 then do:
                       find first kdaffil where kdaffil.kdcif = kdlon.kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '31' no-lock no-error.
                       if avail kdaffil then dt_str = string(kdaffil.whn).
                     end.
                     else do:
                       find first kdaffil where kdaffil.kdcif = kdlon.kdcif and kdaffil.kdlon = kdlon.kdlon and kdaffil.code = '60' no-lock no-error.
                       if avail kdaffil then dt_str = string(kdaffil.whn).  
                     end.
                   end.
  end case.
  
  put stream rep unformatted
              "<tr>" skip
              "<td>" coun "</td>" skip
              "<td>" kdlon.kdcif "</td>" skip
              "<td>" kdcif.name "</td>" skip
              "<td>" txb.name "</td>" skip
              "<td>" kdlon.amount "</td>" skip
              "<td>" crc.code "</td>" skip
              "<td>" replace(string(round(sumkr_usd, 2)), '.', ',') "</td>" skip
              "<td>" dt_str "</td>" skip
              "</tr>" skip.
  coun = coun + 1.
  
end. /* for each kdlon */

put stream rep "</table></body></html>" .
output stream rep close.
unix silent cptwin kdexpsp.htm excel.