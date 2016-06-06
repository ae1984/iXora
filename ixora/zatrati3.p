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

 if v-pril = '21' then do:

 {pr3.i &dep = "true"}
 {pr4.i}
 {pr5.i &dep = "true" }
 {pr6.i }
 {pr7.i}
 {pr8.i}
 {pr9.i &dep = "true"}
 {pr10.i}
 {pr11.i &dep = "true"}
 {pr12.i &dep = "true"}
 {pr13.i &dep = "true"}
 {pr14.i &dep = "true"}
 {pr15.i &dep = "true"}
 {pr16.i &dep = "true"}
 {pr17.i &dep = "true"}
 {pr18.i &dep = "true"}
 {pr19.i &dep = "true"}
 {pr20.i &dep = "true"}

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

for each temp1 break by temp1.dep  .

     accum temp1.pr16_4 (total by temp1.dep ).
     accum temp1.pr16_5 (total by temp1.dep ).
     accum temp1.pr16_6 (total by temp1.dep ).
     accum temp1.pr16_7 (total by temp1.dep ).
     accum temp1.pr16_8 (total by temp1.dep ).
     accum temp1.pr16_9 (total by temp1.dep ).
     accum temp1.pr16_10 (total by temp1.dep ).
     accum temp1.pr16_11 (total by temp1.dep ).
     accum temp1.pr16_12 (total by temp1.dep ). 

     accum temp1.pr17_4 (total by temp1.dep ).
     accum temp1.pr17_5 (total by temp1.dep ).
     accum temp1.pr17_6 (total by temp1.dep ).
     accum temp1.pr17_7 (total by temp1.dep ).
     accum temp1.pr17_8 (total by temp1.dep ).
     accum temp1.pr17_9 (total by temp1.dep ).
     accum temp1.pr17_10 (total by temp1.dep ).
     accum temp1.pr17_11 (total by temp1.dep ).

     accum temp1.pr18_4 (total by temp1.dep ).
     accum temp1.pr18_5 (total by temp1.dep ).
     accum temp1.pr18_6 (total by temp1.dep ).

     accum temp1.pr19_4 (total by temp1.dep ).
     accum temp1.pr19_5 (total by temp1.dep ).
     accum temp1.pr19_6 (total by temp1.dep ).
     accum temp1.pr19_7 (total by temp1.dep ).

     accum temp1.pr20_4 (total by temp1.dep ).
     accum temp1.pr20_5 (total by temp1.dep ).
     accum temp1.pr20_6 (total by temp1.dep ).
     accum temp1.pr20_7 (total by temp1.dep ).
     accum temp1.pr20_8 (total by temp1.dep ).
     accum temp1.pr20_9 (total by temp1.dep ).
     accum temp1.pr20_10 (total by temp1.dep ).
     accum temp1.pr20_11 (total by temp1.dep ).


  if last-of(temp1.dep) then do:

   /*депозиты клиентов*/ 
    create tottemp.
     assign
           tottemp.prz = 5
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[5]
           tottemp.des  = des[5] 
           tottemp.sum = (accum total by temp1.dep temp1.pr16_4) + (accum total by temp1.dep temp1.pr16_5) + 
                         (accum total by temp1.dep temp1.pr16_6) + (accum total by temp1.dep temp1.pr16_7) +
                         (accum total by temp1.dep temp1.pr16_8) + (accum total by temp1.dep temp1.pr16_9) +
                         (accum total by temp1.dep temp1.pr16_10) + (accum total by temp1.dep temp1.pr16_11) + 
                         (accum total by temp1.dep temp1.pr16_12).

/*       message  tottemp.prz tottemp.dep tottemp.depname tottemp.sum.*/
  /*ЦБ*/ 
      create tottemp.
        assign
           tottemp.prz = 7
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[7]
           tottemp.des  = des[7] 
           tottemp.sum = (accum total by temp1.dep temp1.pr17_4).

  /*Субор долг*/ 
      create tottemp.
       assign
           tottemp.prz = 8
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[8]
           tottemp.des  = des[8] 
           tottemp.sum = (accum total by temp1.dep temp1.pr17_5) + (accum total by temp1.dep temp1.pr17_6) + 
                         (accum total by temp1.dep temp1.pr17_7) + (accum total by  temp1.dep temp1.pr17_8) +
                         (accum total by temp1.dep temp1.pr17_9) + (accum total by temp1.dep temp1.pr17_10). 

 /*ассигнование*/ 
      create tottemp.
       assign
           tottemp.prz = 9
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[9]
           tottemp.des  = des[9] 
           tottemp.sum = (accum total by temp1.dep temp1.pr18_4) + (accum total by temp1.dep temp1.pr18_5) + 
                         (accum total by temp1.dep temp1.pr18_6).
  /*дилинговые операции*/ 
      create tottemp.
       assign
           tottemp.prz = 10
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[10]
           tottemp.des  = des[10] 
           tottemp.sum = (accum total by temp1.dep temp1.pr19_4) + (accum total by temp1.dep temp1.pr19_5) + 
                         (accum total by temp1.dep temp1.pr19_6) + (accum total by temp1.dep temp1.pr17_11) .

  /*комис расходы банка*/ 
      create tottemp.
       assign
           tottemp.prz = 11
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[11]
           tottemp.des  = des[11] 
           tottemp.sum = (accum total by temp1.dep temp1.pr20_4) + (accum total by temp1.dep temp1.pr20_5) + 
                         (accum total by temp1.dep temp1.pr20_6) + (accum total by temp1.dep temp1.pr20_7) +
                         (accum total by temp1.dep temp1.pr20_8) + (accum total by temp1.dep temp1.pr20_9) +
                         (accum total by temp1.dep temp1.pr20_10) + (accum total by temp1.dep temp1.pr20_11) .

  /*от переоценки*/ 
      create tottemp.
       assign
           tottemp.prz = 12
           tottemp.dep = temp1.dep
           tottemp.depname = temp1.depname
           tottemp.gl  = totgl[12]
           tottemp.des  = des[12] 
           tottemp.sum = (accum total by temp1.dep temp1.pr19_7) .

 end. /*last-of*/
