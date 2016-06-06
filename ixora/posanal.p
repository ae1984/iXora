/* posanal.p
 * MODULE
        Потребительское кредитование   
 * DESCRIPTION
        Анализ должностей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
 * AUTHOR
        12.04.2004 tsoy
 * CHANGES
 */

{mainhead.i}

def var i as integer.

define stream m-out.
output stream m-out to pos_a.html.

def temp-table pos_a
    field pos_a_bank         as char
    field pos_a_pos          as char
    field pos_a_cif          as char
    field pos_a_income       as char
    field pos_a_sts          as char   
    field pos_a_amt          as deci
    field pos_a_dt           as date.

for each pkanketa no-lock:
create pos_a.
   pos_a.pos_a_cif = pkanketa.cif.
   pos_a.pos_a_bank = pkanketa.bank.

   find first pkanketh where pkanketh.bank           = pkanketa.bank
                             and pkanketh.ln         = pkanketa.ln                        
                             and pkanketh.credtype   = pkanketa.credtype 
                             and pkanketh.kritcod    = "jobsn" no-lock no-error.

   if avail pkanketh then
       pos_a.pos_a_pos   = pkanketh.value1.
   else
       pos_a.pos_a_pos   = "".

   find first pkanketh where pkanketh.bank           = pkanketa.bank
                             and pkanketh.ln         = pkanketa.ln                        
                             and pkanketh.credtype   = pkanketa.credtype 
                             and pkanketh.kritcod    = "gcvpsum" no-lock no-error.

   if avail pkanketh then
       pos_a.pos_a_income   = pkanketh.value1.
   else
       pos_a.pos_a_income   = "".


   find bookcod where bookcod.bookcod = "pkstsank" and bookcod.code = pkanketa.sts no-lock no-error.
   if avail bookcod then 
             pos_a.pos_a_sts = bookcod.name.
      else
             pos_a.pos_a_sts   = "".

   pos_a.pos_a_amt     = pkanketa.summa.
   
   find first lon where lon.lon = pkanketa.lon no-lock no-error.
   if avail lon then
      pos_a.pos_a_dt = lon.duedt.
end.
put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

for each pos_a no-lock break by pos_a.pos_a_bank by pos_a.pos_a_pos:

if first-of(pos_a.pos_a_bank) then do:
i = 0.

find first txb where txb.consolid =  true 
                     and txb.bank = pos_a.pos_a_bank no-lock no-error.

if avail txb then 
   put stream m-out unformatted "<h3>" txb.name  "<br></h3>" skip.
else
   put stream m-out unformatted "<h3>" pos_a.pos_a_bank "<br></h3>" skip.

put stream m-out unformatted "<h3>Анализ должностей  <br></h3>" skip.
put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                      style=""border-collapse: collapse"">" skip. 
put stream m-out unformatted "<tr style=""font:bold"">"
                  "<td>N</td>"
                  "<td>Клиент</td>"                  
                  "<td>Должность</td>"                  
                  "<td>Чистый доход<br>(по данным ГЦВП)</td>"                  
                  "<td>Статус Анкеты</td>"                  
                  "<td>Сумма выданного кредита</td>"                  
                  "<td>Срок кредита</td>"                  
                  "</tr>" skip.
end.
i = i + 1.
put stream m-out  unformatted "<tr style=""font:bold"">"
                   "<td>" string(i) "</td>"  
                   "<td>" pos_a_cif       "</td>"  
                   "<td>" pos_a_pos       "</td>"  
                   "<td>" replace(trim(string(deci(pos_a_income), ">>>,>>>,>>>,>>9.99")), ",", ",")    "</td>"  
                   "<td>" pos_a_sts                                                                    "</td>"  
                   "<td>" replace(trim(string(pos_a_amt, ">>>,>>>,>>>,>>9.99")), ",", ",")             "</td>"  
                   "<td>" if pos_a_dt = ? then "" else  string(pos_a_dt, "99.99.9999")                 "</td>"  
                   "</tr>" skip.
                                
if last-of(pos_a.pos_a_bank) then do:
    put stream m-out unformatted
    "</table>". 
end.

end.

output stream m-out close.
unix silent cptwin pos_a.html excel.
