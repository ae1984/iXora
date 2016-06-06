/* eknp_f1.p
 * MODULE
        СТАТИСТИКА
 * DESCRIPTION
        Отчет о покупке-продаже иностранной валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-9-6-3
 * BASES
        BANK COMM
 * AUTHOR
        05/04/2006 dpuchkov
 * CHANGES
        26/05/2006 dpuchkov перекомпиляция
        09.06.2006 dpuchkov - добавил проверку на наличные деньги
*/


{global.i}
def new shared var vn-dt as date     no-undo.
def new shared var vn-dtbeg as date  no-undo.
def new shared var v-jss as char     no-undo.
def var v-str as char                no-undo.
def var file1 as char format "x(20)" no-undo.





 def new shared temp-table tmp-f2p2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2

     field RRez  as decimal decimals 2
     field RNer  as decimal decimals 2
     field NRez  as decimal decimals 2
     field NNer  as decimal decimals 2. 

     def buffer b1 for tmp-f2p2.
     def buffer b2 for tmp-f2p2.
     def buffer b3 for tmp-f2p2.
     def buffer b4 for tmp-f2p2.
     def buffer b5 for tmp-f2p2.
     def buffer b6 for tmp-f2p2.
     def buffer b7 for tmp-f2p2.



 update vn-dtbeg label " Укажите период с"  /* validate(vn-dtbeg >= g-today - 15, "Только за последнюю декаду ") */
 vn-dt label "по" /* validate(vn-dt <= g-today, "Только за последнюю декаду ")*/
 with side-labels centered row 9.


