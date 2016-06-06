/* fiz.p
 * MODULE
        Счета
 * DESCRIPTION
        Отчет по текущим счетам физических лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-7-1-16-4-2
 * AUTHOR
        28.04.06 dpuchkov
 * CHANGES
        03.05.2006 dpuchkov - исправил ошибки при суммировании итоговых сумм.
*/




{global.i}


def new shared var d_date as date.
def new shared var d-ix as integer.
        d-ix = 100.


def new shared temp-table dn 
     field num      as integer
     field ind      as char
     field tn_kzt   as integer
     field tnul_kzt as integer
     field bn_kzt   as integer
     field bnul_kzt as integer
     field tn_usd   as integer
     field tnul_usd as integer
     field tn_eur   as integer
     field tnul_eur as integer.


def var file1 as char format "x(20)" .

   define frame frame1
   d_date  label "Отчет на дату    " with side-labels centered row 9.
   d_date = date(month(g-today), 01, year(g-today)).
   displ d_date with frame frame1.
   hide frame frame1.

   display "ЖДИТЕ ИДЕТ ФОРМИРОВАНИЕ ОТЧЕТА..." skip  with row 12 frame ww centered no-box.
   pause 0.

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
        "<P align=""center"" style=""font:bold;font-size:small""> Отчет по текущим счетам физических лиц на " d_date  "<BR>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.



    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
        "<TD></TD>"                     skip
        "<TD colspan = 7 >KZT</TD>"    skip
        "<TD colspan = 3>USD</TD>"     skip
        "<TD colspan = 3>EUR</TD>"     skip
        "<TD colspan = 3>ВСЕГО</TD>"   skip         
        "</TR>" skip


        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip

        "<TD></TD>"                               skip 
        "<TD colspan = 3 >Текущие счета</TD>"    skip
        "<TD colspan = 3 >Быстрые деньги</TD>"   skip
        "<TD colspan = 1></TD>"                  skip

        "<TD colspan = 3 >Текущие счета</TD>"    skip
        "<TD colspan = 3 >Текущие счета</TD>"    skip
        "<TD colspan = 3 >по KZT, USD, EUR</TD>" "</TR>" skip

        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip 


        "<TD></TD>"                        skip
        "<TD>с ненулевыми остатками</TD>"  skip 
        "<TD>с нулевыми остатками</TD>"    skip 
        "<TD>Итого по текущим счетам</TD>" skip
        "<TD>с ненулевыми остатками</TD>"  skip
        "<TD>с нулевыми остатками</TD>"    skip
        "<TD>Всего по БД:</TD>"            skip
        "<TD>Всего KZT</TD>"               skip

        "<TD>с ненулевыми остатками</TD>"  skip
        "<TD>с нулевыми остатками</TD>"    skip
        "<TD>Всего USD</TD>"               skip

        "<TD>с ненулевыми остатками</TD>"  skip
        "<TD>с нулевыми остатками</TD>"    skip
        "<TD>Всего EUR</TD>"               skip

        "<TD>с ненулевыми остатками</TD>"  skip
        "<TD>с нулевыми остатками</TD>"    skip
        "<TD>ВСЕГО</TD>"                   skip.






