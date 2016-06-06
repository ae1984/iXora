/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        График погашения для lon.grp = 81, 82
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        08.02.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        28.06.2011 ruslan добавил валюту
        13.01.2012 aigul - добавила find first lons where lons.lon = s-lon no-lock no-error.
        13.02.3012 kapar  - (wrk.prc = lnsci.iv-sc) изменил на (wrk.prc = wrk.prc + lnsci.iv-sc)
        10/09/2013 galina - ТЗ1398 добавила расчет комиссии под 4 процента годовых
        16/09/2013 galina - перекомпеляция
*/

{global.i}

def stream rep.
def var coun as int no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-itogo as deci no-undo extent 3.
def var v-ofile as char no-undo.
def var v-com as deci no-undo.
def var v-com30 as deci no-undo.
def var v-dt1 as date no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def var i as integer no-undo.

def shared var s-lon like lon.lon.
def var v-crc like crc.des.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
  message " Ссудный счет не найден " view-as alert-box error.
  return.
end.
else do:
    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then v-crc = crc.des.
end.

find first loncon where loncon.cif = lon.cif no-lock no-error.
if not avail loncon then do:
  message " № контракта не найден " view-as alert-box info.
  return.
end.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
v-ofile = "rep.htm".
v-sum = lon.opnamt.
v-sum1 = lon.opnamt.
def temp-table wrk no-undo
  field dt as date
  field ost as deci
  field od as deci
  field prc as deci
  field koms as deci
  field fin as decimal
  index idx is primary dt.
def buffer b-wrk for wrk.
  v-itogo = 0.

for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock:
  find first wrk where wrk.dt = lnsch.stdat exclusive-lock no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.dt = lnsch.stdat.
    end.
    wrk.ost = v-sum.
    wrk.od = lnsch.stval.
    v-sum = v-sum - lnsch.stval.
    v-itogo[1] = v-itogo[1] + wrk.od.
end.

for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock:
    find first wrk where wrk.dt = lnsci.idat exclusive-lock no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.dt = lnsci.idat.
    end.
    wrk.prc = wrk.prc + lnsci.iv-sc.
    v-itogo[2] = v-itogo[2] + lnsci.iv-sc.
end.

for each wrk exclusive-lock:
    if wrk.od = 0 and wrk.prc <> 0 then wrk.ost = v-sum1.
    v-sum1 = v-sum1 - wrk.od.
end.
find first lons where lons.lon = s-lon no-lock no-error.
if avail lons then do:
    for each lnscs where lnscs.lon = s-lon and lnscs.sch no-lock:
        find first wrk where wrk.dt = lnscs.stdat exclusive-lock no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.dt = lnscs.stdat.
        end.
        wrk.koms = wrk.koms + lnscs.stval.
        v-itogo[3] = v-itogo[3] + wrk.koms.
    end.
end.
else do:
    i = 0.

    for each wrk no-lock:
       i = i + 1.
       if i = 1 then run day-360(lon.rdt,wrk.dt - 1,360,output dn1,output dn2).
       else run day-360(v-dt1,wrk.dt - 1,360,output dn1,output dn2).
       v-com30 = round(wrk.ost * 4 / 1200,2).
       v-com = round(dn1 * v-com30 / 30,2).

       if v-com > 0 then do:
          find b-wrk where b-wrk.dt = wrk.dt exclusive-lock no-error.
          b-wrk.koms = v-com.
          find current b-wrk no-lock no-error.
          v-itogo[3] = v-itogo[3] + wrk.koms.
       end.
       v-dt1 = wrk.dt.
    end.
end.

