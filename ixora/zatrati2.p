/* zatrati2.i
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
{zatrati.i }

def var i as integer init 1.
def var v-sum as decimal.
def var coldep as integer.

if v-pril = '10' then do:

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
     " <TD colspan=7> Затраты на коммунальные услуги </TD>" skip 
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
     "<TD><FONT size=""1""><B>другие</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>начисл коммун услуги </B></FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

{pr10.i}

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr10_4   (total  by temp.dep by temp.tn).
     accum temp.pr10_5 (total  by temp.dep by temp.tn).
     accum temp.pr10_6 (total  by temp.dep by temp.tn).
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
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_6),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_5) +  (accum total by temp.tn temp.pr10_6) + (accum total by temp.tn temp.pr10_7) + (accum total by temp.tn temp.pr10_8) + (accum total by temp.tn temp.pr10_9) + (accum total by temp.tn temp.pr10_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_6),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_5)  + (accum total by temp.dep temp.pr10_6) + (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

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
     " <TD colspan=24>Затраты на услуги </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Расходы по услугам справ службы, на радио</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Услуги спец связи,курьерские,почтовые,DHL</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Покупка инфоуслуг</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>MOODis</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Нотариальные услуги</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Накып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Юр инфо,инфотехсервис</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Центр недвижимости</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Казник,Оливема</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Переводческие операции</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>КГП ЦИС подтв счета</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сопровождение программ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Амер торг палата,АФН,Каз фон биржа</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Алсеко,РГКП ГЦВП,компсистемы для бизнеса, кадр агенства</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по инкассации</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Реклама</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх по обсл пожарно-охран сигнал</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>На провдение совещ, приемов,гражд обороны</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>по эксплуат компьютеров и комп оборудования</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>по стоим носителя ключа USBeToken ЮЛ, карт-ридеры</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По эксп ср-в механизации, множит техн устройств связи,др произ оборудования</B></FONT></TD>" skip     "<TD><FONT size=""1""><B>Расходы по инкассации</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Аудиторские и консалтинговые услуги</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по страхованию</B></FONT></TD>" skip
   "</TR>" skip.

{pr11.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.
for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr11_4   (total  by temp.dep by temp.tn).
     accum temp.pr11_5   (total  by temp.dep by temp.tn).
     accum temp.pr11_6   (total  by temp.dep by temp.tn).
     accum temp.pr11_7   (total  by temp.dep by temp.tn).
     accum temp.pr11_8   (total  by temp.dep by temp.tn).
     accum temp.pr11_9   (total  by temp.dep by temp.tn).
     accum temp.pr11_10  (total  by temp.dep by temp.tn).
     accum temp.pr11_11  (total  by temp.dep by temp.tn).
     accum temp.pr11_12  (total  by temp.dep by temp.tn).
     accum temp.pr11_13  (total  by temp.dep by temp.tn).
     accum temp.pr11_14  (total  by temp.dep by temp.tn).
     accum temp.pr11_15   (total  by temp.dep by temp.tn).
     accum temp.pr11_16   (total  by temp.dep by temp.tn).
     accum temp.pr11_17   (total  by temp.dep by temp.tn).
     accum temp.pr11_18   (total  by temp.dep by temp.tn).
     accum temp.pr11_19   (total  by temp.dep by temp.tn).
     accum temp.pr11_20   (total  by temp.dep by temp.tn).
     accum temp.pr11_21   (total  by temp.dep by temp.tn).
     accum temp.pr11_22   (total  by temp.dep by temp.tn).
     accum temp.pr11_23   (total  by temp.dep by temp.tn).
     accum temp.pr11_24   (total  by temp.dep by temp.tn).
     accum temp.pr11_25   (total  by temp.dep by temp.tn).
     accum temp.pr11_26   (total  by temp.dep by temp.tn).
     accum temp.pr11_27   (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum = (accum total by temp.tn temp.pr11_4) + (accum total by temp.tn temp.pr11_5) 
                + (accum total by temp.tn temp.pr11_6) + (accum total by temp.tn temp.pr11_7) 
                + (accum total by temp.tn temp.pr11_8) + (accum total by temp.tn temp.pr11_9) 
                + (accum total by temp.tn temp.pr11_10) + (accum total by temp.tn temp.pr11_11) 
                + (accum total by temp.tn temp.pr11_12) + (accum total by temp.tn temp.pr11_13) 
                + (accum total by temp.tn temp.pr11_14) + (accum total by temp.tn temp.pr11_15)
                + (accum total by temp.tn temp.pr11_16) + (accum total by temp.tn temp.pr11_17) 
                + (accum total by temp.tn temp.pr11_18) + (accum total by temp.tn temp.pr11_19)
                + (accum total by temp.tn temp.pr11_20) + (accum total by temp.tn temp.pr11_21) 
                + (accum total by temp.tn temp.pr11_22) + (accum total by temp.tn temp.pr11_23)
                + (accum total by temp.tn temp.pr11_24) + (accum total by temp.tn temp.pr11_25) 
                + (accum total by temp.tn temp.pr11_26) + (accum total by temp.tn temp.pr11_27).


  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_19) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_20) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_21) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_23) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_24) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_25) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_26) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr11_27) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
    v-sum =       (accum total by temp.dep temp.pr11_4) + (accum total by temp.dep temp.pr11_5) 
                + (accum total by temp.dep temp.pr11_6) + (accum total by temp.dep temp.pr11_7) 
                + (accum total by temp.dep temp.pr11_8) + (accum total by temp.dep temp.pr11_9) 
                + (accum total by temp.dep temp.pr11_10) + (accum total by temp.dep temp.pr11_11) 
                + (accum total by temp.dep temp.pr11_12) + (accum total by temp.dep temp.pr11_13) 
                + (accum total by temp.dep temp.pr11_14) + (accum total by temp.dep temp.pr11_15)
                + (accum total by temp.dep temp.pr11_16) + (accum total by temp.dep temp.pr11_17) 
                + (accum total by temp.dep temp.pr11_18) + (accum total by temp.dep temp.pr11_19)
                + (accum total by temp.dep temp.pr11_20) + (accum total by temp.dep temp.pr11_21) 
                + (accum total by temp.dep temp.pr11_22) + (accum total by temp.dep temp.pr11_23)
                + (accum total by temp.dep temp.pr11_24) + (accum total by temp.dep temp.pr11_25) 
                + (accum total by temp.dep temp.pr11_26) + (accum total by temp.dep temp.pr11_27).
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_11),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_19) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_20) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_21) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_23) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_24) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_25) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_26) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr11_27) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril11*/ 
else if v-pril = '12' then do:

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
     " <TD colspan=7> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>расходы на замену зап частей и др транс ср-в</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>расходы на ГСМ </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>начисл расходы на ГСМ </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>расходы на ТМЦ и зап части по содерж оборудования</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>моющ и дезин ср-ва,обтирочное полотно</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>расходы на ГСМ,зап части</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>по реализ ОС и НМА</B></FONT></TD>" skip
   "</TR>" skip.

