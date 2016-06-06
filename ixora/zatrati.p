/* zatrati.i
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
        22.06.2006 nataly был довавлена обработка склада, Прилож 12,13,14.
*/

{zatratdef.i }
{zatrati.i "new"}
def var i as integer init 1.
def var v-sum as decimal.
def var coldep as integer.


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
     " <TD colspan=8> Затраты на амортизацию ОС, тенге  </TD>" skip
     "<TD rowspan=2><FONT size=""1"">ВСЕГО</FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Здания,сооружения</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Компьютеры, обор-ие</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Другие ОС</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ОС принятым в физлизинг</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ОС для сдачи в аренду</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Транспорт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>За счет прибыли</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>НМА</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

/*{pr3.i &dep = "v-deps.dep = depzl" }*/
{pr3.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr3_7   (total  by temp.dep by temp.tn).
     accum temp.pr3_8 (total  by temp.dep by temp.tn).
     accum temp.pr3_9 (total  by temp.dep by temp.tn).
     accum temp.pr3_10 (total  by temp.dep by temp.tn).
     accum temp.pr3_11 (total  by temp.dep by temp.tn).
     accum temp.pr3_12 (total  by temp.dep by temp.tn).
     accum temp.pr3_13 (total  by temp.dep by temp.tn).
     accum temp.pr3_14 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_10),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr3_7)  + (accum total by temp.tn temp.pr3_8)  + (accum total by temp.tn temp.pr3_9) + (accum total by temp.tn temp.pr3_10)  + (accum total by temp.tn temp.pr3_11)  + (accum total by temp.tn temp.pr3_12) + (accum total by temp.tn temp.pr3_13) + (accum total by temp.tn temp.pr3_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_12)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr3_7)  + (accum total by temp.dep temp.pr3_8)  + (accum total by temp.dep temp.pr3_9) + (accum total by temp.dep temp.pr3_10) + (accum total by temp.dep temp.pr3_11) + (accum total by temp.dep temp.pr3_12)  + (accum total by temp.dep temp.pr3_13)  + (accum total by temp.dep temp.pr3_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
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
     " <TD colspan=3> Затраты на подготовку и переподготовку на терр-ии РК </TD>" skip
     " <TD colspan=3> Затраты на подготовку и переподготовку в странах СНГ и за рубежом </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     " <TD colspan=3> Затраты на служебные командировки </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего затрат</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>менеджмента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>сотрудников</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>рабочих </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>менеджмента</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>сотрудников</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>рабочих </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>суточные</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>проездные</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>квартирные</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr4.i}

