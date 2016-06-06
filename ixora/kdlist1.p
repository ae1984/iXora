/* kdlist1.p
 * MODULE
     Кредитное досье 
      
 * DESCRIPTION
        Вывод списка всех отклоненных заявок 
 * RUN
        без параметров
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-5-5 
 * AUTHOR
        16.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - отбор по датам не работал
                          в ГБ выводятся все досье (включая досье филиалов)
*/



{global.i}
{kd.i new}

/*s-kdlon = 'KD11'.
*/
def var v-cod as char.
def var coun as inte init 1.
define var v-crc as char.
define var v-descr as char.
define var v-descr1 as char.
define variable dt   as date format '99/99/9999'.
define variable dt1  as date format '99/99/9999'.
define variable v-dat  as date format '99/99/9999'.

dt = g-today.
dt1 = g-today.

update dt label ' Укажите дату с ' format '99/99/9999' dt1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">".
                  
put stream m-out "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr><br><br>".

put stream m-out "<tr align=""center""><td><h3>Заявки, отклоненные с "
                 string(dt) " по " string(dt1) "</h3></td></tr><br><br>".
 put stream m-out "<br><br><tr></tr>".

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>".
                  
       if s-ourbank = "TXB00" then
          put stream m-out "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>".
                  
       put stream m-out "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата заседания КК или отказа менеджера</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид финансирования</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Примечание</td>" 
                  "<td bgcolor=""#C0C0C0"" align=""center"">Менеджер</td>" 
                  "</table>" skip.

for each kdlon where (kdlon.bank = s-ourbank or s-ourbank = "TXB00") and kdlon.resume begins '1' and
                     ((kdlon.datkk >= dt and kdlon.datkk <= dt1) or (kdlon.resdat[2] >= dt and kdlon.resdat[2] <= dt1)) no-lock
                     break by kdlon.who by kdlon.kdcif.
   
     put stream m-out "<table border=""1"" cellpadding=""3"" cellspacing=""0""
                        style=""border-collapse: collapse"">" skip.

    find first txb where txb.bank = kdlon.bank and txb.consolid = yes no-lock no-error.
    find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
    if avail kdcif then do:
    find first crc where crc.crc = kdlon.crcz no-lock no-error.
    if avail crc then v-crc = crc.des.
                 else v-crc = ''.
    find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = kdlon.type_lnz no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
                     else v-descr = ''.
    find bookcod where bookcod.bookcod = "kdsts" and bookcod.code = kdlon.sts no-lock no-error.
    if avail bookcod then v-descr1 = bookcod.name. 
                     else v-descr1 = ''.
    if kdlon.resume = '11' or kdlon.resume = '13' then v-dat = kdlon.datkk.
    if kdlon.resume = '12' or kdlon.resume = '14' then v-dat = kdlon.resdat[2].
/*    find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.code = '21' and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon no-error.
    if avail 
*/
    put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>".
    
    if s-ourbank = "TXB00" then
        put stream m-out "<td align=""left""> " txb.name "</td>".
               
    put stream m-out "<td align=""left""> " trim(kdcif.prefix) + " " + kdcif.name format "x(60)" "</td>"
               "<td align=""left""> " v-dat  "</td>"
               "<td align=""right""> " kdlon.amountz format "->>>,>>>,>>9.99" "</td>"
               "<td align=""center""> " v-crc format "x(15)" "</td>"
               "<td align=""left""> " v-descr format 'x(30)' "</td>"
               "<td align=""left""> " v-descr1 format 'x(25)'  "</td>"
               "<td align=""left""> " kdlon.who format 'x(15)' "</td>"
               skip.
   end.
   coun = coun + 1.

end.

put stream m-out "</table></body></html>" .
output stream m-out close.
unix silent cptwin rpt.html excel. 