create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 1.  tmp-f2p2.name = "Раздел 1. Поступление иностранной валюты в пользу клиентов". 
create tmp-f2p2. tmp-f2p2.kod = 10000. tmp-f2p2.nom = 2.  tmp-f2p2.name = "Всего". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 3.  tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 11000. tmp-f2p2.nom = 4.  tmp-f2p2.name = "Платежи и переводы денег контрпартнеров на банковские счета:". 
create tmp-f2p2. tmp-f2p2.kod = 11100. tmp-f2p2.nom = 5.  tmp-f2p2.name = "физических лиц, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 11200. tmp-f2p2.nom = 6.  tmp-f2p2.name = "юридических лиц". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 7.  tmp-f2p2.name = "в том числе по операциям:". 
create tmp-f2p2. tmp-f2p2.kod = 11210. tmp-f2p2.nom = 8.  tmp-f2p2.name = "продажа товаров и нематериальных активов". 
create tmp-f2p2. tmp-f2p2.kod = 11220. tmp-f2p2.nom = 9.  tmp-f2p2.name = "предоставление услуг". 
create tmp-f2p2. tmp-f2p2.kod = 11230. tmp-f2p2.nom = 10.  tmp-f2p2.name = "получение основной суммы долга и доходов по выданным  займам". 
create tmp-f2p2. tmp-f2p2.kod = 11240. tmp-f2p2.nom = 11.  tmp-f2p2.name = "привлечение займов". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 12.  tmp-f2p2.name = "из них от:". 
create tmp-f2p2. tmp-f2p2.kod = 11241. tmp-f2p2.nom = 13.  tmp-f2p2.name = "других банков-резидентов". 
create tmp-f2p2. tmp-f2p2.kod = 11242. tmp-f2p2.nom = 14.  tmp-f2p2.name = "банков-нерезидентов". 
create tmp-f2p2. tmp-f2p2.kod = 11250. tmp-f2p2.nom = 15.  tmp-f2p2.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 16.  tmp-f2p2.name = "из них:". 
create tmp-f2p2. tmp-f2p2.kod = 11251. tmp-f2p2.nom = 17.  tmp-f2p2.name = "акции, взносы участников и другие инструменты, обеспечивающие участие в капитале резидентов, паи инвестиционных фондов резидентов". 
create tmp-f2p2. tmp-f2p2.kod = 11252. tmp-f2p2.nom = 18.  tmp-f2p2.name = "акции, взносы участников и другие инструменты, обеспечивающие участие в капитале  нерезидентов,  паи инвестиционных фондов нерезидентов". 
create tmp-f2p2. tmp-f2p2.kod = 11253. tmp-f2p2.nom = 19.  tmp-f2p2.name = "государственные  долговые ценные бумаги Республики Казахстан". 
create tmp-f2p2. tmp-f2p2.kod = 11254. tmp-f2p2.nom = 20.  tmp-f2p2.name = "долговые ценные бумаги и векселя, выпущенные другими резидентами". 
create tmp-f2p2. tmp-f2p2.kod = 11255. tmp-f2p2.nom = 21.  tmp-f2p2.name = "долговые ценные бумаги и векселя, выпущенные нерезидентами". 
create tmp-f2p2. tmp-f2p2.kod = 11260. tmp-f2p2.nom = 22.  tmp-f2p2.name = "прочие переводы денег". 
create tmp-f2p2. tmp-f2p2.kod = 12000. tmp-f2p2.nom = 23.  tmp-f2p2.name = "Переводы без открытия банковского счета". 
create tmp-f2p2. tmp-f2p2.kod = 13000. tmp-f2p2.nom = 24.  tmp-f2p2.name = "Переводы клиентами денег со своих банковских счетов". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 25.  tmp-f2p2.name = "из них открытых в:". 
create tmp-f2p2. tmp-f2p2.kod = 13001. tmp-f2p2.nom = 26.  tmp-f2p2.name = "других банках-резидентах". 
create tmp-f2p2. tmp-f2p2.kod = 13002. tmp-f2p2.nom = 27.  tmp-f2p2.name = "банках-нерезидентах". 
create tmp-f2p2. tmp-f2p2.kod = 14000. tmp-f2p2.nom = 28.  tmp-f2p2.name = "Покупка иностранной валюты за тенге". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 29.  tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 14100. tmp-f2p2.nom = 30.  tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 14200. tmp-f2p2.nom = 31.  tmp-f2p2.name = "юридическими лицами". 
create tmp-f2p2. tmp-f2p2.kod = 15000. tmp-f2p2.nom = 32.  tmp-f2p2.name = "Зачисление наличной иностранной валюты на свои банковские счета". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 33.  tmp-f2p2.name = "из них:". 
create tmp-f2p2. tmp-f2p2.kod = 15100. tmp-f2p2.nom = 34.  tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 15200. tmp-f2p2.nom = 35.  tmp-f2p2.name = "юридическими лицами". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 36.  tmp-f2p2.name = "Раздел 2. Снятие и/или перевод иностранной валюты клиентами". 
create tmp-f2p2. tmp-f2p2.kod = 20000. tmp-f2p2.nom = 37.  tmp-f2p2.name = "Всего". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 38.  tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 21000. tmp-f2p2.nom = 39.  tmp-f2p2.name = " Платежи и переводы денег контрпартнерам с банковских счетов:". 
create tmp-f2p2. tmp-f2p2.kod = 21100. tmp-f2p2.nom = 40.  tmp-f2p2.name = "физических лиц, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 21200. tmp-f2p2.nom = 41.  tmp-f2p2.name = "юридических лиц". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 42.  tmp-f2p2.name = "в том числе по операциям:". 
create tmp-f2p2. tmp-f2p2.kod = 21210. tmp-f2p2.nom = 43.  tmp-f2p2.name = "покупка товаров и нематериальных активов". 
create tmp-f2p2. tmp-f2p2.kod = 21220. tmp-f2p2.nom = 44.  tmp-f2p2.name = "получение услуг". 
create tmp-f2p2. tmp-f2p2.kod = 21230. tmp-f2p2.nom = 45.  tmp-f2p2.name = "получение услуг". 
create tmp-f2p2. tmp-f2p2.kod = 21240. tmp-f2p2.nom = 46.  tmp-f2p2.name = "выполнение обязательств по займам". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 47.  tmp-f2p2.name = "из них по привлеченным от: ". 
create tmp-f2p2. tmp-f2p2.kod = 21241. tmp-f2p2.nom = 48.  tmp-f2p2.name = "других банков-резидентов". 
create tmp-f2p2. tmp-f2p2.kod = 21242. tmp-f2p2.nom = 49.  tmp-f2p2.name = "банков-нерезидентов". 
create tmp-f2p2. tmp-f2p2.kod = 21250. tmp-f2p2.nom = 50.  tmp-f2p2.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 51.  tmp-f2p2.name = "из них:". 
create tmp-f2p2. tmp-f2p2.kod = 21251. tmp-f2p2.nom = 52.  tmp-f2p2.name = "акции, взносы участников и другие инструменты, обеспечивающие участие в капитале резидентов, паи инвестиционных фондов резидентов". 
create tmp-f2p2. tmp-f2p2.kod = 21252. tmp-f2p2.nom = 53.  tmp-f2p2.name = "Акции, взносы участников и другие инструменты, обеспечивающие участие в капитале  нерезидентов,  паи инвестиционных фондов нерезидентов". 
create tmp-f2p2. tmp-f2p2.kod = 21253. tmp-f2p2.nom = 54.  tmp-f2p2.name = "государственные  долговые ценные бумаги Республики Казахстан". 
create tmp-f2p2. tmp-f2p2.kod = 21254. tmp-f2p2.nom = 55.  tmp-f2p2.name = "долговые ценные бумаги и векселя, выпущенные другими резидентами". 
create tmp-f2p2. tmp-f2p2.kod = 21255. tmp-f2p2.nom = 56.  tmp-f2p2.name = "долговые ценные бумаги, выпущенные нерезидентами". 
create tmp-f2p2. tmp-f2p2.kod = 21260. tmp-f2p2.nom = 57.  tmp-f2p2.name = "прочие переводы денег". 
create tmp-f2p2. tmp-f2p2.kod = 22000. tmp-f2p2.nom = 58.  tmp-f2p2.name = "Переводы без открытия банковского счета". 
create tmp-f2p2. tmp-f2p2.kod = 23000. tmp-f2p2.nom = 59.  tmp-f2p2.name = "Переводы клиентами денег на свои банковские счета". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 60.  tmp-f2p2.name = "из них открытых в:". 
create tmp-f2p2. tmp-f2p2.kod = 23001. tmp-f2p2.nom = 61.  tmp-f2p2.name = "других банках-резидентах". 
create tmp-f2p2. tmp-f2p2.kod = 23002. tmp-f2p2.nom = 62.  tmp-f2p2.name = "Банках-нерезидентах". 
create tmp-f2p2. tmp-f2p2.kod = 24000. tmp-f2p2.nom = 63.  tmp-f2p2.name = "Продажа иностранной валюты за тенге". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 64.  tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 24100. tmp-f2p2.nom = 65.  tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 24200. tmp-f2p2.nom = 66.  tmp-f2p2.name = "юридическими лицами". 
create tmp-f2p2. tmp-f2p2.kod = 25000. tmp-f2p2.nom = 67.  tmp-f2p2.name = "Снятие наличной иностранной валюты со своих банковских счетов". 
create tmp-f2p2. tmp-f2p2.kod = 0.     tmp-f2p2.nom = 68.  tmp-f2p2.name = "из них:". 
create tmp-f2p2. tmp-f2p2.kod = 25100. tmp-f2p2.nom = 69.  tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 25200. tmp-f2p2.nom = 70.  tmp-f2p2.name = "юридическими лицами". 













   file1 = "212.html".
   output to value(file1).
   {html-title.i}