{pr12.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr12_4   (total  by temp.dep by temp.tn).
     accum temp.pr12_5 (total  by temp.dep by temp.tn).
     accum temp.pr12_6 (total  by temp.dep by temp.tn).
     accum temp.pr12_7 (total  by temp.dep by temp.tn).
     accum temp.pr12_8 (total  by temp.dep by temp.tn).
     accum temp.pr12_9 (total  by temp.dep by temp.tn).
     accum temp.pr12_10 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr12_4) + (accum total by temp.tn temp.pr12_5) + (accum total by temp.tn temp.pr12_6) + (accum total by temp.tn temp.pr12_7) + (accum total by temp.tn temp.pr12_8)  + (accum total by temp.tn temp.pr12_9)  + (accum total by temp.tn temp.pr12_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr12_4)  + (accum total by temp.dep temp.pr12_5)  + (accum total by temp.dep temp.pr12_6)  + (accum total by temp.dep temp.pr12_7) + (accum total by temp.dep temp.pr12_8) + + (accum total by temp.dep temp.pr12_9) + (accum total by temp.dep temp.pr12_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril12*/ 
else if v-pril = '13' then do:

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
     " <TD colspan=13>Затраты  </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>КНП,уплачен в бюджет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>КНП,удерж нерезидентом</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Оплачен подох налог на нерез</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Налог на доб стом-ть</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по зем налогу</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по налогу на имущество</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сбор с аукцион продаж</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по налогу на транс ср-ва</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Госпошлина</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Соц отчисления</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие налоги</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Штрафы,уплачен в бюджет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по гарнат вкладов</B></FONT></TD>" skip
   "</TR>" skip.

{pr13.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.
for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr13_4   (total  by temp.dep by temp.tn).
     accum temp.pr13_5   (total  by temp.dep by temp.tn).
     accum temp.pr13_6   (total  by temp.dep by temp.tn).
     accum temp.pr13_7   (total  by temp.dep by temp.tn).
     accum temp.pr13_8   (total  by temp.dep by temp.tn).
     accum temp.pr13_9   (total  by temp.dep by temp.tn).
     accum temp.pr13_10  (total  by temp.dep by temp.tn).
     accum temp.pr13_11  (total  by temp.dep by temp.tn).
     accum temp.pr13_12  (total  by temp.dep by temp.tn).
     accum temp.pr13_13  (total  by temp.dep by temp.tn).
     accum temp.pr13_14  (total  by temp.dep by temp.tn).
     accum temp.pr13_15   (total  by temp.dep by temp.tn).
     accum temp.pr13_16   (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum = (accum total by temp.tn temp.pr13_4) + (accum total by temp.tn temp.pr13_5) 
                + (accum total by temp.tn temp.pr13_6) + (accum total by temp.tn temp.pr13_7) 
                + (accum total by temp.tn temp.pr13_8) + (accum total by temp.tn temp.pr13_9) 
                + (accum total by temp.tn temp.pr13_10) + (accum total by temp.tn temp.pr13_11) 
                + (accum total by temp.tn temp.pr13_12) + (accum total by temp.tn temp.pr13_13) 
                + (accum total by temp.tn temp.pr13_14) + (accum total by temp.tn temp.pr13_15)
                + (accum total by temp.tn temp.pr13_16).  


  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr13_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp.dep) then do:
    v-sum =       (accum total by temp.dep temp.pr13_4) + (accum total by temp.dep temp.pr13_5) 
                + (accum total by temp.dep temp.pr13_6) + (accum total by temp.dep temp.pr13_7) 
                + (accum total by temp.dep temp.pr13_8) + (accum total by temp.dep temp.pr13_9) 
                + (accum total by temp.dep temp.pr13_10) + (accum total by temp.dep temp.pr13_11) 
                + (accum total by temp.dep temp.pr13_12) + (accum total by temp.dep temp.pr13_13) 
                + (accum total by temp.dep temp.pr13_14) + (accum total by temp.dep temp.pr13_15)
                + (accum total by temp.dep temp.pr13_16) .
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_11),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr13_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril13*/ 
else if v-pril = '14' then do:

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
     " <TD colspan=5> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>расходы на фьючерсам,форвардам,опционам ср-в</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>прочие по банк деят-ти </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>прочие расх,несвязан с банк деят-тью </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>по акцептам, полученным гарантиям </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>чрезвычайные расходы </B></FONT></TD>" skip
   "</TR>" skip.

{pr14.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr14_4   (total  by temp.dep by temp.tn).
     accum temp.pr14_5 (total  by temp.dep by temp.tn).
     accum temp.pr14_6 (total  by temp.dep by temp.tn).
     accum temp.pr14_7 (total  by temp.dep by temp.tn).
     accum temp.pr14_8 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr14_4) + (accum total by temp.tn temp.pr14_5) + (accum total by temp.tn temp.pr14_6) + (accum total by temp.tn temp.pr14_7) + (accum total by temp.tn temp.pr14_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr14_4)  + (accum total by temp.dep temp.pr14_5)  + (accum total by temp.dep temp.pr14_6)  + (accum total by temp.dep temp.pr14_7) + (accum total by temp.dep temp.pr14_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril14*/ 
else if v-pril = '15' then do:

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
     " <TD colspan=6> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Расх связан с вып по вклад от Правит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По крат крдит получ от друг банков</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы связан с вып по сроч вкладам НБ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы оп крат вкладам др банк до 1 года</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Вознагражд по операц РЕПО с ГЦБ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По займам овернайт др банков</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B></B></FONT></TD>" skip
   "</TR>" skip.

{pr15.i &dep = "t-cods.dep = v-doxras" }

for each temp where temp.dep = depzl  break by temp.dep by temp.tn.
 if first-of(temp.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp.pr15_4   (total  by temp.dep by temp.tn).
     accum temp.pr15_5 (total  by temp.dep by temp.tn).
     accum temp.pr15_6 (total  by temp.dep by temp.tn).
     accum temp.pr15_7 (total  by temp.dep by temp.tn).
     accum temp.pr15_8 (total  by temp.dep by temp.tn).
     accum temp.pr15_9 (total  by temp.dep by temp.tn).


 if last-of(temp.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp.tn  "</TD>" skip
      "<TD>"  temp.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp.tn temp.pr15_4) + (accum total by temp.tn temp.pr15_5) + (accum total by temp.tn temp.pr15_6) + (accum total by temp.tn temp.pr15_7) + (accum total by temp.tn temp.pr15_8)  + (accum total by temp.tn temp.pr15_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
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
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp.dep temp.pr15_4)  + (accum total by temp.dep temp.pr15_5)  + (accum total by temp.dep temp.pr15_6)  + (accum total by temp.dep temp.pr15_7) + (accum total by temp.dep temp.pr15_8) + (accum total by temp.dep temp.pr15_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril15*/ 
else if v-pril = '16' then do:

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
     " <TD colspan=9> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Выплата вознаг ЮЛ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>РАсходы по вклдаам до востреб клиентов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх на вып вознаг по крат деп ЮЛ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх на вып вознаг по крат деп ФЛ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх на крат вклад ФЛ, являющ объектом обяз коллек гарантиров</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх на вып вознаг по долгосроч деп ФЛ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх по долгосроч вклад ФЛ - гаран</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх по условным вклад ФЛ,являющ объектом обяз коллек гарантир</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расх на выплату вознаграж по вкладам гарантиям</B></FONT></TD>" skip
   "</TR>" skip.

{pr16.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.

for each temp1 where temp1.dep = depzl  break by temp1.dep by temp1.tn.
 if first-of(temp1.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp1.pr16_4   (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_5 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_6 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_7 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_8 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_9 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_10 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_11 (total  by temp1.dep by temp1.tn).
     accum temp1.pr16_12 (total  by temp1.dep by temp1.tn).


 if last-of(temp1.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum =       (accum total by temp1.tn temp1.pr16_4) + (accum total by temp1.tn temp1.pr16_5) 
                + (accum total by temp1.tn temp1.pr16_6) + (accum total by temp1.tn temp1.pr16_7) 
                + (accum total by temp1.tn temp1.pr16_8) + (accum total by temp1.tn temp1.pr16_9) 
                + (accum total by temp1.tn temp1.pr16_10) + (accum total by temp1.tn temp1.pr16_11) 
                + (accum total by temp1.tn temp1.pr16_12) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp1.tn  "</TD>" skip
      "<TD>"  temp1.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr16_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp1.dep) then do:
    v-sum =       (accum total by temp1.dep temp1.pr16_4) + (accum total by temp1.dep temp1.pr16_5) 
                + (accum total by temp1.dep temp1.pr16_6) + (accum total by temp1.dep temp1.pr16_7) 
                + (accum total by temp1.dep temp1.pr16_8) + (accum total by temp1.dep temp1.pr16_9) 
                + (accum total by temp1.dep temp1.pr16_10) + (accum total by temp1.dep temp1.pr16_11) 
                + (accum total by temp1.dep temp1.pr16_12) .
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr16_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril16*/ 
else if v-pril = '17' then do:

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
     " <TD colspan=8> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Аморт премии по ГЦБ,для продажи</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по аморт дисконта п овыпущен в обр суб обл 1-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по аморт дисконта по выпущен в обр суб обл 2-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по аморт дисконта по выпущен в обр суб обл 3-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы,связ с вып вознагр по выпущен в обр суб обл 1-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы,связ с вып вознагр по выпущен в обр суб обл 2-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы,связ с вып вознагр по выпущен в обр суб обл 3-го вып</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы от купли-продажи ЦБ</B></FONT></TD>" skip
   "</TR>" skip.

{pr17.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.

for each temp1 where temp1.dep = depzl  break by temp1.dep by temp1.tn.
 if first-of(temp1.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp1.pr17_4   (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_5 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_6 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_7 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_8 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_9 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_10 (total  by temp1.dep by temp1.tn).
     accum temp1.pr17_11 (total  by temp1.dep by temp1.tn).


 if last-of(temp1.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum =       (accum total by temp1.tn temp1.pr17_4) + (accum total by temp1.tn temp1.pr17_5) 
                + (accum total by temp1.tn temp1.pr17_6) + (accum total by temp1.tn temp1.pr17_7) 
                + (accum total by temp1.tn temp1.pr17_8) + (accum total by temp1.tn temp1.pr17_9) 
                + (accum total by temp1.tn temp1.pr17_10) + (accum total by temp1.tn temp1.pr17_11) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp1.tn  "</TD>" skip
      "<TD>"  temp1.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr17_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp1.dep) then do:
    v-sum =       (accum total by temp1.dep temp1.pr17_4) + (accum total by temp1.dep temp1.pr17_5) 
                + (accum total by temp1.dep temp1.pr17_6) + (accum total by temp1.dep temp1.pr17_7) 
                + (accum total by temp1.dep temp1.pr17_8) + (accum total by temp1.dep temp1.pr17_9) 
                + (accum total by temp1.dep temp1.pr17_10) + (accum total by temp1.dep temp1.pr17_11). 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr17_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril17*/ 
else if v-pril = '18' then do:

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
     " <TD colspan=3> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Ассиг по спец резервам по вкл в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Ассиг по спец резервам по займам клиентов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Ассигн по спец резервам по условн обяз</B></FONT></TD>" skip
   "</TR>" skip.

{pr18.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.

for each temp1 where temp1.dep = depzl  break by temp1.dep by temp1.tn.
 if first-of(temp1.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp1.pr18_4   (total  by temp1.dep by temp1.tn).
     accum temp1.pr18_5 (total  by temp1.dep by temp1.tn).
     accum temp1.pr18_6 (total  by temp1.dep by temp1.tn).


 if last-of(temp1.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum =       (accum total by temp1.tn temp1.pr18_4) + (accum total by temp1.tn temp1.pr18_5) 
                + (accum total by temp1.tn temp1.pr18_6) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp1.tn  "</TD>" skip
      "<TD>"  temp1.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr18_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr18_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr18_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp1.dep) then do:
    v-sum =       (accum total by temp1.dep temp1.pr18_4) + (accum total by temp1.dep temp1.pr18_5) 
                + (accum total by temp1.dep temp1.pr18_6) .
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr18_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr18_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr18_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril18*/ 
else if v-pril = '19' then do:

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
     " <TD colspan=4> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Потери по купле продаже безнал инвалюты</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Потери по купле продаже нал инвалюты</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по временной курсовой разнице</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы по переоценке инвалюты</B></FONT></TD>" skip
   "</TR>" skip.

{pr19.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.

for each temp1 where temp1.dep = depzl  break by temp1.dep by temp1.tn.
 if first-of(temp1.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp1.pr19_4   (total  by temp1.dep by temp1.tn).
     accum temp1.pr19_5 (total  by temp1.dep by temp1.tn).
     accum temp1.pr19_6 (total  by temp1.dep by temp1.tn).
     accum temp1.pr19_7 (total  by temp1.dep by temp1.tn).


 if last-of(temp1.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum =       (accum total by temp1.tn temp1.pr19_4) + (accum total by temp1.tn temp1.pr19_5) 
                + (accum total by temp1.tn temp1.pr19_6) + (accum total by temp1.tn temp1.pr19_7) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp1.tn  "</TD>" skip
      "<TD>"  temp1.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr19_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr19_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr19_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr19_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp1.dep) then do:
    v-sum =       (accum total by temp1.dep temp1.pr19_4) + (accum total by temp1.dep temp1.pr19_5) 
                + (accum total by temp1.dep temp1.pr19_6) +  (accum total by temp1.dep temp1.pr19_7).
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr19_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr19_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr19_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr19_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril19*/ 
else if v-pril = '20' then do:

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
     " <TD colspan=8> Затраты </TD>" skip 
     " <TD rowspan=2>ИТОГО </TD>" skip .
put stream vcrpt unformatted
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" 
     "<TD><FONT size=""1""><B>Комис расх от услуг др банков по переводн операциям</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис расх по реал ЦБ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Каз фондовая биржа(за торги по вал)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие комис расходы банка</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Расходы за Cash Letter по дор чекам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Начисл расходы по переводам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис расходы по плат карточкам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис расх по кастодиальной деятельности </B></FONT></TD>" skip
   "</TR>" skip.

{pr20.i &dep = "t-cods.dep = v-doxras" }
 v-sum = 0.

for each temp1 where temp1.dep = depzl  break by temp1.dep by temp1.tn.
 if first-of(temp1.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp1.pr20_4   (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_5 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_6 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_7 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_8 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_9 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_10 (total  by temp1.dep by temp1.tn).
     accum temp1.pr20_11 (total  by temp1.dep by temp1.tn).


 if last-of(temp1.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".
    v-sum =       (accum total by temp1.tn temp1.pr20_4) + (accum total by temp1.tn temp1.pr20_5) 
                + (accum total by temp1.tn temp1.pr20_6) + (accum total by temp1.tn temp1.pr20_7)
                + (accum total by temp1.tn temp1.pr20_8) + (accum total by temp1.tn temp1.pr20_9)
                + (accum total by temp1.tn temp1.pr20_10) + (accum total by temp1.tn temp1.pr20_11) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp1.tn  "</TD>" skip
      "<TD>"  temp1.name  "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_5),"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp1.tn temp1.pr20_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp1.dep) then do:
    v-sum =       (accum total by temp1.dep temp1.pr20_4) + (accum total by temp1.dep temp1.pr20_5) 
                + (accum total by temp1.dep temp1.pr20_6) +  (accum total by temp1.dep temp1.pr20_7)
                + (accum total by temp1.dep temp1.pr20_8) +  (accum total by temp1.dep temp1.pr20_9)
                + (accum total by temp1.dep temp1.pr20_10) +  (accum total by temp1.dep temp1.pr20_11).
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_5),"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp1.dep temp1.pr20_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril20*/ 
else if v-pril = '30' then do:

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
     "<TD><FONT size=""1""><B>По кор счетам банка в НБРК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По кор счетам банка в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по вкл,разм в НБРК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По вкл оврнайт,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По вкл. до востреб,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По крсроч вкл,разм в др банках до 1 мес</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По крсроч вкл,разм в др банках до 1 года</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По долгосроч вкл,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По условн вкл,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Вознаграж по афф драгмет на мет.сч.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по  крсроч кред др банкам </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по долгосроч кред др банкам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доходы по просроч кред др банкам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доходы по  кр/долгоср/просроч займам ОООВБО </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>по овердрафтам пред клиентам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по кред картам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по кратк кред(ЮЛ,ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох-ЮЛ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох-ФЛ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по долгоср кред(ЮЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по долгоср кред(ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох по долгоср (ЮЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох по долгоср (ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по проч кред опрерац </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доход по внутр расчетам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ годн для продажи </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ для торговли </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Аморт премии по вып в ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Аморт премии по вып в обращ суб облиг </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Прочие дох по ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Возн по оп Обр РЕПО с ЦБ </B></FONT></TD>" skip
       "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr30.i &dep = "t-cods.dep = v-doxras" }
     v-sum = 0.
for each temp2 where temp2.dep = depzl  break by temp2.dep by temp2.tn.
 if first-of(temp2.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp2.pr30_4   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_5   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_6   (total  by temp2.dep by temp2.tn).
/*     accum temp2.pr30_7   (total  by temp2.dep by temp2.tn).*/
     accum temp2.pr30_8   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_9   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_10   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_11   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_12   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_13   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_14   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_15   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_16   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_17   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_18   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_19   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_20   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_21   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_22   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_23   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_24   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_25   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_26   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_27   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_28   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_29   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_30   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_31   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_32   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_33   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_34   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_35   (total  by temp2.dep by temp2.tn).
     accum temp2.pr30_36   (total  by temp2.dep by temp2.tn).

 if last-of(temp2.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

 v-sum = (accum total by temp2.tn temp2.pr30_4) + (accum total by temp2.tn temp2.pr30_5) 
                + (accum total by temp2.tn temp2.pr30_6) + (accum total by temp2.tn temp2.pr30_8) 
                + (accum total by temp2.tn temp2.pr30_9) + (accum total by temp2.tn temp2.pr30_10) 
                + (accum total by temp2.tn temp2.pr30_11) + (accum total by temp2.tn temp2.pr30_12) 
                + (accum total by temp2.tn temp2.pr30_13) + (accum total by temp2.tn temp2.pr30_14) 
                + (accum total by temp2.tn temp2.pr30_16) + (accum total by temp2.tn temp2.pr30_16)
                + (accum total by temp2.tn temp2.pr30_17) + (accum total by temp2.tn temp2.pr30_18) 
                + (accum total by temp2.tn temp2.pr30_19) + (accum total by temp2.tn temp2.pr30_20)
                + (accum total by temp2.tn temp2.pr30_21) + (accum total by temp2.tn temp2.pr30_22) 
                + (accum total by temp2.tn temp2.pr30_23) + (accum total by temp2.tn temp2.pr30_24)
                + (accum total by temp2.tn temp2.pr30_25) + (accum total by temp2.tn temp2.pr30_26) 
                + (accum total by temp2.tn temp2.pr30_27) + (accum total by temp2.tn temp2.pr30_28)
                + (accum total by temp2.tn temp2.pr30_29) + (accum total by temp2.tn temp2.pr30_30) 
                + (accum total by temp2.tn temp2.pr30_31) + (accum total by temp2.tn temp2.pr30_31)
                + (accum total by temp2.tn temp2.pr30_33) + (accum total by temp2.tn temp2.pr30_34) 
                + (accum total by temp2.tn temp2.pr30_35) + (accum total by temp2.tn temp2.pr30_36).

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp2.tn  "</TD>" skip
      "<TD>"  temp2.name  "</TD>" skip
      "<TD>"  temp2.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_12)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_16)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_17)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_18)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_19)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  put stream vcrpt unformatted
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_20)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_21)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_22)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_23)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_24)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_25)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_26)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_27)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_28)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_29)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_30)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_31)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_32)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_33)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_34)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_35)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr30_36)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" +  replace(string( v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp2.dep) then do:
        v-sum =     (accum total by temp2.dep temp2.pr30_4)  + (accum total by temp2.dep temp2.pr30_5) 
                               + (accum total by temp2.dep temp2.pr30_6)  + (accum total by temp2.dep temp2.pr30_8) 
                               + (accum total by temp2.dep temp2.pr30_9)  + (accum total by temp2.dep temp2.pr30_10) 
                               + (accum total by temp2.dep temp2.pr30_11) + (accum total by temp2.dep temp2.pr30_12) 
                               + (accum total by temp2.dep temp2.pr30_13) + (accum total by temp2.dep temp2.pr30_14) 
                               + (accum total by temp2.dep temp2.pr30_15) + (accum total by temp2.dep temp2.pr30_16) 
                               + (accum total by temp2.dep temp2.pr30_17) + (accum total by temp2.dep temp2.pr30_18)
                               + (accum total by temp2.dep temp2.pr30_19)  + (accum total by temp2.dep temp2.pr30_20) 
                               + (accum total by temp2.dep temp2.pr30_21)  + (accum total by temp2.dep temp2.pr30_22) 
                               + (accum total by temp2.dep temp2.pr30_23) + (accum total by temp2.dep temp2.pr30_24) 
                               + (accum total by temp2.dep temp2.pr30_25) + (accum total by temp2.dep temp2.pr30_26) 
                               + (accum total by temp2.dep temp2.pr30_27) + (accum total by temp2.dep temp2.pr30_28) 
                               + (accum total by temp2.dep temp2.pr30_29) + (accum total by temp2.dep temp2.pr30_30)
                               + (accum total by temp2.dep temp2.pr30_31)  + (accum total by temp2.dep temp2.pr30_32) 
                               + (accum total by temp2.dep temp2.pr30_33)  + (accum total by temp2.dep temp2.pr30_34) 
                               + (accum total by temp2.dep temp2.pr30_35) + (accum total by temp2.dep temp2.pr30_36). 
 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
 /*     "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip*/
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  put stream vcrpt unformatted
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_19)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_20)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_21)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_23) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_24) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_25) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_26) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_27) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_28) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_29) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_30) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_31) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_32) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_33) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_34) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_35) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr30_36) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril30*/ 
else if v-pril = '31' then do:

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
     "<TD><FONT size=""1""><B>Доходы по купле-продаже ЦБ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по купле-продаже ин валюте без НДС</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Купля-продажа клиентам инвал (ФЛ)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По купле-продажи драг мет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от переоц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от пероц афф драг мет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от пероц займ банкам фикс KZT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от пероц вкладов фикс ЮЛ,ФЛ</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от изм ст-ти ЦБ для торговли</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от изм ст-ти ЦБ для продажи</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от прочей переоцнки</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы от восст убыт от обесц осн ср-в, НМА,УК</B></FONT></TD>" skip
       "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr31.i &dep = "t-cods.dep = v-doxras" }
     v-sum = 0.
