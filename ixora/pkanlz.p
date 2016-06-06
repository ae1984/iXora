/* pkanlz.p
 * MODULE
        Название Программного Модуля
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
        31/12/99 pragma
 * CHANGES
     15.09.03 marinav  - свод по всем филиалам
     31.08.06 Natalya D. - одинаковые запросы вывела в temp-table.
*/

{global.i}
{pk.i "new"}

def var coun as int init 1.
define variable datums  as date format '99/99/9999'  no-undo.
define variable datums1  as date format '99/99/9999'  no-undo.
define var v-sum as deci no-undo. 
define var v-amt as deci no-undo. 
define var v-sumcr as deci no-undo. 
define var v-sumcr% as deci no-undo. 

def temp-table t-ank  no-undo
    field ln like pkanketa.ln
    field lon like lon.lon
    field credtype like pkanketa.credtype
    field credname as char
    field crc like crc.crc
    field docdt like pkanketa.docdt    
    field od as deci
    field billsum as deci
    field vosv as deci
    field paid-iv as deci
    field sumcr% as deci    
    field sumcom like pkanketa.sumcom. 

datums = g-today.

update datums label ' Укажите дату  ' format '99/99/9999' skip
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
put stream m-out "<tr align=""center""><td><h3>Сведения о выданных займах " skip
                 " на " string(datums) 
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<tr></tr><tr></tr>"
                 skip(1).
put stream m-out "<tr align=""left""><td><h3>Основной долг " skip
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" datums "</td></tr>" 
skip.

for each bookcod where bookcod.bookcod = 'credtype' no-lock:
  for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = bookcod.code and pkanketa.lon ne '' no-lock.
  
    create t-ank.
    assign t-ank.ln = pkanketa.ln
           t-ank.lon = pkanketa.lon
           t-ank.credtype = pkanketa.credtype
           t-ank.credname = bookcod.name
           t-ank.crc      = pkanketa.crc
           t-ank.docdt    = pkanketa.docdt
           t-ank.billsum  = pkanketa.billsum
           t-ank.sumcom   = pkanketa.sumcom.           
end.
end.



for each t-ank no-lock break by t-ank.credtype.   
if first-of(t-ank.credtype) then v-sumcr = 0.                                                                          
     /*run atl-dat1 (t-ank.lon,datums,1,output v-sum). */ /* остаток  ОД*/                       
     run lonbal('LON',t-ank.lon,datums,1,true,output v-sum).
     find last crchis where crchis.crc = t-ank.crc and crchis.regdt <= datums no-lock no-error.
     v-sumcr = v-sumcr + v-sum * crchis.rate[1].

   if last-of (t-ank.credtype) then 
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " t-ank.credname "</td>"
               "<td> " replace(trim(string(v-sumcr, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "</tr>" skip.
end.
                       


put stream m-out "</table>" skip.
put stream m-out "<tr></tr><tr></tr>"
                 skip(1).
put stream m-out "<tr align=""left""><td><h3> Возврат основного долга" skip
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" datums "</td>" 
                  "</tr>" 
skip.

for each t-ank no-lock break by t-ank.credtype.
   if first-of(t-ank.credtype) then v-sumcr = 0.                                                                          
   for each lnsch where lnsch.lnn = t-ank.lon and
      lnsch.fpn = 0 and lnsch.flp > 0 and lnsch.stdat < datums no-lock:
      find last crchis where crchis.crc = t-ank.crc and crchis.regdt <= lnsch.stdat no-lock no-error.
          v-sumcr = v-sumcr + lnsch.paid * crchis.rate[1].
   end.

   
   if last-of (t-ank.credtype) then 
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " t-ank.credname "</td>"
               "<td> " replace(trim(string(v-sumcr, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "</tr>" skip.
end.
                       

put stream m-out "</table>" skip.
put stream m-out "<tr></tr><tr></tr>"
                 skip(1).
put stream m-out "<tr align=""left""><td><h3> Залоговое обеспечение " skip
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" datums "</td></tr>" 
skip.

for each t-ank no-lock where t-ank.docdt <= datums break by t-ank.credtype.
     if first-of(t-ank.credtype) then v-sumcr = 0.
                                                                          
     find last crchis where crchis.crc = t-ank.crc and crchis.regdt <= datums no-lock no-error.
     v-sumcr = v-sumcr + t-ank.billsum * crchis.rate[1].

   if last-of (t-ank.credtype) then 
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " t-ank.credname "</td>"
               "<td> " replace(trim(string(v-sumcr, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "</tr>" skip.
end.
                       

put stream m-out "</table>" skip.
put stream m-out "<tr></tr><tr></tr>"
                 skip(1).
put stream m-out "<tr align=""left""><td><h3>Проценты полученные" skip
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" datums "</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные %</td></tr>" 
skip.

for each t-ank no-lock break by t-ank.credtype.
     if first-of(t-ank.credtype) then do: 
        v-sumcr = 0.
        v-sumcr% = 0.
     end.                                                                        
   for each lnsci where lnsci.lni = t-ank.lon and
      lnsci.fpn = 0 and lnsci.flp > 0 and lnsci.idat < datums no-lock:
      find last crchis where crchis.crc = t-ank.crc and crchis.regdt <= lnsci.idat no-lock no-error.
          v-sumcr = v-sumcr + lnsci.paid-iv * crchis.rate[1].
   end.
   
   find last crchis where crchis.crc = t-ank.crc and crchis.regdt <= datums no-lock no-error.
   run atl-prcl(t-ank.lon,g-today - 1, output v-sum, output v-amt, 
         output v-amt).
     v-sumcr% = v-sumcr% + v-sum * crchis.rate[1].


   if last-of (t-ank.credtype) then 
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " t-ank.credname "</td>"
               "<td> " replace(trim(string(v-sumcr, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "<td> " replace(trim(string(v-sumcr%, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "</tr>" skip.
end.
                       

put stream m-out "</table>" skip.
put stream m-out "<tr></tr><tr></tr>"
                 skip(1).
put stream m-out "<tr align=""left""><td><h3>Комиссия " skip
                 "</h3></td></tr><br><br>"
                 skip(1).
put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">" datums "</td></tr>" 
skip.

for each t-ank no-lock where t-ank.docdt <= datums break by t-ank.credtype.
     if first-of(t-ank.credtype) then v-sumcr = 0.                                                                           
     v-sumcr = v-sumcr + t-ank.sumcom.

   if last-of (t-ank.credtype) then 
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " t-ank.credname "</td>"
               "<td> " replace(trim(string(v-sumcr, "->>>>>>>>>9.99")), ".", ",") "</td>"
               "</tr>" skip.
end.
                      


put stream m-out "</table>" skip.


output stream m-out close.

unix silent cptwin repday.html excel.exe. 