put  unformatted
   "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
   "<HEAD>"                                       skip
" <!--[if gte mso 9]><xml>"                       skip
" <x:ExcelWorkbook>"                              skip
" <x:ExcelWorksheets>"                            skip
" <x:ExcelWorksheet>"                             skip
" <x:Name>17161</x:Name>"                         skip
" <x:WorksheetOptions>"                           skip
" <x:Zoom>70</x:Zoom>"                            skip
" <x:Selected/>"                                  skip
" <x:DoNotDisplayGridlines/>"                     skip
" <x:TopRowVisible>52</x:TopRowVisible>"          skip
" <x:Panes>"                                      skip
" <x:Pane>"                                       skip
" <x:Number>3</x:Number>"                         skip
" <x:ActiveRow>12</x:ActiveRow>"                  skip
" <x:ActiveCol>24</x:ActiveCol>"                  skip
" </x:Pane>"                                      skip
" </x:Panes>"                                     skip
" <x:ProtectContents>False</x:ProtectContents>"   skip
" <x:ProtectObjects>False</x:ProtectObjects>"     skip
" <x:ProtectScenarios>False</x:ProtectScenarios>" skip
" </x:WorksheetOptions>"                          skip
" </x:ExcelWorksheet>"                            skip
" </x:ExcelWorksheets>"                           skip
" <x:WindowHeight>7305</x:WindowHeight>"          skip
" <x:WindowWidth>14220</x:WindowWidth>"           skip
" <x:WindowTopX>120</x:WindowTopX>"               skip
" <x:WindowTopY>30</x:WindowTopY>"                skip
" <x:ProtectStructure>False</x:ProtectStructure>" skip
" <x:ProtectWindows>False</x:ProtectWindows>"     skip
" </x:ExcelWorkbook>"                             skip
"</xml><![endif]-->"                              skip
"<meta http-equiv=Content-Language content=ru>"   skip.



    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small"">Форма 1. Сводный отчет о движении денег в иностранной валюте <br> по банковским счетам клиентов и переводам без открытия банковского счета c" vn-dtbeg "по" vn-dt "<BR>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>N</TD>"                              skip
        "<TD>Наименование показателя </TD>"       skip
        "<TD>Код строки</TD>"                     skip
        "<TD>Всего </TD>"            skip
        "<TD>Резидентов по операциям с резидентами </TD>"    skip
        "<TD>Резидентов по операциям с нерезидентами</TD>"   skip
        "<TD>Нерезидентов по операциям с резидентами</TD>"     skip
        "<TD>Нерезидентов по операциям с нерезидентами</TD>"   skip.



   {r-branch.i &proc = "eknptxb1"} 