for each temp2 where temp2.dep = depzl  break by temp2.dep by temp2.tn.
 if first-of(temp2.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp2.pr31_4   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_5   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_6   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_7   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_8   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_9   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_10   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_11   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_12   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_13   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_14   (total  by temp2.dep by temp2.tn).
     accum temp2.pr31_15   (total  by temp2.dep by temp2.tn).

 if last-of(temp2.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

 v-sum = (accum total by temp2.tn temp2.pr31_4) + (accum total by temp2.tn temp2.pr31_5) 
                + (accum total by temp2.tn temp2.pr31_6) + (accum total by temp2.tn temp2.pr31_7) 
                + (accum total by temp2.tn temp2.pr31_8) + (accum total by temp2.tn temp2.pr31_9) 
                + (accum total by temp2.tn temp2.pr31_10) + (accum total by temp2.tn temp2.pr31_11) 
                + (accum total by temp2.tn temp2.pr31_12) + (accum total by temp2.tn temp2.pr31_13) 
                + (accum total by temp2.tn temp2.pr31_14) + (accum total by temp2.tn temp2.pr31_15).

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp2.tn  "</TD>" skip
      "<TD>"  temp2.name  "</TD>" skip
      "<TD>"  temp2.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_12)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr31_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" +  replace(string( v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp2.dep) then do:
        v-sum =     (accum total by temp2.dep temp2.pr31_4)  + (accum total by temp2.dep temp2.pr31_5) 
                               + (accum total by temp2.dep temp2.pr31_6)  + (accum total by temp2.dep temp2.pr31_8) 
                               + (accum total by temp2.dep temp2.pr31_9)  + (accum total by temp2.dep temp2.pr31_10) 
                               + (accum total by temp2.dep temp2.pr31_11) + (accum total by temp2.dep temp2.pr31_12) 
                               + (accum total by temp2.dep temp2.pr31_13) + (accum total by temp2.dep temp2.pr31_14) 
                               + (accum total by temp2.dep temp2.pr31_15) + (accum total by temp2.dep temp2.pr31_7) .
 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr31_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril31*/ 
else if v-pril = '32' then do:

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
     "<TD><FONT size=""1""><B>По кор счетам банка в НБРК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По кор счетам банка в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по вкл,разм в НБРК</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По вкл оврнайт,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По вкл. до востреб,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По крсроч вкл,разм в др банках до 1 мес</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По крсроч вкл,разм в др банках до 1 года</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По долгосроч вкл,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>По условн вкл,разм в др банках</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Вознаграж по афф драгмет на мет.сч.</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по  крсроч кред др банкам </B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доходы по долгосроч кред др банкам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доходы по просроч кред др банкам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доходы по  кр/долгоср/просроч займам ОООВБО </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>по овердрафтам пред клиентам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по кред картам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по кратк кред(ЮЛ,ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох-ЮЛ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох-ФЛ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по долгоср кред(ЮЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Нач дох по долгоср кред(ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох по долгоср (ЮЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Получ дох по долгоср (ФЛ) </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по проч кред опрерац </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Доход по внутр расчетам </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ годн для продажи </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Дох по ЦБ для торговли </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Аморт премии по вып в ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Аморт премии по вып в обращ суб облиг </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Прочие дох по ЦБ </B></FONT></TD>" skip
    "<TD><FONT size=""1""><B>Возн по оп Обр РЕПО с ЦБ </B></FONT></TD>" skip
       "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr32.i &dep = "t-cods.dep = v-doxras" }
     v-sum = 0.
for each temp2 where temp2.dep = depzl  break by temp2.dep by temp2.tn.
 if first-of(temp2.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp2.pr32_4   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_5   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_6   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_7   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_8   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_9   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_10   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_11   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_12   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_13   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_14   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_15   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_16   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_17   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_18   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_19   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_20   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_21   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_22   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_23   (total  by temp2.dep by temp2.tn).
     accum temp2.pr32_24   (total  by temp2.dep by temp2.tn).

 if last-of(temp2.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

 v-sum = (accum total by temp2.tn temp2.pr32_4) + (accum total by temp2.tn temp2.pr32_5) 
                + (accum total by temp2.tn temp2.pr32_6) + (accum total by temp2.tn temp2.pr32_8) 
                + (accum total by temp2.tn temp2.pr32_9) + (accum total by temp2.tn temp2.pr32_10) 
                + (accum total by temp2.tn temp2.pr32_11) + (accum total by temp2.tn temp2.pr32_12) 
                + (accum total by temp2.tn temp2.pr32_13) + (accum total by temp2.tn temp2.pr32_14) 
                + (accum total by temp2.tn temp2.pr32_16) + (accum total by temp2.tn temp2.pr32_16)
                + (accum total by temp2.tn temp2.pr32_17) + (accum total by temp2.tn temp2.pr32_18) 
                + (accum total by temp2.tn temp2.pr32_19) + (accum total by temp2.tn temp2.pr32_20)
                + (accum total by temp2.tn temp2.pr32_21) + (accum total by temp2.tn temp2.pr32_22) 
                + (accum total by temp2.tn temp2.pr32_23) + (accum total by temp2.tn temp2.pr32_24).

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp2.tn  "</TD>" skip
      "<TD>"  temp2.name  "</TD>" skip
      "<TD>"  temp2.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_12)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_16)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_17)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_18)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_19)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.
  put stream vcrpt unformatted
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_20)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_21)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_22)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_23)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr32_24)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" +  replace(string( v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp2.dep) then do:
        v-sum =     (accum total by temp2.dep temp2.pr32_4)  + (accum total by temp2.dep temp2.pr32_5) 
                               + (accum total by temp2.dep temp2.pr32_6)  + (accum total by temp2.dep temp2.pr32_8) 
                               + (accum total by temp2.dep temp2.pr32_9)  + (accum total by temp2.dep temp2.pr32_10) 
                               + (accum total by temp2.dep temp2.pr32_11) + (accum total by temp2.dep temp2.pr32_12) 
                               + (accum total by temp2.dep temp2.pr32_13) + (accum total by temp2.dep temp2.pr32_14) 
                               + (accum total by temp2.dep temp2.pr32_15) + (accum total by temp2.dep temp2.pr32_16) 
                               + (accum total by temp2.dep temp2.pr32_17) + (accum total by temp2.dep temp2.pr32_18)
                               + (accum total by temp2.dep temp2.pr32_19)  + (accum total by temp2.dep temp2.pr32_20) 
                               + (accum total by temp2.dep temp2.pr32_21)  + (accum total by temp2.dep temp2.pr32_22) 
                               + (accum total by temp2.dep temp2.pr32_23) + (accum total by temp2.dep temp2.pr32_24) .
 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_17) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_18) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  put stream vcrpt unformatted
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_19)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_20)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_21)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_22) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_23) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr32_24) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end. /*pril32*/ 
else if v-pril = '33' then do:

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
     "<TD><FONT size=""1""><B>Доходы от инкас с НДС</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>За дубл выписки(пл карт)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дох по плат карточкам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис за усл сейф депозит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>За дубл плат док-тов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B></B>Комис вознагр по кредитам</FONT></TD>" skip
     "<TD><FONT size=""1""><B>Другие комис доходы</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие комиссии</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис доход за акцепт плат док</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис дох по форфейт операц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис дох за усл банка по фактор операц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доход от продаж</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дох по операц с произв инструм</B></FONT></TD>" skip
       "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr33.i &dep = "t-cods.dep = v-doxras" }
     v-sum = 0.
