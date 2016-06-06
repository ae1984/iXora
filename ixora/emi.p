/* emi.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        06/03/09 id00004
 * CHANGES
        23.11.2011 id00004 - добавил новые валюты и группы
        15.03.2012 id00810 - добавила v-bankname для печати
        04/05/2012 evseev - наименование банка из banknameDgv
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
*/

{global.i}

def var file1 as char.
def var v-bankname as char no-undo.
def new  shared var g_date as date.
def new  shared var v-dbeg as date.
def new  shared var v-dend as date.
def new  shared var v-tp as integer.

def new  shared temp-table tom
    field  pp as char    /* DF-деп физ   DU - депозит юр лица TF - текущий физ   TU - текущий юр  */
    field  df_kzt_kol as integer
    field  df_kzt_sum as decimal
    field  df_usd_kol as integer
    field  df_usd_sum as decimal
    field  df_eur_kol as integer
    field  df_eur_sum as decimal
    field  df_rur_kol as integer
    field  df_rur_sum as decimal

    field  df_gbp_kol as integer
    field  df_gbp_sum as decimal
    field  df_aud_kol as integer
    field  df_aud_sum as decimal
    field  df_sek_kol as integer
    field  df_sek_sum as decimal
    field  df_chf_kol as integer
    field  df_chf_sum as decimal
    field  df_zar_kol as integer
    field  df_zar_sum as decimal
    field  df_cad_kol as integer
    field  df_cad_sum as decimal.

    g_date = g-today.

    update "Дата ...   " v-dbeg  with frame cc row 14  column 30 no-label no-box.

    if v-dbeg < 03.01.09 then do:
       message "Дата должна быть не ранее 1 марта 2009 г" .
       pause.
       return.
    end.

create tom. tom.pp = "DF".
create tom. tom.pp = "DU".
create tom. tom.pp = "TF".
create tom. tom.pp = "TU".

  {r-branch.i &proc = "emi1"}

    find last tom where tom.pp = "DF".

    find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
    if avail sysc then v-bankname = sysc.chval.

    file1 = "file3.html".
    output to value(file1).

put  unformatted
   "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns=""http://www.w3.org/TR/REC-html40"">" skip
   "<HEAD>" skip
" <!--[if gte mso 9]><xml>" skip
" <x:ExcelWorkbook>" skip
"  <x:ExcelWorksheets>" skip
"   <x:ExcelWorksheet>" skip
"    <x:Name>17161</x:Name>" skip
"    <x:WorksheetOptions>" skip
"     <x:Zoom>100</x:Zoom>" skip
"     <x:Selected/>" skip
"     <x:DoNotDisplayGridlines/>" skip
"     <x:TopRowVisible>52</x:TopRowVisible>" skip
"     <x:Panes>" skip
"      <x:Pane>" skip
"       <x:Number>3</x:Number>" skip
"       <x:ActiveRow>12</x:ActiveRow>" skip
"       <x:ActiveCol>24</x:ActiveCol>" skip
"      </x:Pane>" skip
"     </x:Panes>" skip
"     <x:ProtectContents>False</x:ProtectContents>" skip
"     <x:ProtectObjects>False</x:ProtectObjects>" skip
"     <x:ProtectScenarios>False</x:ProtectScenarios>" skip
"    </x:WorksheetOptions>" skip
"   </x:ExcelWorksheet>" skip
"  </x:ExcelWorksheets>" skip
"  <x:WindowHeight>7305</x:WindowHeight>" skip
"  <x:WindowWidth>14220</x:WindowWidth>" skip
"  <x:WindowTopX>120</x:WindowTopX>" skip
" <x:WindowTopY>30</x:WindowTopY>" skip
"  <x:ProtectStructure>False</x:ProtectStructure>" skip
"  <x:ProtectWindows>False</x:ProtectWindows>" skip
" </x:ExcelWorkbook>" skip
"</xml><![endif]-->" skip
"<meta http-equiv=Content-Language content=ru>" skip


   "<TITLE>" skip.

put  unformatted
   '{&title}' skip.

put  unformatted
   "</TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip

   "<STYLE>" skip.


