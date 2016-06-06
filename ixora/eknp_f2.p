/* eknp_f2.p
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
        8-9-6-4
 * CONNECT
        comm, txb
 * BASES
        BANK COMM
 * AUTHOR
        05/04/2006 dpuchkov
 * CHANGES
        03.05.2006 dpuchkov изменил округление до целых
        26/05/2006 dpuchkov перекомпиляция
        09.06.2006 dpuchkov - добавил проверку на наличные деньги
*/




{global.i}
def new shared var vn-dt as date     no-undo.
def new shared var vn-dtbeg as date  no-undo.
def new shared var v-jss as char     no-undo.
def var v-str as char                no-undo.
def var file1 as char format "x(20)" no-undo.

 def new shared temp-table tmp-f2 
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field usd  as decimal decimals 2
     field eur  as decimal decimals 2
     field rur  as decimal decimals 2. 

 def new shared temp-table tmp-f2p2
     field nom  as integer
     field name as char
     field kod  as integer
     field summ as decimal decimals 2
     field tgrez   as decimal decimals 2
     field tgnorez  as decimal decimals 2
     field valrez  as decimal decimals 2
     field valnorez  as decimal decimals 2. 

 def new shared temp-table tmp-d
     field djh as integer.


create tmp-f2. tmp-f2.nom = 1. tmp-f2.name = "Покупка иностранной валюты банком". tmp-f2.kod = 110000.
create tmp-f2. tmp-f2.nom = 2. tmp-f2.name = "в том числе:".                      tmp-f2.kod = 0.
create tmp-f2. tmp-f2.nom = 3. tmp-f2.name = "у клиентов банка".                  tmp-f2.kod = 110001.
create tmp-f2. tmp-f2.nom = 4. tmp-f2.name = "на Казахстанской фондовой бирже".   tmp-f2.kod = 110002.
create tmp-f2. tmp-f2.nom = 5. tmp-f2.name = "Продажа иностранной валюты банком". tmp-f2.kod = 120000.
create tmp-f2. tmp-f2.nom = 6. tmp-f2.name = "в том числе:".                      tmp-f2.kod = 0.
create tmp-f2. tmp-f2.nom = 7. tmp-f2.name = "клиентам банка".                    tmp-f2.kod = 120001.
create tmp-f2. tmp-f2.nom = 8. tmp-f2.name = "на Казахстанской фондовой бирже".   tmp-f2.kod = 120002.



 update vn-dtbeg label " Укажите период с"  /* validate(vn-dtbeg >= g-today - 15, "Только за последнюю декаду ") */
 vn-dt label "по" /* validate(vn-dt <= g-today, "Только за последнюю декаду ")*/
 with side-labels centered row 9.


   file1 = "3213.html".
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
        "<P align=""center"" style=""font:bold;font-size:small"">Форма 2. Отчет о покупке/продаже иностранной валюты банком и его клиентами <br> Раздел 1. Операции банка" vn-dtbeg "по" vn-dt "<BR>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>N</TD>"     skip
        "<TD>Наименование показателя </TD>" skip
        "<TD>Код строки</TD>"     skip
        "<TD>Всего (тысяч тенге)</TD>"     skip
        "<TD>USD</TD>"     skip
        "<TD>EUR</TD>"     skip
        "<TD>RUR</TD>"     skip.


    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>A</TD>"     skip
        "<TD>Б</TD>"     skip
        "<TD>В</TD>"     skip
        "<TD>1</TD>"     skip
        "<TD>2</TD>"     skip
        "<TD>3</TD>"     skip
        "<TD>4</TD>"     skip.
