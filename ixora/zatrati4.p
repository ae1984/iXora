/* zatrati4.i
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

 if v-pril = '22' then do:

{pr3.i &dep = "true"}
{pr4.i}
{pr5.i &dep = "true" }
{pr6.i}
{pr7.i}
{pr8.i}
{pr9.i &dep = "true" }
{pr10.i}
{pr11.i &dep = "true" }
{pr12.i &dep = "true"}
{pr14.i &dep = "true"}
{pr15.i &dep = "true"}
{pr16.i &dep = "true"}
{pr17.i &dep = "true"}

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

/*     accum temp.oos1 (total by temp.tn ).
     accum temp.oos2 (total by temp.tn ).
     accum temp.oos3 (total by temp.tn ).
     accum temp.oos4 (total by temp.tn ).
     accum temp.oos5 (total by temp.tn ).*/

     accum temp.pr3_7 (total   by temp.tn ).
     accum temp.pr3_8 (total  by temp.tn ).
     accum temp.pr3_9 (total  by temp.tn ).
     accum temp.pr3_10 (total  by temp.tn ).
     accum temp.pr3_11 (total  by temp.tn ).
     accum temp.pr3_12 (total  by temp.tn ).
     accum temp.pr3_13 (total  by temp.tn ).
     accum temp.pr3_14 (total  by temp.tn ).

     accum temp.pr4_7 (total   by temp.tn ).
     accum temp.pr4_8 (total  by temp.tn ).
     accum temp.pr4_9 (total  by temp.tn ).
     accum temp.pr4_10 (total  by temp.tn ).
     accum temp.pr4_11 (total  by temp.tn ).
     accum temp.pr4_12 (total  by temp.tn ).
     accum temp.pr4_14 (total  by temp.tn ).
     accum temp.pr4_15 (total  by temp.tn ).
     accum temp.pr4_16 (total  by temp.tn ).

     accum temp.pr5_9   (total by temp.tn ).
     accum temp.pr5_10 (total by temp.tn ).
     accum temp.pr5_11 (total by temp.tn ).
     accum temp.pr5_13 (total by temp.tn ).
     accum temp.pr5_14 (total  by temp.tn ).
     accum temp.pr5_15 (total  by temp.tn ).
     accum temp.pr5_16 (total  by temp.tn ).
     accum temp.pr5_17 (total  by temp.tn ).
     accum temp.pr5_18 (total  by temp.tn ).
     accum temp.pr5_19 (total  by temp.tn ).
     accum temp.pr5_20 (total  by temp.tn ).
     accum temp.pr5_21 (total  by temp.tn ).
     accum temp.pr5_22 (total  by temp.tn ).

     accum temp.pr6_7   (total by temp.tn ).
     accum temp.pr6_8   (total by temp.tn ).

     accum temp.pr7_6   (total by temp.tn ).
     accum temp.pr7_7   (total by temp.tn ).
     accum temp.pr7_8   (total by temp.tn ).
     accum temp.pr7_9   (total by temp.tn ).

     accum temp.pr8_4   (total by temp.tn ).
     accum temp.pr8_5   (total by temp.tn ).
     accum temp.pr8_6   (total by temp.tn ).
     accum temp.pr8_7   (total by temp.tn ).
     accum temp.pr8_8   (total by temp.tn ).
     accum temp.pr8_9   (total by temp.tn ).
     accum temp.pr8_10   (total by temp.tn ).
     accum temp.pr8_11   (total by temp.tn ).

     accum temp.pr9_4 (total  by temp.tn ).
     accum temp.pr9_5 (total  by temp.tn ).
     accum temp.pr9_6  (total  by temp.tn ).
     accum temp.pr9_7 (total  by temp.tn ).

     accum temp.pr10_4  (total by temp.tn ).
     accum temp.pr10_5 (total by temp.tn ).
     accum temp.pr10_6 (total by temp.tn ).
     accum temp.pr10_7  (total by temp.tn ).
     accum temp.pr10_8  (total by temp.tn ).
     accum temp.pr10_9  (total by temp.tn ).
     accum temp.pr10_10 (total by temp.tn ).

     accum temp.pr11_4 (total by temp.tn ).
     accum temp.pr11_5 (total by temp.tn ).
     accum temp.pr11_6 (total by temp.tn ).
     accum temp.pr11_7 (total by temp.tn ).
     accum temp.pr11_8 (total by temp.tn ).
     accum temp.pr11_9 (total by temp.tn ).
     accum temp.pr11_10 (total by temp.tn ).
     accum temp.pr11_11 (total by temp.tn ).
     accum temp.pr11_12 (total by temp.tn ).
     accum temp.pr11_13 (total by temp.tn ).
     accum temp.pr11_14 (total by temp.tn ).
     accum temp.pr11_15 (total by temp.tn ).
     accum temp.pr11_16 (total by temp.tn ).
     accum temp.pr11_17 (total by temp.tn ).
     accum temp.pr11_18 (total by temp.tn ).
     accum temp.pr11_19 (total by temp.tn ).
     accum temp.pr11_20 (total by temp.tn ).
     accum temp.pr11_21 (total by temp.tn ).
     accum temp.pr11_22 (total by temp.tn ).
     accum temp.pr11_23 (total by temp.tn ).
     accum temp.pr11_24 (total by temp.tn ).
     accum temp.pr11_25 (total by temp.tn ).
     accum temp.pr11_26 (total by temp.tn ).
     accum temp.pr11_27 (total by temp.tn ).

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
           tottemp.sum = (accum total by temp.tn temp.pr3_7) +  (accum total by temp.tn temp.pr3_8) + (accum total by temp.tn temp.pr3_9) +
                         + (accum total by temp.tn temp.pr3_10)  + (accum total by temp.tn temp.pr3_11)  + (accum total by temp.tn temp.pr3_12)  
                         + (accum total by temp.tn temp.pr3_13)  + (accum total by temp.tn temp.pr3_14) .  

     create tottemp.
     assign 
           tottemp.prz = 4  /*подготовка  переподготовка */
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_8).

     create tottemp.
     assign 
           tottemp.prz = 5 /*командировки*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_15).

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
           tottemp.sum = (accum total by temp.tn temp.pr5_9) + (accum total by temp.tn temp.pr5_10) + (accum total by temp.tn temp.pr5_11) 
                         + (accum total by temp.tn temp.pr5_11) + (accum total by temp.tn temp.pr5_13) + (accum total by temp.tn temp.pr5_14)
                         + (accum total by temp.tn temp.pr5_15) + (accum total by temp.tn temp.pr5_16) + (accum total by temp.tn temp.pr5_17)
                         + (accum total by temp.tn temp.pr5_18) + (accum total by temp.tn temp.pr5_19) + (accum total by temp.tn temp.pr5_20)
                         + (accum total by temp.tn temp.pr5_21) + (accum total by temp.tn temp.pr5_22).
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
                         (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_8) + 
                         (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_14) + 
                         (accum total by temp.tn temp.pr4_14) +
                         (accum total by temp.tn temp.pr5_9) +  (accum total by temp.tn temp.pr5_10) +
                         (accum total by temp.tn temp.pr3_7) +  (accum total by temp.tn temp.pr3_8) + (accum total by temp.tn temp.pr3_9) +
                         + (accum total by temp.tn temp.pr3_10)  + (accum total by temp.tn temp.pr3_11)  + (accum total by temp.tn temp.pr3_12)  
                         + (accum total by temp.tn temp.pr3_13)  + (accum total by temp.tn temp.pr3_14) .  
/*                         (accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) + (accum total by temp.tn temp.oos4).*/

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
           tottemp.sum = 0 .

     create tottemp.
     assign 
           tottemp.prz = 11 /*затраты на ТМЦ*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.tn temp.pr9_4) .

     create tottemp.
     assign 
           tottemp.prz = 12 /*бланочная продукция*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.tn temp.pr9_5)  .


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
           tottemp.sum = (accum total by temp.tn temp.pr9_7) .



     create tottemp.
     assign 
           tottemp.prz = 15 /*затраты на услуги связи*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.tn temp.pr5_11) +  (accum total by temp.tn temp.pr5_15)  + 
                          (accum total by temp.tn temp.pr5_16)   .


     create tottemp.
     assign 
           tottemp.prz = 16 /*ИТОГО косвенные затраты*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.tn temp.pr5_11)  +  (accum total by temp.tn temp.pr5_15)  + 
                         (accum total by temp.tn temp.pr5_16)  +
            (accum total by temp.tn temp.pr9_4)  + (accum total by temp.tn temp.pr9_5) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7).

     create tottemp.
     assign 
           tottemp.prz = 17 /*коммунальные услуги*/
           tottemp.dep = temp.tn
           tottemp.depname = temp.name
           tottemp.gl  = totgl[13]
           tottemp.des = des[13] 
           tottemp.sum = (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_5) +  (accum total by temp.tn temp.pr10_6) +
                         (accum total by temp.tn temp.pr10_7)  + (accum total by temp.tn temp.pr10_8)  + 
                         (accum total by temp.tn temp.pr10_9)  + (accum total by temp.tn temp.pr10_10)  .


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
           tottemp.sum = (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_5)  +  (accum total by temp.tn temp.pr10_6) +
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
                         (accum total by temp.tn temp.pr4_7) +  (accum total by temp.tn temp.pr4_8) + 
                         (accum total by temp.tn temp.pr4_11) +  (accum total by temp.tn temp.pr4_12) + (accum total by temp.tn temp.pr4_14) + 
                         (accum total by temp.tn temp.pr4_14) +
                         (accum total by temp.tn temp.pr5_9) +  (accum total by temp.tn temp.pr5_10) +                                          
                         (accum total by temp.tn temp.pr5_11) +  (accum total by temp.tn temp.pr5_15)  + 
                         (accum total by temp.tn temp.pr5_16)  +
                         (accum total by temp.tn temp.pr3_7) +  (accum total by temp.tn temp.pr3_8) + (accum total by temp.tn temp.pr3_9) +
                         + (accum total by temp.tn temp.pr3_10)  + (accum total by temp.tn temp.pr3_11)  + (accum total by temp.tn temp.pr3_12)  
                         + (accum total by temp.tn temp.pr3_13)  + (accum total by temp.tn temp.pr3_14) +   