put unformatted ".xl33 \{serif;mso-font-charset:204;text-align:center;font-family:""Times New Roman"", serif;white-space:normal;background:silver; \}" skip.

put unformatted
        ".xl34"
	" \{mso-style-parent:style0;"
	"font-size:10.0pt;"
	"font-weight:700;"
	"font-family:""Times New Roman"", serif;"
	"mso-font-charset:0; \}" skip.

put unformatted
        ".xl35"
	" \{mso-style-parent:style0;"
	"font-size:10.0pt;"
	"font-weight:700;"
	"font-family:""Times New Roman"", serif;"
	"mso-font-charset:0; "
        "white-space:normal;background:silver;\}" skip.


put unformatted
        ".xl36"
	" \{mso-style-parent:style0;"
	"font-size:10.0pt;"
        "mso-number-format:Standard;"
	"font-family:""Times New Roman"", serif;"
	"mso-font-charset:0; \}" skip.

put unformatted
".xl37"
	"\{mso-style-parent:style0;"
	"font-size:8.0pt;"
	"font-style:italic;"
	"font-family:""Times New Roman"", serif;"
	"mso-font-charset:204;"
	"text-align:left; \}" skip.

put  unformatted    "</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.

    put unformatted  "<P align=""center"" style=""font:bold;font-size:small""> Анализ сберегательных и текущих счетов физ, юр лиц АО " + v-bankname + " на " + string(v-dbeg) +  " </P>" skip.

        put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">Сберегательные счета физических лиц "  /*+ "</P>" */ .

        put unformatted "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""50%"">" skip.

            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                                      skip.
            put unformatted "<td ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">Дата</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">тенге</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары США</td>"  skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">евро</td>"         skip.

            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">фунты</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары АВСТ</td>" skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">кроны</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">франки</td>"       skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">ранды</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары КНД</td>"  skip.

            put unformatted "</TR>" skip.
            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                        skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "</TR>" skip.

            find last tom where tom.pp = "DF".

            put unformatted "<tr valign=top >" skip.
            put unformatted
                "<td>" trim(string(v-dbeg)) "</td>"  skip


                "<td>" df_kzt_kol "</td>"  skip
                "<td style=""text-align:right;"">" replace(string((df_kzt_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_usd_kol "</td>"  skip
                "<td>" replace(string((df_usd_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_eur_kol "</td>"  skip
                "<td>" replace(string((df_eur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip

                "<td>" df_gbp_kol "</td>"  skip
                "<td>" replace(string((df_gbp_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                 "<td>" df_aud_kol "</td>"  skip
                "<td>" replace(string((df_aud_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_sek_kol "</td>"  skip
                "<td>" replace(string((df_sek_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_chf_kol "</td>"  skip
                "<td>" replace(string((df_chf_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_zar_kol "</td>"  skip
                "<td>" replace(string((df_zar_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_cad_kol "</td>"  skip
                "<td>" replace(string((df_cad_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip.

            put unformatted "</TR>" skip.

        put unformatted "</TABLE>" skip.

        put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">Сберегательные счета юридических лиц "  /*+ "</P>" */ .

        put unformatted "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""50%"">" skip.

            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                                      skip.
            put unformatted "<td ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">Дата</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">тенге</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары США</td>"  skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">евро</td>"         skip.

            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">фунты</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары АВСТ</td>" skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">кроны</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">франки</td>"       skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">ранды</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары КНД</td>"  skip.

            put unformatted "</TR>" skip.
            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                        skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "</TR>" skip.

            find last tom where tom.pp = "DU".

            put unformatted "<tr valign=top >" skip.
            put unformatted
                "<td>" trim(string(v-dbeg)) "</td>"  skip

                "<td>" df_kzt_kol "</td>"  skip
                "<td style=""text-align:right;"">" replace(string((df_kzt_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_usd_kol "</td>"  skip
                "<td>" replace(string((df_usd_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_eur_kol "</td>"  skip
                "<td>" replace(string((df_eur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip

                "<td>" df_gbp_kol "</td>"  skip
                "<td>" replace(string((df_gbp_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                 "<td>" df_aud_kol "</td>"  skip
                "<td>" replace(string((df_aud_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_sek_kol "</td>"  skip
                "<td>" replace(string((df_sek_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_chf_kol "</td>"  skip
                "<td>" replace(string((df_chf_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_zar_kol "</td>"  skip
                "<td>" replace(string((df_zar_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_cad_kol "</td>"  skip
                "<td>" replace(string((df_cad_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip.



            put unformatted "</TR>" skip.

        put unformatted "</TABLE>" skip.

        put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">Текущие счета физических лиц "  /*+ "</P>" */ .

        put unformatted "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""50%"">" skip.

            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                                      skip.
            put unformatted "<td ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">Дата</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">тенге</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары США</td>"  skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">евро</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">рубли</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">фунты</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары АВСТ</td>" skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">кроны</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">франки</td>"       skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">ранды</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары КНД</td>"  skip.

            put unformatted "</TR>" skip.
            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                        skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "</TR>" skip.

            find last tom where tom.pp = "TF".

            put unformatted "<tr valign=top >" skip.
            put unformatted
                "<td>" trim(string(v-dbeg)) "</td>"  skip

                "<td>" df_kzt_kol "</td>"  skip
                "<td style=""text-align:right;"">" replace(string((df_kzt_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_usd_kol "</td>"  skip
                "<td>" replace(string((df_usd_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_eur_kol "</td>"  skip
                "<td>" replace(string((df_eur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_rur_kol "</td>"  skip
                "<td>" replace(string((df_rur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip

                "<td>" df_gbp_kol "</td>"  skip
                "<td>" replace(string((df_gbp_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                 "<td>" df_aud_kol "</td>"  skip
                "<td>" replace(string((df_aud_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_sek_kol "</td>"  skip
                "<td>" replace(string((df_sek_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_chf_kol "</td>"  skip
                "<td>" replace(string((df_chf_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_zar_kol "</td>"  skip
                "<td>" replace(string((df_zar_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_cad_kol "</td>"  skip
                "<td>" replace(string((df_cad_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip.

            put unformatted "</TR>" skip.

        put unformatted "</TABLE>" skip.

        put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">Текущие счета юридических лиц "  /*+ "</P>" */ .

        put unformatted "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""50%"">" skip.

            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                                      skip.
            put unformatted "<td ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">Дата</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">тенге</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары США</td>"  skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">евро</td>"         skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">рубли</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">фунты</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары АВСТ</td>" skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">кроны</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">франки</td>"       skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">ранды</td>"        skip.
            put unformatted "<td COLSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;"">доллары КНД</td>"  skip.


            put unformatted "</TR>" skip.
            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"                        skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.

            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">кол-во</td>"  skip.
            put unformatted "<td  class=xl34 style=""text-align:center;vertical-align:middle;"">сумма</td>"   skip.


            put unformatted "</TR>" skip.

            find last tom where tom.pp = "TU".

            put unformatted "<tr valign=top >" skip.
            put unformatted
                "<td>" trim(string(v-dbeg)) "</td>"  skip

                "<td>" df_kzt_kol "</td>"  skip
                "<td style=""text-align:right;"">" replace(string((df_kzt_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_usd_kol "</td>"  skip
                "<td>" replace(string((df_usd_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_eur_kol "</td>"  skip
                "<td>" replace(string((df_eur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_rur_kol "</td>"  skip
                "<td>" replace(string((df_rur_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip

                "<td>" df_gbp_kol "</td>"  skip
                "<td>" replace(string((df_gbp_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                 "<td>" df_aud_kol "</td>"  skip
                "<td>" replace(string((df_aud_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_sek_kol "</td>"  skip
                "<td>" replace(string((df_sek_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_chf_kol "</td>"  skip
                "<td>" replace(string((df_chf_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_zar_kol "</td>"  skip
                "<td>" replace(string((df_zar_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip
                "<td>" df_cad_kol "</td>"  skip
                "<td>" replace(string((df_cad_sum) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>"  skip.

            put unformatted "</TR>" skip.

        put unformatted "</TABLE>" skip.


    {html-end.i " "}
  output close .
  hide frame ww.
  unix silent cptwin value(file1) excel.