/*    run eknptxb1. */

/* Суммируем */
   run sv1(25000, 25100, 25200).
   run sv1(24000, 24100, 24200).
   run sv1(23000, 23001, 23002).
   run sv1(21240, 21241, 21242).
   run sv1(15000, 15100, 15200).
   run sv1(14000, 14100, 14200).
   run sv1(13000, 13001, 13002).
   run sv1(11240, 11241, 11242).


   find last tmp-f2p2 where tmp-f2p2.kod = 21250.
   find last b1 where b1.kod = 21251.
   find last b2 where b2.kod = 21252.
   find last b3 where b3.kod = 21253.
   find last b4 where b4.kod = 21254.
   find last b5 where b5.kod = 21255.
   tmp-f2p2.summ =  b1.summ + b2.summ + b3.summ + b4.summ + b5.summ. 
   tmp-f2p2.RRez =  b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez. 
   tmp-f2p2.RNer =  b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer.   
   tmp-f2p2.NRez =  b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez.    
   tmp-f2p2.NNer =  b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer.


   run sv1(11000, 11100, 11200).

   find last tmp-f2p2 where tmp-f2p2.kod = 10000.
   find last b1 where b1.kod = 11000.
   find last b2 where b2.kod = 12000.
   find last b3 where b3.kod = 13000.
   find last b4 where b4.kod = 14000.
   find last b5 where b5.kod = 15000.
   tmp-f2p2.summ =  b1.summ + b2.summ + b3.summ + b4.summ + b5.summ. 
