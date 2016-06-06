/* lnfutur.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Будущие платежи по кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        4-4-3-8 
 * AUTHOR
        07/10/03 marinav
 * CHANGES
        27/04/2004 valery добавил выбор валюты
        07/02/2005 madiyar полностью переделал расчет прогнозных платежей
        08/02/2005 madiyar еще раз переделал расчет прогнозных платежей
        05/05/2005 madiyar выплата по % > 3,000,000 тенге - отдельная запись
        02/06/2005 madiyar исправил ошибку в логике
        09/12/2009 galina - вынесла в отдельную программу lnfutur1.p сбор данных
                            добавила выбор формирования консолидированного отчета или на филиал
        27/01/2011 madiyar - разбивка розница, МСБ, корпоративные
*/

def shared var g-today as date.
def var coun as int init 1.
define variable dat1  as date format '99/99/9999' label 'С'.
define variable dat2  as date format '99/99/9999' label 'по'.
define variable bil1 as decimal format '->,>>>,>>>,>>9.99' init 0.
define variable bil2 as decimal format '->,>>>,>>>,>>9.99' init 0.


def var v-crc like crc.crc.

DEFINE FRAME main-frame
   v-crc help " F2 - выбор валюты или 0 чтобы сформировать общий в тенге"  WITH row 2 centered no-labels TITLE "Укажите валюту" .

update v-crc validate(can-find(crc where crc.crc eq v-crc) or v-crc = 0, 
                        "Валюта с таким кодом не найдена") with frame main-frame.

def var v-month as int.
def var v-year as int.
dat1 = g-today + 1.
v-month = month(g-today) + 1.
v-year = year(g-today).
if v-month = 13 then do: v-month = 1. v-year = year(g-today) + 1. end.
dat2 = date(v-month,1,v-year) - 1.

def new shared var s-reptype as integer no-undo.
s-reptype = 0.

update dat1 label ' Укажите дату c ' format '99/99/9999' validate (dat1 > g-today, "Дата должна быть больше текущей") 
       dat2 format '99/99/9999' validate (dat2 >= dat1, "Дата должна быть больше первоначальной") ' ' skip
       s-reptype label ' Вид отчета ' format '9' validate(s-reptype >= 0 and s-reptype <= 3, "Некорректный тип отчета!") help "0-Все 1-Розница 2-МСБ 3-Корп" skip
       with side-label row 5 centered frame dat .

def new shared temp-table wrk
    field dt    like lon.rdt
    field cif   like cif.cif
    field name  like cif.name
    field mon   as inte
    field yer   as inte
    field od    as deci
    field prc   as deci
    index dt dt cif.

def temp-table wrk2
    field dt    like lon.rdt
    field od    as deci
    index dt dt.


{r-brfilial.i &proc = "lnfutur1(dat1,dat2,v-crc)"}



find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">" skip.

put stream m-out "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr><br><br>" skip.

put stream m-out "<tr align=""center""><td><h3>Будущие платежи клиентов с " string(dat1) " по " string(dat2)
                 "</h3></td></tr><br><br>" skip.

find crc where crc.crc = v-crc no-lock no-error.
if  avail crc then do:
	put stream m-out "<tr align=""center""><td><h3>" crc.des "</h3></td></tr><br><br>" skip.
end.


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма процентов</td>"
                  "</tr>" skip.

for each wrk break by wrk.yer by wrk.mon by wrk.dt by wrk.name.

     if wrk.cif = '' then do:
            put stream m-out unformatted "<tr><td align=""left""> " wrk.dt "</td>"
               "<td> " replace(trim(string(wrk.od, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.prc, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "</tr>" skip.
     end.
     else do:
          put stream m-out unformatted "<tr style=""font-size:12px""><td align=""left""><I> " wrk.name format 'x(60)' "</I></td>"
               "<td><I> " replace(trim(string(wrk.od, "->>>>>>>>>>>9.99")),".",",") "</I></td>"
               "<td><I> " replace(trim(string(wrk.prc, "->>>>>>>>>>>9.99")),".",",") "</I></td>"
               "</tr>" skip.
     end.

     if wrk.cif = '' then do:
        accumulate wrk.od (TOTAL by wrk.yer by wrk.mon).
        accumulate wrk.prc (TOTAL by wrk.yer by wrk.mon).
     end. 

    if last-of (wrk.mon) then
    do:
       bil1 = ACCUMulate total  by (wrk.mon) wrk.od.   
       bil2 = ACCUMulate total  by (wrk.mon) wrk.prc.   
       put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                "<td align=""center""> ИТОГО ПО  " wrk.mon "</td>"
                "<td > " replace(trim(string(bil1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(bil2, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "</tr>" skip.
    end.
    if last-of (wrk.yer) then
    do:
       bil1 = ACCUMulate total  by (wrk.yer) wrk.od.   
       bil2 = ACCUMulate total  by (wrk.yer) wrk.prc.   
       put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                "<td align=""center""> ИТОГО ПО  " wrk.yer "</td>"
                "<td > " replace(trim(string(bil1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(bil2, "->>>>>>>>>>>9.99")),".",",") "</td>"
                "</tr>" skip.
    end.

end.                       

put stream m-out "</table>" .
output stream m-out close.

unix silent cptwin rpt.html excel.