/* run eknptxb2. */
   {r-branch.i &proc = "eknptxb2"} 

  def buffer b1-tmp-f2 for tmp-f2.
  def buffer b2-tmp-f2 for tmp-f2.
  find last tmp-f2    where tmp-f2.kod    = 110000.
  find last b1-tmp-f2 where b1-tmp-f2.kod = 110001.
  find last b2-tmp-f2 where b2-tmp-f2.kod = 110002.
  tmp-f2.summ =  b1-tmp-f2.summ + b2-tmp-f2.summ.
  tmp-f2.usd  =  b1-tmp-f2.usd  + b2-tmp-f2.usd.
  tmp-f2.eur  =  b1-tmp-f2.eur  + b2-tmp-f2.eur.
  tmp-f2.rur  =  b1-tmp-f2.rur  + b2-tmp-f2.rur.

  find last tmp-f2    where tmp-f2.kod    = 120000.
  find last b1-tmp-f2 where b1-tmp-f2.kod = 120001.
  find last b2-tmp-f2 where b2-tmp-f2.kod = 120002.
  tmp-f2.summ =  b1-tmp-f2.summ + b2-tmp-f2.summ.
  tmp-f2.usd  =  b1-tmp-f2.usd  + b2-tmp-f2.usd.
  tmp-f2.eur  =  b1-tmp-f2.eur  + b2-tmp-f2.eur.
  tmp-f2.rur  =  b1-tmp-f2.rur  + b2-tmp-f2.rur.



for each tmp-f2 break by tmp-f2.nom:
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>" tmp-f2.nom  "</TD>" skip
        "<TD>" tmp-f2.name "</TD>" skip.
if tmp-f2.kod <> 0 then
    put unformatted
        "<TD>" tmp-f2.kod   "</TD>" skip
        "<TD>" tmp-f2.summ  "</TD>" skip
        "<TD>" tmp-f2.usd   "</TD>" skip
        "<TD>" tmp-f2.eur   "</TD>" skip
        "<TD>" tmp-f2.rur   "</TD>" skip.
else
    put unformatted "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip "<TD></TD>" skip.

end.

   {html-end.i " "}
   output close.
   unix silent cptwin value(file1) excel.









