/* zatrat.i
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        04/02/06 nataly
 * CHANGES
        04.02.2006 nataly был довавлена обработка склада, Прилож 12,13,14.
*/

if v-pril = '01' then do:
put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" 
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Код подр-я</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наим подраз-я</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кол-во отраб часов</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.
      i = 1.

for each temp  where temp.dep = depzl use-index dep  break by temp.tn .
   accum temp.dnf (total by temp.tn).
 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  v-attn   /*temp.dep*/  "</TD>" skip
      "<TD>"  v-depname /*temp.depname*/  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>"  string(accum total by temp.tn temp.dnf)  "</TD>" skip.
            i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
 end.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.
end.  /*pril1*/
else if v-pril = '02' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.


put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .


put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Кол-во отраб часов</B></FONT></TD>" skip
     " <TD colspan=6> Начисления  </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого начис-но</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Соц. налог</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Соц. отчис-ия</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего затраты</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Затраты по выплате окладов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты по выплате отпускных</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты по надбавкам и доплатам </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Тек премии. Единоврем премии</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пособия по времен. нетрудос., в т.ч. по берем-ти и родам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Фин помощь</B></FONT></TD>" skip
      "</TR>" skip.

      i = 1.  
for each temp where temp.dep = depzl  break by temp.dep by  temp.tn  .

   accum temp.dnf (total by temp.dep by temp.tn).
   accum temp.oklad (total by temp.dep by temp.tn).
   accum temp.otpusk (total by temp.dep by temp.tn).
   accum temp.nadb (total by temp.dep by temp.tn).
   accum temp.prem (total by temp.dep by temp.tn).
   accum temp.posob (total by temp.dep by temp.tn).
   accum temp.hlp (total by temp.dep by temp.tn).
   accum temp.nalog (total by temp.dep by temp.tn).
   accum temp.otch (total by temp.dep by temp.tn).

 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

   
  if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>"  string(accum total by temp.tn temp.dnf)  "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oklad,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.otpusk,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.nadb,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.prem,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.posob,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.hlp,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" replace(string((accum total by temp.tn temp.oklad) + (accum total by temp.tn temp.otpusk) + (accum total by temp.tn temp.nadb) + (accum total by temp.tn temp.prem) + (accum total by temp.tn temp.posob) + (accum total by temp.tn temp.hlp) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.nalog,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.otch,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD><b>" + replace(string((accum total by temp.tn temp.oklad) + (accum total by temp.tn temp.otpusk) + (accum total by temp.tn temp.nadb) + (accum total by temp.tn temp.prem) + (accum total by temp.tn temp.posob) + (accum total by temp.tn temp.hlp) + (accum total by temp.tn temp.nalog) +  (accum total by temp.tn temp.otch),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
 end.
  if last-of(temp.dep) then 
  put stream vcrpt unformatted
       "<TR valign=""top"">" skip 
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>" string( accum  total by temp.dep temp.dnf ) "</TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.oklad,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.otpusk,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.nadb,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.prem,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.posob,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.hlp,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" replace(string((accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) + (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) + (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.nalog,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.otch,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string((accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) + (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) + (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp) + (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.
end.  /*pril2*/
else if v-pril = '03' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril  + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     " <TD colspan=4> Затраты на амортизацию ОС, тенге  </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     " <TD colspan=3> Затраты на амортизацию НА, тенге  </TD>" skip
     "<TD rowspan=2><FONT size=""1"">Признак НМА</FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1"">ВСЕГО</FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Компьютеры, обор-ие</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Спец инструменты, инвентарь</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Транспорт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Здания,сооружения</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Программное обеспечение</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Техническая документация</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Лицензия</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr3.i &dep = "v-deps.dep = depzl" }
/*{pr3.i}*/

for each temp where temp.dep = depzl  break by temp.dep by  temp.tn  .

   accum temp.oos1 (total by temp.dep by temp.tn).
   accum temp.oos2 (total by temp.dep by temp.tn).
   accum temp.oos3 (total by temp.dep by temp.tn).
   accum temp.oos4 (total by temp.dep by temp.tn).
   accum temp.oos5 (total by temp.dep by temp.tn).

 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

 if last-of(temp.tn) then do:            
  put stream vcrpt unformatted           
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oos1,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oos2,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oos3,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oos4,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
        "<TD><b>" + replace(string((accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) +  (accum total by temp.tn temp.oos4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD>" + replace(string(accum total by temp.tn temp.oos5,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" "</TD>" skip
      "<TD>" "</TD>" skip
      "<TD>" "</TD>" skip
        "<TD><b>" + replace(string((accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) +  (accum total by temp.tn temp.oos4) + (accum total by temp.tn temp.oos5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip .

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
 end.
  if last-of(temp.dep) then 
  put stream vcrpt unformatted
       "<TR valign=""top"">" skip 
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.oos1,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.oos2,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.oos3,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.oos4,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" replace(string((accum total by temp.dep temp.oos1) + (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4)  ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip 
        "<TD><b>" + replace(string(accum total by temp.dep temp.oos5,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD>" "</TD>" skip
      "<TD>" "</TD>" skip
      "<TD>" "</TD>" skip
        "<TD><b>" + replace(string((accum total by temp.dep temp.oos5) + (accum total by temp.dep temp.oos1) + (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

end.

put stream vcrpt unformatted
  "</TABLE>" skip.
end.  /*pril3*/
else if v-pril = '04' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     " <TD colspan=2> Затраты на подготовку и переподготовку </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     " <TD colspan=4> Затраты на служебные командировки </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего затрат</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>на терр-ии РК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в странах СНГ и за рубежом </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>суточные</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>проездные</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>квартирные</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>представительские расходы</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr4.i}

for each temp where temp.dep = depzl break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr4_7 (total   by temp.dep by temp.tn).
     accum temp.pr4_89 (total  by temp.dep by temp.tn).
     accum temp.pr4_11 (total  by temp.dep by temp.tn).
     accum temp.pr4_12 (total  by temp.dep by temp.tn).
     accum temp.pr4_13 (total  by temp.dep by temp.tn).
     accum temp.pr4_14 (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_7,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_89,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_7) + (accum total by temp.tn temp.pr4_89),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_11,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_12,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_13,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_14,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_11) + (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_13) + (accum total by temp.tn temp.pr4_14),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_7) + (accum total by temp.tn temp.pr4_89) + (accum total by temp.tn temp.pr4_11) + (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_13) + (accum total by temp.tn temp.pr4_14),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
  if last-of(temp.dep) then 
  put stream vcrpt unformatted
       "<TR valign=""top"">" skip 
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_7,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_89,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
         "<TD><b>" replace(string((accum total by temp.dep temp.pr4_7) + (accum total by temp.dep temp.pr4_89)  ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip 
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_11,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_12,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_13,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_14,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" replace(string((accum total by temp.dep temp.pr4_11) + (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13) + (accum total by temp.dep temp.pr4_14) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip 
      "<TD><b>" replace(string((accum total by temp.dep temp.pr4_7) + (accum total by temp.dep temp.pr4_89) + (accum total by temp.dep temp.pr4_11) + (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13) + (accum total by temp.dep temp.pr4_14) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip .

 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril4*/ 
else if v-pril = '05' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br>Приложение " + v-pril +  "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Номер телефона</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Номер сотового телефона</B></FONT></TD>" skip
     " <TD colspan=2> Затраты на услуги связи </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     " <TD colspan=5> Затраты на услуги связи </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего затрат</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>за пользование телефоном</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>за пользование сотовой связью </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>за телекоммуникац. услуги</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>за пользование телефоном</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>за пользование услугами телетайпа и телеграфа</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>абон. плата за пользование радиоточками</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>за спец. связь</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr5.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr5_9   (total  by temp.dep by temp.tn).
     accum temp.pr5_10a (total  by temp.dep by temp.tn).
     accum temp.pr5_10b (total  by temp.dep by temp.tn).
     accum temp.pr5_12a (total  by temp.dep by temp.tn).
     accum temp.pr5_12b (total  by temp.dep by temp.tn).
     accum temp.pr5_12c (total  by temp.dep by temp.tn).
     accum temp.pr5_15 (total  by temp.dep by temp.tn).
     accum temp.pr5_16 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_10a) + (accum total by temp.tn temp.pr5_10b) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_9)  + (accum total by temp.tn temp.pr5_10a)  + (accum total by temp.tn temp.pr5_10b) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_12a)  + (accum total by temp.tn temp.pr5_12b)  + (accum total by temp.tn temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_15)  + (accum total by temp.tn temp.pr5_16)  + (accum total by temp.tn temp.pr5_12a)  + (accum total by temp.tn temp.pr5_12b)   + (accum total by temp.tn temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_9)  + (accum total by temp.tn temp.pr5_10a)  + (accum total by temp.tn temp.pr5_10b)  + (accum total by temp.tn temp.pr5_15)  + (accum total by temp.tn temp.pr5_16)  + (accum total by temp.tn temp.pr5_12a)  + (accum total by temp.tn temp.pr5_12b)   + (accum total by temp.tn temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_10a)  + (accum total by temp.dep temp.pr5_10b)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_9)  + (accum total by temp.dep temp.pr5_10a)  + (accum total by temp.dep temp.pr5_10b)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_12a)  + (accum total by temp.dep temp.pr5_12b)  + (accum total by temp.dep temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_15)  + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_12a)  + (accum total by temp.dep temp.pr5_12b)   + (accum total by temp.dep temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_9)  + (accum total by temp.dep temp.pr5_10a)  + (accum total by temp.dep temp.pr5_10b)  + (accum total by temp.dep temp.pr5_15)  + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_12a)  + (accum total by temp.dep temp.pr5_12b)   + (accum total by temp.dep temp.pr5_12c) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril5*/ 
else if v-pril = '06' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B> Прочие адм. расходы</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Предст.затраты, связ. с проведением культурных мер-ий(праздники, соревнования, конкурсы)</B></FONT></TD>" skip
     " <TD> Признак распред затрат </TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr6.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr6_7   (total  by temp.dep by temp.tn).
     accum temp.pr6_8   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>"   "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr6_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>"   "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr6_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD>"   "</TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril6*/ 
else if v-pril = '07' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril +  "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по аренде</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr7.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr7_6   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr7_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril7*/ 
else if v-pril = '09' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br>Приложение " + v-pril +  "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Должность</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на ТМЦ(товары)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на бланочную продукцию</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B> Затраты на канц. товары  </TD>" skip
     "<TD><FONT size=""1""><B> Затраты на приобретение печатной продукции  </TD>" skip
     "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr9.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr9_4a   (total  by temp.dep by temp.tn).
     accum temp.pr9_4b   (total  by temp.dep by temp.tn).
     accum temp.pr9_4c   (total  by temp.dep by temp.tn).
     accum temp.pr9_4d   (total  by temp.dep by temp.tn).
     accum temp.pr9_4e   (total  by temp.dep by temp.tn).
     accum temp.pr9_4f   (total  by temp.dep by temp.tn).
     accum temp.pr9_5a   (total  by temp.dep by temp.tn).
     accum temp.pr9_5b   (total  by temp.dep by temp.tn).
     accum temp.pr9_5c   (total  by temp.dep by temp.tn).
     accum temp.pr9_6   (total  by temp.dep by temp.tn).
     accum temp.pr9_7a   (total  by temp.dep by temp.tn).
     accum temp.pr9_7b   (total  by temp.dep by temp.tn).
     accum temp.pr9_7c   (total  by temp.dep by temp.tn).
     accum temp.pr9_7d   (total  by temp.dep by temp.tn).
     accum temp.pr9_7e   (total  by temp.dep by temp.tn).
     accum temp.pr9_7f   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_4a) + (accum total by temp.tn temp.pr9_4b) + (accum total by temp.tn temp.pr9_4c) + (accum total by temp.tn temp.pr9_4d) + (accum total by temp.tn temp.pr9_4e) + (accum total by temp.tn temp.pr9_4f) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_5a) + (accum total by temp.tn temp.pr9_5b) + (accum total by temp.tn temp.pr9_5c)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_7a) + (accum total by temp.tn temp.pr9_7b) + (accum total by temp.tn temp.pr9_7c) + (accum total by temp.tn temp.pr9_7d) + (accum total by temp.tn temp.pr9_7e) + (accum total by temp.tn temp.pr9_7f) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.tn temp.pr9_4a) + (accum total by temp.tn temp.pr9_4b) + (accum total by temp.tn temp.pr9_4c) + (accum total by temp.tn temp.pr9_4d) + (accum total by temp.tn temp.pr9_4e) + (accum total by temp.tn temp.pr9_4f) + (accum total by temp.tn temp.pr9_5a) + (accum total by temp.tn temp.pr9_5b) + (accum total by temp.tn temp.pr9_5c) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7a) + (accum total by temp.tn temp.pr9_7b) + (accum total by temp.tn temp.pr9_7c) + (accum total by temp.tn temp.pr9_7d) + (accum total by temp.tn temp.pr9_7e) + (accum total by temp.tn temp.pr9_7f), "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) + (accum total by temp.dep temp.pr9_4e) + (accum total by temp.dep temp.pr9_4f) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + (accum total by temp.dep temp.pr9_5c)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) + (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) + (accum total by temp.dep temp.pr9_4e) + (accum total by temp.dep temp.pr9_4f) + (accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + (accum total by temp.dep temp.pr9_5c) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) + (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f), "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril9*/ 

else if v-pril = '10' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     " <TD colspan=6> Затраты на коммунальные услуги </TD>" skip 
     "<TD rowspan=2><FONT size=""1""><B>ИТОГО</B></FONT></TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>электроэнергия</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>отопление и гор.водоснабжение </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>хол.водоснабжение и канализация</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>дезинфекция и дератизация</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>вывоз мусора</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>другие</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr10.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr10_4   (total  by temp.dep by temp.tn).
     accum temp.pr10_56 (total  by temp.dep by temp.tn).
     accum temp.pr10_7 (total  by temp.dep by temp.tn).
     accum temp.pr10_8 (total  by temp.dep by temp.tn).
     accum temp.pr10_9 (total  by temp.dep by temp.tn).
     accum temp.pr10_10 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_56),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_56)  + (accum total by temp.tn temp.pr10_7) + (accum total by temp.tn temp.pr10_8) + (accum total by temp.tn temp.pr10_9) + (accum total by temp.tn temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_56),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_56)  + (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril10*/ 
else if v-pril = '11' then do:

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril  + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Таб номер</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>ФИО</B></FONT></TD>" skip
     " <TD colspan=5>Затраты на кап.ремонт ОС </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip 
     " <TD colspan=6>Затраты на тек.ремонт и осмотр ОС </TD>" skip 
     " <TD rowspan=2>Признак распределения затрат </TD>" skip 
     "<TD rowspan=2><FONT size=""1""><B>ИТОГО</B></FONT></TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>компьютеры, комп. оборудование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ср-ва механизации кассовых операций </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ср-ва охраны и сигнализации </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>спец.инструменты, инвентарь и принадлежности<B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>здания,сооружения,строения произв. назначения</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>компьютеры, комп. оборудование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ср-ва механизации кассовых операций </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ср-ва охраны и сигнализации </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>спец.инструменты, инвентарь и принадлежности<B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>мебель для офиса<B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>здания,сооружения,строения произв. назначения</B></FONT></TD>" skip
   "</TR>" skip.

{pr11.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr11_10   (total  by temp.dep by temp.tn).
     accum temp.pr11_11 (total  by temp.dep by temp.tn).
     accum temp.pr11_12 (total  by temp.dep by temp.tn).
     accum temp.pr11_14 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_11),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_10)  + (accum total by temp.tn temp.pr11_11)  + (accum total by temp.tn temp.pr11_12) + (accum total by temp.tn temp.pr11_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_11),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD>"    "</TD>" skip
      "<TD>"    "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)  + (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril11*/ 