/*                         (accum total by temp.tn temp.oos1) +  (accum total by temp.tn temp.oos2) + (accum total by temp.tn temp.oos3) + (accum total by temp.tn temp.oos4) + 
                         (accum total by temp.tn temp.oos5) + */
                         (accum total by temp.tn temp.pr10_4)  + (accum total by temp.tn temp.pr10_5)  + (accum total by temp.tn temp.pr10_6) + 
                         (accum total by temp.tn temp.pr10_7)  + (accum total by temp.tn temp.pr10_8)  + 
                         (accum total by temp.tn temp.pr10_9)  + (accum total by temp.tn temp.pr10_10) + 
                         (accum total by temp.tn temp.pr11_10)  + (accum total by temp.tn temp.pr11_11)+     
                         (accum total by temp.tn temp.pr11_12)  + (accum total by temp.tn temp.pr11_14)+
                         (accum total by temp.tn temp.pr6_7) + 
                         (accum total by temp.tn temp.pr6_8) + 
                         (accum total by temp.tn temp.pr9_4) + (accum total by temp.tn temp.pr9_5) + (accum total by temp.tn temp.pr9_6) + (accum total by temp.tn temp.pr9_7) .


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

end.  /*pril22*/
else if v-pril = '23' then do:

{pr3.i &dep = "true"}
{pr4.i}
{pr5.i &dep = "true" }
{pr6.i}
{pr7.i}
{pr9.i &dep = "true"}
{pr10.i}
{pr11.i &dep = "true"}
{pr12.i &dep = "true"}
{pr14.i &dep = "true"}
{pr15.i &dep = "true"}
{pr16.i &dep = "true"}
{pr17.i &dep = "true"}

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