end. /*temp1*/
     
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

     accum temp.pr3_7 (total   by temp.dep ).
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
     accum temp.pr4_15 (total  by temp.dep ).
     accum temp.pr4_16 (total  by temp.dep ).

     accum temp.pr5_9   (total by temp.dep ).
     accum temp.pr5_10 (total by temp.dep ).
     accum temp.pr5_11 (total by temp.dep ).
     accum temp.pr5_13 (total by temp.dep ).
     accum temp.pr5_14 (total by temp.dep ).
     accum temp.pr5_15 (total  by temp.dep ).
     accum temp.pr5_16 (total  by temp.dep ).
     accum temp.pr5_17 (total  by temp.dep ).
     accum temp.pr5_18 (total  by temp.dep ).
     accum temp.pr5_19 (total  by temp.dep ).
     accum temp.pr5_20 (total  by temp.dep ).
     accum temp.pr5_21 (total  by temp.dep ).
     accum temp.pr5_22 (total  by temp.dep ).

     accum temp.pr6_7   (total by temp.dep ).
     accum temp.pr6_8   (total by temp.dep ).

     accum temp.pr7_6   (total by temp.dep ).
     accum temp.pr7_7   (total by temp.dep ).
     accum temp.pr7_8   (total by temp.dep ).
     accum temp.pr7_9   (total by temp.dep ).

     accum temp.pr8_4   (total by temp.dep ).
     accum temp.pr8_5   (total by temp.dep ).
     accum temp.pr8_6   (total by temp.dep ).
     accum temp.pr8_7   (total by temp.dep ).
     accum temp.pr8_8   (total by temp.dep ).
     accum temp.pr8_9   (total by temp.dep ).
     accum temp.pr8_10   (total by temp.dep ).
     accum temp.pr8_11   (total by temp.dep ).

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

     accum temp.pr11_4 (total by temp.dep ).
     accum temp.pr11_5 (total by temp.dep ).
     accum temp.pr11_6 (total by temp.dep ).
     accum temp.pr11_7 (total by temp.dep ).
     accum temp.pr11_8 (total by temp.dep ).
     accum temp.pr11_9 (total by temp.dep ).
     accum temp.pr11_10 (total by temp.dep ).
     accum temp.pr11_11 (total by temp.dep ).
     accum temp.pr11_12 (total by temp.dep ).
     accum temp.pr11_13 (total by temp.dep ).
     accum temp.pr11_14 (total by temp.dep ).
     accum temp.pr11_15 (total by temp.dep ).
     accum temp.pr11_16 (total by temp.dep ).
     accum temp.pr11_17 (total by temp.dep ).
     accum temp.pr11_18 (total by temp.dep ).
     accum temp.pr11_19 (total by temp.dep ).
     accum temp.pr11_20 (total by temp.dep ).
     accum temp.pr11_21 (total by temp.dep ).
     accum temp.pr11_22 (total by temp.dep ).
     accum temp.pr11_23 (total by temp.dep ).
     accum temp.pr11_24 (total by temp.dep ).
     accum temp.pr11_25 (total by temp.dep ).
     accum temp.pr11_26 (total by temp.dep ).
     accum temp.pr11_27 (total by temp.dep ).

     accum temp.pr12_4 (total by temp.dep ).
     accum temp.pr12_5 (total by temp.dep ).
     accum temp.pr12_6 (total by temp.dep ).
     accum temp.pr12_7 (total by temp.dep ).
     accum temp.pr12_8 (total by temp.dep ).
     accum temp.pr12_9 (total by temp.dep ).
     accum temp.pr12_10 (total by temp.dep ).

     accum temp.pr13_4 (total by temp.dep ).
     accum temp.pr13_5 (total by temp.dep ).
     accum temp.pr13_6 (total by temp.dep ).
     accum temp.pr13_7 (total by temp.dep ).
     accum temp.pr13_8 (total by temp.dep ).
     accum temp.pr13_9 (total by temp.dep ).
     accum temp.pr13_10 (total by temp.dep ).
     accum temp.pr13_11 (total by temp.dep ).
     accum temp.pr13_12 (total by temp.dep ).
     accum temp.pr13_13 (total by temp.dep ).
     accum temp.pr13_14 (total by temp.dep ).
     accum temp.pr13_15 (total by temp.dep ).
     accum temp.pr13_16 (total by temp.dep ).

     accum temp.pr14_4 (total by temp.dep ).
     accum temp.pr14_5 (total by temp.dep ).
     accum temp.pr14_6 (total by temp.dep ).
     accum temp.pr14_7 (total by temp.dep ).
     accum temp.pr14_8 (total by temp.dep ).

     accum temp.pr15_4 (total by temp.dep ).
     accum temp.pr15_5 (total by temp.dep ).
     accum temp.pr15_6 (total by temp.dep ).
     accum temp.pr15_7 (total by temp.dep ).
     accum temp.pr15_8 (total by temp.dep ).
     accum temp.pr15_9 (total by temp.dep ).

  if last-of(temp.dep) then do:

