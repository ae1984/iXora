/* lndyndoh.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Показатели и динамика доходности кредитного портфеля
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
        30/06/2005 madiyar
 * BASES
        bank, comm
 * CHANGES
        05/07/2005 madiyar - формирование массива дат - подправил
        06/07/2005 madiyar - изменения в тексте отчета, подправил расчет доходности
        08/07/2005 madiyar - отчет формируется на 7 дат, для расчета изменения на 6-ую дату
        15/08/2005 madiyar - добавились комиссии
        02/02/2006 madiyar - расчет динамики начисленных процентов - по оборотам по счетам 174010 и 174020; убрал вывод некоторых статей
        03/02/2006 madiyar - расчет динамики полученных процентов и динмики полученных комиссий - также по оборотам
        06/04/2007 madiyar - no-undo
        17/11/2009 galina - изменения согласно ТЗ 579 от 09/11/2009
        25/02/2010 galina - собираем полученные комиссии и %% из проводок
*/

{mainhead.i}

def new shared temp-table wrk no-undo
    field idt      as   integer
    field idr      as   integer
    field rtitle   as   char
    field rval     as   deci extent 7
    index ind is primary idt idr.

def buffer b-wrk for wrk.
def buffer b1-wrk for wrk.

def var dat as date no-undo format '99/99/9999'.
def new shared var dates as date extent 7.
def new shared var port_ur as decimal extent 7.
def new shared var port_fiz as decimal extent 7.
port_ur = 0. port_fiz = 0.
def var usrnm as char no-undo.
def var st_border as char no-undo init "style=""border:.5pt; border:solid;""".
def var ttitle as char no-undo.
def var i as integer no-undo.
def var k as integer no-undo.

dat = g-today.
update dat label ' На дату ' format '99/99/9999' skip with side-label row 5 centered frame dat.

dates[1] = dat.
if day(dat) <> 1 then dates[2] = date(month(dat),1,year(dat)).
else dates[2] = date(month(dates[1] - 1),1,year(dates[1] - 1)).
do i = 3 to 7:
  dates[i] = date(month(dates[i - 1] - 1),1,year(dates[i - 1] - 1)).
end.

message " Формируется отчет...".

do i = 0 to 2:
  create wrk. assign wrk.idt = i wrk.idr = 0 wrk.rtitle = "Кредитный портфель, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 1 wrk.rtitle = "Начисленное вознаграждение на дату, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 2 wrk.rtitle = "Начисленное вознаграждение за период, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 3 wrk.rtitle = "Полученное вознаграждение на дату, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 4 wrk.rtitle = "Полученное вознаграждения за период, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 5 wrk.rtitle = "Комиссия за обслуживание кредита на дату, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 6 wrk.rtitle = "Комиссия за обслуживание кредита за период, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 7 wrk.rtitle = "Начисленная пеня на дату, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 8 wrk.rtitle = "Начисленная пеня за период, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 9 wrk.rtitle = "Полученная пеня на дату, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 10 wrk.rtitle = "Полученная пеня за период, KZT".
  create wrk. assign wrk.idt = i wrk.idr = 11 wrk.rtitle = "Доходность кредитного портфеля без комиссионных доходов (% за период)".
  create wrk. assign wrk.idt = i wrk.idr = 12 wrk.rtitle = "Доходность кредитного портфеля с комиссионными доходами (% за период)".
end.

{r-brfilial.i &proc = "lndyndoh1"}

do k = 0 to 2:
    
    
    find first wrk where wrk.idt = k and wrk.idr = 7.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 8.
    do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] - wrk.rval[i + 1]. end.

    find first wrk where wrk.idt = k and wrk.idr = 9.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 10.
    do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] - wrk.rval[i + 1]. end.
    
    find first wrk where wrk.idt = k and wrk.idr = 3.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 4.
    do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] - wrk.rval[i + 1]. end.


    find first wrk where wrk.idt = k and wrk.idr = 5.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 6.
    do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] - wrk.rval[i + 1]. end.

    find first wrk where wrk.idt = k and wrk.idr = 4.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 11.
    case k:
      when 0 then do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] / (port_ur[i] + port_ur[i + 1]) * 100 * 2. end.
      when 1 then do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] / (port_fiz[i] + port_fiz[i + 1]) * 100 * 2. end.
      when 2 then do i = 1 to 6: b-wrk.rval[i] = wrk.rval[i] / (port_ur[i] + port_fiz[i] + port_ur[i + 1] + port_fiz[i + 1]) * 100 * 2. end.
    end case.
    
    find first wrk where wrk.idt = k and wrk.idr = 4.
    find first b1-wrk where b1-wrk.idt = k and b1-wrk.idr = 6.
    find first b-wrk where b-wrk.idt = k and b-wrk.idr = 12.
    case k:
      when 0 then do i = 1 to 6: b-wrk.rval[i] = (wrk.rval[i] + b1-wrk.rval[i]) / (port_ur[i] + port_ur[i + 1]) * 100 * 2. end.
      when 1 then do i = 1 to 6: b-wrk.rval[i] = (wrk.rval[i] + b1-wrk.rval[i]) / (port_fiz[i] + port_fiz[i + 1]) * 100 * 2. end.
      when 2 then do i = 1 to 6: b-wrk.rval[i] = (wrk.rval[i] + b1-wrk.rval[i]) / (port_ur[i] + port_fiz[i] + port_ur[i + 1] + port_fiz[i + 1]) * 100 * 2. end.
    end case.
    
end. /* do k = 0 to 2 */

/* приводим к тысячам */
/*for each wrk:
  if not(lookup(string(wrk.idr),"13,14")) > 0 then
    do i = 1 to 7:
      wrk.rval[i] = wrk.rval[i] / 1000.
    end.
end.*/

define stream rep.
output stream rep to lndyndoh.htm.

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
    "<center><b>Показатели и динамика доходности кредитного портфеля на " dat format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=0 cellpadding=0 cellspacing=0>" skip.

for each wrk no-lock break by wrk.idt:
  
  if first-of(wrk.idt) then do:
    case wrk.idt:
      when 0 then ttitle = "Юридические лица".
      when 1 then ttitle = "Физические лица".
      when 2 then ttitle = "Всего по Банку/Филиалу".
    end case.
    put stream rep unformatted
       "<tr>" skip
       "<td colspan=7 style=""font:bold"">&nbsp;<br>" ttitle "</td>" skip
       "</tr>" skip
       "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
       "<td " st_border "></td>" skip
       "<td " st_border ">" dates[1] format "99/99/9999" "</td>" skip
       "<td " st_border ">" dates[2] format "99/99/9999" "</td>" skip
       "<td " st_border ">" dates[3] format "99/99/9999" "</td>" skip
       "<td " st_border ">" dates[4] format "99/99/9999" "</td>" skip
       "<td " st_border ">" dates[5] format "99/99/9999" "</td>" skip
       "<td " st_border ">" dates[6] format "99/99/9999" "</td>" skip
       "</tr>" skip.
  end.

  put stream rep unformatted
       "<tr>" skip
       "<td " st_border ">" wrk.rtitle "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[4],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[5],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "<td " st_border ">" replace(trim(string(wrk.rval[6],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
       "</tr>" skip.
  
end.

put stream rep "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin lndyndoh.htm excel.
