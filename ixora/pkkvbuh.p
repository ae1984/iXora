/* pkkvbuh.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Ежеквартальный отчет ДПК в бухгалтерию
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
        26/10/2004 madiar
 * BASES
        bank, comm
 * CHANGES
        12/11/2004 madiar - изменил содержимое колонки "Сумма займа по договору"
*/

{mainhead.i}

def new shared temp-table wrk
  field segm        as   char
  field bank        as   char
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field grp         as   int
  field crc         like lon.crc
  field prem        as   deci
  field rdt         as   date
  field opnamt      as   deci
  field vyd_kzt     as   deci
  field pog_kzt     as   deci
  field nachprc_kzt as   deci
  field polprc_kzt  as   deci
  field prol_kzt    as   deci
  index ind is primary bank segm cif.

def var usrnm as char.
def stream rep.

def var dat1 as date.
def var dat2 as date.
def var coun as integer.
def var v-month as integer.
def var v-year as integer.
def var i as integer.

def var itog_segm as deci extent 5.
def var itog_bank as deci extent 5.
def var itog as deci extent 5.
def var opnamt_crc as deci extent 3.

v-month = month(g-today) - 1.
v-year = year(g-today).
if v-month = 0 then do: v-month = 12. v-year = v-year - 1. end.
dat1 = date(v-month,1,v-year).
dat2 = date(month(g-today),1,year(g-today)) - 1.
update dat1 label ' Отчет с ' format '99/99/9999' validate (dat1 <= g-today, " Дата должна быть не позже текущей! ")
       dat2 label ' по ' format '99/99/9999' validate (dat2 <= g-today, " Дата должна быть не позже текущей! ")
       with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "pkkvbuh2 (dat1,dat2)"}

output stream rep to pkkvbuh_big.htm.

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
    "<BR><b>Подготовил:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по выданным займам с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td><BR><BR>пп</td>" skip
    "<td><BR>Код<BR>клиента</td>" skip
    "<td><BR><BR>Наименование заемщика</td>" skip
    "<td colspan=2><BR>Сумма займа<BR>по договору</td>" skip
    "<td><BR>Выданная сумма<BR>займа, тенге</td>" skip
    "<td>Погашенная сумма<BR>займа, тенге</td>" skip
    "<td>Начисленная сумма<BR>вознаграждения,<BR>тенге</td>" skip
    "<td>Полученная сумма<BR>вознаграждения,<BR>тенге</td>" skip
    "<td>Сумма<BR>пролонгированного<BR>займа, тенге</td>" skip
    "</tr>" skip.

coun = 1.

