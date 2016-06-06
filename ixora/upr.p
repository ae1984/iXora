/* 13lv_r.p
 * MODULE
        Депозитарий
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
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
        24/05/05 dpuchkov
 * CHANGES
        01/06/05 id00004 добавил no-lock
        14/06/05 id00004 добавил поле льготный тариф
        15.07.05 id00004 добавил сумму ежемесячного списания отчет
        22.11.05 id00004 добавил группу 412 (сл. записка от 22.11.05)
        25.05.2009 id00004 заменил Алию Турлыбекову на Аиду Мининову и удалил не существующие отделения
        30.03.10 id00004 - добавил группы для учета счетов KASSANOVA
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{mainhead.i}
/*{crc-crc.i} */
{nbankBik.i}

function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for crchis.
define buffer bcrc2 for crchis.

if d1 = 10.01.08 or d1 = 12.01.08 or d1 = 04.01.09 or d1 >= 03.02.09 then do:

    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end.
else
do:
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.


end.



end.



def new shared var d_date as date.
def new shared var g_date as date.
def new shared var v-paramt as integer.
def var file1 as char.


def new  shared temp-table t-zzz
       field  txb as char
       field  crc as integer
       field  sum as decimal
       field  rate as decimal
       field  lgr as char
       field  dep as integer
       field  ppoint as char
       field type as char
       field  ddt as date
       field  jur as char
       field  luksK as integer
       field  luksS as decimal
       field  vipK as integer
       field  vipS as decimal
       field  classK as integer
       field  classS as decimal
       field  standK as integer
       field  standS as decimal
       field  supeK as integer
       field  supeS as decimal
       field  metroK as integer
       field  metroS as decimal
       field  pensK as integer
       field  pensS as decimal
       field  kztK_ur as integer
       field  kztS_ur as decimal
       field  usdK_ur as integer
       field  usdS_ur as decimal
       field  eurK_ur as integer
       field  eurS_ur as decimal
       field  rubK_ur as integer
       field  rubS_ur as decimal
       field  kztK_fz as integer
       field  kztS_fz as decimal
       field  usdK_fz as integer
       field  usdS_fz as decimal
       field  eurK_fz as integer
       field  eurS_fz as decimal
       field  rubK_fz as integer
       field  rubS_fz as decimal
       field  nakK as integer
       field  nakS as decimal
       field  srochK as integer
       field  citi as char
       field  srochS as decimal .


def var v-kol_luks as integer.
def var v-sum_luks as decimal.
def var v-kol_vip as integer.
def var v-sum_vip as decimal.
def var v-kol_classic as integer.
def var v-sum_classic as decimal.
def var v-kol_standart as integer.
def var v-sum_standart as decimal.
def var v-kol_super as integer.
def var v-sum_super as decimal.



def var v-kol_kzt as integer.
def var v-sum_kzt as decimal.
def var v-kol_usd as integer.
def var v-sum_usd as decimal.
def var v-kol_eur as integer.
def var v-sum_eur as decimal.
def var v-kol_rub as integer.
def var v-sum_rub as decimal.

def var v-kol_nakop as integer.
def var v-sum_nakop as decimal.
def var v-kol_sroch as integer.
def var v-sum_sroch as decimal.

def var v-temp as decimal extent 30.

def var daterate as date.
def var v-dep as integer.



def var v-usdkol as decimal.
def var v-usdsum as decimal.
def var v-kztsum as decimal.



  run sel2 (" Параметры ", " 1. Ежемесячный отчет | 2. Еженедельный отчет | ВЫХОД", output v-dep).
  v-paramt = v-dep.
  if v-dep = 3 then return.
/*
if v-dep = 2  then do:
   message "Запрещено: нет данных для формирования еженедельного отчета" .
   return.
end.  */
  g_date = g-today.


  for each t-zzz:
      delete t-zzz.
  end.

  {r-branch.i &proc = "upr1"}




