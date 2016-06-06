/* pkanlz%.p
 * MODULE
        Потребит кредиты
 * DESCRIPTION
        Полученные проценты за период по каждому виду кредита
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
        31/12/99 pragma
 * CHANGES
        15.01.04 marinav - добавлена полученная комиссия
        11/09/06 marinav - перестроено условие for each lnsci  под индекс
  
*/


/*pkanlz%.p  Потреб кредиты
            
              Полученные проценты за период времени с разбивкой по месяцам

  16.07.03  marinav */


{global.i}
{pk.i "new"}

def var coun as int init 1.
define variable datums  as date format '99/99/9999'.
define variable datums1  as date format '99/99/9999'.
define variable v-dat  as date format '99/99/9999'.
define variable v-dat0  as date format '99/99/9999'.
define var v-sum as deci. 
define var v-amt as deci. 
define var v-sumcr as deci. 
define var v-sumcr% as deci. 
def var vyear as inte.
def var vmonth as inte.
def var vday as inte.
def temp-table  wrk
    field name    as char
    field v-dat   as date
    field v-sum   as deci
    field v-sumcom   as deci.

datums = g-today.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

  v-dat0 = datums.

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to repday.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 skip. 


put stream m-out "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out "<tr align=""center""><td><h3>Сведения о полученных процентах " skip
                 " с " string(datums) 
                 " по " string(datums1) 
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out "<tr></tr><tr></tr>"
                 skip(1).


repeat:
  vyear = year(v-dat0). 
  vmonth = month(v-dat0) + 1. 
  vday = 1.
  if vmonth = 13 then do: 
     vmonth = 1. vyear = vyear + 1. 
  end.
  v-dat = date(vmonth,vday,vyear).
  if v-dat > datums1 then v-dat = datums1.

for each pkanketa no-lock where pkanketa.bank = s-ourbank and 
         pkanketa.lon ne '' 
         break by pkanketa.credtype.


   if first-of (pkanketa.credtype) then do:
     find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
     v-sumcr = 0.
     v-sumcr% = 0.
   end.
                                                                          
   for each lnsci where lnsci.lni = pkanketa.lon and lnsci.f0 = 0 and lnsci.idat >= v-dat0 and lnsci.idat < v-dat no-lock:
          find last crchis where crchis.crc = pkanketa.crc and crchis.regdt <= lnsci.idat no-lock no-error.
          v-sumcr = v-sumcr + lnsci.paid-iv * crchis.rate[1].
   end.

   if pkanketa.docdt >= v-dat0 and pkanketa.docdt < v-dat then v-sumcr% = v-sumcr% + pkanketa.sumcom.
   

   if last-of (pkanketa.credtype) then do:
      create wrk.
      wrk.name = bookcod.name.
      wrk.v-dat = v-dat.
      wrk.v-sum = v-sumcr. 
      wrk.v-sumcom = v-sumcr%. 
   end.

end.                       

  if v-dat = datums1 then leave.
  v-dat0 = v-dat.
end.


/*шапка*/

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
               "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2> Вид кредита</td>".

for each wrk break by wrk.v-dat.

  if first-of (wrk.v-dat) then 
    put stream m-out 
               "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2> " wrk.v-dat "</td>".

end.
put stream m-out "</tr>" skip.

put stream m-out "<tr style=""font:bold"">".
for each wrk break by wrk.v-dat.
if first-of (wrk.v-dat) then 
put stream m-out 
               "<td bgcolor=""#C0C0C0"" align=""center"" > Проценты</td>"
               "<td bgcolor=""#C0C0C0"" align=""center"" > Комиссия</td>".
end.
put stream m-out "</tr>" skip.

/**Данные***/

for each wrk break by wrk.name by wrk.v-dat.

if first-of (wrk.name) then
put stream m-out "<tr align=""right"">"
               "<td align=""left""> " wrk.name format 'x(30)' "</td>".

put stream m-out 
               "<td> " replace(trim(string(wrk.v-sum, "->>>>>>>>9.99")), ".", ",") "</td>"
               "<td> " replace(trim(string(wrk.v-sumcom, "->>>>>>>>9.99")), ".", ",") "</td>".

if last-of (wrk.name) then
put stream m-out  "</tr>" skip.

end.

put stream m-out "</table>" skip.

put stream m-out "<tr></tr><tr></tr>"
                 skip(1).

put stream m-out "</table>" skip.


output stream m-out close.

unix silent cptwin repday.html excel.exe. 