tmp-f2p2.RRez =  b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez. 
tmp-f2p2.RNer =  b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer.   
tmp-f2p2.NRez =  b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez.    
tmp-f2p2.NNer =  b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer.

   find last tmp-f2p2 where tmp-f2p2.kod = 21200.
   find last b1 where b1.kod = 21210.
   find last b2 where b2.kod = 21220.
   find last b3 where b3.kod = 21230.
   find last b4 where b4.kod = 21240.
   find last b5 where b5.kod = 21250.
   find last b6 where b6.kod = 21260.
   tmp-f2p2.summ = tmp-f2p2.summ + b1.summ + b2.summ + b3.summ + b4.summ + b5.summ + b6.summ. 
   tmp-f2p2.RRez = tmp-f2p2.RRez + b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez + b6.RRez. 
   tmp-f2p2.RNer = tmp-f2p2.RNer + b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer + b6.RNer.   
   tmp-f2p2.NRez = tmp-f2p2.NRez + b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez + b6.NRez.    
   tmp-f2p2.NNer = tmp-f2p2.NNer + b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer + b6.NNer.

   run sv1(21000, 21100, 21200).

   find last tmp-f2p2 where tmp-f2p2.kod = 20000.
   find last b1 where b1.kod = 21000.
   find last b2 where b2.kod = 22000.
   find last b3 where b3.kod = 23000.
   find last b4 where b4.kod = 24000.
   find last b5 where b5.kod = 25000.
   tmp-f2p2.summ = tmp-f2p2.summ + b1.summ + b2.summ + b3.summ + b4.summ + b5.summ. tmp-f2p2.RRez = tmp-f2p2.RRez + b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez. tmp-f2p2.RNer = tmp-f2p2.RNer + b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer.   tmp-f2p2.NRez = tmp-f2p2.NRez + b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez.    tmp-f2p2.NNer = tmp-f2p2.NNer + b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer.

   find last tmp-f2p2 where tmp-f2p2.kod = 11250.
   find last b1 where b1.kod = 11251.
   find last b2 where b2.kod = 11252.
   find last b3 where b3.kod = 11253.
   find last b4 where b4.kod = 11254.
   find last b5 where b5.kod = 11255.
   tmp-f2p2.summ =  b1.summ + b2.summ + b3.summ + b4.summ + b5.summ. 
tmp-f2p2.RRez =  b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez. 
tmp-f2p2.RNer =  b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer.   
tmp-f2p2.NRez =  b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez.    
tmp-f2p2.NNer =  b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer.

   find last tmp-f2p2 where tmp-f2p2.kod = 11200.
   find last b1 where b1.kod = 11210.
   find last b2 where b2.kod = 11220.
   find last b3 where b3.kod = 11230.
   find last b4 where b4.kod = 11240.
   find last b5 where b5.kod = 11250.
   find last b6 where b6.kod = 11260.
   tmp-f2p2.summ = tmp-f2p2.summ + b1.summ + b2.summ + b3.summ + b4.summ + b5.summ + b6.summ. 
   tmp-f2p2.RRez = tmp-f2p2.RRez + b1.RRez + b2.RRez + b3.RRez + b4.RRez + b5.RRez + b6.RRez. 
   tmp-f2p2.RNer = tmp-f2p2.RNer + b1.RNer + b2.RNer + b3.RNer + b4.RNer + b5.RNer + b6.RNer.   
   tmp-f2p2.NRez = tmp-f2p2.NRez + b1.NRez + b2.NRez + b3.NRez + b4.NRez + b5.NRez + b6.NRez.    
   tmp-f2p2.NNer = tmp-f2p2.NNer + b1.NNer + b2.NNer + b3.NNer + b4.NNer + b5.NNer + b6.NNer.









for each tmp-f2p2 break by tmp-f2p2.nom:
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>" tmp-f2p2.nom  "</TD>" skip
        "<TD align=""left"">" tmp-f2p2.name "</TD>" skip.
    if tmp-f2p2.kod <> 0 then
       put unformatted
          "<TD>" tmp-f2p2.kod  "</TD>" skip
          "<TD>" tmp-f2p2.summ "</TD>" skip
          "<TD>" tmp-f2p2.RRez "</TD>" skip
          "<TD>" tmp-f2p2.RNer "</TD>" skip
          "<TD>" tmp-f2p2.NRez "</TD>" skip
          "<TD>" tmp-f2p2.NNer "</TD>" skip.
    else
       put unformatted "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip.
end.


   {html-end.i " "}
   output close.
   unix silent cptwin value(file1) excel.



procedure sv1:
     def input parameter i0 as integer.
     def input parameter i1 as integer.
     def input parameter i2 as integer.
     find last tmp-f2p2 where tmp-f2p2.kod = i0.
     find last b1 where b1.kod = i1.
     find last b2 where b2.kod = i2.
     tmp-f2p2.summ =  b1.summ + b2.summ.  
     tmp-f2p2.RRez =  b1.RRez + b2.RRez. 
     tmp-f2p2.RNer =  b1.RNer + b2.RNer. 
     tmp-f2p2.NRez =  b1.NRez + b2.NRez. 
     tmp-f2p2.NNer =  b1.NNer + b2.NNer.
end.