/*добавил */
if v-dep = 1  or v-dep = 2 then do:
  for each upr:
     find last t-zzz where  t-zzz.txb = upr.txb  and  t-zzz.dep = upr.dep  and  t-zzz.ddt = upr.ddt no-error.
     if not avail t-zzz then do:
        create t-zzz.
     end.


         t-zzz.txb  =   upr.txb.
         t-zzz.rate =   upr.rate.
         t-zzz.dep  =   upr.dep.
         t-zzz.ppoint = upr.ppoint .
         t-zzz.ddt    = upr.ddt.
         t-zzz.luksK =  upr.luksK.
         t-zzz.luksS  = upr.luksS.
         t-zzz.vipK  =  upr.vipK.
         t-zzz.vipS  =  upr.vipS.
         t-zzz.classK = upr.classK.
         t-zzz.classS = upr.classS.
         t-zzz.standK = upr.standK.
         t-zzz.standS = upr.standS.
         t-zzz.supeK  = upr.superK.
         t-zzz.supeS  = upr.superS.
         t-zzz.metroK = upr.metroK.
         t-zzz.metroS = upr.metroS.
         t-zzz.pensK  = upr.pensK .
         t-zzz.pensS  = upr.pensS .
         t-zzz.kztK_ur = upr.kztK_ur.
         t-zzz.kztS_ur = upr.kztS_ur.
         t-zzz.usdK_ur = upr.usdK_ur.
         t-zzz.usdS_ur = upr.usdS_ur.
         t-zzz.eurK_ur = upr.eurK_ur.
         t-zzz.eurS_ur = upr.eurS_ur.
         t-zzz.rubK_ur = upr.rubK_ur.
         t-zzz.rubS_ur = upr.rubS_ur.
         t-zzz.kztK_fz = upr.kztK_fz.
         t-zzz.kztS_fz = upr.kztS_fz.
         t-zzz.usdK_fz = upr.usdK_fz.
         t-zzz.usdS_fz = upr.usdS_fz.
         t-zzz.eurK_fz = upr.eurK_fz.
         t-zzz.eurS_fz = upr.eurS_fz.
         t-zzz.rubK_fz = upr.rubK_fz.
         t-zzz.rubS_fz = upr.runS_fz.
         t-zzz.nakK    = upr.nakK   .
         t-zzz.nakS    = upr.nakS   .
         t-zzz.srochK  = upr.srochK .
         t-zzz.citi    = upr.citi   .
         t-zzz.srochS  = upr.srochS .
  end.
  for each t-zzz:
     find last upr where  upr.txb = t-zzz.txb   and  upr.dep = t-zzz.dep   and  upr.ddt = t-zzz.ddt  no-error.
     if not avail upr then do:
        create upr.
         upr.txb  = t-zzz.txb.
         upr.rate = t-zzz.rate.
         upr.dep = t-zzz.dep.
         upr.ppoint = t-zzz.ppoint.
         upr.ddt = t-zzz.ddt.
         upr.luksK = t-zzz.luksK.
         upr.luksS = t-zzz.luksS.
         upr.vipK = t-zzz.vipK.
         upr.vipS = t-zzz.vipS.
         upr.classK = t-zzz.classK.
         upr.classS = t-zzz.classS.
         upr.standK = t-zzz.standK.
         upr.standS = t-zzz.standS.
         upr.superK = t-zzz.supeK.
         upr.superS = t-zzz.supeS.
         upr.metroK = t-zzz.metroK.
         upr.metroS = t-zzz.metroS.
         upr.pensK  = t-zzz.pensK .
         upr.pensS = t-zzz.pensS.
         upr.kztK_ur = t-zzz.kztK_ur.
         upr.kztS_ur = t-zzz.kztS_ur.
         upr.usdK_ur = t-zzz.usdK_ur.
         upr.usdS_ur = t-zzz.usdS_ur.
         upr.eurK_ur = t-zzz.eurK_ur.
         upr.eurS_ur = t-zzz.eurS_ur.
         upr.rubK_ur = t-zzz.rubK_ur .
         upr.rubS_ur = t-zzz.rubS_ur.
         upr.kztK_fz = t-zzz.kztK_fz.
         upr.kztS_fz = t-zzz.kztS_fz.
         upr.usdK_fz = t-zzz.usdK_fz.
         upr.usdS_fz = t-zzz.usdS_fz .
         upr.eurK_fz = t-zzz.eurK_fz.
         upr.eurS_fz = t-zzz.eurS_fz.
         upr.rubK_fz = t-zzz.rubK_fz.
         upr.runS_fz = t-zzz.rubS_fz.
         upr.nakK  = t-zzz.nakK .
         upr.nakS  = t-zzz.nakS .
         upr.srochK = t-zzz.srochK.
         upr.citi = t-zzz.citi  .
         upr.srochS  = t-zzz.srochS.

     end.
  end.

end.





/*добавил */


  file1 = "file1.html".
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


  put unformatted "<P align=""left"" style=""font:bold;font-size:small""> Операционный департамент " "<BR>" skip.
  put unformatted "<P class=xl34  align=""center"" ><b> Анализ сберегательных счетов физических лиц по " + v-nbankru + " " "</b><BR></BR>" skip.
  def var ii as integer.
  def var jj as integer.
  def var dtt as date.
  def var dttcnt as date.
  def var v-accept as integer.
  def var vs-txb as char.
  def var v-bnk as char.
  def var idx_i as integer.

    vs-txb = "00,16,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15" .



    do idx_i = 1 to 17:
       v-bnk = ENTRY(idx_i, vs-txb).
    for each txb where txb.consolid = true and txb.bank = string("TXB" + string(v-bnk)) no-lock:
        do ii = 1 to 20 :
           find last t-zzz  where t-zzz.txb = txb.bank  and t-zzz.dep = ii no-lock no-error.



                  if not avail t-zzz then next.