output stream rep to value(v-ofile).

     put stream rep unformatted
      "<HTML><HEAD><TITLE></TITLE>
     <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
     <META content=ru http-equiv=Content-Language>
     </HEAD>
     <BODY style='margin-left:.5pt;margin-top:.1pt;margin-right:.1pt;margin-bottom:.2pt'>
     <TABLE style=""FONT-SIZE: 12pt"" border=0 align=center width=700 style=""font-family: times new roman"">
      <TR>
      <TD width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:right'><b>«__» _______ 20___ж. № _______<br>Тўтынушы несиесін беру туралы<br> Шартына <br> Ќосымша  № 1 </p></TD>
      <TD width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:right'><b>Приложение № 1<br>к Договору № _______ о предоставлении <br>потребительского кредита<br>от  «__» ________ 20____  года </p></TD></TR>
      <TR>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>Заемшы Шартќа осы Ќосымша  № 1 ќол ќоя отырып, Банкпен  тїрлі јдістерімен есептеліп ўсынылєан  Несиені ґтеу кестесімен танысќанын растайды, Заемшымен  ґтеу јдісін таѕдауда Тараптар келесіге тоќтады:</p></TD>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>Подписанием настоящего Приложения № 1 к Договору, Заемщик подтверждает, что  ознакомлен с предложенными Банком графиками погашения Кредита, рассчитанными различными методами, таким образом, при выборе Заемщиком метода погашения Стороны пришли к следующему:</p></TD></TR>
      <TR>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>1. Заемшы
      <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
      аннуитетті тґлемдермен/теѕ їлестермен/тараптардыѕ келісуі бойынша ґзге јдістермен тґлеуден бас тартады.
      </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
      </p></TD>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>1. Заемщик от методов погашения
      <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
      аннуитетными платежами/равными долями/других методов по соглашению сторон
      </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
      отказывается. </p></TD></TR>
      <TR>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>2. Заемшымен тґмендегі Кестеде ќолданылатын
      <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
      аннуитетті тґлемдермен/теѕ їлестермен/тараптардыѕ келісуі бойынша ґзге јдістермен јдісі таѕдалды
      </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
      : </p></TD>
      <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>2. Заемщиком выбран метод погашения
      <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
      аннуитетными платежами/равными долями/других методов по соглашению сторон
      </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
      , применяемый в нижеследующем Графике платежей: </p></TD></TR></TBODY></TABLE>"
     skip.

     put stream rep unformatted
      "<TABLE align=center width=700 style=""font-family: times new roman"" style=""FONT-SIZE: 12pt"">
      <TR>
      <TD align=middle><b>ТҐЛЕМДЕР КЕСТЕСІ/ ГРАФИК ПЛАТЕЖЕЙ</b></TD></TR></TBODY></TABLE>
      <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=691
   style='width:518.5pt;border-collapse:collapse;border:none;mso-border-alt:
   solid windowtext .75pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
   .75pt solid windowtext;mso-border-insidev:.75pt solid windowtext' align=center>
      <tr style=""font:bold"">
	  <td align=center style=""FONT-SIZE: 12pt""> Кїні/Дата</td>
	  <td align=center style=""FONT-SIZE: 12pt""> Суммa<br> Кредита к<br> погашению/ <br>Ґтелінетін<br> Несие<br> сомасы</td>
	  <td align=center style=""FONT-SIZE: 12pt""> Сумма<br> вознаграж<br>дения к<br> погашению<br>/Ґтелінетін<br> сыйаќы<br> сомасы</td>
	  <td align=center style=""FONT-SIZE: 12pt""> Сумма<br> Кредита и<br> вознагражде<br>ния к<br> погашению/<br>Ґтелінетін<br> Несие<br> сомасы мен<br> сыйаќы<br> сомасы</td>
	  <td align=center style=""FONT-SIZE: 12pt""> Комиссия<br> погашаемая <br>при расторжении<br>трудового<br>договора/<br>Еѕбек шартын <br>бўзєан <br>жаєдайда<br>ґтелінетін<br> Комиссия</td>
      <td align=center style=""FONT-SIZE: 12pt""> Ежемесячный<br> платеж/<br>Ай сайынєы<br> тґлем</td>
	  <td align=center style=""FONT-SIZE: 12pt""> Остаток<br> Кредита на<br> дату<br> следующего<br> погашения<br> /Келесіде<br> ґтелетін<br> Несие<br> сомасыныѕ<br> ќалдыєы</td>
      </tr>"
   skip.

     coun = 1.
    for each wrk where wrk.od <> 0 or wrk.prc <> 0 or wrk.koms <> 0 no-lock:
     put stream rep unformatted
             "<tr>" skip
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(string(wrk.dt, "99/99/9999"),"/",".") "</td>" skip.
             if wrk.od > 0 then put stream rep unformatted
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.od, ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
              else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if wrk.prc > 0 then put stream rep unformatted
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.prc, ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
              else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if wrk.od + wrk.prc > 0 then put stream rep unformatted
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.od + wrk.prc, ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if wrk.koms > 0 then put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.koms, ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if wrk.od + wrk.prc + wrk.koms > 0 then put stream rep unformatted
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.od + wrk.prc + wrk.koms, ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if wrk.ost - wrk.od > 0 then put stream rep unformatted
             "<td align=""center"" style=""FONT-SIZE: 12pt"">" replace(replace(string(wrk.ost - wrk.od, "->>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             put stream rep unformatted
             "</tr>" skip.
   coun = coun + 1.
   end.

   put stream rep unformatted
             "<tr style=""font:bold"">" skip
             "<td align=""center"">Сомалыќ <br>белгісі /<br> Суммарное<br> значение (" v-crc "):</td>" skip.
             if v-itogo[1] > 0 then put stream rep unformatted
             "<td align=""center"">" replace(replace(string(v-itogo[1], ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if v-itogo[2] > 0 then put stream rep unformatted
             "<td align=""center"">" replace(replace(string(v-itogo[2], ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if v-itogo[1] + v-itogo[2] > 0 then put stream rep unformatted
             "<td align=""center"">" replace(replace(string(v-itogo[1] + v-itogo[2], ">>>,>>>,>>>,>>9.99"),","," "),".",",") + "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if v-itogo[3] > 0 then put stream rep unformatted
             "<td align=""center"">" replace(replace(string(v-itogo[3],  ">>>,>>>,>>>,>>9.99"),","," "),".",",") + "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             if v-itogo[1] + v-itogo[2] + v-itogo[3] > 0 then put stream rep unformatted
             "<td align=""center"">" replace(replace(string(v-itogo[1] + v-itogo[2] + v-itogo[3], ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
             else do:
                put stream rep unformatted
                "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
             end.
             put stream rep unformatted
             "<td align=""center""></td>" skip
             "</tr></table>" skip.

  put stream rep unformatted
              "<br><br>
               <table class=MsoNormalTable border=0 cellpadding=0 style='mso-cellspacing:1.5pt; mso-yfti-tbllook:1184; width:525.0pt;' align=center>
                <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>БАНК/БАНК</b></p></td></tr>
                <tr style='mso-yfti-irow:1'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>_____________________________________________________</p></td></tr>
                <tr style='mso-yfti-irow:2'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>
                <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
                &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
                </p></tr>
                <tr style='mso-yfti-irow:3'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>ЗАЕМШЫ/ЗАЕМЩИК</b></p></td></tr>
                <tr style='mso-yfti-irow:4'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>_____________________________________________________</p></td></tr>
                <tr style='mso-yfti-irow:5'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>
                <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
                толыќ аты-жґні/Ф.И.О. полностью
                </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
                </p></td></tr>
                <tr style='mso-yfti-irow:6'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><td>&nbsp</p></tr>
                <tr style='mso-yfti-irow:7'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>
                <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
                <b>ТЕЅ ЗАЕМШЫ/СОЗАЕМЩИК</b>
                </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
                </p></td></tr>
                <tr style='mso-yfti-irow:8'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>
                <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
                _____________________________________________________
                </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
                </p></td></tr>
                <tr style='mso-yfti-irow:9'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>
                <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
                толыќ аты-жґні/Ф.И.О. полностью
                </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
                </p></td></tr>
                </TABLE>"
    skip.

  put stream rep unformatted "</body></html>" skip.

output stream rep close.

unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).