/* scrc_print.p
 * MODULE
        Казначейство
 * DESCRIPTION
        Установка опорных курсов
 * RUN
        7-3-6
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        14.03.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        20.04.2011 aigul - переделала формат отчета на html
        06.01.2012 aigul - добавила сортировку по годам
        18.04.2012 id00810 - изменение названия банка
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        13.09.2012 Lyubov - список адресов в рассылке заменила на группу
*/

{global.i}
{nbankBik.i}
def shared var s-order as int.
def shared var s-dt as date.
def var mn as char.
def var ccode as char.
def var choice as logi no-undo.
def var v-ofc as char.
find first ofc where ofc.ofc = "id00776" no-lock no-error.
if avail ofc then v-ofc = ofc.name.
if month(s-dt) = 01 then mn = "января".
if month(s-dt) = 02 then mn = "февраля".
if month(s-dt) = 03 then mn = "марта".
if month(s-dt) = 04 then mn = "апреля".
if month(s-dt) = 05 then mn = "мая".
if month(s-dt) = 06 then mn = "июня".
if month(s-dt) = 07 then mn = "июля".
if month(s-dt) = 08 then mn = "августа".
if month(s-dt) = 09 then mn = "сентября".
if month(s-dt) = 10 then mn = "октября".
if month(s-dt) = 11 then mn = "ноября".
if month(s-dt) = 12 then mn = "декабря".
define stream m-out.
/*    output stream m-out to kurs.doc.
    put stream m-out unformatted "

<html>
<head>
<title>MetroComBank</title>
</head>
<body>
<div class=Section1>

<p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
auto;text-align:center'><br>
<br>
<span style='font-size:16.0pt'><span Times New '>АО «ForteBank»<u1:p></u1:p></span><o:p></o:p></span></p>


<p class=MsoNormal align=right style='text-align:right'>
<span style='font-family:'Times New Roman','serif''>" day(s-dt) " " mn " " year(s-dt) " г.<o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'>
<span style='font-size:12.0pt;line-height:115%'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'>
<b style='mso-bidi-font-weight:normal'>
<span style='font-size:14.0pt';font-family:'Times New Roman'>Распоряжение №" s-order "<o:p></o:p></span></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:1.0cm'><span
style='font-size:14.0pt;line-height:115%;font-family:'Times New Roman','serif''>
Установить следующие «опорные курсы» и «минимальный спрэд» по операциям с наличной иностранной валютой для обменных пунктов филиалов АО «ForteBank»:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify;text-indent:1.0cm'><o:p>&nbsp;</o:p></p>
<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width='100%'
 style='width:100.0%;border-collapse:collapse;mso-yfti-tbllook:160;mso-padding-alt:
 1.5pt 1.5pt 1.5pt 1.5pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:27.55pt'>
  <td width='19%' style='width:19.26%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt;
  height:27.55pt'>
  <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
  auto;text-align:center'><b><span style='font-size:12.0pt;line-height:115%;
  font-family:'Times New Roman','serif''>Вид<span style='mso-spacerun:yes'>
  </span>валюты<o:p></o:p></span></b></p>

  </td>
  <td width='20%' style='width:20.06%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt;
  height:27.55pt'>
  <p align=center style='text-align:center'><b>«Опорный курс» покупки <o:p></o:p></b></p>
  </td>
  <td width='20%' style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt;
  height:27.55pt'>
  <p align=center style='text-align:center'><b>«Опорный курс» продажи<o:p></o:p></b></p>
  </td>
  <td width='20%' valign=top style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt;
  height:27.55pt'>
  <p align=center style='text-align:center'><b><span style='mso-fareast-font-family:
  'Times New Roman';mso-fareast-language:EN-US'>«Минимальный спрэд»<o:p></o:p></span></b></p>
  </td>
  <td width='20%' valign=top style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt;
  height:27.55pt'>
  <p align=center style='text-align:center'><b><span style='mso-fareast-font-family:
  'Times New Roman';mso-fareast-language:EN-US'>Время <br>Астаны<o:p></o:p></span></b></p>
  </td>
 </tr>".

 for each scrc where scrc.order = s-order no-lock:
    find first ncrc where ncrc.crc = scrc.crc no-lock no-error.
    if avail ncrc then ccode = ncrc.code.
    put stream m-out unformatted "
     <tr style='mso-yfti-irow:1'>
      <td width='19%' style='width:19.26%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt'>
      <p class=MsoNormal align=center style='text-align:center'><b><span
      style='font-size:14.0pt;line-height:115%;font-family:'Times New Roman','serif''>" ccode "<o:p></o:p></span></b></p>
      </td>
      <td width='20%' valign=top style='width:20.06%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt'>
      <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
      auto;text-align:center'><span style='mso-bidi-font-size:12.0pt;line-height:
      115%'><o:p>" replace(trim(string(scrc.buycrc,'>>>>>>>>>>>9.99')),'.',',') "</o:p></span></p>
      </td>
      <td width='20%' valign=top style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt'>
      <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
      auto;text-align:center'><span style='mso-bidi-font-size:12.0pt;line-height:
      115%'><o:p>" replace(trim(string(scrc.sellcrc,'>>>>>>>>>>>9.99')),'.',',') "</o:p></span></p>
      </td>

      <td width='20%' valign=top style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt'>
      <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
      auto;text-align:center'><o:p>" replace(trim(string(scrc.minspr,'>>>>>>>>>>>9.99')),'.',',') "</o:p></p>
      </td>
      <td width='20%' valign=top style='width:20.22%;background:white;padding:1.5pt 1.5pt 1.5pt 1.5pt'>
      <p class=MsoNormal align=center style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
      auto;text-align:center'><o:p>" string(scrc.tim, "HH:MM:SS") "</o:p></p>
      </td>
     </tr>".
end.

put stream m-out unformatted "
</table>
<br>
<br>
<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'><u1:p>&nbsp;</u1:p></p>
<p class=MsoNormal><span style='mso-fareast-font-family:'Times New Roman''><br>
Директор Департамента Казначейства <span style='mso-tab-count:4'></span><span Times New '>"*/ /*v-ofc */ /*"<o:p></o:p></span></span></p>
<br>
<br>
<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'><u1:p>&nbsp;</u1:p></p>
<p class=MsoNormal><span style='mso-fareast-font-family:'Times New Roman''><br><span style='mso-tab-count:4'></span></span>
<span Times New '><o:p></o:p></span></p>
<br>
<br>
<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'><u1:p>&nbsp;</u1:p></p>
<p class=MsoNormal><span style='mso-fareast-font-family:'Times New Roman''><br><span style='mso-tab-count:4'></span></span>
<span Times New '><o:p></o:p></span></p>
<br>
<p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:auto'><u1:p>&nbsp;</u1:p></p>
<p class=MsoNormal><span style='mso-fareast-font-family:'Times New Roman''><br><span style='mso-tab-count:4'></span></span>
<span Times New '><o:p></o:p></span></p>
</div>
</div>
</div>
</body>
</html>".
unix silent cptwin kurs.doc winword.*/