if  t-zzz.ppoint begins "СП-2 г.Алматы ул.Толе би, 297" then next.
if  t-zzz.ppoint begins "СП-3 г.Алматы мкр-н 6, д.11" then next.
if  t-zzz.ppoint begins "СП-5 г.Алматы ул. Толе би, 104" then next.
if  t-zzz.ppoint begins "СП-6 г.Алматы Мамыр-1 д.10 кв.2" then next.
if  t-zzz.ppoint begins "СП-0 г.Алматы ул. Тынышбаева д.3 кв.18" then next.
if  t-zzz.ppoint begins "СП-8 г.Алматы ул. Макатаева д.53 кв.2" then next.
if  t-zzz.ppoint begins "СП-10" then next.
if  t-zzz.ppoint begins "СП-11" then next.


                  if txb.bank = "TXB16" then
                        put unformatted "<P class=xl34 align=""center"" ><b>" t-zzz.ppoint  " (Филиал по г.Алматы) </b>" skip.
                  else
                        put unformatted "<P class=xl34 align=""center""><b>" t-zzz.citi /*t-zzz.ppoint*/  "</b>" skip.

                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>МетроЛюкс</TD>    "
                  "            <TD COLSPAN=2 class=xl34>МетроVIP</TD>        "
                  "            <TD COLSPAN=2 class=xl34>МетроКлассик</TD>    "
                  "            <TD COLSPAN=2 class=xl34>МетроСтандарт</TD>   "
                  "            <TD COLSPAN=2 class=xl34>МетроСуперЛюкс</TD>  "
                  "            <TD COLSPAN=2 class=xl34>Метрошка</TD>        "
                  "            <TD COLSPAN=2 class=xl34>Пенсионный</TD>      "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD>           "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "
                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">  "
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в KZT</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в KZT</TD>"
                  "        </TR>".

           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.
           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:
              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.
                else do:
                   if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                      if dttcnt = dtt then do:
                         dttcnt = dtt + 7.
                         v-accept = 1.
                      end.
                   end.
                end.

              end.

              if v-accept = 1 then do: /* формируем отчет за данную дату */




                 for each t-zzz  where t-zzz.ddt = dtt and  t-zzz.txb = txb.bank and t-zzz.dep = ii no-lock:
                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rate) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" t-zzz.luksK  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.luksS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.vipK   "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.vipS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.classK "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.classS) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" t-zzz.standK "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.standS) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" t-zzz.supeK  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.supeS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.metroK  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.metroS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.pensK  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.pensS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.luksK + t-zzz.vipK + t-zzz.classK + t-zzz.standK + t-zzz.supeK + t-zzz.metroK + t-zzz.pensK "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS), 1, 2, dtt),2) ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" (t-zzz.luksK + t-zzz.vipK + t-zzz.classK + t-zzz.standK + t-zzz.supeK + t-zzz.metroK + t-zzz.pensK) - v-usdkol   "</TD>" skip.

/*                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip  */

if dtt < 03.01.09 then
   put unformatted "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
   put unformatted "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS - v-kztsum), 1, 1, dtt),2) / t-zzz.rate ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip .




put unformatted

                       "<TD class=xl36>" replace(string(((t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = t-zzz.luksK + t-zzz.vipK + t-zzz.classK + t-zzz.standK + t-zzz.supeK + t-zzz.metroK + t-zzz.pensK.
                     v-usdsum = round(crc-crc-date(decimal(t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS), 1, 2, dtt),2).

                     v-kztsum = t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS.
                 end. /*for each t-zzz*/


               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
               put unformatted "</TABLE>".
          end.  /*do ii = 1*/
    end. /*for each txb*/
end.


                  put unformatted "<P class=xl34 align=""center"" ><b> Итого по банку </b>" skip.
                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>МетроЛюкс</TD>    "
                  "            <TD COLSPAN=2 class=xl34>МетроVIP</TD>        "
                  "            <TD COLSPAN=2 class=xl34>МетроКлассик</TD>    "
                  "            <TD COLSPAN=2 class=xl34>МетроСтандарт</TD>   "
                  "            <TD COLSPAN=2 class=xl34>МетроСуперЛюкс</TD>  "
                  "            <TD COLSPAN=2 class=xl34>Метрошка</TD>        "
                  "            <TD COLSPAN=2 class=xl34>Пенсионный</TD>      "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD>           "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "
                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">  "
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в KZT</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма в KZT</TD>"
                  "        </TR>".

           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.

           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:


              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.

                if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                   if dttcnt = dtt then do:
                      dttcnt = dtt + 7.
                      v-accept = 1.
                   end.
                end.

              end.


              if v-accept = 1 then do: /* формируем отчет за данную дату */

                 v-temp = 0.

if dtt = 10.01.08 or dtt = 12.01.08 or dtt = 04.01.09 or dtt >= 03.02.09 then
                 find last crchis where crchis.crc = 2 and crchis.rdt < dtt no-lock no-error.
else
                 find last crchis where crchis.crc = 2 and crchis.rdt <= dtt no-lock no-error.


                 for each t-zzz  where t-zzz.ddt = dtt no-lock:
                     v-temp[2] = crchis.rate[1].
                     v-temp[3] = v-temp[3]   + t-zzz.luksK.
                     v-temp[4] = v-temp[4]   + t-zzz.luksS.
                     v-temp[5] = v-temp[5]   + t-zzz.vipK.
                     v-temp[6] = v-temp[6]   + t-zzz.vipS.
                     v-temp[7] = v-temp[7]   + t-zzz.classK.
                     v-temp[8] = v-temp[8]   + t-zzz.classS.
                     v-temp[9] = v-temp[9]   + t-zzz.standK.
                     v-temp[10] = v-temp[10] + t-zzz.standS.
                     v-temp[11] = v-temp[11] + t-zzz.supeK.
                     v-temp[12] = v-temp[12] + t-zzz.supeS.
                     v-temp[13] = v-temp[13] + t-zzz.metroK.
                     v-temp[14] = v-temp[14] + t-zzz.metroS.
                     v-temp[15] = v-temp[15] + t-zzz.pensK.
                     v-temp[16] = v-temp[16] + t-zzz.pensS.
                     v-temp[17] = v-temp[17] + (t-zzz.luksK + t-zzz.vipK + t-zzz.classK + t-zzz.standK + t-zzz.supeK + t-zzz.metroK + t-zzz.pensK).
                     v-temp[19] = v-temp[19] + (t-zzz.luksS + t-zzz.vipS + t-zzz.classS + t-zzz.standS + t-zzz.supeS + t-zzz.metroS + t-zzz.pensS).
                     v-temp[20] = v-temp[20] + 0.
                     v-temp[21] = v-temp[21] + 0.
                     v-temp[22] = v-temp[22] + 0.
                 end.


                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[2]) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" v-temp[3]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[4]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[5]   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[6]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[7] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[8]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[9] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[10]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[11]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[12]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip


                     "<TD>" v-temp[13]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[14]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip


                     "<TD>" v-temp[15]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[16]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip


                     "<TD>" v-temp[17] "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[19]), 1, 2, dtt),2),"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string(v-temp[19] ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.



                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" v-temp[17] - v-usdkol   "</TD>" skip.
if dtt < 03.01.09 then
put unformatted        "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[19]), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.

else
put unformatted        "<TD class=xl36>" replace(string((round(decimal(v-temp[19]),2) - v-kztsum) / crchis.rate[1] ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.




put unformatted        "<TD class=xl36>" replace(string(((v-temp[19]) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = v-temp[17].
                     v-usdsum = crc-crc-date(decimal(v-temp[19]), 1, 2, dtt).
                     v-kztsum = v-temp[19].



               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
           put unformatted "</TABLE>".















  put unformatted "<BR>" skip.
  put unformatted "<P class=xl37> Отчет подготовила: Менеджер А.Д. Миминова <BR>"  skip.
  put unformatted " Отчет проверила: Директор ОД И.Я. Бояркина " "<BR>" skip.
        {html-end.i " "}
        output close .
        hide frame ww.
        unix silent cptwin value(file1) excel.



















/*11111111111111111111111111*/
/*11111111111111111111111111*/
/*11111111111111111111111111*/
  file1 = "file2.html".
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


  put unformatted "<P align=""left"" style=""font:bold;font-size:small""> Операционный департамент " "<BR>" skip.
  put unformatted "<P class=xl34  align=""center"" ><b> Анализ текущих счетов юридических лиц по " + v-nbankru + " " "</b><BR></BR>" skip.


    do idx_i = 1 to 17:
       v-bnk = ENTRY(idx_i, vs-txb).
    for each txb where txb.consolid = true and txb.bank = string("TXB" + string(v-bnk)) no-lock:


        do ii = 1 to 20 :
           find last t-zzz  where t-zzz.txb = txb.bank  and t-zzz.dep = ii no-lock no-error.



                  if not avail t-zzz then next.


if  t-zzz.ppoint begins "СП-2 г.Алматы ул.Толе би, 297" then next.
if  t-zzz.ppoint begins "СП-3 г.Алматы мкр-н 6, д.11" then next.
if  t-zzz.ppoint begins "СП-5 г.Алматы ул. Толе би, 104" then next.
if  t-zzz.ppoint begins "СП-6 г.Алматы Мамыр-1 д.10 кв.2" then next.
if  t-zzz.ppoint begins "СП-0 г.Алматы ул. Тынышбаева д.3 кв.18" then next.
if  t-zzz.ppoint begins "СП-8 г.Алматы ул. Макатаева д.53 кв.2" then next.
if  t-zzz.ppoint begins "СП-10" then next.
if  t-zzz.ppoint begins "СП-11" then next.

                  if txb.bank = "TXB16" then
                        put unformatted "<P class=xl34 align=""center"" ><b>" t-zzz.ppoint  " (Филиал по г.Алматы) </b>" skip.
                  else
                        put unformatted "<P class=xl34 align=""center""><b>" t-zzz.citi /*t-zzz.ppoint*/  "</b>" skip.



                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>KZT</TD> "
                  "            <TD COLSPAN=2 class=xl34>USD</TD> "
                  "            <TD COLSPAN=2 class=xl34>EUR</TD> "
                  "            <TD COLSPAN=2 class=xl34>RUB</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "

                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35>кол-во <br> сумма KZT</TD>"

                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">кол-во <br> счетов</TD>"
                  "            <TD class=xl35>кол-во <br> сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "        </TR>".


           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.
           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:
              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.
                else do:
                   if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                      if dttcnt = dtt then do:
                         dttcnt = dtt + 7.
                         v-accept = 1.
                      end.
                   end.
                end.

              end.

              if v-accept = 1 then do: /* формируем отчет за данную дату */




                 for each t-zzz  where t-zzz.ddt = dtt and  t-zzz.txb = txb.bank and t-zzz.dep = ii no-lock:
                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rate) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" t-zzz.kztK_ur  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.kztS_ur) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.usdK_ur   "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.usdS_ur) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.eurK_ur "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.eurS_ur) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" t-zzz.rubK_ur "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rubS_ur) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip

                     "<TD>" t-zzz.kztK_ur + t-zzz.usdK_ur + t-zzz.eurK_ur + t-zzz.rubK_ur "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur), 1, 2, dtt),2) ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" (t-zzz.kztK_ur + t-zzz.usdK_ur + t-zzz.eurK_ur + t-zzz.rubK_ur) - v-usdkol   "</TD>" skip.


if dtt < 03.01.09 then
put unformatted        "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
put unformatted        "<TD class=xl36>" replace(string(round(decimal(t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur - v-kztsum),2) / t-zzz.rate ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.




put unformatted        "<TD class=xl36>" replace(string(((t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = t-zzz.kztK_ur + t-zzz.usdK_ur + t-zzz.eurK_ur + t-zzz.rubK_ur.
                     v-usdsum = round(crc-crc-date(decimal(t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur), 1, 2, dtt),2).
                     v-kztsum = t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur.
                 end. /*for each t-zzz*/
               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
               put unformatted "</TABLE>".
          end.  /*do ii = 1*/
    end. /*for each txb*/
    end.


                  put unformatted "<P class=xl34 align=""center"" ><b> Итого по банку </b>" skip.
                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>KZT</TD> "
                  "            <TD COLSPAN=2 class=xl34>USD</TD> "
                  "            <TD COLSPAN=2 class=xl34>EUR</TD> "
                  "            <TD COLSPAN=2 class=xl34>RUB</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "

                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35>кол-во <br> сумма KZT</TD>"

                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">кол-во <br> счетов</TD>"
                  "            <TD class=xl35>кол-во <br> сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "        </TR>".

           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.

           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:


              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.

                if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                   if dttcnt = dtt then do:
                      dttcnt = dtt + 7.
                      v-accept = 1.
                   end.
                end.

              end.


              if v-accept = 1 then do: /* формируем отчет за данную дату */


                 v-temp = 0.

if dtt = 10.01.08 or dtt = 12.01.08 or dtt = 04.01.09 or dtt >= 03.02.09 then
                 find last crchis where crchis.crc = 2 and crchis.rdt < dtt no-lock no-error.
else
                 find last crchis where crchis.crc = 2 and crchis.rdt <= dtt no-lock no-error.
                 for each t-zzz  where t-zzz.ddt = dtt no-lock:
                     v-temp[2] = crchis.rate[1].
                     v-temp[3] = v-temp[3]   + t-zzz.kztK_ur.
                     v-temp[4] = v-temp[4]   + t-zzz.kztS_ur.
                     v-temp[5] = v-temp[5]   + t-zzz.usdK_ur.
                     v-temp[6] = v-temp[6]   + t-zzz.usdS_ur.
                     v-temp[7] = v-temp[7]   + t-zzz.eurK_ur.
                     v-temp[8] = v-temp[8]   + t-zzz.eurS_ur.
                     v-temp[9] = v-temp[9]   + t-zzz.rubK_ur.
                     v-temp[10] = v-temp[10] + t-zzz.rubS_ur.
                     v-temp[11] = v-temp[11] + (t-zzz.kztK_ur + t-zzz.usdK_ur + t-zzz.eurK_ur + t-zzz.rubK_ur).
                     v-temp[13] = v-temp[13] + (t-zzz.kztS_ur + t-zzz.usdS_ur + t-zzz.eurS_ur + t-zzz.rubS_ur).
                     v-temp[14] = v-temp[14] + 0.
                     v-temp[15] = v-temp[15] + 0.
                     v-temp[16] = v-temp[16] + 0.
                 end.


                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[2]) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" v-temp[3]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[4]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[5]   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[6]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[7] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[8]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[9] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[10]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[11]  "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[13]), 1, 2, dtt),2),"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[13]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" v-temp[11] - v-usdkol   "</TD>" skip.


if dtt < 03.01.09 then
   put unformatted       "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[13]), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
   put unformatted       "<TD class=xl36>" replace(string(round(decimal(v-temp[13] - v-kztsum), 2) / crchis.rate[1] ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.



put unformatted          "<TD class=xl36>" replace(string(((v-temp[13]) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = v-temp[11].
                     v-usdsum = crc-crc-date(decimal(v-temp[13]), 1, 2, dtt).
                     v-kztsum = v-temp[13].



               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
           put unformatted "</TABLE>".















  put unformatted "<BR>" skip.
  put unformatted "<P class=xl37> Отчет подготовила: Менеджер А.Д. Миминова <BR>"  skip.
  put unformatted " Отчет проверила: Директор ОД И.Я. Бояркина " "<BR>" skip.
        {html-end.i " "}
        output close .
        hide frame ww.
        unix silent cptwin value(file1) excel.



/*22222222222222222222222222*/
/*22222222222222222222222222*/
/*22222222222222222222222222*/



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


  put unformatted "<P align=""left"" style=""font:bold;font-size:small""> Операционный департамент " "<BR>" skip.
  put unformatted '<P class=xl34  align="center" ><b> Анализ текущих счетов физических лиц по ' + v-nbankru + '</b><BR></BR>' skip.


    do idx_i = 1 to 17:
       v-bnk = ENTRY(idx_i, vs-txb).
    for each txb where txb.consolid = true and txb.bank = string("TXB" + string(v-bnk)) no-lock:


        do ii = 1 to 20 :
           find last t-zzz  where t-zzz.txb = txb.bank  and t-zzz.dep = ii no-lock no-error.



                  if not avail t-zzz then next.
if  t-zzz.ppoint begins "СП-2 г.Алматы ул.Толе би, 297" then next.
if  t-zzz.ppoint begins "СП-3 г.Алматы мкр-н 6, д.11" then next.
if  t-zzz.ppoint begins "СП-5 г.Алматы ул. Толе би, 104" then next.
if  t-zzz.ppoint begins "СП-6 г.Алматы Мамыр-1 д.10 кв.2" then next.
if  t-zzz.ppoint begins "СП-0 г.Алматы ул. Тынышбаева д.3 кв.18" then next.
if  t-zzz.ppoint begins "СП-8 г.Алматы ул. Макатаева д.53 кв.2" then next.
if  t-zzz.ppoint begins "СП-10" then next.
if  t-zzz.ppoint begins "СП-11" then next.
                  if txb.bank = "TXB16" then
                        put unformatted "<P class=xl34 align=""center"" ><b>" t-zzz.ppoint  " (Филиал по г.Алматы) </b>" skip.
                  else
                        put unformatted "<P class=xl34 align=""center""><b>" t-zzz.citi /*t-zzz.ppoint*/  "</b>" skip.



                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>KZT</TD> "
                  "            <TD COLSPAN=2 class=xl34>USD</TD> "
                  "            <TD COLSPAN=2 class=xl34>EUR</TD> "
                  "            <TD COLSPAN=2 class=xl34>RUB</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "

                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35>кол-во <br> сумма KZT</TD>"

                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">кол-во <br> счетов</TD>"
                  "            <TD class=xl35>кол-во <br> сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "        </TR>".


           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.
           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:
              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.
                else do:
                   if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                      if dttcnt = dtt then do:
                         dttcnt = dtt + 7.
                         v-accept = 1.
                      end.
                   end.
                end.

              end.

              if v-accept = 1 then do: /* формируем отчет за данную дату */




                 for each t-zzz  where t-zzz.ddt = dtt and  t-zzz.txb = txb.bank and t-zzz.dep = ii no-lock:
                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rate) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" t-zzz.kztK_fz  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.kztS_fz) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.usdK_fz   "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.usdS_fz) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.eurK_fz "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.eurS_fz) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" t-zzz.rubK_fz "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rubS_fz) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip

                     "<TD>" t-zzz.kztK_fz + t-zzz.usdK_fz + t-zzz.eurK_fz + t-zzz.rubK_fz "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz), 1, 2, dtt),2) ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" (t-zzz.kztK_fz + t-zzz.usdK_fz + t-zzz.eurK_fz + t-zzz.rubK_fz) - v-usdkol   "</TD>" skip.

if dtt < 03.01.09 then

put unformatted       "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.

else
put unformatted       "<TD class=xl36>" replace(string(round(decimal(t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz - v-kztsum),2) / t-zzz.rate ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.






put unformatted
                       "<TD class=xl36>" replace(string(((t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = t-zzz.kztK_fz + t-zzz.usdK_fz + t-zzz.eurK_fz + t-zzz.rubK_fz.
                     v-usdsum = round(crc-crc-date(decimal(t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz), 1, 2, dtt),2).
                     v-kztsum = t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz.
                 end. /*for each t-zzz*/
               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
               put unformatted "</TABLE>".
          end.  /*do ii = 1*/
    end. /*for each txb*/
    end.


                  put unformatted "<P class=xl34 align=""center"" ><b> Итого по банку </b>" skip.
                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>KZT</TD> "
                  "            <TD COLSPAN=2 class=xl34>USD</TD> "
                  "            <TD COLSPAN=2 class=xl34>EUR</TD> "
                  "            <TD COLSPAN=2 class=xl34>RUB</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "

                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35>кол-во <br> сумма KZT</TD>"

                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">кол-во <br> счетов/TD>"
                  "            <TD class=xl35>кол-во <br> сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "        </TR>".

           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.

           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:


              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.

                if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                   if dttcnt = dtt then do:
                      dttcnt = dtt + 7.
                      v-accept = 1.
                   end.
                end.

              end.


              if v-accept = 1 then do: /* формируем отчет за данную дату */


                 v-temp = 0.

if dtt = 10.01.08 or dtt = 12.01.08 or dtt = 04.01.09 or dtt >= 03.02.09 then
                 find last crchis where crchis.crc = 2 and crchis.rdt < dtt no-lock no-error.
else

                 find last crchis where crchis.crc = 2 and crchis.rdt <= dtt no-lock no-error.
                 for each t-zzz  where t-zzz.ddt = dtt no-lock:
                     v-temp[2] = crchis.rate[1].
                     v-temp[3] = v-temp[3]   + t-zzz.kztK_fz.
                     v-temp[4] = v-temp[4]   + t-zzz.kztS_fz.
                     v-temp[5] = v-temp[5]   + t-zzz.usdK_fz.
                     v-temp[6] = v-temp[6]   + t-zzz.usdS_fz.
                     v-temp[7] = v-temp[7]   + t-zzz.eurK_fz.
                     v-temp[8] = v-temp[8]   + t-zzz.eurS_fz.
                     v-temp[9] = v-temp[9]   + t-zzz.rubK_fz.
                     v-temp[10] = v-temp[10] + t-zzz.rubS_fz.
                     v-temp[11] = v-temp[11] + (t-zzz.kztK_fz + t-zzz.usdK_fz + t-zzz.eurK_fz + t-zzz.rubK_fz).
                     v-temp[13] = v-temp[13] + (t-zzz.kztS_fz + t-zzz.usdS_fz + t-zzz.eurS_fz + t-zzz.rubS_fz).
                     v-temp[14] = v-temp[14] + 0.
                     v-temp[15] = v-temp[15] + 0.
                     v-temp[16] = v-temp[16] + 0.
                 end.


                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[2]) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" v-temp[3]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[4]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[5]   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[6]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[7] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[8]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[9] "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[10]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip
                     "<TD>" v-temp[11]  "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[13]), 1, 2, dtt),2),"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[13]) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" v-temp[11] - v-usdkol   "</TD>" skip.


if dtt < 03.01.09 then
put unformatted        "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[13]), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
put unformatted        "<TD class=xl36>" replace(string(round(decimal(v-temp[13] - v-kztsum ),2) / crchis.rate[1] ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.




put unformatted

                       "<TD class=xl36>" replace(string(((v-temp[13]) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = v-temp[11].
                     v-usdsum = crc-crc-date(decimal(v-temp[13]), 1, 2, dtt).
                     v-kztsum = v-temp[13].



               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
           put unformatted "</TABLE>".















  put unformatted "<BR>" skip.
  put unformatted "<P class=xl37> Отчет подготовила: Менеджер А.Д. Миминова <BR>"  skip.
  put unformatted " Отчет проверила: Директор ОД И.Я. Бояркина " "<BR>" skip.
        {html-end.i " "}
        output close .
        hide frame ww.
        unix silent cptwin value(file1) excel.












/*-------------------------*/


  file1 = "file4.html".
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


  put unformatted "<P align=""left"" style=""font:bold;font-size:small""> Операционный департамент " "<BR>" skip.
  put unformatted '<P class=xl34  align="center" ><b> Анализ сберегательных счетов юридических лиц по ' + v-nbankru + '</b><BR></BR>' skip.



    do idx_i = 1 to 17:
       v-bnk = ENTRY(idx_i, vs-txb).
    for each txb where txb.consolid = true and txb.bank = string("TXB" + string(v-bnk)) no-lock:


        do ii = 1 to 20 :
           find last t-zzz  where t-zzz.txb = txb.bank  and t-zzz.dep = ii no-lock no-error.



                  if not avail t-zzz then next.
if  t-zzz.ppoint begins "СП-2 г.Алматы ул.Толе би, 297" then next.
if  t-zzz.ppoint begins "СП-3 г.Алматы мкр-н 6, д.11" then next.
if  t-zzz.ppoint begins "СП-5 г.Алматы ул. Толе би, 104" then next.
if  t-zzz.ppoint begins "СП-6 г.Алматы Мамыр-1 д.10 кв.2" then next.
if  t-zzz.ppoint begins "СП-0 г.Алматы ул. Тынышбаева д.3 кв.18" then next.
if  t-zzz.ppoint begins "СП-8 г.Алматы ул. Макатаева д.53 кв.2" then next.
if  t-zzz.ppoint begins "СП-10" then next.
if  t-zzz.ppoint begins "СП-11" then next.


                  if txb.bank = "TXB16" then
                        put unformatted "<P class=xl34 align=""center"" ><b>" t-zzz.ppoint  " (Филиал по г.Алматы) </b>" skip.
                  else
                        put unformatted "<P class=xl34 align=""center""><b>" t-zzz.citi /*t-zzz.ppoint*/  "</b>" skip.

                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>Накопительный вклад</TD> "
                  "            <TD COLSPAN=2 class=xl34>Срочный вклад</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "
                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"

                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"


                  "        </TR>".




           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.
           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:
              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.
                else do:
                   if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                      if dttcnt = dtt then do:
                         dttcnt = dtt + 7.
                         v-accept = 1.
                      end.
                   end.
                end.

              end.

              if v-accept = 1 then do: /* формируем отчет за данную дату */




                 for each t-zzz  where t-zzz.ddt = dtt and  t-zzz.txb = txb.bank and t-zzz.dep = ii no-lock:
                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.rate) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" t-zzz.nakK  "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.nakS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.srochK   "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.srochS) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" t-zzz.nakK + t-zzz.srochK "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.nakS + t-zzz.srochS), 1, 2, dtt),2) ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string((t-zzz.nakS + t-zzz.srochS) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.




                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" (t-zzz.nakK + t-zzz.srochK) - v-usdkol   "</TD>" skip.



if dtt < 03.01.09 then
put unformatted        "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(t-zzz.nakS + t-zzz.srochS), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
put unformatted        "<TD class=xl36>" replace(string(round(decimal(t-zzz.nakS + t-zzz.srochS - v-kztsum),2) / t-zzz.rate,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.





put unformatted

                       "<TD class=xl36>" replace(string(((t-zzz.nakS + t-zzz.srochS) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.

                     v-usdkol = t-zzz.nakK + t-zzz.srochK.
                     v-usdsum = round(crc-crc-date(decimal(t-zzz.nakS + t-zzz.srochS), 1, 2, dtt),2).
                     v-kztsum = t-zzz.nakS + t-zzz.srochS.
                 end. /*for each t-zzz*/
               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
               put unformatted "</TABLE>".
          end.  /*do ii = 1*/
    end. /*for each txb*/
   end.


                  put unformatted "<P class=xl34 align=""center"" ><b> Итого по банку </b>" skip.

                  put unformatted
                        "<TABLE cellspacing=""0"" cellpadding=""0"" align=""center"" border=""1"" width=""100%"">" skip
                        "<TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF "">" skip
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Дата</TD>"
                  "            <TD ROWSPAN=2 class=xl34 style=""text-align:center;vertical-align:middle;""><b>Курс НБРК</TD>"
                  "            <TD COLSPAN=2 class=xl34><b>Накопительный вклад</TD> "
                  "            <TD COLSPAN=2 class=xl34>Срочный вклад</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого</TD> "
                  "            <TD COLSPAN=3 class=xl34>Итого за период</TD> "
                  "        </TR>"
                  "        <TR align=""center"" style=""font:bold;font-size:x-small;background:#ECE5FF"">"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "            <TD class=xl35>кол-во <br> счетов</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма USD</TD>"
                  "            <TD class=xl35 style=""text-align:center;vertical-align:middle;"">сумма KZT</TD>"
                  "        </TR>".


           v-usdkol = 0.001.
           v-usdsum = 0.
           v-kztsum = 0.

           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g-today)) + "." + string(year(g-today))).

           do dtt = 03.17.08 to g_date:


              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.

                if month(g-today) = month(dtt) and day(dtt) <> 1 then do:
                   if dttcnt = dtt then do:
                      dttcnt = dtt + 7.
                      v-accept = 1.
                   end.
                end.

              end.


              if v-accept = 1 then do: /* формируем отчет за данную дату */


                 v-temp = 0.
if dtt = 10.01.08 or dtt = 12.01.08 or dtt = 04.01.09 or dtt >= 03.02.09 then
                 find last crchis where crchis.crc = 2 and crchis.rdt < dtt no-lock no-error.
else

                 find last crchis where crchis.crc = 2 and crchis.rdt <= dtt no-lock no-error.
                 for each t-zzz  where t-zzz.ddt = dtt no-lock:
                     v-temp[2] = crchis.rate[1].
                     v-temp[3] = v-temp[3]   + t-zzz.nakK.
                     v-temp[4] = v-temp[4]   + t-zzz.nakS.
                     v-temp[5] = v-temp[5]   + t-zzz.srochK.
                     v-temp[6] = v-temp[6]   + t-zzz.srochS.
                     v-temp[7] = v-temp[7] + (t-zzz.nakK + t-zzz.srochK).
                     v-temp[9] = v-temp[9] + (t-zzz.nakS + t-zzz.srochS).
                 end.


                     put unformatted
                     "<TR align=""center"" style=""font-size:x-small;background:white "">" skip
                     "<TD>" dtt          "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[2]) ,"-zzzzzzzzzzzzz9.99"),".",",")    "</TD>" skip
                     "<TD>" v-temp[3]  "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[4]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[5]   "</TD>" skip
                     "<TD class=xl36>" replace(string((v-temp[6]) ,"-zzzzzzzzzzzzz9.99"),".",",")   "</TD>" skip
                     "<TD>" v-temp[7] "</TD>" skip
                     "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[9]), 1, 2, dtt),2),"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                     "<TD class=xl36>" replace(string(v-temp[9] ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.


                     if v-usdkol = 0.001 then do:
                       put unformatted  "<TD> 0   </TD>" skip
                                        "<TD> 0,00 </TD>" skip
                                        "<TD> 0,00 </TD>" skip.
                     end.
                     else do:
                       put unformatted
                       "<TD>" v-temp[7] - v-usdkol   "</TD>" skip.


if dtt < 03.01.09 then
put unformatted        "<TD class=xl36>" replace(string(round(crc-crc-date(decimal(v-temp[9]), 1, 2, dtt),2) - v-usdsum ,"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
else
put unformatted        "<TD class=xl36>" replace(string(round(decimal(v-temp[9] - v-kztsum),2) / crchis.rate[1],"-zzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.




put unformatted

                       "<TD class=xl36>" replace(string(((v-temp[9]) - v-kztsum) ,"-zzzzzzzzzzzzz9.99"),".",",")  "</TD>" skip.
                     end.
                     v-usdkol = v-temp[7].
                     v-usdsum = crc-crc-date(decimal(v-temp[9]), 1, 2, dtt).
                     v-kztsum = v-temp[9].



               end. /*if v-accept = 1*/
            end.  /*do dtt = 03.17.08*/
           put unformatted "</TABLE>".















  put unformatted "<BR>" skip.
  put unformatted "<P class=xl37> Отчет подготовила: Менеджер А.Д. Миминова <BR>"  skip.
  put unformatted " Отчет проверила: Директор ОД И.Я. Бояркина " "<BR>" skip.
        {html-end.i " "}
        output close .
        hide frame ww.
        unix silent cptwin value(file1) excel.