/*от правительства*/ 
    create tottemp.
     assign
           tottemp.prz = 1
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[1]
           tottemp.des  = des[1] 
           tottemp.sum = (accum total by temp.dep temp.pr15_4).

/*др банки*/ 
    create tottemp.
     assign
           tottemp.prz = 2
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[2]
           tottemp.des  = des[2] 
           tottemp.sum = (accum total by temp.dep temp.pr15_5).
                     
/*овернайт*/ 
    create tottemp.
     assign
           tottemp.prz = 3
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[3]
           tottemp.des  = des[3] 
           tottemp.sum = (accum total by temp.dep temp.pr15_9).

/*вклады др банков*/ 
    create tottemp.
     assign
           tottemp.prz = 4
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[4]
           tottemp.des  = des[4] 
           tottemp.sum = (accum total by temp.dep temp.pr15_6) + (accum total by temp.dep temp.pr15_7).

   /*temp1*/

/*РЕПО*/ 
    create tottemp.
     assign
           tottemp.prz = 6
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[6]
           tottemp.des  = des[6] 
           tottemp.sum = (accum total by temp.dep temp.pr15_8).

  /*temp1*/
 /*ЗП*/
     create tottemp.
     assign
           tottemp.prz = 13
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[13]
           tottemp.des  = des[13] 
           tottemp.sum = (accum total by temp.dep temp.oklad) + (accum total by temp.dep temp.otpusk) + 
                         (accum total by temp.dep temp.nadb) + (accum total by temp.dep temp.prem) + 
                         (accum total by temp.dep temp.posob) + (accum total by temp.dep temp.hlp).
 /*соц налог*/
     create tottemp.
     assign 
           tottemp.prz = 14
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[14]
           tottemp.des  = des[14] 
           tottemp.sum = (accum total by temp.dep temp.nalog) +  (accum total by temp.dep temp.otch).

/*ГСМ*/ 
    create tottemp.
     assign
           tottemp.prz = 15
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[15]
           tottemp.des  = des[15] 
           tottemp.sum = (accum total by temp.dep temp.pr12_4) +  (accum total by temp.dep temp.pr12_5) .

/*ГСМ начисл*/ 
    create tottemp.
     assign
           tottemp.prz = 16
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[16]
           tottemp.des  = des[16] 
           tottemp.sum = (accum total by temp.dep temp.pr12_6).

/*ТМЦ запасы*/
     create tottemp.
     assign 
           tottemp.prz = 17
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[17]
           tottemp.des  = des[17] 
           tottemp.sum = (accum total by temp.dep temp.pr9_4) .


 /*обучение*/
     create tottemp.
     assign 
           tottemp.prz = 18
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[18]
           tottemp.des  = des[18] 
           tottemp.sum = (accum total by temp.dep temp.pr4_7) +  (accum total by temp.dep temp.pr4_8) + (accum total by temp.dep temp.pr4_9) + 
                         (accum total by temp.dep temp.pr4_10) + (accum total by temp.dep temp.pr4_11) + (accum total by temp.dep temp.pr4_12).