for each temp where temp.dep = depzl break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr4_7 (total   by temp.dep by temp.tn).
     accum temp.pr4_8 (total  by temp.dep by temp.tn).
     accum temp.pr4_9 (total  by temp.dep by temp.tn).
     accum temp.pr4_10 (total  by temp.dep by temp.tn).
     accum temp.pr4_11 (total  by temp.dep by temp.tn).
     accum temp.pr4_12 (total  by temp.dep by temp.tn).
     accum temp.pr4_14 (total  by temp.dep by temp.tn).
     accum temp.pr4_15 (total  by temp.dep by temp.tn).
     accum temp.pr4_16 (total  by temp.dep by temp.tn).

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
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_8,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_9,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_10,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_11,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_12,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_7) + (accum total by temp.tn temp.pr4_8) + (accum total by temp.tn temp.pr4_9) + (accum total by temp.tn temp.pr4_10) + (accum total by temp.tn temp.pr4_11) + (accum total by temp.tn temp.pr4_12),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_14,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_15,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(accum total by temp.tn temp.pr4_16,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_14) + (accum total by temp.tn temp.pr4_15) + (accum total by temp.tn temp.pr4_16),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr4_7) + (accum total by temp.tn temp.pr4_8) + (accum total by temp.tn temp.pr4_9) + (accum total by temp.tn temp.pr4_10) + (accum total by temp.tn temp.pr4_11) + (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_14) + (accum total by temp.tn temp.pr4_15) + (accum total by temp.tn temp.pr4_16),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.

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
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_8,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_9,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_10,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_11,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_12,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
         "<TD><b>" replace(string((accum total by temp.dep temp.pr4_7) + (accum total by temp.dep temp.pr4_8) + (accum total by temp.dep temp.pr4_9) + (accum total by temp.dep temp.pr4_10) + (accum total by temp.dep temp.pr4_11)  + (accum total by temp.dep temp.pr4_12) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip 
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_14,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_15,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
        "<TD><b>" + replace(string(accum total by temp.dep temp.pr4_16,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" replace(string((accum total by temp.dep temp.pr4_14) + (accum total by temp.dep temp.pr4_15) + (accum total by temp.dep temp.pr4_16),"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip 
         "<TD><b>" replace(string((accum total by temp.dep temp.pr4_7) + (accum total by temp.dep temp.pr4_8) + (accum total by temp.dep temp.pr4_9) + (accum total by temp.dep temp.pr4_10) + (accum total by temp.dep temp.pr4_11)  + (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_14) + (accum total by temp.dep temp.pr4_15) + (accum total by temp.dep temp.pr4_16) ,"zzzzzzzzzzzzz9.99"),".",",")   "</b></TD>" skip  .

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
     " <TD colspan=3> За пользование сотовой связью </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     " <TD colspan=10> Затраты на услуги связи </TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Итого</B></FONT></TD>" skip
     "<TD rowspan=2><FONT size=""1""><B>Всего затрат</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>GSM</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Dalacom </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>K-mobile</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Казахтелеком</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Нурсат</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Алматытелеком</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Astel</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Арна</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>АлмаТВ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Плата за телефон</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Спут связь ""Орбита плюс""</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Казтелепорт - пользование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Начисл расходы на услуги</B></FONT></TD>" skip.

put stream vcrpt unformatted
   "</TR>" skip.

{pr5.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr5_9   (total  by temp.dep by temp.tn).
     accum temp.pr5_10 (total  by temp.dep by temp.tn).
     accum temp.pr5_11 (total  by temp.dep by temp.tn).
     accum temp.pr5_13 (total  by temp.dep by temp.tn).
     accum temp.pr5_14 (total  by temp.dep by temp.tn).
     accum temp.pr5_15 (total  by temp.dep by temp.tn).
     accum temp.pr5_16 (total  by temp.dep by temp.tn).
     accum temp.pr5_17 (total  by temp.dep by temp.tn).
     accum temp.pr5_18 (total  by temp.dep by temp.tn).
     accum temp.pr5_19 (total  by temp.dep by temp.tn).
     accum temp.pr5_20 (total  by temp.dep by temp.tn).
     accum temp.pr5_21 (total  by temp.dep by temp.tn).
     accum temp.pr5_22 (total  by temp.dep by temp.tn).


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
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_9) + (accum total by temp.tn temp.pr5_10) + (accum total by temp.tn temp.pr5_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_19) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_20) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_21) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_13)  + (accum total by temp.tn temp.pr5_14) + (accum total by temp.tn temp.pr5_15)  + (accum total by temp.tn temp.pr5_16)  + (accum total by temp.tn temp.pr5_17) + (accum total by temp.tn temp.pr5_18)  + (accum total by temp.tn temp.pr5_19) + (accum total by temp.tn temp.pr5_20)  + (accum total by temp.tn temp.pr5_21) + (accum total by temp.tn temp.pr5_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr5_9)  + (accum total by temp.tn temp.pr5_10)  + (accum total by temp.tn temp.pr5_11) + (accum total by temp.tn temp.pr5_13)  + (accum total by temp.tn temp.pr5_14)  + (accum total by temp.tn temp.pr5_15) + (accum total by temp.tn temp.pr5_16) + (accum total by temp.tn temp.pr5_17) + (accum total by temp.tn temp.pr5_18) + (accum total by temp.tn temp.pr5_19) + (accum total by temp.tn temp.pr5_20) + (accum total by temp.tn temp.pr5_21) + (accum total by temp.tn temp.pr5_22),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_9)  + (accum total by temp.dep temp.pr5_10)  + (accum total by temp.dep temp.pr5_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_19) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_20) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_21) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_13) + (accum total by temp.dep temp.pr5_14) + (accum total by temp.dep temp.pr5_15)  + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_17) + (accum total by temp.dep temp.pr5_18) + (accum total by temp.dep temp.pr5_19) + (accum total by temp.dep temp.pr5_20) + (accum total by temp.dep temp.pr5_21) + (accum total by temp.dep temp.pr5_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr5_9)  + (accum total by temp.dep temp.pr5_10)  + (accum total by temp.dep temp.pr5_11) + (accum total by temp.dep temp.pr5_13) + (accum total by temp.dep temp.pr5_14) + (accum total by temp.dep temp.pr5_15)  + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_17) + (accum total by temp.dep temp.pr5_18) + (accum total by temp.dep temp.pr5_19) + (accum total by temp.dep temp.pr5_20) + (accum total by temp.dep temp.pr5_21) + (accum total by temp.dep temp.pr5_22)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

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
     " <TD> ИТОГО </TD>" skip.
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
      "<TD>" + replace(string((accum total by temp.tn temp.pr6_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr6_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr6_8) + (accum total by temp.tn temp.pr6_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip .
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr6_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr6_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
    "<TD><b>" + replace(string((accum total by temp.dep temp.pr6_8) + (accum total by temp.dep temp.pr6_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

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
     "<TD><FONT size=""1""><B>Аренда помещения</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Аренда оборудования</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Аренда др имущества</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Начсил расходы по аренде помещений</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ИТОГО</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr7.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr7_6   (total  by temp.dep by temp.tn).
     accum temp.pr7_7   (total  by temp.dep by temp.tn).
     accum temp.pr7_8   (total  by temp.dep by temp.tn).
     accum temp.pr7_9   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr7_6) + (accum total by temp.tn temp.pr7_7) + (accum total by temp.tn temp.pr7_8) + (accum total by temp.tn temp.pr7_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD>" + replace(string((accum total by temp.dep temp.pr7_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr7_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr7_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr7_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr7_6) + (accum total by temp.dep temp.pr7_7) + (accum total by temp.dep temp.pr7_8)  + (accum total by temp.dep temp.pr7_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril7*/ 
else if v-pril = '08' then do:

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
     "<TD><FONT size=""1""><B>Ремонт здания</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Ремонт автотранспорта(легк авто)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Ремонт автотранспорта(спец авто)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по тек ремонту(техобслуж) компюьтеры, комп оборудование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по тек ремонту(техобслуж) ср-ва охраны и сигнализации</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по тек ремонту(техобслуж) мебель для офиса</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по тек ремонту(техобслуж) прочие ОС</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ИТОГО</B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr8.i}
message depzl.
for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr8_4   (total  by temp.dep by temp.tn).
     accum temp.pr8_5   (total  by temp.dep by temp.tn).
     accum temp.pr8_6   (total  by temp.dep by temp.tn).
     accum temp.pr8_7   (total  by temp.dep by temp.tn).
     accum temp.pr8_8   (total  by temp.dep by temp.tn).
     accum temp.pr8_9   (total  by temp.dep by temp.tn).
     accum temp.pr8_10   (total  by temp.dep by temp.tn).
     accum temp.pr8_11   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr8_4) + (accum total by temp.tn temp.pr8_5) + (accum total by temp.tn temp.pr8_6) + (accum total by temp.tn temp.pr8_7) + (accum total by temp.tn temp.pr8_8) + (accum total by temp.tn temp.pr8_9) + (accum total by temp.tn temp.pr8_10) + (accum total by temp.tn temp.pr8_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.dep temp.pr8_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr8_4) + (accum total by temp.dep temp.pr8_5) + (accum total by temp.dep temp.pr8_6)  + (accum total by temp.dep temp.pr8_7) + (accum total by temp.dep temp.pr8_8) + (accum total by temp.dep temp.pr8_8) + (accum total by temp.dep temp.pr8_9) + (accum total by temp.dep temp.pr8_10) + (accum total by temp.dep temp.pr8_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril8*/ 
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

     accum temp.pr9_4   (total  by temp.dep by temp.tn).
     accum temp.pr9_5   (total  by temp.dep by temp.tn).
     accum temp.pr9_6   (total  by temp.dep by temp.tn).
     accum temp.pr9_7   (total  by temp.dep by temp.tn).

 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>"  temp.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr9_7)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.tn temp.pr9_4) + (accum total by temp.tn temp.pr9_5) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7) , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr9_4)  + (accum total by temp.dep temp.pr9_5) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7) , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril9*/ 

else run zatrati2.
{html-end.i " stream vcrpt "}

output stream vcrpt close.

  unix silent value("cptwin zatrat.html excel").

pause 0.