create tmp-f2p2. tmp-f2p2.kod = 210000. tmp-f2p2.nom = 1.  tmp-f2p2.name = "Покупка иностранной валюты клиентами банка". 
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 2.  tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 211000. tmp-f2p2.nom = 3.  tmp-f2p2.name = "физическими лицами, включая <br> зарегистрированных в качестве <br> хозяйствующих субъектов без <br> образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 211400. tmp-f2p2.nom = 4.  tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в иностранной валюте". 
create tmp-f2p2. tmp-f2p2.kod = 212000. tmp-f2p2.nom = 5.  tmp-f2p2.name = "юридическими лицами". 
create tmp-f2p2. tmp-f2p2.kod = 212400. tmp-f2p2.nom = 6.  tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в иностранной валюте". 
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 7.  tmp-f2p2.name = "в том числе для целей:". 
create tmp-f2p2. tmp-f2p2.kod = 212409. tmp-f2p2.nom = 8.  tmp-f2p2.name = "проведения обменных операций с наличной иностранной валютой". 
create tmp-f2p2. tmp-f2p2.kod = 212410. tmp-f2p2.nom = 9.  tmp-f2p2.name = "осуществления платежей и переводов денег в пользу резидентов". 
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 10. tmp-f2p2.name = "в том числе по операциям:". 
create tmp-f2p2. tmp-f2p2.kod = 212411. tmp-f2p2.nom = 11. tmp-f2p2.name = "покупка товаров и нематериальных активов". 
create tmp-f2p2. tmp-f2p2.kod = 212412. tmp-f2p2.nom = 12. tmp-f2p2.name = "получение услуг". 
create tmp-f2p2. tmp-f2p2.kod = 212413. tmp-f2p2.nom = 13. tmp-f2p2.name = "выдача займов". 
create tmp-f2p2. tmp-f2p2.kod = 212414. tmp-f2p2.nom = 14. tmp-f2p2.name = "выполнение обязательств по займам". 
create tmp-f2p2. tmp-f2p2.kod = 212415. tmp-f2p2.nom = 15. tmp-f2p2.name = "расчеты по операциям с ценными бумагами". 
create tmp-f2p2. tmp-f2p2.kod = 212416. tmp-f2p2.nom = 16. tmp-f2p2.name = "выплата заработной платы". 
create tmp-f2p2. tmp-f2p2.kod = 212417. tmp-f2p2.nom = 17. tmp-f2p2.name = "выплата командировочных и представительских расходов". 
create tmp-f2p2. tmp-f2p2.kod = 212418. tmp-f2p2.nom = 18. tmp-f2p2.name = "прочее". 
create tmp-f2p2. tmp-f2p2.kod = 212420. tmp-f2p2.nom = 19. tmp-f2p2.name = "осуществление платежей и переводов денег в пользу нерезидентов". 
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 20. tmp-f2p2.name = "в том числе по операциям:". 
create tmp-f2p2. tmp-f2p2.kod = 212421. tmp-f2p2.nom = 21. tmp-f2p2.name = "покупка товаров и нематериальных активов". 
create tmp-f2p2. tmp-f2p2.kod = 212422. tmp-f2p2.nom = 22. tmp-f2p2.name = "получение услуг". 
create tmp-f2p2. tmp-f2p2.kod = 212423. tmp-f2p2.nom = 23. tmp-f2p2.name = "выдача займов". 
create tmp-f2p2. tmp-f2p2.kod = 212424. tmp-f2p2.nom = 24. tmp-f2p2.name = "выполнение обязательств по займам ". 
create tmp-f2p2. tmp-f2p2.kod = 212425. tmp-f2p2.nom = 25. tmp-f2p2.name = "расчеты по операциям с ценными бумагами". 
create tmp-f2p2. tmp-f2p2.kod = 212426. tmp-f2p2.nom = 26. tmp-f2p2.name = "выплаты заработной платы". 
create tmp-f2p2. tmp-f2p2.kod = 212427. tmp-f2p2.nom = 27. tmp-f2p2.name = "выплата командировочных и представительских расходов". 
create tmp-f2p2. tmp-f2p2.kod = 212428. tmp-f2p2.nom = 28. tmp-f2p2.name = "прочее". 
create tmp-f2p2. tmp-f2p2.kod = 220000. tmp-f2p2.nom = 29. tmp-f2p2.name = "Продажа иностранной валюты клиентами банка". 
create tmp-f2p2. tmp-f2p2.kod = 0.      tmp-f2p2.nom = 30. tmp-f2p2.name = "в том числе:". 
create tmp-f2p2. tmp-f2p2.kod = 221000. tmp-f2p2.nom = 31. tmp-f2p2.name = "физическими лицами, включая зарегистрированных в качестве хозяйствующих субъектов без образования юридического лица". 
create tmp-f2p2. tmp-f2p2.kod = 221400. tmp-f2p2.nom = 32. tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в  национальной валюте". 
create tmp-f2p2. tmp-f2p2.kod = 222000. tmp-f2p2.nom = 33. tmp-f2p2.name = "юридическими лицами". 
create tmp-f2p2. tmp-f2p2.kod = 222400. tmp-f2p2.nom = 34. tmp-f2p2.name = "из них зачислено на собственные банковские счета клиентов в национальной валюте". 
create tmp-f2p2. tmp-f2p2.kod = 222408. tmp-f2p2.nom = 35. tmp-f2p2.name = "из них обратная продажа неиспользованной купленной иностранной валюты". 


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
        "<P align=""center"" style=""font:bold;font-size:small"">Форма 2. Отчет о покупке/продаже иностранной валюты банком и его клиентами <br> Раздел 2. Операции клиентов банка" vn-dtbeg "по" vn-dt "<BR>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>N</TD>"                              skip
        "<TD>Наименование показателя </TD>"       skip
        "<TD>Код строки</TD>"                     skip
        "<TD>Всего (тысяч тенге)</TD>"            skip
        "<TD>За тенге  <br> резидентами </TD>"    skip
        "<TD>За тенге  <br> нерезидентами</TD>"   skip
        "<TD>За валюту <br> резидентами</TD>"     skip
        "<TD>За валюту <br> нерезидентами</TD>"   skip.


    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>A</TD>"     skip
        "<TD>Б</TD>"     skip
        "<TD>В</TD>"     skip
        "<TD>1</TD>"     skip
        "<TD>2</TD>"     skip
        "<TD>3</TD>"     skip
        "<TD>4</TD>"     skip
        "<TD>5</TD>"     skip.

 def buffer b-f2p2 for tmp-f2p2.
 def buffer b1-f2p2 for tmp-f2p2.
 def buffer b2-f2p2 for tmp-f2p2.
 def buffer b3-f2p2 for tmp-f2p2.
 def buffer b4-f2p2 for tmp-f2p2.
 def buffer b5-f2p2 for tmp-f2p2.
 def buffer b6-f2p2 for tmp-f2p2.
 def buffer b7-f2p2 for tmp-f2p2.