/*администр расходы*/
     create tottemp.
     assign 
           tottemp.prz = 19
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[19]
           tottemp.des  = des[19] 
           tottemp.sum = (accum total by temp.dep temp.pr11_4) +  (accum total by temp.dep temp.pr11_5)  + (accum total by temp.dep temp.pr11_6) +
                         (accum total by temp.dep temp.pr11_7) +  (accum total by temp.dep temp.pr11_8)  + (accum total by temp.dep temp.pr11_9) + 
                         (accum total by temp.dep temp.pr11_10) +  (accum total by temp.dep temp.pr11_11) + (accum total by temp.dep temp.pr11_12) +
                         (accum total by temp.dep temp.pr11_13) +  (accum total by temp.dep temp.pr11_14) + (accum total by temp.dep temp.pr11_15) +
                         (accum total by temp.dep temp.pr11_16) +  (accum total by temp.dep temp.pr11_17) + (accum total by temp.dep temp.pr11_18) .
 
  /*комнадировки*/
     create tottemp.
     assign 
           tottemp.prz = 20
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[20]
           tottemp.des  = des[20] 
           tottemp.sum = (accum total by temp.dep temp.pr4_14) +  (accum total by temp.dep temp.pr4_15) + (accum total by temp.dep temp.pr4_16).


  /*связь*/
     create tottemp.
     assign 
           tottemp.prz = 21
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[21]
           tottemp.des  = des[21] 
           tottemp.sum = (accum total by temp.dep temp.pr5_9) +  (accum total by temp.dep temp.pr5_10) + (accum total by temp.dep temp.pr5_11) +
                         + (accum total by temp.dep temp.pr5_13)  + (accum total by temp.dep temp.pr5_14)  + (accum total by temp.dep temp.pr5_15)  
                         + (accum total by temp.dep temp.pr5_16)  + (accum total by temp.dep temp.pr5_17)  + (accum total by temp.dep temp.pr5_18)  
                         + (accum total by temp.dep temp.pr5_19)  + (accum total by temp.dep temp.pr5_20)  + (accum total by temp.dep temp.pr5_21)  
                         + (accum total by temp.dep temp.pr5_22) .  

    /*ОС*/
     create tottemp.
     assign 
           tottemp.prz = 22
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[22]
           tottemp.des  = des[22] 
           tottemp.sum = (accum total by temp.dep temp.pr3_7) +  (accum total by temp.dep temp.pr3_8) + (accum total by temp.dep temp.pr3_9) +
                         + (accum total by temp.dep temp.pr3_10)  + (accum total by temp.dep temp.pr3_11)  + (accum total by temp.dep temp.pr3_12)  
                         + /* (accum total by temp.dep temp.pr3_13)  +*/ (accum total by temp.dep temp.pr3_14) .  

    /*инкассация*/
     create tottemp.
     assign 
           tottemp.prz = 23
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[23]
           tottemp.des  = des[23] 
           tottemp.sum = (accum total by temp.dep temp.pr11_19) .

/*Бланочная продукция*/
    create tottemp.
     assign 
           tottemp.prz = 24
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[24]
           tottemp.des  = des[24] 
           tottemp.sum = (accum total by temp.dep temp.pr9_5) .

/*Канц товары*/
     create tottemp.
     assign 
           tottemp.prz = 25
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[25]
           tottemp.des  = des[25] 
           tottemp.sum = (accum total by temp.dep temp.pr9_6) . 

/*Приобретение печатной продукции*/
     create tottemp.
     assign 
           tottemp.prz = 26
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[26]
           tottemp.des  = des[26] 
           tottemp.sum = (accum total by temp.dep temp.pr9_7).

 /*коммунальные услуги*/
      create tottemp.      
     assign 
           tottemp.prz = 27
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[27]
           tottemp.des = des[27] 
           tottemp.sum = (accum total by temp.dep temp.pr10_4)  + (accum total by temp.dep temp.pr10_5) + (accum total by temp.dep temp.pr10_6) +
                         (accum total by temp.dep temp.pr10_7)  + (accum total by temp.dep temp.pr10_8) + (accum total by temp.dep temp.pr10_9) .


 /*кап ремонт ОС*/
     create tottemp.
     assign 
           tottemp.prz = 28
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[28]
           tottemp.des = des[28] 
           tottemp.sum = (accum total by temp.dep temp.pr8_4) .

/*           tottemp.sum = (accum total by temp.dep temp.pr11_10)  + (accum total by temp.dep temp.pr11_11)  
                         + (accum total by temp.dep temp.pr11_12)  + (accum total by temp.dep temp.pr11_14).*/
 /*тек ремонт ОС*/
     create tottemp.
     assign 
           tottemp.prz = 29
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[29]
           tottemp.des = des[29] 
           tottemp.sum = (accum total by temp.dep temp.pr8_7) + (accum total by temp.dep temp.pr8_8) + (accum total by temp.dep temp.pr8_9) + 
                         (accum total by temp.dep temp.pr8_10) + (accum total by temp.dep temp.pr8_11).


/*ремонт автотранспорта*/
      create tottemp.      
     assign 
           tottemp.prz = 30
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[30]
           tottemp.des = des[30] 
           tottemp.sum = (accum total by temp.dep temp.pr8_5) +  (accum total by temp.dep temp.pr8_6).

/*реклама */
      create tottemp.      
     assign 
           tottemp.prz = 31
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[31]
           tottemp.des = des[31] 
           tottemp.sum = (accum total by temp.dep temp.pr11_20).

/*пожарно-охран сигнализация*/
      create tottemp.      
     assign 
           tottemp.prz = 32
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[32]
           tottemp.des = des[32] 
           tottemp.sum = (accum total by temp.dep temp.pr11_21).

/*Прочие адм затраты*/
      create tottemp.      
     assign 
           tottemp.prz = 33
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[33]
           tottemp.des = des[33] 
           tottemp.sum = (accum total by temp.dep temp.pr11_22) + (accum total by temp.dep temp.pr11_23) + 
                         (accum total by temp.dep temp.pr11_24) + (accum total by temp.dep temp.pr11_25) +
                         (accum total by temp.dep temp.pr12_7) + (accum total by temp.dep temp.pr12_8)  + 
                         (accum total by temp.dep temp.pr12_9) .

 /* начисл. коммунальные услуги*/
      create tottemp.      
     assign 
           tottemp.prz = 34
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[34]
           tottemp.des = des[34] 
           tottemp.sum =  (accum total by temp.dep temp.pr10_10)  .


/*аудит,консалтинг*/
      create tottemp.      
     assign 
           tottemp.prz = 35
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[35]
           tottemp.des = des[35] 
           tottemp.sum = (accum total by temp.dep temp.pr11_26).