/*   run fiztxb.   */
  def var tl as integer EXTENT 20.

  {r-branch.i &proc = "fiztxb"} 
  def buffer b-dn for dn.
  for each dn break by dn.num:
      if dn.num = 101 then do: /* сумма */
         for each b-dn where b-dn.num < 100:
             tl[1] = tl[1] + b-dn.tn_kzt.
             tl[2] = tl[2] + b-dn.tnul_kzt.
             tl[3] = tl[3] + b-dn.tnul_kzt + b-dn.tn_kzt.
             tl[4] = tl[4] + b-dn.bn_kzt.
             tl[5] = tl[5] + b-dn.bnul_kzt.
             tl[6] = tl[6] + b-dn.bn_kzt + b-dn.bnul_kzt.
             tl[7] = tl[7] + b-dn.bn_kzt + b-dn.bnul_kzt + b-dn.tnul_kzt + b-dn.tn_kzt.
             tl[8] = tl[8] + b-dn.tn_usd.
             tl[9] = tl[9] + b-dn.tnul_usd.
             tl[10] = tl[10] + b-dn.tn_usd + b-dn.tnul_usd.
             tl[11] = tl[11] + b-dn.tn_eur.
             tl[12] = tl[12] + b-dn.tnul_eur.
             tl[13] = tl[13] + b-dn.tn_eur + b-dn.tnul_eur.
             tl[14] = tl[14] + b-dn.tn_kzt + b-dn.bn_kzt + b-dn.tn_usd + b-dn.tn_eur.
             tl[15] = tl[15] + b-dn.tnul_kzt + b-dn.bnul_kzt + b-dn.tnul_usd + b-dn.tnul_eur.
             tl[16] = tl[16] + b-dn.tn_kzt + b-dn.bn_kzt + b-dn.tn_usd + b-dn.tn_eur + b-dn.tnul_kzt + b-dn.bnul_kzt + b-dn.tnul_usd + b-dn.tnul_eur.
         end.
      put unformatted
         "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
         "<TD>  Всего по г.Алматы </TD>"  skip
         "<TD>" tl[1]   "</TD>"  skip
         "<TD>" tl[2] "</TD>"  skip
         "<TD>" tl[3] "</TD>"  skip
         "<TD>" tl[4]   "</TD>"  skip
         "<TD>" tl[5] "</TD>"  skip
         "<TD>" tl[6] "</TD>"  skip
         "<TD>" tl[7] "</TD>"  skip
         "<TD>" tl[8]   "</TD>"  skip
         "<TD>" tl[9] "</TD>"  skip
         "<TD>" tl[10] "</TD>"  skip
         "<TD>" tl[11]   "</TD>"  skip
         "<TD>" tl[12] "</TD>"  skip
         "<TD>" tl[13] "</TD>"  skip
         "<TD>" tl[14] "</TD>"  skip
         "<TD>" tl[15] "</TD>"  skip
         "<TD>" tl[16] "</TD>" skip.
      end.
      put unformatted
         "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
         "<TD>" dn.ind   "</TD>"  skip            
         "<TD>" tn_kzt   "</TD>"  skip                
         "<TD>" tnul_kzt "</TD>"  skip                
         "<TD>" tnul_kzt + tn_kzt "</TD>"  skip       
         "<TD>" bn_kzt   "</TD>"  skip                
         "<TD>" bnul_kzt "</TD>"  skip                 
         "<TD>" bn_kzt + bnul_kzt "</TD>"  skip         
         "<TD>" bn_kzt + bnul_kzt + tnul_kzt + tn_kzt "</TD>"  skip   
         "<TD>" tn_usd   "</TD>"  skip                                
         "<TD>" tnul_usd "</TD>"  skip                                
         "<TD>" tn_usd + tnul_usd "</TD>"  skip                       
         "<TD>" tn_eur   "</TD>"  skip                                
         "<TD>" tnul_eur "</TD>"  skip                                
         "<TD>" tn_eur + tnul_eur "</TD>"  skip                       
         "<TD>" tn_kzt + bn_kzt + tn_usd + tn_eur "</TD>"  skip       
         "<TD>" tnul_kzt + bnul_kzt + tnul_usd + tnul_eur "</TD>"  skip   
         "<TD>" tn_kzt + bn_kzt + tn_usd + tn_eur + tnul_kzt + bnul_kzt + tnul_usd + tnul_eur "</TD>" skip. 
  end.
         tl = 0.
         for each b-dn:
             tl[1] = tl[1] + b-dn.tn_kzt.
             tl[2] = tl[2] + b-dn.tnul_kzt.
             tl[3] = tl[3] + b-dn.tnul_kzt + b-dn.tn_kzt.
             tl[4] = tl[4] + b-dn.bn_kzt.
             tl[5] = tl[5] + b-dn.bnul_kzt.
             tl[6] = tl[6] + b-dn.bn_kzt + b-dn.bnul_kzt.
             tl[7] = tl[7] + b-dn.bn_kzt + b-dn.bnul_kzt + b-dn.tnul_kzt + b-dn.tn_kzt.
             tl[8] = tl[8] + b-dn.tn_usd.
             tl[9] = tl[9] + b-dn.tnul_usd.
             tl[10] = tl[10] + b-dn.tn_usd + b-dn.tnul_usd.
             tl[11] = tl[11] + b-dn.tn_eur.
             tl[12] = tl[12] + b-dn.tnul_eur.
             tl[13] = tl[13] + b-dn.tn_eur + b-dn.tnul_eur.
             tl[14] = tl[14] + b-dn.tn_kzt + b-dn.bn_kzt + b-dn.tn_usd + b-dn.tn_eur.
             tl[15] = tl[15] + b-dn.tnul_kzt + b-dn.bnul_kzt + b-dn.tnul_usd + b-dn.tnul_eur.
             tl[16] = tl[16] + b-dn.tn_kzt + b-dn.bn_kzt + b-dn.tn_usd + b-dn.tn_eur + b-dn.tnul_kzt + b-dn.bnul_kzt + b-dn.tnul_usd + b-dn.tnul_eur.
         end.
      put unformatted
         "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
         "<TD>  ИТОГО </TD>"  skip
         "<TD>" tl[1]   "</TD>"  skip
         "<TD>" tl[2] "</TD>"  skip
         "<TD>" tl[3] "</TD>"  skip
         "<TD>" tl[4]   "</TD>"  skip
         "<TD>" tl[5] "</TD>"  skip
         "<TD>" tl[6] "</TD>"  skip
         "<TD>" tl[7] "</TD>"  skip
         "<TD>" tl[8]   "</TD>"  skip
         "<TD>" tl[9] "</TD>"  skip
         "<TD>" tl[10] "</TD>"  skip
         "<TD>" tl[11]   "</TD>"  skip
         "<TD>" tl[12] "</TD>"  skip
         "<TD>" tl[13] "</TD>"  skip
         "<TD>" tl[14] "</TD>"  skip
         "<TD>" tl[15] "</TD>"  skip
         "<TD>" tl[16] "</TD>" skip.




   {html-end.i " "}
   output close.
   unix silent cptwin value(file1) excel.