for each temp2 where temp2.dep = depzl  break by temp2.dep by temp2.tn.
 if first-of(temp2.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp2.pr33_4   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_5   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_6   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_7   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_8   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_9   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_10   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_11   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_12   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_13   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_14   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_15   (total  by temp2.dep by temp2.tn).
     accum temp2.pr33_16   (total  by temp2.dep by temp2.tn).


 if last-of(temp2.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

 v-sum = (accum total by temp2.tn temp2.pr33_4) + (accum total by temp2.tn temp2.pr33_5) 
                + (accum total by temp2.tn temp2.pr33_6) + (accum total by temp2.tn temp2.pr33_7) 
                + (accum total by temp2.tn temp2.pr33_8) + (accum total by temp2.tn temp2.pr33_9) 
                + (accum total by temp2.tn temp2.pr33_10) + (accum total by temp2.tn temp2.pr33_11) 
                + (accum total by temp2.tn temp2.pr33_12) + (accum total by temp2.tn temp2.pr33_13) 
                + (accum total by temp2.tn temp2.pr33_14) + (accum total by temp2.tn temp2.pr33_15)
                + (accum total by temp2.tn temp2.pr33_16) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp2.tn  "</TD>" skip
      "<TD>"  temp2.name  "</TD>" skip
      "<TD>"  temp2.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_7)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_12)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_13)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_14)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_15)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr33_16)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" +  replace(string( v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp2.dep) then do:
        v-sum =     (accum total by temp2.dep temp2.pr33_4)  + (accum total by temp2.dep temp2.pr33_5) 
                               + (accum total by temp2.dep temp2.pr33_6)  + (accum total by temp2.dep temp2.pr33_7) 
                               + (accum total by temp2.dep temp2.pr33_8)  + (accum total by temp2.dep temp2.pr33_9) 
                               + (accum total by temp2.dep temp2.pr33_10) + (accum total by temp2.dep temp2.pr33_11) 
                               + (accum total by temp2.dep temp2.pr33_12) + (accum total by temp2.dep temp2.pr33_13) 
                               + (accum total by temp2.dep temp2.pr33_14) + (accum total by temp2.dep temp2.pr33_15) 
                               + (accum total by temp2.dep temp2.pr33_16) .
 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_12) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_13) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_14) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_15) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr33_16) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril33*/ 