/*страхование*/
     create tottemp.
     assign 
           tottemp.prz = 36
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[36]
           tottemp.des  = des[36] 
           tottemp.sum = (accum total by temp.dep temp.pr11_27).


 /* НДС*/
      create tottemp.      
     assign 
           tottemp.prz = 37
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[37]
           tottemp.des = des[37] 
           tottemp.sum = (accum total by temp.dep temp.pr13_7).


 /* соц отчисления*/
      create tottemp.      
     assign 
           tottemp.prz = 38
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[38]
           tottemp.des = des[38] 
           tottemp.sum = (accum total by temp.dep temp.pr13_13).

 /* земельный налог*/
      create tottemp.      
     assign 
           tottemp.prz = 39
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[39]
           tottemp.des = des[39] 
           tottemp.sum = (accum total by temp.dep temp.pr13_8).



 /* налог имущество*/
      create tottemp.      
     assign 
           tottemp.prz = 40
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[40]
           tottemp.des = des[40] 
           tottemp.sum = (accum total by temp.dep temp.pr13_9).


 /* налог транспорт*/
      create tottemp.      
     assign 
           tottemp.prz = 41
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[41]
           tottemp.des = des[41] 
           tottemp.sum = (accum total by temp.dep temp.pr13_11).

/*аукцион*/
     create tottemp.
     assign 
           tottemp.prz = 42
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[42]
           tottemp.des  = des[42] 
           tottemp.sum = (accum total by temp.dep temp.pr13_10).

/*гос пошлина*/
     create tottemp.
     assign 
           tottemp.prz = 43
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[43]
           tottemp.des  = des[43] 
           tottemp.sum = (accum total by temp.dep temp.pr13_12) + (accum total by temp.dep temp.pr13_14).

/*ОС, НМА*/
     create tottemp.
     assign 
           tottemp.prz = 44
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[44]
           tottemp.des  = des[44] 
           tottemp.sum = (accum total by temp.dep temp.pr12_10) .

/*форварт,фьючерсы*/
     create tottemp.
     assign 
           tottemp.prz = 45
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[45]
           tottemp.des  = des[45] 
           tottemp.sum = (accum total by temp.dep temp.pr14_4). 

/*штрафы, пани*/
     create tottemp.
     assign 
           tottemp.prz = 46
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[46]
           tottemp.des  = des[46] 
           tottemp.sum = (accum total by temp.dep temp.pr13_15). 


/* проч от банк деят*/
     create tottemp.
     assign 
           tottemp.prz = 47
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[47]
           tottemp.des  = des[47] 
           tottemp.sum = (accum total by temp.dep temp.pr14_5). 

/*гаран страх*/
     create tottemp.
     assign 
           tottemp.prz = 48
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[48]
           tottemp.des  = des[48] 
           tottemp.sum = (accum total by temp.dep temp.pr13_16). 

/*представ затраты*/
     create tottemp.
     assign 
           tottemp.prz = 49
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[49]
           tottemp.des = des[49] 
           tottemp.sum = (accum total by temp.dep temp.pr6_7) + (accum total by temp.dep temp.pr6_8).

/*налог нерез*/
     create tottemp.
     assign 
           tottemp.prz = 50
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[50]
           tottemp.des  = des[50] 
           tottemp.sum = (accum total by temp.dep temp.pr13_6). 

/*связан с небанк деят*/
     create tottemp.
     assign 
           tottemp.prz = 51
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[51]
           tottemp.des  = des[51] 
           tottemp.sum = (accum total by temp.dep temp.pr14_6). 


 /*расходы по аренде*/
     create tottemp.
     assign 
           tottemp.prz = 52
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[52]
           tottemp.des = des[52] 
           tottemp.sum = (accum total by temp.dep temp.pr7_6) + (accum total by temp.dep temp.pr7_7) +  (accum total by temp.dep temp.pr7_8) + (accum total by temp.dep temp.pr7_9).

/*акцепт*/
     create tottemp.
     assign 
           tottemp.prz = 53
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[53]
           tottemp.des  = des[53] 
           tottemp.sum = (accum total by temp.dep temp.pr14_7). 


/*чрезвыч расходы*/
     create tottemp.
     assign 
           tottemp.prz = 54
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[54]
           tottemp.des  = des[54] 
           tottemp.sum = (accum total by temp.dep temp.pr14_8). 

/*КНП в бюджет*/
     create tottemp.
     assign 
           tottemp.prz = 55
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[55]
           tottemp.des  = des[55] 
           tottemp.sum = (accum total by temp.dep temp.pr13_4). 

/*КНП нерезидентом*/
     create tottemp.
     assign 
           tottemp.prz = 56
           tottemp.dep = temp.dep
           tottemp.depname = temp.depname
           tottemp.gl  = totgl[56]
           tottemp.des  = des[56] 
           tottemp.sum = (accum total by temp.dep temp.pr13_5). 


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

end.  /*pril21*/
else if v-pril = '35' then do:

{pr30.i &dep = "true"}
{pr31.i &dep = "true"}
{pr32.i &dep = "true"}  
{pr33.i &dep = "true"}
{pr34.i &dep = "true"}

