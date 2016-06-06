/* acc_cls.p
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
        8.1.8.14
 * BASES
        BANK COMM
 * AUTHOR
        06/03/09 id00004
        27.01.10 marinav - расширение поля счета до 20 знаков
        30.03.10 id00004 - добавил группы для учета счетов KASSANOVA
        07.10.11 lyubov - заменила r-branch на r-brfilial
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
*/

{global.i}

def new  shared var g_date as date.
def new  shared var v-dbeg as date.
def new  shared var v-dend as date.
def new  shared var v-tp as integer.

def var file1 as char.
def var lb_1 as integer.

def new  shared temp-table t-clients
    field  cif as char
    field  name as char
    field  aaa like bank.aaa.aaa
    field  who as char
    field  whn as date
    field  whncls as date
    field  crc as integer
    field  stchet as char  /*D-депозит  T-текущий*/
    field  stpp as char  /*U-юридическое лицо P-физическое лицо*/
    field  txb as char
    field  konv as char
    field  prim as char
    field  sumvval as decimal
    field  sumvtng as decimal
    field  rte as char
    field  ddes as char.



    g_date = g-today.



    update "Дата ...   с " v-dbeg "  по " v-dend with frame cc row 14  column 30 no-label no-box.
    run sel2 (" Тип ", " 1. Физические лица | 2. Юридические лица", output v-tp).

    if v-dbeg = ?  or v-dend = ? then do:
       message "Дата введена некорректно " .
       pause.
       return.
    end.



/*    if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
       message "Дата должна быть не ранее 1 марта 2009 г" .
       pause.
       return.
    end. */

    {r-brfilial.i &proc = "acc_cls1"}


    file1 = "file2.html".
    output to value(file1).
/*    {html-title.i}  */

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

/*put unformatted '.xl34 \{mso-style-parent:style0;font-weight:700;font-family:"Times New Roman", serif;mso-font-charset:204;text-align:center;white-space:normal;\}' skip.
*/
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

if v-tp = 1 then
    put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">ОТЧЁТ ПО ЗАКРЫТЫМ СЧЕТАМ ФИЗИЧЕСКИХ ЛИЦ C " + string(v-dbeg) + "  ПО " + string(v-dend) +  " </P>" skip.
else
    put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">ОТЧЁТ ПО ЗАКРЫТЫМ СЧЕТАМ ЮРИДИЧЕСКИХ ЛИЦ C " + string(v-dbeg) + "  ПО " + string(v-dend) +  " </P>" skip.



    for each txb where txb.consolid = true  no-lock:

        lb_1 = 0.
        for each t-clients where t-clients.txb = txb.bank  :
            lb_1 = lb_1 + 1.
        end.

        if lb_1 <> 0 then do:
        put unformatted  "<P align=""center"" style=""font:bold;font-size:small"">" + txb.info /*+ "</P>" */ .

        put unformatted "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.


            put unformatted "<tr valign=top style=""background:"  "lightyellow " """>"      skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Код клиента</td>"      skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">ФИО/Наименование</td>" skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Счет клиента</td>"     skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Ставка</td>"           skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Наименование</td>"     skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Логин менеджера</td>"  skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Дата открытия</td>"    skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Дата закрытия</td>"    skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Валюта счета</td>"     skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Статус счета</td>"     skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Примечание</td>"       skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Сумма в вал вклада</td>" skip.
            put unformatted "<td class=xl34 style=""text-align:center;vertical-align:middle;"">Сумма в тенге</td>"      skip.

            put unformatted "</TR>" skip.




        for each t-clients where t-clients.txb = txb.bank:


            put unformatted "<tr valign=top style=""background:"  "white " """>" skip.
            put unformatted
                "<td>" t-clients.cif "</td>"  skip
                "<td>" t-clients.name "</td>" skip
                "<td>" t-clients.aaa "</td>"  skip
                "<td>'" t-clients.rte "</td>"  skip
                "<td>" t-clients.ddes "</td>"  skip
/*              "<td>" t-clients.konv "</td>" skip   */
                "<td>" t-clients.who "</td>"  skip
                "<td>" t-clients.whn "</td>"  skip
                "<td>" t-clients.whncls "</td>"  skip.

if t-clients.crc = 1 then put unformatted "<td>KZT</td>"  skip.
if t-clients.crc = 2 then put unformatted "<td>USD</td>"  skip.
if t-clients.crc = 3 then put unformatted "<td>EUR</td>"  skip.
if t-clients.crc = 4 then put unformatted "<td>RUR</td>"  skip.

if t-clients.crc = 6 then put unformatted "<td>GBP</td>"  skip.
if t-clients.crc = 7 then put unformatted "<td>SEK</td>"  skip.
if t-clients.crc = 8 then put unformatted "<td>AUD</td>"  skip.
if t-clients.crc = 9 then put unformatted "<td>CHF</td>"  skip.

if t-clients.crc = 10 then put unformatted "<td>ZAR</td>" skip.
if t-clients.crc = 11 then put unformatted "<td>CAD</td>" skip.

                if stchet = "D" then  put unformatted "<td>депозит</td>"  skip.
                if stchet = "T" then  put unformatted "<td>текущий</td>"  skip.

            put unformatted "<td>" t-clients.prim "</td>" skip.

            put unformatted "<td>" replace(string((t-clients.sumvval) ,"-zzzzzzzzzzzzz9.99"),".",",") "</td>" skip.
            put unformatted "<td>" replace(string((t-clients.sumvtng) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</td>" skip.


            put unformatted "</TR>" skip.
        end.
        put unformatted "</TABLE>" skip.


       end. /* lb_1 <> 0 */

    end.


    {html-end.i " "}
  output close .
  hide frame ww.
  unix silent cptwin value(file1) excel.