/* pkdays.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Свод по всем кредитам - выданные за период потреб кредиты 
        в разрезе каждого дня перода
 * RUN
        из пункта меню без параметров
 * CALLER
        
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU 
        4-14-4 
 * AUTHOR
        19.08.2003 marinav
 * CHANGES
     15.09.03 marinav  - свод по всем филиалам
*/

{global.i}
{pk.i "new"}

def var coun as int init 1.
define variable datums  as date format '99/99/9999'.
define variable datums1  as date format '99/99/9999'.
define var v-sum as deci. 
define var v-amt as deci. 
define var v-sumcr as deci. 
define var v-sumcr% as deci. 
def temp-table  wrk
    field name    as char
    field v-dat   as date
    field v-coun  as inte
    field v-sum   as deci
    index name name index dat v-dat.

datums = g-today.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

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

put stream m-out "<tr align=""center""><td><h3>Сведения о выданных потребительских кредитах " skip
                 " с " string(datums) " по " string(datums1)
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out "<tr></tr><tr></tr>"
                 skip(1).

for each pkanketa no-lock where pkanketa.bank = s-ourbank and 
         pkanketa.lon ne '' and pkanketa.docdt >= datums and  pkanketa.docdt <= datums1.

find first wrk where wrk.v-dat = pkanketa.docdt no-lock no-error.
if not avail wrk then do:
for each bookcod where bookcod.bookcod = "credtype" no-lock.
      create wrk.
      wrk.name = bookcod.code.
      wrk.v-dat = pkanketa.docdt.
end.
end.

   find last crchis where crchis.crc = pkanketa.crc and crchis.regdt <= pkanketa.docdt no-lock no-error.
   v-sumcr = pkanketa.summa * crchis.rate[1].

   find first wrk where wrk.name = pkanketa.credtype and wrk.v-dat = pkanketa.docdt no-lock no-error.
   if not avail wrk then do:
      displ 'ERROR'.
   end.
   wrk.v-sum = wrk.v-sum + v-sumcr.
   wrk.v-coun = wrk.v-coun + 1.
end.                       

/*шапка*/

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
               "<td bgcolor=""#C0C0C0"" align=""center""> Вид кредита</td>".

for each wrk break by wrk.name.

  if first-of (wrk.name) then do:
     find bookcod where bookcod.bookcod = "credtype" and bookcod.code = wrk.name no-lock no-error.
    put stream m-out  "<td colspan=2 bgcolor=""#C0C0C0"" align=""center""> " bookcod.name "</td>".
  end.
end.

put stream m-out "</tr>" skip.
put stream m-out  "<td bgcolor=""#C0C0C0"" align=""center""> </td>".
for each wrk break by wrk.name.

  if first-of (wrk.name) then do:
    put stream m-out  "<td bgcolor=""#C0C0C0"" align=""center""> Кол-во </td>"
                      "<td bgcolor=""#C0C0C0"" align=""center""> Сумма </td>".
  end.
end.

put stream m-out "</tr>" skip.

/**Данные***/

for each wrk break by wrk.v-dat by wrk.name.

if first-of (wrk.v-dat) then
put stream m-out "<tr align=""right"">"
               "<td align=""left""> " wrk.v-dat "</td>".

put stream m-out  "<td> " v-coun "</td> " 
                  "<td> " replace(trim(string(wrk.v-sum, "->>>>>>>>9.99")), ".", ",") "</td>".

if last-of (wrk.v-dat) then put stream m-out  "</tr>" skip.

end.

put stream m-out "</table>" skip.


output stream m-out close.

unix silent cptwin repday.html excel. 