else if v-pril = '12' then do:

{pr3.i &dep = "true"}
{pr4.i}
{pr5.i}
{pr6.i}
{pr7.i}
{pr9.i &dep = "true"}
{pr10.i}
{pr11.i}

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .
  
for each temp break by temp.dep.
  if last-of (temp.dep) then do:
    coldep = coldep + 1.
  end.
end .
put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2 ><FONT size=""1""><B>Балансовый счет</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Наименование затрат</B></FONT></TD>" skip
     "<TD colspan= " coldep " ><FONT size=""1""><B>Наименование подразделения</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.


for each temp break by temp.dep  .

   accum temp.dnf    (total by temp.dep ).
   accum temp.oklad  (total by temp.dep ).
 
   accum temp.otpusk (total by temp.dep ).
   accum temp.nadb   (total by temp.dep ).
   accum temp.prem   (total by temp.dep ).
   accum temp.posob  (total by temp.dep ).
   accum temp.hlp    (total by temp.dep ).
   accum temp.nalog  (total by temp.dep ).
   accum temp.otch   (total by temp.dep ).

     accum temp.oos1 (total by temp.dep ).
     accum temp.oos2 (total by temp.dep ).
     accum temp.oos3 (total by temp.dep ).
     accum temp.oos4 (total by temp.dep ).
     accum temp.oos5 (total by temp.dep ).
     accum temp.pr4_7 (total   by temp.dep ).
     accum temp.pr4_89 (total  by temp.dep ).
     accum temp.pr4_11 (total  by temp.dep ).
     accum temp.pr4_12 (total  by temp.dep ).
     accum temp.pr4_13 (total  by temp.dep ).
     accum temp.pr4_14 (total  by temp.dep ).
     accum temp.pr5_9   (total by temp.dep ).
     accum temp.pr5_10a (total by temp.dep ).
     accum temp.pr5_10b (total by temp.dep ).
     accum temp.pr5_12a (total by temp.dep ).
     accum temp.pr5_12b (total by temp.dep ).
     accum temp.pr5_12c (total by temp.dep ).
     accum temp.pr5_15 (total  by temp.dep ).
     accum temp.pr5_16 (total  by temp.dep ).

     accum temp.pr9_4a (total  by temp.dep ).
     accum temp.pr9_4b (total  by temp.dep ).
     accum temp.pr9_4c (total  by temp.dep ).
     accum temp.pr9_4d (total  by temp.dep ).
     accum temp.pr9_4e (total  by temp.dep ).
     accum temp.pr9_4f (total  by temp.dep ).
     accum temp.pr9_5a (total  by temp.dep ).
     accum temp.pr9_5b (total  by temp.dep ).
     accum temp.pr9_5c (total  by temp.dep ).
     accum temp.pr9_6  (total  by temp.dep ).
     accum temp.pr9_7a (total  by temp.dep ).
     accum temp.pr9_7b (total  by temp.dep ).
     accum temp.pr9_7c (total  by temp.dep ).
     accum temp.pr9_7d (total  by temp.dep ).
     accum temp.pr9_7e (total  by temp.dep ).
     accum temp.pr9_7f (total  by temp.dep ).

     accum temp.pr10_4  (total by temp.dep ).
     accum temp.pr10_56 (total by temp.dep ).
     accum temp.pr10_7  (total by temp.dep ).
     accum temp.pr10_8  (total by temp.dep ).
     accum temp.pr10_9  (total by temp.dep ).
     accum temp.pr10_10 (total by temp.dep ).
     accum temp.pr11_10 (total by temp.dep ).
     accum temp.pr11_11 (total by temp.dep ).
     accum temp.pr11_12 (total by temp.dep ).
     accum temp.pr11_14 (total by temp.dep ).
     accum temp.pr6_7   (total by temp.dep ).
     accum temp.pr6_8   (total by temp.dep ).

  if last-of(temp.dep) then do:

     create tottemp.
     assign
           tottemp.prz = 1
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[1]
           tottemp.des  = des[1] 
           tottemp.sum = (accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) + 
                         (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) + 
                         (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp).
     create tottemp.
     assign 
           tottemp.prz = 2
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[2]
           tottemp.des  = des[2] 
           tottemp.sum = (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch).

     create tottemp.
     assign 
           tottemp.prz = 3
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_89).

     create tottemp.
     assign 
           tottemp.prz = 4
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13).

     create tottemp.
     assign 
           tottemp.prz = 5
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[5]
           tottemp.des  = des[5] 
           tottemp.sum = (accum total by temp.dep temp.pr4_14).

     create tottemp.
     assign 
           tottemp.prz = 6
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[6]
           tottemp.des  = des[6] 
           tottemp.sum = (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10a) + (accum total by temp.dep temp.pr5_10b)
                         + (accum total by temp.dep temp.pr5_15)  + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_12a)  
                         + (accum total by temp.dep temp.pr5_12b)   + (accum total by temp.dep temp.pr5_12c)  .

     create tottemp.
     assign 
           tottemp.prz = 7
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[7]
           tottemp.des  = des[7] 
           tottemp.sum = (accum total by temp.dep temp.oos1) +  (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4).

     create tottemp.
     assign 
           tottemp.prz = 8
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[8]
           tottemp.des  = des[8] 
           tottemp.sum = (accum total by temp.dep temp.oos5).


     create tottemp.
     assign 
           tottemp.prz = 9
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[9]
           tottemp.des  = des[9] 
           tottemp.sum = (accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + 
                         (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) +
                         (accum total by temp.dep temp.pr9_4e)  + (accum total by temp.dep temp.pr9_4f) .
 
    create tottemp.
     assign 
           tottemp.prz = 10
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[10]
           tottemp.des  = des[10] 
           tottemp.sum = (accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + 
                         (accum total by temp.dep temp.pr9_5c)  .

     create tottemp.
     assign 
           tottemp.prz = 11
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[11]
           tottemp.des  = des[11] 
           tottemp.sum = (accum total by temp.dep temp.pr9_6) . 

     create tottemp.
     assign 
           tottemp.prz = 12
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[12]
           tottemp.des  = des[12] 
           tottemp.sum = (accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + 
                         (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) +
                         (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f)   .

      create tottemp.      
     assign 
           tottemp.prz = 13
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[13]
           tottemp.des = des[13] 
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_56) + 
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10).

     create tottemp.
     assign 
           tottemp.prz = 15
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[15]
           tottemp.des = des[15] 
           tottemp.sum = (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)  
                         + (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14).

     create tottemp.
     assign 
           tottemp.prz = 16
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[16]
           tottemp.des = des[16] 
           tottemp.sum = (accum total by temp.dep temp.pr6_7).

     create tottemp.
     assign 
           tottemp.prz = 17
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.dep temp.pr6_8).
 
