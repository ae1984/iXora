
/* kdresum1.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        анализ риск-менеджера
 * RUN
        kdresum
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-5-7 
 * AUTHOR
        15.03.2004 marinav 
 * CHANGES
        30/04/2004 madiar - Работа с досье филиалов в ГБ.
                          Добавил вывод названия филиала, в котором досье было зарегистрировано
        18/05/2004 madiar - Добавил no-lock
        20/05/2004 madiar - Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
    05/09/06   marinav - добавление индексов
*/

{global.i}
{kd.i}

define var v-descr as char.
define var sum1 as deci.

def var v-ofc as char.

find first kdlon where  kdlon.kdlon = s-kdlon and (bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
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
                 
put stream m-out "<tr align=""center""><td><b><u> Заключение риск-менеджера по проекту <br><br></td></tr>" skip.


find ofc where ofc.ofc = g-ofc no-lock no-error.
v-ofc = entry(1, ofc.name, " ").
if num-entries(ofc.name, " ") > 1 then v-ofc = v-ofc + " " + substr(entry(2, ofc.name, " "), 1, 1) + ".".
if num-entries(ofc.name, " ") > 2 then v-ofc = v-ofc + substr(entry(3, ofc.name, " "), 1, 1) + ".".

put stream m-out "<tr></tr><tr bgcolor=""#C0C0C0"" align=""left""><td><b> I. Результаты кредитного расследования </td></tr>".

find first txb where txb.bank = kdlon.bank and txb.consolid = yes no-lock no-error.
 
put stream m-out "<br><tr></tr><tr><td><table border=""0"" cellpadding=""3"" cellspacing=""0""
                  style=""border-collapse: collapse"">"
                  "<tr>"
                  "<td align=""left""> Филиал:</td>"
                  "<td align=""left""> " txb.name format "x(60)" "</td></tr>"
                  "</tr>" skip
                  "<tr>"
                  "<td align=""left""> Заемщик:</td>"
                  "<td align=""left""> " kdcif.name format "x(60)" "</td></tr>"
                  skip.

/*Запрашиваемые условия*/

  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = type_ln no-lock no-error.
  if avail bookcod then v-descr = bookcod.name.
                   else v-descr = ''.

   put stream m-out "<br><tr align=""left"">"
               "<td>  Инструмент финансирования </td>"
               "<td> " type_ln + '    ' + v-descr format 'x(40)' "</td></tr>" skip.

   put stream m-out "<tr align=""left"">"
               "<td>  Лимит финансирования </td>"
               "<td align=""right""> " kdlon.amount "</td>"
               "</tr>" skip.
   find first crc where crc.crc = kdlon.crc no-lock no-error.
   put stream m-out "<tr align=""left"">"
               "<td>  Валюта финансирования </td>"
               "<td align=""right"">  " crc.code "</td></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td>  Ставка вознагр (% годовых) </td>"
               "<td align=""right""> " kdlon.rate format '>>9.99%' "</td></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td>  Срок финансирования (мес) </td>"
               "<td align=""right""> " string(srok) + "  месяцев" format 'x(20)' "</td></tr>" skip.

  find first codfr where codfr.codfr = "lntgt" and codfr.code = kdlon.goal no-lock no-error.
  if avail codfr then v-descr = codfr.name[1].
                 else v-descr = ''.
   put stream m-out "<tr align=""left"">"
               "<td>  Цель финансирования </td>"
               "<td> " v-descr format 'x(40)' "</td></tr>" skip.


  find first codfr where codfr.codfr = 'ecdivis' and codfr.code = kdcif.ecdivis no-lock no-error.
  if avail codfr then v-descr = codfr.name[1].
                 else v-descr = ''.

  put stream m-out 
               "<tr></tr><tr>"
               "<td align=""left""> Отрасль  </td>"
               "<td align=""left""> " v-descr format "x(60)"  "</td>"
               "</tr>"  skip.
  put stream m-out "</table>".

find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '26' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                    "<tr><td><b>Первичный источник погашения:</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Вторичный источник погашения:</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(2000)' "</td></tr>" skip
                    "<tr><td><b>Ликвидационная стоимость залога:</td></tr>" skip.
   put stream m-out "</table>".
end.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '27' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                    "<tr><td><b>Гаранты:</td></tr>".
   for each kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '27' no-lock.
   put stream m-out 
                    "<tr align=""left""><td> " kdaffil.name format 'x(40)' "</td>" skip
                    "<td colspan=3> " kdaffil.info[1] format 'x(500)' "</td></tr>" skip.
   end.
   put stream m-out "</table>".
end.
else do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                   "<tr><td><b>Гаранты: </td><td>гаранты в обеспечение не предполагаются</td></tr>" .
   put stream m-out "</table>".
end.               


put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
put stream m-out "<br><tr></tr><tr bgcolor=""#C0C0C0"" align=""left"" ><td colspan=5><b> 
   II. Анализ баланса, отчета о финансовых результатах , финансовых коэффициентов: </td></tr><br>".

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '28' no-lock no-error.
if avail kdaffil then do:
   put stream m-out 
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip
                    "<tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(2000)' "</td></tr>" skip
                    "<tr align=""left""><td colspan=5> " kdaffil.info[3] format 'x(2000)' "</td></tr>" skip.
end.
put stream m-out "</table>".



put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
put stream m-out "<br><tr></tr><tr bgcolor=""#C0C0C0"" align=""left"" ><td colspan=4><b> 
   III. Риски, связанные с залоговым обеспечением: </td></tr><br>".
put stream m-out "</table>".

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" 
                  "<tr style=""font:bold"">"
                  "<td align=""center"">Наименование обеспечения</td>"
                  "<td align=""center"">Залоговая стоимость</td>"
                  "<td align=""center"">Валюта</td>"
                  "<td align=""center"">Удельный вес</td>"
                  "</tr>" skip.

     sum1 = 0.

     for each kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20'  no-lock .
         sum1 = sum1 + kdaffil.amount_bank.
     end.


     for each kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' no-lock .
        find first lonsec where lonsec.lonsec = kdaffil.lonsec no-lock no-error.
        find first crc where crc.crc = kdaffil.crc no-lock no-error.
        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left"">" lonsec.des format 'x(40)' "</td>"
               "<td>" replace(trim(string(kdaffil.amount_bank, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" crc.code "</td>"
               "<td>" replace(trim(string(kdaffil.amount_bank / sum1 * 100 , "->>9.99%")),".",",") "</td>"
               "</tr>" skip.
     end.
     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""left""><b>ИТОГО</b></td>"
               "<td><b>" replace(trim(string(sum1, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
               "<td></td>"
               "<td><b>" replace(trim(string(100, "->>9.99%")),".",",") "</b></td>"
               "</tr><tr></tr>" skip.

   put stream m-out "</table>".
end.
find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '29' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                    "<tr><td>Комментарии:</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip.
   put stream m-out "</table>".
end.



put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
put stream m-out "<br><tr></tr><tr bgcolor=""#C0C0C0"" align=""left""><td colspan=2><b> IV. Выводы и рекомендации </td></tr>".

put stream m-out "</table>".

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '31' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                    "<tr align=""left""><td colspan=5> " kdaffil.info[2] format 'x(2000)' "</td></tr>" skip.
   put stream m-out "</table>".
end.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '31' no-lock no-error.
if avail kdaffil then do:

   def var r-type_ln like kdlon.type_ln.
   def var r-amount like kdlon.amount.
   def var v-crc like kdlon.crc.
   def var r-rate like kdlon.rate.
   def var r-srok like kdlon.srok.
   def var r-goal like kdlon.goal.
   def var r-repay   like kdlon.repay.
   def var r-repay%  like kdlon.repay%.
   
   if num-entries(kdaffil.info[1]) ne 0 then do:
    assign r-type_ln = entry(1, kdaffil.info[1])
           r-amount = deci(entry(2, kdaffil.info[1])) 
           v-crc = inte(entry(3, kdaffil.info[1])) 
           r-rate = deci(entry(4, kdaffil.info[1]))
           r-srok = inte(entry(5, kdaffil.info[1]))
           r-goal = entry(6, kdaffil.info[1])
           r-repay = entry(7, kdaffil.info[1])
           r-repay% = entry(8, kdaffil.info[1]) .
   end.

    find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = r-type_ln no-lock no-error.
    if avail bookcod then v-descr = bookcod.name.
                     else v-descr = ''.

   put stream m-out "<br><tr><table border=""1"" cellpadding=""10"" cellspacing=""0""
                     style=""border-collapse: collapse""></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td> Инструмент финансирования  </td>"
               "<td align=""right""> " r-type_ln ' ' v-descr format 'X(30)' "</td>"
               "</tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td> Лимит финансирования </td>"
               "<td align=""right""> " r-amount "</td>"
               "</tr>" skip.
   find first crc where crc.crc = v-crc no-lock no-error.
   put stream m-out "<tr align=""left"">"
               "<td>  Валюта финансирования </td>"
               "<td align=""right"">  " crc.code "</td></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td>  Ставка вознагр (% годовых) </td>"
               "<td align=""right""> " r-rate format '>>9.99%' "</td></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td> Срок финансирования (мес) </td>"
               "<td align=""right""> " string(r-srok) + "  месяцев" format 'x(20)' "</td></tr>" skip.

  find first codfr where codfr.codfr = "lntgt" and codfr.code = r-goal no-lock no-error.
  if avail codfr then v-descr = codfr.name[1] .
                 else v-descr = ''.
 
   put stream m-out "<tr align=""left"">"
               "<td>  Цель финансирования </td>"
               "<td> " v-descr format 'x(40)' "</td></tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td>  Погашение основного долга </td>"
               "<td> " r-repay  format 'x(100)' "</td>"
               "</tr>" skip.
   put stream m-out "<tr align=""left"">"
               "<td>  Выплата вознаграждения </td>"
               "<td> " r-repay%  format 'x(40)' "</td>"
               "</tr>" skip.
  put stream m-out "</table>".
end.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '30' no-lock no-error.
if avail kdaffil then do:
  put stream m-out "<br><tr><table border=""0"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse""></tr>" skip.
   put stream m-out 
                    "<tr><td>Мониторинг:</td></tr>"                
                    "<tr align=""left""><td colspan=5> " kdaffil.info[1] format 'x(2000)' "</td></tr>" skip.
   put stream m-out "</table>".
end.

put stream m-out "<br><br><br><tr align=""left""><td> Риск-менеджер : __________________________ "  v-ofc format 'x(30)' "</td></tr>".
put stream m-out "</table></body></html>".

output stream m-out close.
unix silent cptwin rpt.html excel.