output to kurs.htm.
    put unformatted "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                    "<head><title></title>" skip
                    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                    "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip.
    put unformatted "<center> <font size=3><P> " + v-nbankru + " </font></center>" skip.
    put unformatted "<P><div style='text-align: right; width: 100%; float: left;'>" day(s-dt) " " mn " " year(s-dt) " г. </font></div></P>" skip.
    put unformatted "<center> <font size=3><P><b> Распоряжение № " s-order "</b></font></center>" skip.
    put unformatted
    "<font size=3><P> Установить следующие «опорные курсы» и «минимальный спрэд» по операциям с наличной иностранной валютой для обменных пунктов филиалов " + v-nbankru + ":</font></p>" skip.
    put unformatted "<center><TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
                    "<tr><td align=center ><b> Вид валюты </b></td>" skip
                    "<td align=center ><b> «Опорный курс» покупки  </b></td>" skip
                    "<td align=center ><b> «Опорный курс» продажи </b></td>"
                    "<td align=center ><b> «Минимальный спрэд»  </b></td>" skip
                    "<td align=center ><b> Время Астаны </b></td>" skip
                    "</tr>" skip.
    for each scrc where scrc.order = s-order and scrc.regdt = g-today no-lock:
        find first ncrc where ncrc.crc = scrc.crc no-lock no-error.
        if avail ncrc then ccode = ncrc.code.
        put unformatted "<tr><td align=center>" ccode "</td>" skip
                        "<td align=center >" replace(trim(string(scrc.buycrc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                        "<td align=center >" replace(trim(string(scrc.sellcrc,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                        "<td align=center >" replace(trim(string(scrc.minspr,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                        "<td align=center >" string(scrc.tim, "HH:MM:SS") "</td>" skip
                        "</tr>" skip.
    end.
    put unformatted "</table></center>" skip.
    put unformatted "<P ALIGN='LEFT'><font size=3> Директор Департамента Казначейства &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" /*v-ofc*/ "</font></p>" skip.
    put unformatted "</html>"  skip.
unix silent cptwin kurs.htm iexplore.

message "Отправить распоряжение по филиалам?" view-as alert-box question buttons yes-no update choice.
if choice then do:
    for each txb where txb.consolid no-lock:
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run scrc-rasp("kurs.htm").
        disconnect txb.
    end.
    run mail("treasury@fortebank.com", "BANK <abpk@fortebank.com>", "Опорные курсы", "", "", "","kurs.htm").
end.



