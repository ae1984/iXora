/* lnturn.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Динамика оборотов заемщиков в периодах
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
        02/09/2004 madiar
 * CHANGES
        03/09/2004 madiar - при расчете последнего столбца (оборот/остаток кредита) делить не на остаток кредита, а на сумму остатков
                            по всем кредитам клиента
        02/12/2004 madiar - изменения в формате вывода отчета
        02/09/2005 madiar - вывод консолидированно по клиенту
*/

{mainhead.i}

def new shared temp-table wrk
  field bank        as   char
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field crc         like lon.crc
  field ostatok     as   deci
  field rdt         like lon.rdt
  field duedt       like lon.duedt
  field prem        like lon.prem
  field turnover    as   deci extent 6
  index ind is primary bank cif.

def temp-table wrk2
  field bank        as   char
  field cif         like lon.cif
  field ost_sum     as   deci
  index ind is primary bank cif.

def var usrnm as char.
def var dat as date.
def var coun as integer.
def var s-rate as deci.
def var i as integer.
def var bb as deci.
def var mname as char extent 12 init ["январь","февраль","март","апрель","май","июнь","июль","август","сентябрь","октябрь","ноябрь","декабрь"].
def stream rep.

dat = g-today.

update dat label ' На дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "lnturn2 (dat)"}

for each wrk no-lock:
  find first wrk2 where wrk2.bank = wrk.bank and wrk2.cif = wrk.cif no-error.
  if not avail wrk2 then do:
    create wrk2.
    wrk2.bank = wrk.bank.
    wrk2.cif = wrk.cif.
    wrk2.ost_sum = 0.
  end.
  
  s-rate = 0.
  if dat = g-today then do:
    find first crc where crc.crc = wrk.crc no-lock no-error.
    s-rate = crc.rate[1].
  end.
  else do:
    find last crchis where crchis.crc = wrk.crc and crchis.regdt <= dat no-lock no-error.
    s-rate = crchis.rate[1].
  end.
  
  wrk2.ost_sum = wrk2.ost_sum + wrk.ostatok * s-rate.
end. /* for each wrk */

output stream rep to rep.htm.

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
    "<center><b>Динамика оборотов заемщиков - юридических лиц на " dat format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td rowspan=2>пп</td>" skip
    "<td rowspan=2>Код<BR>клиента</td>" skip
    "<td rowspan=2><BR>Наименование клиента</td>" skip
    "<td rowspan=2>Остаток<BR>кредита (KZT)</td>" skip
    "<td colspan=6>Чистые обороты по текущим счетам (KZT)</td>" skip
    "<td rowspan=2>Среднемес<BR>оборот</td>" skip
    "<td rowspan=2>Среднемес. оборот /<BR>Остаток кредита * 100</td>" skip
    "</tr>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip.

do i = 6 to 1 by -1:
   coun = month(dat) - i.
   if coun <= 0 then coun = coun + 12.
   put stream rep unformatted "<td>" mname[coun] "</td>" skip.
end.

put stream rep unformatted "</tr>" skip.
    
   

coun = 1.
for each wrk no-lock break by wrk.bank by wrk.cif:
  
  if first-of(wrk.bank) then put stream rep unformatted "<tr><td colspan=12 bgcolor=""#9BCDFF""><b>" wrk.bank "</b></td></tr>" skip.
  
  if first-of(wrk.cif) then do:
     
     find first wrk2 where wrk2.bank = wrk.bank and wrk2.cif = wrk.cif no-lock no-error.
     
     put stream rep unformatted "<tr>" skip "<td>" coun "</td>" skip.
     find last crchis where crchis.crc = wrk.crc and crchis.regdt < dat no-lock no-error.
     put stream rep unformatted
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.klname "</td>" skip
        "<td>" replace(string(wrk2.ost_sum, "->>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip.
     
     bb = 0.
     do i = 1 to 6:
       put stream rep unformatted "<td>" replace(string(wrk.turnover[i], "->>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip.
       bb = bb + wrk.turnover[i].
     end.
     
     put stream rep unformatted
         "<td>" replace(string(bb / 6, "->>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
         "<td align=""right"">" replace(string(bb / 6 / wrk2.ost_sum * 100, "->>>>>9.99"),'.',',') "%</td>" skip
         "</tr>" skip.
     
     coun = coun + 1.
     
  end.
  
end. /* for each wrk */

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rep.htm excel.