put stream vcrpt unformatted 
   "<p><B>"  v-bank  +  ".<br>" + names[integer(v-pril)] + " за период  с " + 
        months[integer(m1)] + " по " + months[integer(m2)] + " " + string(y1) " года" + ".<br> Приложение " + v-pril + "</B></p>" skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" .
  
for each temp2 break by temp2.dep.
  if last-of (temp2.dep) then do:
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


for each temp2 break by temp2.dep  .

     accum temp2.pr30_4  (total by temp2.dep ).
     accum temp2.pr30_5 (total by temp2.dep ).
     accum temp2.pr30_6 (total by temp2.dep ).
/*     accum temp2.pr30_7  (total by temp2.dep ).*/
     accum temp2.pr30_8  (total by temp2.dep ).
     accum temp2.pr30_9  (total by temp2.dep ).
     accum temp2.pr30_9  (total by temp2.dep ).
     accum temp2.pr30_10 (total by temp2.dep ).
     accum temp2.pr30_11 (total by temp2.dep ).
     accum temp2.pr30_12 (total by temp2.dep ).
     accum temp2.pr30_13 (total by temp2.dep ).
     accum temp2.pr30_14 (total by temp2.dep ).
     accum temp2.pr30_15 (total by temp2.dep ).
     accum temp2.pr30_16 (total by temp2.dep ).
     accum temp2.pr30_17 (total by temp2.dep ).
     accum temp2.pr30_18 (total by temp2.dep ).
     accum temp2.pr30_19 (total by temp2.dep ).
     accum temp2.pr30_20 (total by temp2.dep ).
     accum temp2.pr30_21 (total by temp2.dep ).
     accum temp2.pr30_22 (total by temp2.dep ).
     accum temp2.pr30_23 (total by temp2.dep ).
     accum temp2.pr30_24 (total by temp2.dep ).
     accum temp2.pr30_25 (total by temp2.dep ).
     accum temp2.pr30_26 (total by temp2.dep ).
     accum temp2.pr30_27 (total by temp2.dep ).
     accum temp2.pr30_28 (total by temp2.dep ).
     accum temp2.pr30_29 (total by temp2.dep ).
     accum temp2.pr30_30 (total by temp2.dep ).
     accum temp2.pr30_31 (total by temp2.dep ).
     accum temp2.pr30_32 (total by temp2.dep ).
     accum temp2.pr30_33 (total by temp2.dep ).
     accum temp2.pr30_34 (total by temp2.dep ).
     accum temp2.pr30_35 (total by temp2.dep ).
     accum temp2.pr30_36 (total by temp2.dep ).

     accum temp2.pr31_4  (total by temp2.dep ).
     accum temp2.pr31_5 (total by temp2.dep ).
     accum temp2.pr31_6 (total by temp2.dep ).
     accum temp2.pr31_7  (total by temp2.dep ).
     accum temp2.pr31_8  (total by temp2.dep ).
     accum temp2.pr31_9  (total by temp2.dep ).
     accum temp2.pr31_10 (total by temp2.dep ).
     accum temp2.pr31_11 (total by temp2.dep ).
     accum temp2.pr31_12 (total by temp2.dep ).
     accum temp2.pr31_13 (total by temp2.dep ).
     accum temp2.pr31_14 (total by temp2.dep ).
     accum temp2.pr31_15 (total by temp2.dep ).

     accum temp2.pr32_4  (total by temp2.dep ).
     accum temp2.pr32_5 (total by temp2.dep ).
     accum temp2.pr32_6 (total by temp2.dep ).
     accum temp2.pr32_7  (total by temp2.dep ).
     accum temp2.pr32_8  (total by temp2.dep ).
     accum temp2.pr32_9  (total by temp2.dep ).
     accum temp2.pr32_10 (total by temp2.dep ).
     accum temp2.pr32_11 (total by temp2.dep ).
     accum temp2.pr32_12 (total by temp2.dep ).
     accum temp2.pr32_13 (total by temp2.dep ).
     accum temp2.pr32_14 (total by temp2.dep ).
     accum temp2.pr32_15 (total by temp2.dep ).
     accum temp2.pr32_16 (total by temp2.dep ).
     accum temp2.pr32_17 (total by temp2.dep ).
     accum temp2.pr32_18 (total by temp2.dep ).
     accum temp2.pr32_19 (total by temp2.dep ).
     accum temp2.pr32_20 (total by temp2.dep ).
     accum temp2.pr32_21 (total by temp2.dep ).
     accum temp2.pr32_22 (total by temp2.dep ).
     accum temp2.pr32_23 (total by temp2.dep ).
     accum temp2.pr32_24 (total by temp2.dep ).
     accum temp2.pr32_25 (total by temp2.dep ).

     accum temp2.pr33_4  (total by temp2.dep ).
     accum temp2.pr33_5 (total by temp2.dep ).
     accum temp2.pr33_6 (total by temp2.dep ).
     accum temp2.pr33_7  (total by temp2.dep ).
     accum temp2.pr33_8  (total by temp2.dep ).
     accum temp2.pr33_9  (total by temp2.dep ).
     accum temp2.pr33_10 (total by temp2.dep ).
     accum temp2.pr33_11 (total by temp2.dep ).
     accum temp2.pr33_12 (total by temp2.dep ).
     accum temp2.pr33_13 (total by temp2.dep ).
     accum temp2.pr33_14 (total by temp2.dep ).
     accum temp2.pr33_15 (total by temp2.dep ).
     accum temp2.pr33_16 (total by temp2.dep ).

     accum temp2.pr34_4  (total by temp2.dep ).
     accum temp2.pr34_5 (total by temp2.dep ).
     accum temp2.pr34_6 (total by temp2.dep ).
     accum temp2.pr34_7  (total by temp2.dep ).
     accum temp2.pr34_8  (total by temp2.dep ).
     accum temp2.pr34_9  (total by temp2.dep ).
     accum temp2.pr34_10 (total by temp2.dep ).
     accum temp2.pr34_11 (total by temp2.dep ).

  if last-of(temp2.dep) then do:
                     
 /*доходы по корр счетам*/
     create tottemp.
     assign 
           tottemp.prz = 1
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[1]
           tottemp.des  = des2[1] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_4) +  (accum total by temp2.dep temp2.pr30_5) .

  /*вклдады в НБРК*/
     create tottemp.
     assign 
           tottemp.prz = 2
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[2]
           tottemp.des  = des2[2] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_6) .


  /*по ЦБ  для торговли*/
     create tottemp.
     assign 
           tottemp.prz = 3
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[3]
           tottemp.des  = des2[3] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_32) .

  /*вклдады размещ в др банках*/
     create tottemp.
     assign 
           tottemp.prz = 4
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[4]
           tottemp.des  = des2[4] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_8) + (accum total by temp2.dep temp2.pr30_9) + (accum total by temp2.dep temp2.pr30_10) 
                         + (accum total by temp2.dep temp2.pr30_11) + (accum total by temp2.dep temp2.pr30_12) + (accum total by temp2.dep temp2.pr30_13)
                         + (accum total by temp2.dep temp2.pr30_14)   .

  /*расчеты с филиалами*/
     create tottemp.
     assign 
           tottemp.prz = 5
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[5]
           tottemp.des  = des2[5] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_29). 
