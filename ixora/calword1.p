/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        График погашения для lon.grp = 14,15,24,25,54,55,64,65
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
        BANK
 * CHANGES
        28.06.2011 ruslan добавил валюту
        13.02.3012 kapar  - (wrk.prc = lnsci.iv-sc) изменил на (wrk.prc = wrk.prc + lnsci.iv-sc)
        21/05/2012 kapar - ТЗ ДАМУ
*/

{global.i}

def stream rep.
def var coun as int no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-itogo as deci no-undo extent 3.
def var v-ofile as char no-undo.

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

if avail lons then do:
    for each lnscs where lnscs.lon = s-lon and lnscs.sch no-lock:
        find first wrk where wrk.dt = lnscs.stdat exclusive-lock no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.dt = lnscs.stdat.
        end.
        wrk.koms = lnscs.stval.
        v-itogo[3] = v-itogo[3] + wrk.koms.
    end.
end.

def var v-ccode as char no-undo.
find first sub-cod where sub-cod.acc=lon.lon and sub-cod.d-cod='lnprod' no-lock no-error.
if available sub-cod then v-ccode = sub-cod.ccode.


output stream rep to value(v-ofile).

    put stream rep unformatted
     "<HTML><HEAD><TITLE></TITLE>
     <META content=""text/html; charset=windows-1251"" http-equiv=Content-Type>
     <META content=ru http-equiv=Content-Language>
     </HEAD>
     <BODY style='margin-left:.5pt;margin-top:.1pt;margin-right:.1pt;margin-bottom:.2pt'>
     <TABLE style=""FONT-SIZE: 12pt"" border=0 align=center width=700 style=""font-family: times new roman"">
     <TR style=""font-family:bold"">
     <TD align=""right"" valign=""top"" width=350><a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'><b>«__» _______ 20___ж.
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     № _______<BR>
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     АКЦЕССОРЛЫЌ/НЕСИЕ шартына<BR>«__» _______ 20___ж.
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     Ќосымша № 1 </TD>
     <TD align=""right"" valign=""top"" width=350><b>Приложение № 1 <BR>
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     от «__» ________ 20____  года
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     <br>к
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     Акцессорному/Кредитному договору<br> № _______ от “___” ________ 20____  года
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     </TD></TR>
     <tr><td  width=350>&nbsp;</td><td  width=350>&nbsp;</td></tr></table>
     <table class=MsoNormalTable border=0 cellpadding=0 width=700 style='width:525.0pt;
 mso-cellspacing:1.5pt;mso-yfti-tbllook:1184' align=center>
     <TR>
     <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>Ќарыз алушы Шартќа осы Ќосымша № 1 ќол ќоя отырып, Банкпен тїрлі јдістерімен есептеліп ўсынылєан Несиені ґтеу кестесімен танысќанын растайды, Ќарыз алушымен ґтеу јдісін таѕдауда Тараптар келесіге тоќтады: </p></TD>
     <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>Подписанием настоящего Приложения № 1 к Договору, Заемщик подтверждает, что ознакомлен с предложенными Банком графиками погашения Кредита, рассчитанными различными методами, таким образом, при выборе Заемщиком метода погашения Стороны пришли к следующему: </p></TD></TR>
     <TR>
     <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>1. Ќарыз алушы
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     аннуитетті тґлемдермен/теѕ їлестермен/тараптардыѕ келісуі бойынша ґзге јдістермен тґлеуден
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     бас тартады. </p></TD>
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
     отказывается </p></TD></TR>
     <TR>
     <td width=350 valign=top style='width:262.5pt;padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>2. Ќарыз алушымен тґмендегі Кестеде ќолданылатын
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     аннуитетті тґлемдермен/теѕ їлестермен/тараптардыѕ келісуі бойынша ґзге јдістермен
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     ґтеу јдісі таѕдалды: </p></TD>
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
     , применяемый в нижеследующем Графике платежей: </p></TD></TR></TABLE><br><br><br>"
     skip.

  if v-ccode = '07' or v-ccode = '08' or v-ccode = '09' then do:
      put stream rep unformatted
         "<TABLE align=center width=700 style=""font-family: times new roman"" align=center>
        <TR style=""font-family:bold"">
        <TD style=""FONT-SIZE: 12pt"" align=middle><b>ТҐЛЕМДЕР КЕСТЕСІ/ ГРАФИК ПЛАТЕЖЕЙ</TD></TR></TABLE>
        <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=691
       style='width:518.5pt;border-collapse:collapse;border:none;mso-border-alt:
       solid windowtext .75pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
       .75pt solid windowtext;mso-border-insidev:.75pt solid windowtext' align=center>
        <tr style=""font:bold"">
        <td align=center> Кїні/Дата</td>
        <td align=center> Ґтелінетін Несие сомасы/Сумма Кредита к погашению	</td>
        <td align=center> Ќаржы агенті тґлейтін сыйаќы сомасы/ Сумма вознаграждения, оплачиваемая Финансовым агентом </td>
        <td align=center> Алушы тґлейтін сыйаќы сомасы/ Сумма вознаграждения, оплачиваемая Получателем </td>
        <td align=center> Ґтелінетін Несие сомасы мен сыйаќы сомасы/Сумма Кредита и вознаграждения к погашению </td>
        <td align=center> Келесі ґтелетін Несие сомасыныѕ ќалдыєы/Остаток суммы Кредита на дату следующего погашения </td>
        </tr>"
        skip.

        for each wrk where wrk.od <> 0 or wrk.prc <> 0 or wrk.koms <> 0 no-lock:
          put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">"replace(string(wrk.dt, "99/99/9999"),"/",".") "</td>" skip.
                 if wrk.od > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.od, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.

                 if wrk.prc > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(((wrk.prc / lon.prem) * lon.dprem), ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if wrk.prc > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(((wrk.prc / lon.prem) * (lon.prem - lon.dprem)), ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.

                 if wrk.prc > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.od + wrk.prc + wrk.koms, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if wrk.ost - wrk.od > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.ost - wrk.od, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 put stream rep unformatted
                 "</tr>" skip.
        end.

        put stream rep unformatted
                 "<tr style=""font-family:bold"">" skip
                 "<td align=""center"">Сомалыќ<br> белгісі/<br>Суммарное<br> значение (" v-crc "):</td>" skip.
                 if v-itogo[1] > 0 then put stream rep unformatted
                 "<td align=""center"">" replace(replace(string(v-itogo[1], ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.

                 if v-itogo[2] > 0 then put stream rep unformatted
                 "<td align=""center"">" replace(replace(string(((v-itogo[2] / lon.prem) * lon.dprem), ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if v-itogo[2] > 0 then put stream rep unformatted
                 "<td align=""center"">" replace(replace(string(((v-itogo[2] / lon.prem) * (lon.prem - lon.dprem)), ">>>,>>>,>>>,>>9.99"),","," "),".",",") "</td>" skip.
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
                 "</tr></table><br><br><br>" skip.
  end.
  else do:
      put stream rep unformatted
         "<TABLE align=center width=700 style=""font-family: times new roman"" align=center>
        <TR style=""font-family:bold"">
        <TD style=""FONT-SIZE: 12pt"" align=middle><b>ТҐЛЕМДЕР КЕСТЕСІ/ ГРАФИК ПЛАТЕЖЕЙ</TD></TR></TABLE>
        <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=691
       style='width:518.5pt;border-collapse:collapse;border:none;mso-border-alt:
       solid windowtext .75pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
       .75pt solid windowtext;mso-border-insidev:.75pt solid windowtext' align=center>
        <tr style=""font:bold"">
        <td align=center> Кїні/Дата</td>
        <td align=center> Ґтелінетін Несие сомасы/Сумма Кредита к погашению	</td>
        <td align=center> Ґтелінетін сыйаќы сомасы/Сумма вознаграждения к погашению </td>
        <td align=center> Ґтелінетін Несие сомасы мен сыйаќы сомасы/Сумма Кредита и вознаграждения к погашению </td>
        <td align=center> Келесі ґтелетін Несие сомасыныѕ ќалдыєы/Остаток суммы Кредита на дату следующего погашения </td>
        </tr>"
        skip.

        for each wrk where wrk.od <> 0 or wrk.prc <> 0 or wrk.koms <> 0 no-lock:
          put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">"replace(string(wrk.dt, "99/99/9999"),"/",".") "</td>" skip.
                 if wrk.od > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.od, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if wrk.prc > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.prc, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if wrk.od + wrk.prc + wrk.koms > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.od + wrk.prc + wrk.koms, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 if wrk.ost - wrk.od > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(wrk.ost - wrk.od, ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                    put stream rep unformatted
                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 put stream rep unformatted
                 "</tr>" skip.
        end.

        put stream rep unformatted
                 "<tr style=""font-family:bold"">" skip
                 "<td align=""center"">Сомалыќ<br> белгісі/<br>Суммарное<br> значение (" v-crc "):</td>" skip.
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
                 if avail lons then do:
                               if v-itogo[3] > 0 then put stream rep unformatted
                               "<td align=""center"">" + replace(replace(string(v-itogo[3], ">>>,>>>,>>>,>>9.99"),","," "),".",",") + "</td>" skip.
                               else do:
                                    put stream rep unformatted
                                    "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                               end.
                 end.
                 if v-itogo[1] + v-itogo[2] + v-itogo[3] > 0 then put stream rep unformatted
                 "<td align=""center"">"replace(replace(string(v-itogo[1] + v-itogo[2] + v-itogo[3], ">>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip.
                 else do:
                     put stream rep unformatted
                     "<td align=""center"" style=""FONT-SIZE: 12pt""> - </td>" skip.
                 end.
                 put stream rep unformatted
                 "<td align=""center""></td>" skip
                 "</tr></table><br><br><br>" skip.
  end.

    put stream rep unformatted
     "<table class=MsoNormalTable border=0 cellpadding=0 style='mso-cellspacing:1.5pt; mso-yfti-tbllook:1184; width:525.0pt;' align=center>
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
    <tr style='mso-yfti-irow:3'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>ЌАРЫЗ АЛУШЫ/ЗАЕМЩИК</b></p></td></tr>
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
    <b>ТЕЅ ЌАРЫЗ АЛУШЫ/СОЗАЕМЩИК</b>
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
    </TABLE>" skip.

    put stream rep unformatted
    "<br>
    <br>
    <span style='font-size:12.0pt;font-family:""Times New Roman"",""serif"";mso-fareast-font-family:
    ""Times New Roman"";mso-ansi-language:RU;mso-fareast-language:RU;mso-bidi-language:
    AR-SA'><br clear=all style='mso-special-character:line-break;page-break-before:
    always'>
    </span>
    <br>
    <table class=MsoNormalTable border=0 cellpadding=0 width=700 style='width:525.0pt;
 mso-cellspacing:1.5pt;mso-yfti-tbllook:1184'>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
    <td style='padding:.75pt .75pt .75pt .75pt'>
    <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
    <b><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'>ТОЛЬКО ДЛЯ КРЕДИТНЫХ ДОГОВОРОВ, К АКЦЕССОРНЫМ ДОГОВОРАМ НЕ</b><br> <b>ПРИЛАГАЕТСЯ - при распечатывании удалить</b>
    </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
    </p></TD></TR></TABLE>" skip.
    put stream rep unformatted
    "<table class=MsoNormalTable border=1 cellpadding=0 width=700 style='width:525.0pt;
 mso-cellspacing:1.5pt;border:solid windowtext 1.0pt;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:1184;mso-border-insidev:.5pt solid windowtext' align=center>
    <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'>
  <p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:right'>
  <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     «__» ______ 20__ ж.
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     <br>№
     <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     _______
     </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
     Несие шартына <br> <b>Ќосымша № 2</b></p></TD>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:right'><b>Приложение № 2</b><br>к Кредитному договору №
  <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
  _______
  </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
 <br>от
  <a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
  «__» ______ 20__ года
  </span><!--[if gte mso 9]><xml> <w:data>FFFFFFFF0000000000000E00220435043A04410442043E0432043E0435041F043E043B0435043100000008003100320033003400350036003700380000000000000000000000000000000000000000000000</w:data>
     </xml><![endif]--></span></span><!--[if supportFields]><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span style='mso-element:field-end'></span><![endif]--><span style='mso-bookmark:ТекстовоеПоле1'></span>
     <span lang=EN-US style='mso-ansi-language: EN-US'><o:p></o:p></span>
  </p></TD></TR>
    <tr style='mso-yfti-irow:1'><td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'>&nbsp;</td><td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'>&nbsp;</td></tr>
    <tr style='mso-yfti-irow:2'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>Ќарыз алушыныѕ ќосымша, соныѕ ішінде<br> ќаржы міндеттемелері </b></p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>Дополнительные, в т.ч. финансовые,<br> обязательства Заемщика:</b></p></TD></TR>
    <tr style='mso-yfti-irow:3'><td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'>&nbsp;</td><td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'>&nbsp;</td></tr>
    <tr style='mso-yfti-irow:4'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>1. Ќандай да бір тґлем ўстамай Шарт бойынша барлыќ тґлемдерді тґлеу, ал ўстап ќалу міндетті болєан жаєдайда Банк Шарт бойынша ґзіне тиесілі барлыќ аќша сомасын толыќ кґлемде алатындай Банкке тґленуге тиісті аќша сомасын ўлєайту;</p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>1. Осуществлять все платежи по Договору без каких-либо удержаний и, в случае если осуществление таких удержаний является обязательным, увеличить подлежащие уплате Банку суммы денег таким образом, чтобы Банк в полном объеме получил все причитающиеся ему по Договору суммы денег;</p></TD></TR>
    <tr style='mso-yfti-irow:5'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>2. Ќазаќстан Республикасыныѕ аумаєындаєы жјне одан тыс жердегі барлыќ банктердегі, банктік операциялардыѕ жекелеген тїрлерін атќаратын ўйымдардаєы, басќа да несие ўйымдарындаєы Ќарыз алушыныѕ барлыќ банктік шоттарыныѕ тізімін, сондай-аќ Ќарыз алушыныѕ олардыѕ алдында берешегініѕ болуы жјне мґлшері туралы мјліметтерді беруге;</p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>2. Предоставить Банку перечень всех банковских счетов Заемщика во всех банках, организациях, осуществляющих отдельные виды банковских операций, и иных кредитных организациях на территории Республики Казахстан и за ее пределами, а также сведения о наличии и размере задолженности Заемщика перед ними;</p></TD>
    </TR>
    <tr style='mso-yfti-irow:6'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>3. Ќарыз алушыныѕ банктермен, банктік операциялардыѕ жекелеген тїрлерін атќаратын ўйымдармен, басќа да несие ўйымдармен жасаєан, болашаќта жасайтын барлыќ банктік шот шарттарына Картотекаєа ќабылдау, бір жыл бойы Банктіѕ орындалмаєан тґлем талап-тапсырмаларын саќтау туралы талапты енгізуге;</p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>3. Включить во все заключенные Заемщиком с иными банками, организациями, осуществляющими отдельные виды банковских операций, и иными кредитными организациями, и заключаемые в будущем договоры банковского счета условие о принятии в Картотеку и хранении в течение одного года неисполненных платежных требований-поручений Банка;</p></TD>
    </TR>" skip.
    put stream rep unformatted
    "<tr style='mso-yfti-irow:7'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>4. Банк талабын алєан кезден бастап їш кїн ішінде Ќамтамасыз ету ретінде берілген мїлік жјне/немесе Ќарыз алушы орналасќан жерге Банк ќызметкерлерініѕ келесі себептерге байланысты баруымен байланысты шыєындар сомасын ґтеуге:<br>
    •	Ќамтамасыз ету ретінде берілген мїлікті ќараумен жјне/немесе баєалаумен;<br>
    •	Ќамтамасыз ету туралы шарттарды жјне/немесе ќосымша келісімдерін жасаумен жјне/немесе тіркеумен;<br>
    •	жоба мониторингімен;<br>
    •	Ќамтамасыз ету мониторингімен;<br>
    •	Шарт жјне/немесе Ќамтамасыз ету бойынша кез келген шарт бойынша міндеттемелердіѕ бўзылу ќауіпініѕ тґнуімен;<br>
    </p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>4. Возмещать Банку в трехдневный срок с момента получения требования Банка суммы расходов, связанных с выездом сотрудников Банка к месту нахождения имущества, представляемого в качестве Обеспечения, и/или Заемщика, в связи с:<br>
    •	осмотром и/или оценкой имущества, представляемого в качестве Обеспечения;<br>
    •	заключением и/или регистрацией договоров по Обеспечению и/или дополнительных соглашений к ним;<br>
    •	мониторингом проекта;<br>
    •	мониторингом Обеспечения;<br>
    •	возникновением угрозы нарушения обязательств по Договору и/или любому из договоров по Обеспечению;<br>
    </p></TD>
    </TR>
    <tr style='mso-yfti-irow:8'>
    <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:none;
    border-bottom:none;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:none;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>5. Банкке келесі аталєан мерзімде келесі есептілікті ўсынуєа: <br>
    •	тоќсан сайын, јр тоќсан ґткеннен кейін 20-сынан кешіктірмей, Банктіѕ бірінші талабы бойынша ќаржылыќ есептілікті жјне/немесе Ќарыз алушыныѕ ќаржы жаєдайын аныќтау їшін ќажетті кез келген басќа аќпаратты (ќўжаттарды, мјліметтерді, аныќтамаларды);<br>
    •	ќаржы жылы аяќталєаннан кейін екі кїнтізбелік айдан кешіктірмей Ќарыз алушыныѕ мґрімен кујландырылєан есеп кезеѕі ішіндегі ќаржылыќ есептердіѕ кґшірмелерін.
    </p></TD>
     <td width=350 valign=top style='width:262.5pt;border-top:none;border-left:
  none;border-bottom:none;border-right:none;
  mso-border-left-alt:none;mso-border-right-alt:none;
  padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'>5. Предоставлять Банку в нижеуказанные сроки следующую отчетность: <br>
    •	ежеквартально, не позднее 20 числа по истечении каждого квартала, а также по первому требованию Банка, финансовую отчетность и/или любую другую информацию (документы, сведения, справки) необходимые для выяснения финансового состояния Заемщика;<br>
    •	не позднее двух календарных месяцев после окончания финансового года, заверенные печатью Заемщика копии финансовых отчетов за отчетный период
    </p></TD>
    </TR>
    </TBODY></TABLE>
    <br>
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
    <tr style='mso-yfti-irow:3'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><b>ЌАРЫЗ АЛУШЫ/ЗАЕМЩИК</b></p></td></tr>
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
    <tr style='mso-yfti-irow:7'><td style='padding:.75pt .75pt .75pt .75pt'><p class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:center'><a name=ТекстовоеПоле1></a><!--[if supportFields]>
     <span style='mso-bookmark:ТекстовоеПоле1'></span><span style='mso-element:field-begin'></span>
     <span style='mso-bookmark:ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language: EN-US'>
     <span style='mso-spacerun:yes'> </span>FORMTEXT <span style='mso-element: field-separator'></span></span></span>
     <![endif]--><span style='mso-bookmark: ТекстовоеПоле1'><span lang=EN-US style='mso-ansi-language:EN-US'>
     <span style='mso-no-proof:yes'>
     <b>ТЕЅ ЌАРЫЗ АЛУШЫ/СОЗАЕМЩИК</b>
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

output stream rep close.

unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).