/*  run eknptxb2p2.  */
/*  {r-branch.i &proc = "eknptxb2p2"}*/


for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
/*    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). */
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run eknptxb2p2.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".
 


   find last tmp-f2p2 where tmp-f2p2.kod = 212420.
   find last b-f2p2  where b-f2p2.kod = 212421.
   find last b1-f2p2 where b1-f2p2.kod = 212422.
   find last b2-f2p2 where b2-f2p2.kod = 212423.
   find last b3-f2p2 where b3-f2p2.kod = 212424.
   find last b4-f2p2 where b4-f2p2.kod = 212425.
   find last b5-f2p2 where b5-f2p2.kod = 212426.
   find last b6-f2p2 where b6-f2p2.kod = 212427.
   find last b7-f2p2 where b7-f2p2.kod = 212428.
   tmp-f2p2.summ     = b-f2p2.summ     + b1-f2p2.summ     + b2-f2p2.summ     + b3-f2p2.summ     + b4-f2p2.summ     + b5-f2p2.summ     + b6-f2p2.summ     + b7-f2p2.summ.
   tmp-f2p2.tgrez    = b-f2p2.tgrez    + b1-f2p2.tgrez    + b2-f2p2.tgrez    + b3-f2p2.tgrez    + b4-f2p2.tgrez    + b5-f2p2.tgrez    + b6-f2p2.tgrez    + b7-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b-f2p2.tgnorez  + b1-f2p2.tgnorez  + b2-f2p2.tgnorez  + b3-f2p2.tgnorez  + b4-f2p2.tgnorez  + b5-f2p2.tgnorez  + b6-f2p2.tgnorez  + b7-f2p2.tgnorez.
   tmp-f2p2.valrez   = b-f2p2.valrez   + b1-f2p2.valrez   + b2-f2p2.valrez   + b3-f2p2.valrez   + b4-f2p2.valrez   + b5-f2p2.valrez   + b6-f2p2.valrez   + b7-f2p2.valrez.
   tmp-f2p2.valnorez = b-f2p2.valnorez + b1-f2p2.valnorez + b2-f2p2.valnorez + b3-f2p2.valnorez + b4-f2p2.valnorez + b5-f2p2.valnorez + b6-f2p2.valnorez + b7-f2p2.valnorez.

   find last tmp-f2p2 where tmp-f2p2.kod = 212410.
   find last b-f2p2  where b-f2p2.kod = 212411.
   find last b1-f2p2 where b1-f2p2.kod = 212412.
   find last b2-f2p2 where b2-f2p2.kod = 212413.
   find last b3-f2p2 where b3-f2p2.kod = 212414.
   find last b4-f2p2 where b4-f2p2.kod = 212415.
   find last b5-f2p2 where b5-f2p2.kod = 212416.
   find last b6-f2p2 where b6-f2p2.kod = 212417.
   find last b7-f2p2 where b7-f2p2.kod = 212418.
   tmp-f2p2.summ     = b-f2p2.summ     + b1-f2p2.summ     + b2-f2p2.summ     + b3-f2p2.summ     + b4-f2p2.summ     + b5-f2p2.summ     + b6-f2p2.summ     + b7-f2p2.summ.
   tmp-f2p2.tgrez    = b-f2p2.tgrez    + b1-f2p2.tgrez    + b2-f2p2.tgrez    + b3-f2p2.tgrez    + b4-f2p2.tgrez    + b5-f2p2.tgrez    + b6-f2p2.tgrez    + b7-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b-f2p2.tgnorez  + b1-f2p2.tgnorez  + b2-f2p2.tgnorez  + b3-f2p2.tgnorez  + b4-f2p2.tgnorez  + b5-f2p2.tgnorez  + b6-f2p2.tgnorez  + b7-f2p2.tgnorez.
   tmp-f2p2.valrez   = b-f2p2.valrez   + b1-f2p2.valrez   + b2-f2p2.valrez   + b3-f2p2.valrez   + b4-f2p2.valrez   + b5-f2p2.valrez   + b6-f2p2.valrez   + b7-f2p2.valrez.
   tmp-f2p2.valnorez = b-f2p2.valnorez + b1-f2p2.valnorez + b2-f2p2.valnorez + b3-f2p2.valnorez + b4-f2p2.valnorez + b5-f2p2.valnorez + b6-f2p2.valnorez + b7-f2p2.valnorez.


   find last tmp-f2p2 where tmp-f2p2.kod = 212400.
   find last b1-f2p2 where b1-f2p2.kod = 212409.
   find last b2-f2p2 where b2-f2p2.kod = 212410.
   find last b3-f2p2 where b3-f2p2.kod = 212420.
   tmp-f2p2.summ     = b1-f2p2.summ + b2-f2p2.summ + b3-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez    + b2-f2p2.tgrez    + b3-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez  + b2-f2p2.tgnorez  + b3-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez   + b2-f2p2.valrez   + b3-f2p2.valrez.
   tmp-f2p2.valnorez = b1-f2p2.valnorez + b2-f2p2.valnorez + b3-f2p2.valnorez.

   find last tmp-f2p2 where tmp-f2p2.kod = 212000.
   find last b1-f2p2 where b1-f2p2.kod = 212400.
   tmp-f2p2.summ     = b1-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez .
   tmp-f2p2.valnorez = b1-f2p2.valnorez.


   find last tmp-f2p2 where tmp-f2p2.kod = 211000.
   find last b1-f2p2 where b1-f2p2.kod = 211400.
   tmp-f2p2.summ     = b1-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez .
   tmp-f2p2.valnorez = b1-f2p2.valnorez.

   find last tmp-f2p2 where tmp-f2p2.kod = 210000.
   find last b1-f2p2 where b1-f2p2.kod = 211000.
   find last b2-f2p2 where b2-f2p2.kod = 212000.
   tmp-f2p2.summ     = b1-f2p2.summ + b2-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez    + b2-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez  + b2-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez   + b2-f2p2.valrez.
   tmp-f2p2.valnorez = b1-f2p2.valnorez + b2-f2p2.valnorez.


   find last tmp-f2p2 where tmp-f2p2.kod = 221400 .
   find last b1-f2p2 where b1-f2p2.kod = 221000.
   tmp-f2p2.summ     = b1-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez .
   tmp-f2p2.valnorez = b1-f2p2.valnorez.