/*овердрафт*/
     create tottemp.
     assign 
           tottemp.prz = 6
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[6]
           tottemp.des  = des2[6] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_19). 

 /*кред карты*/
     create tottemp.
     assign 
           tottemp.prz = 7
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[7]
           tottemp.des  = des2[7] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_20). 

  /*краткосроч редиты ФЛ,ЮЛ*/
     create tottemp.
     assign 
           tottemp.prz = 8
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[8]
           tottemp.des  = des2[8] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_21) + (accum total by temp2.dep temp2.pr30_22) + (accum total by temp2.dep temp2.pr30_23). 

  /*долгосроч редиты ФЛ,ЮЛ*/
     create tottemp.
     assign 
           tottemp.prz = 9
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[9]
           tottemp.des  = des2[9] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_24) + (accum total by temp2.dep temp2.pr30_25) 
                       + (accum total by temp2.dep temp2.pr30_26) +  (accum total by temp2.dep temp2.pr30_27). 

  /*прочие кред операц*/
     create tottemp.
     assign 
           tottemp.prz = 10
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[10]
           tottemp.des  = des2[10] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_28) . 

  /*займы*/
     create tottemp.
     assign 
           tottemp.prz = 11
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[11]
           tottemp.des  = des2[11] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_5)  + (accum total by temp2.dep temp2.pr32_6)  . 

  /*прочие ЦБ*/
     create tottemp.
     assign 
           tottemp.prz = 12
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[12]
           tottemp.des  = des2[12] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_30)  + (accum total by temp2.dep temp2.pr30_31) 
			 + (accum total by temp2.dep temp2.pr30_33) + (accum total by temp2.dep temp2.pr30_34)
                         + (accum total by temp2.dep temp2.pr30_35) . 

  /*обратное РЕПО с ЦБ*/
     create tottemp.
     assign 
           tottemp.prz = 13
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[13]
           tottemp.des  = des2[13] 
           tottemp.sum = (accum total by temp2.dep temp2.pr30_36) . 

  /*дилинговые операции*/
     create tottemp.
     assign 
           tottemp.prz = 14
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[14]
           tottemp.des  = des2[14] 
           tottemp.sum = (accum total by temp2.dep temp2.pr31_4) + (accum total by temp2.dep temp2.pr31_5) + 
                         (accum total by temp2.dep temp2.pr31_6)  + (accum total by temp2.dep temp2.pr31_7).

  /*переводные операции*/
     create tottemp.
     assign 
           tottemp.prz = 15
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[15]
           tottemp.des  = des2[15] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_7)   + (accum total by temp2.dep temp2.pr32_8) + 
                         (accum total by temp2.dep temp2.pr32_9)  + (accum total by temp2.dep temp2.pr32_10) + 
                         (accum total by temp2.dep temp2.pr32_25).

  /*комис по реализации страховых полисов*/
     create tottemp.
     assign 
           tottemp.prz = 16
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[16]
           tottemp.des  = des2[16] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_11) .


  /*купля-продажа ЦБ*/
     create tottemp.
     assign 
           tottemp.prz = 17
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[17]
           tottemp.des  = des2[17] 
           tottemp.sum =  (accum total by temp2.dep temp2.pr32_12) .


  /*купля-продажа ин валюты*/
     create tottemp.
     assign 
           tottemp.prz = 18
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[18]
           tottemp.des  = des2[18] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_13) .



  /*гарантии без НДС*/
     create tottemp.
     assign 
           tottemp.prz = 19
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[19]
           tottemp.des  = des2[19] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_14) . 


  /*дох от открытия вкладов и ведению счетов*/
     create tottemp.
     assign 
           tottemp.prz = 20
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[20]
           tottemp.des  = des2[20] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_15)  + (accum total by temp2.dep temp2.pr32_16) + 
                         (accum total by temp2.dep temp2.pr32_17)  + (accum total by temp2.dep temp2.pr32_18) + 
                         (accum total by temp2.dep temp2.pr32_19)  + (accum total by temp2.dep temp2.pr32_20) + 
                         (accum total by temp2.dep temp2.pr32_21)  . 

  /*прочие комм доходы*/
     create tottemp.
     assign 
           tottemp.prz = 21
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[21]
           tottemp.des  = des2[21] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_4)  + (accum total by temp2.dep temp2.pr33_5) + 
                         (accum total by temp2.dep temp2.pr33_6)  + (accum total by temp2.dep temp2.pr33_7) + 
                         (accum total by temp2.dep temp2.pr33_8)  + (accum total by temp2.dep temp2.pr33_9) + 
                         (accum total by temp2.dep temp2.pr33_10) + (accum total by temp2.dep temp2.pr33_11) .

  /*акцепт чеков*/
     create tottemp.
     assign 
           tottemp.prz = 22
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[22]
           tottemp.des  = des2[22] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_12).

  /*форфейт операции*/
     create tottemp.
     assign 
           tottemp.prz = 23
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[23]
           tottemp.des  = des2[23] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_13).


  /*фактор операции*/
     create tottemp.
     assign 
           tottemp.prz = 24
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[24]
           tottemp.des  = des2[24] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_14)  . 

  /*кассовые операции*/
     create tottemp.
     assign 
           tottemp.prz = 25
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[25]
           tottemp.des  = des2[25] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_22)  + (accum total by temp2.dep temp2.pr32_23) .

  /*документарные расчеты*/
     create tottemp.
     assign 
           tottemp.prz = 26
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[26]
           tottemp.des  = des2[26] 
           tottemp.sum = (accum total by temp2.dep temp2.pr32_24). 

  /*переоценка*/
     create tottemp.
     assign 
           tottemp.prz = 27
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[27]
           tottemp.des  = des2[27] 
           tottemp.sum = (accum total by temp2.dep temp2.pr31_8) + (accum total by temp2.dep temp2.pr31_9) + 
                         (accum total by temp2.dep temp2.pr31_10)  + (accum total by temp2.dep temp2.pr31_11) + 
                         (accum total by temp2.dep temp2.pr31_12) + (accum total by temp2.dep temp2.pr31_13) + 
                         (accum total by temp2.dep temp2.pr31_14)  + (accum total by temp2.dep temp2.pr31_15).

  /*продажа ЦБ с нефиксир доходом*/
     create tottemp.
     assign 
           tottemp.prz = 28
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[28]
           tottemp.des  = des2[28] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_15). 

  /*производные инструменты*/
     create tottemp.
     assign 
           tottemp.prz = 29
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[29]
           tottemp.des  = des2[29] 
           tottemp.sum = (accum total by temp2.dep temp2.pr33_16). 

  /*штрафы*/
     create tottemp.
     assign 
           tottemp.prz = 30
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[30]
           tottemp.des  = des2[30] 
           tottemp.sum = (accum total by temp2.dep temp2.pr34_4)  .

  /*прочие доходы*/
     create tottemp.
     assign 
           tottemp.prz = 31
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[31]
           tottemp.des  = des2[31] 
           tottemp.sum = (accum total by temp2.dep temp2.pr34_5) + (accum total by temp2.dep temp2.pr34_6) + (accum total by temp2.dep temp2.pr34_7). 
 
  /*чрезвычайные доходы*/
     create tottemp.
     assign 
           tottemp.prz = 32
           tottemp.dep = temp2.dep
           tottemp.depname = temp2.depname
           tottemp.gl  = totgl2[32]
           tottemp.des  = des2[32] 
           tottemp.sum = (accum total by temp2.dep temp2.pr34_8) + (accum total by temp2.dep temp2.pr34_9) 
                         + (accum total by temp2.dep temp2.pr34_10) + (accum total by temp2.dep temp2.pr34_11) . 


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
      "<TD>" replace(string(tottemp.sum ,"zzzzzzzzzzzzz9.99-"),".",",")   "</TD>" skip.
  if last-of(tottemp.prz)  then
 put stream vcrpt unformatted
      "<TD>" replace(string((accum total by tottemp.prz tottemp.sum) ,"zzzzzzzzzzzzz9.99-"),".",",")   "</TD>" skip.

end. 
 put stream vcrpt unformatted
    "</TR>" skip.
 put stream vcrpt unformatted
  "</TABLE>" skip.

end.  /*pril35*/
else run zatrati4. 