end.
 end.

put stream vcrpt unformatted
   "<TR align=""center"">" .

 for each tottemp break by tottemp.dep. 
  if first-of(tottemp.dep) then
      put stream vcrpt unformatted
      "<TD>"  tottemp.depname   "</TD>" skip.
end.

put stream vcrpt unformatted
   "</TR>" skip.

 for each tottemp break by tottemp.prz by tottemp.dep.
   accum tottemp.sum   (total by tottemp.prz ).
 if first-of(tottemp.prz) then
 put stream vcrpt unformatted
       "<TR valign=""top"">" skip 
      "<TD>" tottemp.gl   "</TD>" skip
      "<TD>" tottemp.des  "</TD>" skip.
  put stream vcrpt unformatted
      "<TD>" replace(string(tottemp.sum ,"zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip.
  if last-of(tottemp.prz)  then
 put stream vcrpt unformatted
      "<TD>" replace(string((accum total by tottemp.prz tottemp.sum) ,"zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip.

end. 
 put stream vcrpt unformatted
    "</TR>" skip.
 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril12*/
else if v-pril = '13' then do:

{pr3.i &dep = "true"}
{pr4.i}
{pr5.i}
{pr6.i}
{pr7.i}
{pr9.i &dep = "t-cods.dep = v-doxras" }
{pr10.i}
{pr11.i}

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br>Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .
  
put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Код подразделения</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Наимен.подразделения</B></FONT></TD>" skip
     " <TD colspan=7>Прямые затраты </TD>" skip 
     " <TD rowspan=2>Итого прямые затраты </TD>" skip 
     " <TD colspan=7>Косвенные затраты </TD>" skip 
     " <TD rowspan=2>Итого косвенные затраты </TD>" skip 
     " <TD colspan=5>Общебанковские затраты </TD>" skip 
     " <TD rowspan=2>Итого общебанк.затраты  </TD>" skip 
     " <TD rowspan=2>ВСЕГО  </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Затраты на оплату труда персонала</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Соц.налог </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию ОС,закрепленных за сотр. </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты,связанные с обучением персонала </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на служ.командировки(в т.ч.представ.затраты, связанные с выездами в командировки) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие адм.затраты(оформление виз) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на услуги связи(сотовые и персональные телефоны) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию ОС общего значения </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию НМА </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на товарно-материальные ценности(запасы) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на бланочную продукцию </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на канц.товары </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на приобретение печатной продукции </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на услуги связи </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на коммунальные услуги </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на кап.ремонт ОС </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на тек.ремонт и осмотр ОС </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие админист.затраты </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Представит.затраты, связанные с проведением праздничных мероприятий,соревн и др.) </B></FONT></TD>" skip
   "</TR>" skip.


for each temp where temp.dep = depzl break by temp.tn  .
   accum temp.dnf    (total by temp.tn ).

   accum temp.oklad  (total by temp.tn ).
   accum temp.otpusk (total by temp.tn ).
   accum temp.nadb   (total by temp.tn ).
   accum temp.prem   (total by temp.tn ).
   accum temp.posob  (total by temp.tn ).
   accum temp.hlp    (total by temp.tn ).
   accum temp.nalog  (total by temp.tn ).
   accum temp.otch   (total by temp.tn ).

     accum temp.oos1 (total by temp.tn ).
     accum temp.oos2 (total by temp.tn ).
     accum temp.oos3 (total by temp.tn ).
     accum temp.oos4 (total by temp.tn ).
     accum temp.oos5 (total by temp.tn ).
     accum temp.pr4_7 (total   by temp.tn ).
     accum temp.pr4_89 (total  by temp.tn ).
     accum temp.pr4_11 (total  by temp.tn ).
     accum temp.pr4_12 (total  by temp.tn ).
     accum temp.pr4_13 (total  by temp.tn ).
     accum temp.pr4_14 (total  by temp.tn ).
     accum temp.pr5_9   (total by temp.tn ).
     accum temp.pr5_10a (total by temp.tn ).
     accum temp.pr5_10b (total by temp.tn ).
     accum temp.pr5_12a (total by temp.tn ).
     accum temp.pr5_12b (total by temp.tn ).
     accum temp.pr5_12c (total by temp.tn ).
     accum temp.pr5_15 (total  by temp.tn ).
     accum temp.pr5_16 (total  by temp.tn ).

     accum temp.pr9_4a (total  by temp.tn ).
     accum temp.pr9_4b (total  by temp.tn ).
     accum temp.pr9_4c (total  by temp.tn ).
     accum temp.pr9_4d (total  by temp.tn ).
     accum temp.pr9_4e (total  by temp.tn ).
     accum temp.pr9_4f (total  by temp.tn ).
     accum temp.pr9_5a (total  by temp.tn ).
     accum temp.pr9_5b (total  by temp.tn ).
     accum temp.pr9_5c (total  by temp.tn ).
     accum temp.pr9_6  (total  by temp.tn ).
     accum temp.pr9_7a (total  by temp.tn ).
     accum temp.pr9_7b (total  by temp.tn ).
     accum temp.pr9_7c (total  by temp.tn ).
     accum temp.pr9_7d (total  by temp.tn ).
     accum temp.pr9_7e (total  by temp.tn ).
     accum temp.pr9_7f (total  by temp.tn ).

     accum temp.pr10_4  (total by temp.tn ).
     accum temp.pr10_56 (total by temp.tn ).
     accum temp.pr10_7  (total by temp.tn ).
     accum temp.pr10_8  (total by temp.tn ).
     accum temp.pr10_9  (total by temp.tn ).
     accum temp.pr10_10 (total by temp.tn ).
     accum temp.pr11_10 (total by temp.tn ).
     accum temp.pr11_11 (total by temp.tn ).
     accum temp.pr11_12 (total by temp.tn ).
     accum temp.pr11_14 (total by temp.tn ).
     accum temp.pr6_7   (total by temp.tn ).
     accum temp.pr6_8   (total by temp.tn ).

  if last-of(temp.tn) then do:

     create tottemp.
     assign
           tottemp.prz = 1   /*зп, премии и тп*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[1]
           tottemp.des  = des[1] 
           tottemp.sum = (accum total by temp.tn temp.oklad) + (accum total by temp.tn temp.otpusk) + 
                         (accum total by temp.tn temp.nadb) + (accum total by temp.tn temp.prem) + 
                         (accum total by temp.tn temp.posob) + (accum total by temp.tn temp.hlp).
     create tottemp.
     assign 
           tottemp.prz = 2 /*соц налог*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[2]
           tottemp.des  = des[2] 
           tottemp.sum = (accum total by temp.tn temp.nalog) +  (accum total by temp.tn temp.otch).

     create tottemp.
     assign 
           tottemp.prz = 3  /*амортизация ОС, закрепленных за сотрудником*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum = (accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) + (accum total by temp.tn temp.oos4).

     create tottemp.
     assign 
           tottemp.prz = 4  /*подготовка  переподготовка */
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_89).

     create tottemp.
     assign 
           tottemp.prz = 5 /*командировки*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_13).

     create tottemp.
     assign 
           tottemp.prz = 6 /*прочие админист расходы*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[5]
           tottemp.des  = des[5] 
           tottemp.sum = (accum total by temp.tn temp.pr4_14).


     create tottemp.
     assign 
           tottemp.prz = 7  /*телефония*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[6]
           tottemp.des  = des[6] 
           tottemp.sum = (accum total by temp.tn temp.pr5_9) +  (accum total by temp.tn temp.pr5_10a) + 
                         (accum total by temp.tn temp.pr5_10b).

     create tottemp.
     assign 
           tottemp.prz = 8 /*ИТОГО прямые затраты*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.tn temp.oklad) + (accum total by temp.tn temp.otpusk) +
                         (accum total by temp.tn temp.nadb) + (accum total by temp.tn temp.prem) +   
                         (accum total by temp.tn temp.posob) + (accum total by temp.tn temp.hlp) +     
                         (accum total by temp.tn temp.nalog) +  (accum total by temp.tn temp.otch) +
                         (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_89) + 
                         (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_13) + 
                         (accum total by temp.tn temp.pr4_14) +
                         (accum total by temp.tn temp.pr5_9) +  (accum total by temp.tn temp.pr5_10a) +
                         (accum total by temp.tn temp.pr5_10b) +
                         (accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) + (accum total by temp.tn temp.oos4).

     create tottemp.
     assign 
           tottemp.prz = 9  /*амортизация ОС*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[7]
           tottemp.des  = des[7] 
           tottemp.sum = 0.

     create tottemp.
     assign 
           tottemp.prz = 10 /*амортизация нематериальных активов*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[8]
           tottemp.des  = des[8] 
           tottemp.sum = (accum total by temp.tn temp.oos5).

     create tottemp.
     assign 
           tottemp.prz = 11 /*затраты на ТМЦ*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.tn temp.pr9_4a) + (accum total by temp.tn temp.pr9_4b) + 
                          (accum total by temp.tn temp.pr9_4c) + (accum total by temp.tn temp.pr9_4d) + 
                          (accum total by temp.tn temp.pr9_4e) + (accum total by temp.tn temp.pr9_4f). 

     create tottemp.
     assign 
           tottemp.prz = 12 /*бланочная продукция*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.tn temp.pr9_5a) + (accum total by temp.tn temp.pr9_5b) + (accum total by temp.tn temp.pr9_5c) .


     create tottemp.
     assign 
           tottemp.prz = 13 /*канц товары*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.tn temp.pr9_6) .


     create tottemp.
     assign 
           tottemp.prz = 14 /*приобретение печатной продукции*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum = (accum total by temp.tn temp.pr9_7a) + (accum total by temp.tn temp.pr9_7b) + 
                         (accum total by temp.tn temp.pr9_7c) + (accum total by temp.tn temp.pr9_7d) + 
                         (accum total by temp.tn temp.pr9_7e) + (accum total by temp.tn temp.pr9_7f).



     create tottemp.
     assign 
           tottemp.prz = 15 /*затраты на услуги связи*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.tn temp.pr5_12a) + (accum total by temp.tn temp.pr5_12b) +
                          (accum total by temp.tn temp.pr5_12c) +  (accum total by temp.tn temp.pr5_15)  + 
                          (accum total by temp.tn temp.pr5_16)   .


     create tottemp.
     assign 
           tottemp.prz = 16 /*ИТОГО косвенные затраты*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.tn temp.oos5) +
                         (accum total by temp.tn temp.pr5_12a) + (accum total by temp.tn temp.pr5_12b) +
                         (accum total by temp.tn temp.pr5_12c) +  (accum total by temp.tn temp.pr5_15)  + 
                         (accum total by temp.tn temp.pr5_16)  +
            (accum total by temp.tn temp.pr9_4a) + (accum total by temp.tn temp.pr9_4b) + (accum total by temp.tn temp.pr9_4c) + (accum total by temp.tn temp.pr9_4d) + (accum total by temp.tn temp.pr9_4e) + (accum total by temp.tn temp.pr9_4f) + (accum total by temp.tn temp.pr9_5a) + (accum total by temp.tn temp.pr9_5b) + (accum total by temp.tn temp.pr9_5c) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7a) + (accum total by temp.tn temp.pr9_7b) + (accum total by temp.tn temp.pr9_7c) + (accum total by temp.tn temp.pr9_7d) + (accum total by temp.tn temp.pr9_7e) + (accum total by temp.tn temp.pr9_7f).

     create tottemp.
     assign 
           tottemp.prz = 17 /*коммунальные услуги*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[13]
           tottemp.des = des[13] 
           tottemp.sum = (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_56) + 
                         (accum total by temp.tn temp.pr10_7)  + (accum total by temp.tn temp.pr10_8)  + 
                         (accum total by temp.tn temp.pr10_9)  + (accum total by temp.tn temp.pr10_10).


     create tottemp.
     assign 
           tottemp.prz = 18 /*кап ремонт ОС*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[15]
           tottemp.des = des[15] 
           tottemp.sum = 0.

     create tottemp.
     assign 
           tottemp.prz = 19  /*тек ремонт и осмотр ОС*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[16]
           tottemp.des = des[16] 
           tottemp.sum = (accum total by temp.tn temp.pr11_10)  + (accum total by temp.tn temp.pr11_11)  
                         + (accum total by temp.tn temp.pr11_12)  + (accum total by temp.tn temp.pr11_14).

     create tottemp.
     assign 
           tottemp.prz = 20  /*прочие админ расходы*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.tn temp.pr6_7).

     create tottemp.
     assign 
           tottemp.prz = 21  /*представительские затраты, связанные с празд мероприятиями*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.tn temp.pr6_8).
 

     create tottemp.
     assign 
           tottemp.prz = 22  /*ИТОГО общебанковские*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_56) + 
                         (accum total by temp.tn temp.pr10_7)  + (accum total by temp.tn temp.pr10_8)  + 
                         (accum total by temp.tn temp.pr10_9)  + (accum total by temp.tn temp.pr10_10) + 
                         (accum total by temp.tn temp.pr11_10)  + (accum total by temp.tn temp.pr11_11)+     
                         (accum total by temp.tn temp.pr11_12)  + (accum total by temp.tn temp.pr11_14)+
                         (accum total by temp.tn temp.pr6_7) + 
                         (accum total by temp.tn temp.pr6_8) . 


     create tottemp.
     assign 
           tottemp.prz = 23  /*ВСЕГО*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.tn temp.oklad) + (accum total by temp.tn temp.otpusk) +
                         (accum total by temp.tn temp.nadb) + (accum total by temp.tn temp.prem) +   
                         (accum total by temp.tn temp.posob) + (accum total by temp.tn temp.hlp) +     
                         (accum total by temp.tn temp.nalog) +  (accum total by temp.tn temp.otch) +
                         (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_89) + 
                         (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_13) + 
                         (accum total by temp.tn temp.pr4_14) +
                         (accum total by temp.tn temp.pr5_9) +  (accum total by temp.tn temp.pr5_10a) +
                         (accum total by temp.tn temp.pr5_10b) +                                         
                         (accum total by temp.tn temp.pr5_12a) + (accum total by temp.tn temp.pr5_12b) +
                         (accum total by temp.tn temp.pr5_12c) +  (accum total by temp.tn temp.pr5_15)  + 
                         (accum total by temp.tn temp.pr5_16)  +
                         (accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) + (accum total by temp.tn temp.oos4) + 
                         (accum total by temp.tn temp.oos5) +
                         (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_56) + 
                         (accum total by temp.tn temp.pr10_7)  + (accum total by temp.tn temp.pr10_8)  + 
                         (accum total by temp.tn temp.pr10_9)  + (accum total by temp.tn temp.pr10_10) + 
                         (accum total by temp.tn temp.pr11_10)  + (accum total by temp.tn temp.pr11_11)+     
                         (accum total by temp.tn temp.pr11_12)  + (accum total by temp.tn temp.pr11_14)+
                         (accum total by temp.tn temp.pr6_7) + 
                         (accum total by temp.tn temp.pr6_8) + 
                         (accum total by temp.tn temp.pr9_4a) + (accum total by temp.tn temp.pr9_4b) + (accum total by temp.tn temp.pr9_4c) + (accum total by temp.tn temp.pr9_4d) + (accum total by temp.tn temp.pr9_4e) + (accum total by temp.tn temp.pr9_4f) + (accum total by temp.tn temp.pr9_5a) + (accum total by temp.tn temp.pr9_5b) + (accum total by temp.tn temp.pr9_5c) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7a) + (accum total by temp.tn temp.pr9_7b) + (accum total by temp.tn temp.pr9_7c) + (accum total by temp.tn temp.pr9_7d) + (accum total by temp.tn temp.pr9_7e) + (accum total by temp.tn temp.pr9_7f) .


end.
 end.

 for each tottemp break by tottemp.dep by tottemp.prz.
   accum tottemp.sum   (total by tottemp.dep ).

 if first-of(tottemp.dep) then
 put stream vcrpt unformatted
       "<TR valign=""top"">" skip 
      "<TD>" tottemp.dep "</TD>" skip
      "<TD>" tottemp.dep "</TD>" skip
      "<TD>"  tottemp.depname "</TD>" skip.

 if first-of(tottemp.prz) then
  put stream vcrpt unformatted
      "<TD>" replace(string(tottemp.sum ,"zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip.

/*  if last-of(tottemp.dep)  then
 put stream vcrpt unformatted
      "<TD>" replace(string((accum total by tottemp.dep tottemp.sum) ,"zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip.
  */
end. 
 put stream vcrpt unformatted
    "</TR>" skip.

 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril13*/
else if v-pril = '14' then do:

{pr3.i &dep = "true"}
{pr4.i}
{pr5.i}
{pr6.i}
{pr7.i}
{pr9.i &dep = "true"}
{pr10.i}
{pr11.i}

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br>Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .
  
put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD rowspan=2><FONT size=""1""><B>N/N</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Код подразделения</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Наимен.подразделения</B></FONT></TD>" skip
     " <TD colspan=7>Прямые затраты </TD>" skip 
     " <TD rowspan=2>Итого прямые затраты </TD>" skip 
     " <TD colspan=7>Косвенные затраты </TD>" skip 
     " <TD rowspan=2>Итого косвенные затраты </TD>" skip 
     " <TD colspan=5>Общебанковские затраты </TD>" skip 
     " <TD rowspan=2>Итого общебанк.затраты  </TD>" skip 
     " <TD rowspan=2>ВСЕГО  </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Затраты на оплату труда персонала</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Соц.налог </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию ОС,закрепленных за сотр. </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты,связанные с обучением персонала </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на служ.командировки(в т.ч.представ.затраты, связанные с выездами в командировки) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие адм.затраты(оформление виз) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на услуги связи(сотовые и персональные телефоны) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию ОС общего значения </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на амортизацию НМА </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на товарно-материальные ценности(запасы) </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на бланочную продукцию </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на канц.товары </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на приобретение печатной продукции </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на услуги связи </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на коммунальные услуги </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на кап.ремонт ОС </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Затраты на тек.ремонт и осмотр ОС </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие админист.затраты </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Представит.затраты, связанные с проведением праздничных мероприятий,соревн и др.) </B></FONT></TD>" skip
   "</TR>" skip.


for each temp break by temp.dep  .
   accum temp.dnf    (total by temp.dep ).

   accum temp.oklad  (total by temp.dep ).
   accum temp.otpusk (total by temp.dep ).
   accum temp.nadb   (total by temp.dep ).
   accum temp.prem   (total by temp.dep ).
   accum temp.posob  (total by temp.dep ).
   accum temp.hlp    (total by temp.dep ).
   accum temp.nalog  (total by temp.dep ).
   accum temp.otch   (total by temp.dep ).

     accum temp.oos1 (total by temp.dep ).
     accum temp.oos2 (total by temp.dep ).
     accum temp.oos3 (total by temp.dep ).
     accum temp.oos4 (total by temp.dep ).
     accum temp.oos5 (total by temp.dep ).
     accum temp.pr4_7 (total   by temp.dep ).
     accum temp.pr4_89 (total  by temp.dep ).
     accum temp.pr4_11 (total  by temp.dep ).
     accum temp.pr4_12 (total  by temp.dep ).
     accum temp.pr4_13 (total  by temp.dep ).
     accum temp.pr4_14 (total  by temp.dep ).
     accum temp.pr5_9   (total by temp.dep ).
     accum temp.pr5_10a (total by temp.dep ).
     accum temp.pr5_10b (total by temp.dep ).
     accum temp.pr5_12a (total by temp.dep ).
     accum temp.pr5_12b (total by temp.dep ).
     accum temp.pr5_12c (total by temp.dep ).
     accum temp.pr5_15 (total  by temp.dep ).
     accum temp.pr5_16 (total  by temp.dep ).

     accum temp.pr9_4a (total  by temp.dep ).
     accum temp.pr9_4b (total  by temp.dep ).
     accum temp.pr9_4c (total  by temp.dep ).
     accum temp.pr9_4d (total  by temp.dep ).
     accum temp.pr9_4e (total  by temp.dep ).
     accum temp.pr9_4f (total  by temp.dep ).
     accum temp.pr9_5a (total  by temp.dep ).
     accum temp.pr9_5b (total  by temp.dep ).
     accum temp.pr9_5c (total  by temp.dep ).
     accum temp.pr9_6  (total  by temp.dep ).
     accum temp.pr9_7a (total  by temp.dep ).
     accum temp.pr9_7b (total  by temp.dep ).
     accum temp.pr9_7c (total  by temp.dep ).
     accum temp.pr9_7d (total  by temp.dep ).
     accum temp.pr9_7e (total  by temp.dep ).
     accum temp.pr9_7f (total  by temp.dep ).

     accum temp.pr10_4  (total by temp.dep ).
     accum temp.pr10_56 (total by temp.dep ).
     accum temp.pr10_7  (total by temp.dep ).
     accum temp.pr10_8  (total by temp.dep ).
     accum temp.pr10_9  (total by temp.dep ).
     accum temp.pr10_10 (total by temp.dep ).
     accum temp.pr11_10 (total by temp.dep ).
     accum temp.pr11_11 (total by temp.dep ).
     accum temp.pr11_12 (total by temp.dep ).
     accum temp.pr11_14 (total by temp.dep ).
     accum temp.pr6_7   (total by temp.dep ).
     accum temp.pr6_8   (total by temp.dep ).

  if last-of(temp.dep) then do:

     create tottemp.
     assign
           tottemp.prz = 1   /*зп, премии и тп*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[1]
           tottemp.des  = des[1] 
           tottemp.sum = (accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) + 
                         (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) + 
                         (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp).
     create tottemp.
     assign 
           tottemp.prz = 2 /*соц налог*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[2]
           tottemp.des  = des[2] 
           tottemp.sum = (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch).

     create tottemp.
     assign 
           tottemp.prz = 3  /*амортизация ОС, закрепленных за сотрудником*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum = (accum total by temp.dep temp.oos1) +  (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4).

     create tottemp.
     assign 
           tottemp.prz = 4  /*подготовка  переподготовка */
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_89).

     create tottemp.
     assign 
           tottemp.prz = 5 /*командировки*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13).

     create tottemp.
     assign 
           tottemp.prz = 6 /*прочие админист расходы*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[5]
           tottemp.des  = des[5] 
           tottemp.sum = (accum total by temp.dep temp.pr4_14).


     create tottemp.
     assign 
           tottemp.prz = 7  /*телефония*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[6]
           tottemp.des  = des[6] 
           tottemp.sum = (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10a) + 
                         (accum total by temp.dep temp.pr5_10b).

     create tottemp.
     assign 
           tottemp.prz = 8 /*ИТОГО прямые затраты*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) +
                         (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) +   
                         (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp) +     
                         (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch) +
                         (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_89) + 
                         (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13) + 
                         (accum total by temp.dep temp.pr4_14) +
                         (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10a) +
                         (accum total by temp.dep temp.pr5_10b) +
                         (accum total by temp.dep temp.oos1) +  (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4).

     create tottemp.
     assign 
           tottemp.prz = 9  /*амортизация ОС*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[7]
           tottemp.des  = des[7] 
           tottemp.sum = 0.

     create tottemp.
     assign 
           tottemp.prz = 10 /*амортизация нематериальных активов*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[8]
           tottemp.des  = des[8] 
           tottemp.sum = (accum total by temp.dep temp.oos5).

     create tottemp.
     assign 
           tottemp.prz = 11 /*затраты на ТМЦ*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + 
                          (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) + 
                          (accum total by temp.dep temp.pr9_4e) + (accum total by temp.dep temp.pr9_4f). 

     create tottemp.
     assign 
           tottemp.prz = 12 /*бланочная продукция*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + (accum total by temp.dep temp.pr9_5c) .


     create tottemp.
     assign 
           tottemp.prz = 13 /*канц товары*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.dep temp.pr9_6) .


     create tottemp.
     assign 
           tottemp.prz = 14 /*приобретение печатной продукции*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum = (accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + 
                         (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) + 
                         (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f).



     create tottemp.
     assign 
           tottemp.prz = 15 /*затраты на услуги связи*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.dep temp.pr5_12a) + (accum total by temp.dep temp.pr5_12b) +
                          (accum total by temp.dep temp.pr5_12c) +  (accum total by temp.dep temp.pr5_15)  + 
                          (accum total by temp.dep temp.pr5_16)   .


     create tottemp.
     assign 
           tottemp.prz = 16 /*ИТОГО косвенные затраты*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.dep temp.oos5) +
                         (accum total by temp.dep temp.pr5_12a) + (accum total by temp.dep temp.pr5_12b) +
                         (accum total by temp.dep temp.pr5_12c) +  (accum total by temp.dep temp.pr5_15)  + 
                         (accum total by temp.dep temp.pr5_16)  +
            (accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) + (accum total by temp.dep temp.pr9_4e) + (accum total by temp.dep temp.pr9_4f) + (accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + (accum total by temp.dep temp.pr9_5c) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) + (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f).

     create tottemp.
     assign 
           tottemp.prz = 17 /*коммунальные услуги*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[13]
           tottemp.des = des[13] 
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_56) + 
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10).


     create tottemp.
     assign 
           tottemp.prz = 18 /*кап ремонт ОС*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[15]
           tottemp.des = des[15] 
           tottemp.sum = 0.

     create tottemp.
     assign 
           tottemp.prz = 19  /*тек ремонт и осмотр ОС*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[16]
           tottemp.des = des[16] 
           tottemp.sum = (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)  
                         + (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14).

     create tottemp.
     assign 
           tottemp.prz = 20  /*прочие админ расходы*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.dep temp.pr6_7).

     create tottemp.
     assign 
           tottemp.prz = 21  /*представительские затраты, связанные с празд мероприятиями*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.dep temp.pr6_8).
 

     create tottemp.
     assign 
           tottemp.prz = 22  /*ИТОГО общебанковские*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_56) + 
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10) + 
                         (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)+     
                         (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14)+
                         (accum total by temp.dep temp.pr6_7) + 
                         (accum total by temp.dep temp.pr6_8) . 


     create tottemp.
     assign 
           tottemp.prz = 23  /*ВСЕГО*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des = des[17] 
           tottemp.sum = (accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) +
                         (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) +   
                         (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp) +     
                         (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch) +
                         (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_89) + 
                         (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_13) + 
                         (accum total by temp.dep temp.pr4_14) +
                         (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10a) +
                         (accum total by temp.dep temp.pr5_10b) +                                         
                         (accum total by temp.dep temp.oos1) +  (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4) + 
                         (accum total by temp.dep temp.oos5) +
                         (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_56) + 
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10) + 
                         (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)+     
                         (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14)+
                         (accum total by temp.dep temp.pr6_7) + 
                         (accum total by temp.dep temp.pr6_8) + 
                         (accum total by temp.dep temp.pr9_4a) + (accum total by temp.dep temp.pr9_4b) + (accum total by temp.dep temp.pr9_4c) + (accum total by temp.dep temp.pr9_4d) + (accum total by temp.dep temp.pr9_4e) + (accum total by temp.dep temp.pr9_4f) + (accum total by temp.dep temp.pr9_5a) + (accum total by temp.dep temp.pr9_5b) + (accum total by temp.dep temp.pr9_5c) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7a) + (accum total by temp.dep temp.pr9_7b) + (accum total by temp.dep temp.pr9_7c) + (accum total by temp.dep temp.pr9_7d) + (accum total by temp.dep temp.pr9_7e) + (accum total by temp.dep temp.pr9_7f) .

end.
 end.