else if v-pril = '34' then do:

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
     "<TD><FONT size=""1""><B>Доходы от инкас с НДС</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>За дубл выписки(пл карт)</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дох по плат карточкам</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис за усл сейф депозит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>За дубл плат док-тов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B></B>Комис вознагр по кредитам</FONT></TD>" skip
     "<TD><FONT size=""1""><B>Другие комис доходы</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прочие комиссии</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис доход за акцепт плат док</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис дох по форфейт операц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Комис дох за усл банка по фактор операц</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Доход от продаж</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дох по операц с произв инструм</B></FONT></TD>" skip
       "<TD><FONT size=""1""><B>Итого</B></FONT></TD>" skip
   "</TR>" skip.

{pr34.i &dep = "t-cods.dep = v-doxras" }
     v-sum = 0.
for each temp2 where temp2.dep = depzl  break by temp2.dep by temp2.tn.
 if first-of(temp2.dep) then 
   put stream vcrpt unformatted 
   "<p><B>Наим-ие подраз-ия  "  v-depname  +  ".<br> Код подразделения  " + v-attn + "</B></p>" skip.

     accum temp2.pr34_4   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_5   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_6   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_7   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_8   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_9   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_10   (total  by temp2.dep by temp2.tn).
     accum temp2.pr34_11   (total  by temp2.dep by temp2.tn).


 if last-of(temp2.tn) then do:
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>".

 v-sum = (accum total by temp2.tn temp2.pr34_4) + (accum total by temp2.tn temp2.pr34_5) 
                + (accum total by temp2.tn temp2.pr34_6) + (accum total by temp2.tn temp2.pr34_7) 
                + (accum total by temp2.tn temp2.pr34_8) + (accum total by temp2.tn temp2.pr34_9) 
                + (accum total by temp2.tn temp2.pr34_10) + (accum total by temp2.tn temp2.pr34_11) .

  put stream vcrpt unformatted
      string(i)  "</TD>" skip
      "<TD>"  temp2.tn  "</TD>" skip
      "<TD>"  temp2.name  "</TD>" skip
      "<TD>"  temp2.post "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_4) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_5) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_6) ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_7)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_8)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_9)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_10)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string((accum total by temp2.tn temp2.pr34_11)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" +  replace(string( v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip.
  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.

 if last-of(temp2.dep) then do:
        v-sum =     (accum total by temp2.dep temp2.pr34_4)  + (accum total by temp2.dep temp2.pr34_5) 
                               + (accum total by temp2.dep temp2.pr34_6)  + (accum total by temp2.dep temp2.pr34_7) 
                               + (accum total by temp2.dep temp2.pr34_8)  + (accum total by temp2.dep temp2.pr34_9) 
                               + (accum total by temp2.dep temp2.pr34_10) + (accum total by temp2.dep temp2.pr34_11) .
 
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD>"  "</TD>" skip
      "<TD><b>  ИТОГО </b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_4)   ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_5)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_6)  ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_7) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_8) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_9) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_10) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string((accum total by temp2.dep temp2.pr34_11) ,"zzzzzzzzzzzzz9.99"),".",",") + "</b></TD>" skip
      "<TD><b>" + replace(string(v-sum , "zzzzzzzzzzzzz9.99"),".",",") + "</B></TD>" skip.

  i = i + 1.
  put stream vcrpt unformatted
    "</TR>" skip.
  end.
 end. 
 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril34*/ 
else run zatrati3. 