itog = 0. opnamt_crc = 0.
for each wrk no-lock break by wrk.bank by wrk.segm by wrk.cif:
  
  if first-of(wrk.bank) then do:
     put stream rep unformatted "<tr><td colspan=10 bgcolor=""#9BCDFF""><b>" wrk.bank "</b></td></tr>" skip.
     itog_bank = 0.
  end.
  
  if first-of(wrk.segm) then do:
    find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
    if avail codfr then put stream rep unformatted "<tr><td colspan=10 bgcolor=""#FFD1A4""><b>" codfr.name[1] "</b></td></tr>" skip.
    else put stream rep unformatted "<tr><td colspan=10 bgcolor=""#FFD1A4""><b>--unknown segment--</b></td></tr>" skip.
    itog_segm = 0.
  end.
  
  if wrk.vyd_kzt > 0 then do:
    find crc where crc.crc = wrk.crc no-lock no-error.
    
    if wrk.crc = 1 then opnamt_crc[1] = opnamt_crc[1] + wrk.opnamt.
    if wrk.crc = 2 then opnamt_crc[2] = opnamt_crc[2] + wrk.opnamt.
    if wrk.crc = 11 then opnamt_crc[3] = opnamt_crc[3] + wrk.opnamt.
  end.
  
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.klname "</td>" skip
    "<td>" if wrk.vyd_kzt > 0 then replace(trim(string(wrk.opnamt, ">>>>>>>>>>>>>>9.99")),'.',',') else "" "</td>" skip
    "<td>" if wrk.vyd_kzt > 0 then crc.code else "" "</td>" skip
    "<td>" replace(trim(string(wrk.vyd_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.pog_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.nachprc_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.polprc_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.prol_kzt, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
  coun = coun + 1.
  itog_segm[1] = itog_segm[1] + wrk.vyd_kzt.
  itog_segm[2] = itog_segm[2] + wrk.pog_kzt.
  itog_segm[3] = itog_segm[3] + wrk.nachprc_kzt.
  itog_segm[4] = itog_segm[4] + wrk.polprc_kzt.
  itog_segm[5] = itog_segm[5] + wrk.prol_kzt.
  
  if last-of(wrk.segm) then do:
    find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
    if avail codfr then put stream rep unformatted "<tr><td colspan=5 bgcolor=""#FFD1A4""><b>Итого по сегменту " codfr.name[1] "</b></td>" skip.
    else put stream rep unformatted "<tr><td colspan=10 bgcolor=""#FFD1A4""><b>Итого по сегменту --unknown segment--</b></td>" skip.
    do i = 1 to 5:
      put stream rep unformatted "<td bgcolor=""#FFD1A4""><b>" replace(trim(string(itog_segm[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</b></td>" skip.
      itog_bank[i] = itog_bank[i] + itog_segm[i].
    end.
    put stream rep unformatted "</tr>" skip.
  end.
  
  if last-of(wrk.bank) then do:
    put stream rep unformatted "<tr><td colspan=5 bgcolor=""#9BCDFF""><b>Итого по " wrk.bank "</b></td>" skip.
    do i = 1 to 5:
      put stream rep unformatted "<td bgcolor=""#9BCDFF""><b>" replace(trim(string(itog_bank[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</b></td>" skip.
      itog[i] = itog[i] + itog_bank[i].
    end.
    put stream rep unformatted "</tr>" skip.
  end.
  
end. /* for each wrk */

put stream rep unformatted "<tr><td colspan=5><b>ИТОГО</b></td>" skip.
do i = 1 to 5:
   put stream rep unformatted "<td><b>" replace(trim(string(itog[i], ">>>>>>>>>>>>>>9.99")),'.',',') "</b></td>" skip.
end.
put stream rep unformatted "</tr></table></body></html>" skip.
output stream rep close.

/*----------- теперь короткий отчет ------------*/

output stream rep to pkkvbuh_small.htm.

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
    "<BR><b>Подготовил:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по выданным займам с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td><BR><BR>Наименование заемщика</td>" skip
    "<td colspan=2><BR>Сумма займа<BR>по договору</td>" skip
    "<td><BR>Выданная сумма<BR>займа, тенге</td>" skip
    "<td>Погашенная сумма<BR>займа, тенге</td>" skip
    "<td>Начисленная сумма<BR>вознаграждения,<BR>тенге</td>" skip
    "<td>Полученная сумма<BR>вознаграждения,<BR>тенге</td>" skip
    "<td>Сумма<BR>пролонгированного<BR>займа, тенге</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td>Физические лица</td>" skip
    "<td>" replace(trim(string(opnamt_crc[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>KZT</td>" skip
    "<td>" replace(trim(string(itog_bank[1], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(itog_bank[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(itog_bank[3], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(itog_bank[4], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(itog_bank[5], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(opnamt_crc[2], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>USD</td>"
    "<td></td><td></td><td></td><td></td><td></td></tr>" skip.

put stream rep unformatted
    "<tr>" skip
    "<td></td>" skip
    "<td>" replace(trim(string(opnamt_crc[3], ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>EUR</td>"
    "<td></td><td></td><td></td><td></td><td></td></tr>" skip.

output stream rep close.

unix silent cptwin pkkvbuh_big.htm excel.
unix silent cptwin pkkvbuh_small.htm excel.