/* find last tmp-f2p2 where tmp-f2p2.kod = 222400.
   find last b1-f2p2 where b1-f2p2.kod = 222408.
   tmp-f2p2.summ     = b1-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez .
   tmp-f2p2.valnorez = b1-f2p2.valnorez. */


   find last tmp-f2p2 where tmp-f2p2.kod = 222000.
   find last b1-f2p2 where b1-f2p2.kod = 222400.
   tmp-f2p2.summ     = b1-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez .
   tmp-f2p2.valnorez = b1-f2p2.valnorez.



   find last tmp-f2p2 where tmp-f2p2.kod = 220000.
   find last b1-f2p2 where b1-f2p2.kod = 221000.
   find last b2-f2p2 where b2-f2p2.kod = 222000.
   tmp-f2p2.summ     = b1-f2p2.summ + b2-f2p2.summ.
   tmp-f2p2.tgrez    = b1-f2p2.tgrez    + b2-f2p2.tgrez.
   tmp-f2p2.tgnorez  = b1-f2p2.tgnorez  + b2-f2p2.tgnorez.
   tmp-f2p2.valrez   = b1-f2p2.valrez   + b2-f2p2.valrez.
   tmp-f2p2.valnorez = b1-f2p2.valnorez + b2-f2p2.valnorez.











for each tmp-f2p2 break by tmp-f2p2.nom:
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD>" tmp-f2p2.nom      "</TD>" skip
        "<TD>" tmp-f2p2.name     "</TD>" skip
        "<TD>" tmp-f2p2.kod      "</TD>" skip
        "<TD>" tmp-f2p2.summ     "</TD>" skip
        "<TD>" tmp-f2p2.tgrez    "</TD>" skip
        "<TD>" tmp-f2p2.tgnorez  "</TD>" skip
        "<TD>" tmp-f2p2.valrez   "</TD>" skip
        "<TD>" tmp-f2p2.valnorez "</TD>" skip.
end.


   {html-end.i " "}
   output close.
   unix silent cptwin value(file1) excel.

  