/*     accum temp.oos1 (total by temp.dep ).
     accum temp.oos2 (total by temp.dep ).
     accum temp.oos3 (total by temp.dep ).
     accum temp.oos4 (total by temp.dep ).
     accum temp.oos5 (total by temp.dep ).*/

     accum temp.pr3_7 (total  by temp.dep ).
     accum temp.pr3_8 (total  by temp.dep ).
     accum temp.pr3_9 (total  by temp.dep ).
     accum temp.pr3_10 (total  by temp.dep ).
     accum temp.pr3_11 (total  by temp.dep ).
     accum temp.pr3_12 (total  by temp.dep ).
     accum temp.pr3_13 (total  by temp.dep ).
     accum temp.pr3_14 (total  by temp.dep ).

     accum temp.pr4_7 (total   by temp.dep ).
     accum temp.pr4_8 (total  by temp.dep ).
     accum temp.pr4_9 (total  by temp.dep ).
     accum temp.pr4_10 (total  by temp.dep ).
     accum temp.pr4_11 (total  by temp.dep ).
     accum temp.pr4_12 (total  by temp.dep ).
     accum temp.pr4_14 (total  by temp.dep ).

     accum temp.pr5_9   (total by temp.dep ).
     accum temp.pr5_10 (total by temp.dep ).
     accum temp.pr5_11 (total by temp.dep ).
     accum temp.pr5_13 (total by temp.dep ).
     accum temp.pr5_14 (total  by temp.dep ).
     accum temp.pr5_15 (total  by temp.dep ).
     accum temp.pr5_16 (total  by temp.dep ).
     accum temp.pr5_17 (total  by temp.dep ).
     accum temp.pr5_18 (total  by temp.dep ).
     accum temp.pr5_19 (total  by temp.dep ).
     accum temp.pr5_20 (total  by temp.dep ).
     accum temp.pr5_21 (total  by temp.dep ).
     accum temp.pr5_22 (total  by temp.dep ).

     accum temp.pr9_4 (total  by temp.dep ).
     accum temp.pr9_5 (total  by temp.dep ).
     accum temp.pr9_6  (total  by temp.dep ).
     accum temp.pr9_7 (total  by temp.dep ).

     accum temp.pr10_4  (total by temp.dep ).
     accum temp.pr10_5 (total by temp.dep ).
     accum temp.pr10_6 (total by temp.dep ).
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
           tottemp.sum =   (accum total by temp.dep temp.pr3_7) +  (accum total by temp.dep temp.pr3_8) + (accum total by temp.dep temp.pr3_9) +
                         + (accum total by temp.dep temp.pr3_10)  + (accum total by temp.dep temp.pr3_11)  + (accum total by temp.dep temp.pr3_12)  
                         + (accum total by temp.dep temp.pr3_13)  + (accum total by temp.dep temp.pr3_14) .  

     create tottemp.
     assign 
           tottemp.prz = 4  /*подготовка  переподготовка */
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_8).

     create tottemp.
     assign 
           tottemp.prz = 5 /*командировки*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_14).

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
           tottemp.sum = (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10) .

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
                         (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_8) + 
                         (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_14) + 
                         (accum total by temp.dep temp.pr4_14) +
                         (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10) +
                         (accum total by temp.dep temp.pr3_7) +  (accum total by temp.dep temp.pr3_8) + (accum total by temp.dep temp.pr3_9) +
                         + (accum total by temp.dep temp.pr3_10)  + (accum total by temp.dep temp.pr3_11)  + (accum total by temp.dep temp.pr3_12)  
                         + (accum total by temp.dep temp.pr3_13)  + (accum total by temp.dep temp.pr3_14) .  

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
           tottemp.sum = 0 /*(accum total by temp.dep temp.oos5)*/.

     create tottemp.
     assign 
           tottemp.prz = 11 /*затраты на ТМЦ*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.dep temp.pr9_4).

     create tottemp.
     assign 
           tottemp.prz = 12 /*бланочная продукция*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = (accum total by temp.dep temp.pr9_5)  .


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
           tottemp.sum = (accum total by temp.dep temp.pr9_7).



     create tottemp.
     assign 
           tottemp.prz = 15 /*затраты на услуги связи*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des  = "" 
           tottemp.sum =  (accum total by temp.dep temp.pr5_11)  +  (accum total by temp.dep temp.pr5_15)  + 
                          (accum total by temp.dep temp.pr5_16)   .


     create tottemp.
     assign 
           tottemp.prz = 16 /*ИТОГО косвенные затраты*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = ""
           tottemp.des = "" 
           tottemp.sum = /*(accum total by temp.dep temp.oos5) +*/
                         (accum total by temp.dep temp.pr5_11) + (accum total by temp.dep temp.pr5_15)  + 
                         (accum total by temp.dep temp.pr5_16)  +
            (accum total by temp.dep temp.pr9_4) + (accum total by temp.dep temp.pr9_5) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7).

     create tottemp.
     assign 
           tottemp.prz = 17 /*коммунальные услуги*/
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[13]
           tottemp.des = des[13] 
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_5) + (accum total by temp.dep temp.pr10_6) + 
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8) + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10)  .


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
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_5)  +  (accum total by temp.dep temp.pr10_6) +
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
                         (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_8) + 
                         (accum total by temp.dep temp.pr4_11) +  (accum total by temp.dep temp.pr4_12) + (accum total by temp.dep temp.pr4_14) + 
                         (accum total by temp.dep temp.pr4_14) +
                         (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10) +                                         
                         (accum total by temp.dep temp.pr3_7) +  (accum total by temp.dep temp.pr3_8) + (accum total by temp.dep temp.pr3_9) +
                         + (accum total by temp.dep temp.pr3_10)  + (accum total by temp.dep temp.pr3_11)  + (accum total by temp.dep temp.pr3_12)  
                         + (accum total by temp.dep temp.pr3_13)  + (accum total by temp.dep temp.pr3_14) +  
/*                         (accum total by temp.dep temp.oos1) +  (accum total by temp.dep temp.oos2) + (accum total by temp.dep temp.oos3) + (accum total by temp.dep temp.oos4) + 
                         (accum total by temp.dep temp.oos5) + */
                         (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_5) +  (accum total by temp.dep temp.pr10_6) +
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8)  + 
                         (accum total by temp.dep temp.pr10_9)  + (accum total by temp.dep temp.pr10_10)  +
                         (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)+     
                         (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14)+
                         (accum total by temp.dep temp.pr6_7) + 
                         (accum total by temp.dep temp.pr6_8) + 
                         (accum total by temp.dep temp.pr9_4) + (accum total by temp.dep temp.pr9_5) + (accum total by temp.dep temp.pr9_6) + (accum total by temp.dep temp.pr9_7) .

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

end. 
 put stream vcrpt unformatted
    "</TR>" skip.

 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril23*/
