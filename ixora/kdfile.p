
/* kdfile.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Документы для экспертизы (кредитные)
 * RUN
        kdresum
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
         
 * AUTHOR
        12.01.04 marinav  
 * CHANGES
        09.04.04 madiar - добавил наименование заемщика в заголовок отчета и в случае отсутствия документа в поле "дата" выводится "не предоставлен".
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i new}

def var dtstr as char init "".

form s-kdcif label ' Укажите номер клиента ' format 'x(10)' skip 
     s-kdlon label ' Укажите его досье     ' format 'x(10)' skip 
           with side-label row 5 centered frame dat .

update s-kdcif with frame dat.
update s-kdlon with frame dat.


find first kdlon where bank = s-ourbank and kdlon.kdlon = s-kdlon no-lock no-error.
 if not avail kdlon then do:   
   message skip " Заявка N" s-kdlon "не найдена !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.
 
find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
 if not avail kdcif then do:
   message skip " Клиент N" kdlon.kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.

define stream m-out.
output stream m-out to rpt.html.

put stream m-out skip.
           
put stream m-out "<html><head><title>TEXAKABANK:</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>".
put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""3""
                 style=""border-collapse: collapse"">". 
put stream m-out "<tr><td align=""right""><h3>АО TEXAKABANK"
                 "<br></td></tr>" skip.
                 

put stream m-out "<tr align=""center""><td> АКТ ПРИЕМА-ПЕРЕДАЧИ ДОКУМЕНТОВ,
                              НЕОБХОДИМЫХ ДЛЯ ЭКСПЕРТИЗЫ ПРОЕКТА <br><br></td></tr>" skip.
                              
/* добавить имя клиента в заголовок */
put stream m-out "<tr align=""center""><td> Заемщик: " kdcif.name "<br><br></td></tr>" skip.


 put stream m-out "<br><br><tr></tr>".

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Документы заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид документа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Менеджер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Примечание</td></tr>" skip.


for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type = '00' use-index ciflonln no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td align=""right""> ".
    if kddoclon.rdt[1] = ? then dtstr = "не предоставлено".
    else dtstr = string(kddoclon.rdt[1]).
    if trim(kddocs.name) matches "ЗАЛОГОДАТЕЛЬ*" or trim(kddocs.name) = "ПРИМЕЧАНИЕ:" or substring(trim(kddocs.name),2,1) = ")"
       then dtstr = "". 
    
    put stream m-out dtstr format "x(20)" "</td>"
               "<td> " kddoclon.vid format "x(15)" "</td>"
               "<td> " kddoclon.who "</td>"
               "<td> " kddoclon.info[1] format "x(200)"  "</td></tr>"
               skip.
end.

for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type ne '00' 
                        and kddoclon.type ne '10' use-index ciflonlnn no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td align=""right""> ".
    if kddoclon.rdt[1] = ? then dtstr = "не предоставлено".
    else dtstr = string(kddoclon.rdt[1]).
    if trim(kddocs.name) matches "ЗАЛОГОДАТЕЛЬ*" or trim(kddocs.name) = "ПРИМЕЧАНИЕ:" or substring(trim(kddocs.name),2,1) = ")"
       then dtstr = "".
    
    put stream m-out dtstr format "x(20)" "</td>"
               "<td> " kddoclon.vid format "x(15)" "</td>"
               "<td> " kddoclon.who "</td>"
               "<td> " kddoclon.info[1] format "x(200)"  "</td></tr>"
               skip.
end.
for each kddoclon where kdcif = s-kdcif and kdlon = s-kdlon and kddoclon.type = '10' use-index ciflonln no-lock.
   find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error.
    put stream m-out "<tr align=""left"">"
               "<td> " trim(kddocs.name) format "x(200)" "</td>"
               "<td align=""right""> ".
    if kddoclon.rdt[1] = ? then dtstr = "не предоставлено".
    else dtstr = string(kddoclon.rdt[1]).
    if trim(kddocs.name) matches "ЗАЛОГОДАТЕЛЬ*" or trim(kddocs.name) = "ПРИМЕЧАНИЕ:" or substring(trim(kddocs.name),2,1) = ")"
       then dtstr = "".
    
    put stream m-out dtstr format "x(20)" "</td>"
               "<td> " kddoclon.vid format "x(15)" "</td>"
               "<td> " kddoclon.who "</td>"
               "<td> " kddoclon.info[1] format "x(200)"  "</td></tr>"
               skip.
end.
put stream m-out "</table><br><br>" .
 
put stream m-out "<br><tr><td><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" .
put stream m-out "<br><br><tr><td>Документы по акту передал </td><td></td>" 
                             "<td>__________________________</td></tr><tr></tr>".
put stream m-out "<br><br><tr><td>Документы по акту принял </td><td></td>" 
                             "<td>__________________________</td></tr>".
put stream m-out "</table></body></html>" .
output stream m-out close.
unix silent cptwin rpt.html excel. 
