/* pkclnvw.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Печать анкеты для клиента (повторный кредит)
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
        19/08/2005 madiar
 * BASES
        bank, comm
 * CHANGES
        24/08/2005 madiar - объединил анкету и заявление в один документ
        08/09/2005 madiar - добавил ФИО и подпись менеджера
        21/10/2005 madiar - перенес подписи после юридической части
        17/01/2006 madiar - критерии gcvpres,wletter,commentary не выводятся
        06/11/07   marinav - поменяла текст заявления
 */


{global.i}
{pk.i}

define temp-table wrk
  field id as integer
  field kritcod as char
  field kritname as char
  field value1 as char
  index idx is primary id kritname.

def var v-ofcname as char.
def var v-ofcname2 as char.
def var coun as integer.
def var v-yes as logi.
def var v-spr as char.
def var v-stsname as char.

def var v-month as char extent 12 init ["января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря"].

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln " не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
if not avail pkanketh or trim(pkanketh.rescha[3]) = '' then do:
  message skip " Анкета N" s-pkankln " не повторная !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

coun = 0.
for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
  if lookup(pkkrit.kritcod,"gcvpres,wletter,commentary") > 0 then next.
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
  if avail pkanketh then do:
    coun = coun + 1.
    
    create wrk.
    wrk.id = coun.
    wrk.kritcod = pkkrit.kritcod.
    wrk.kritname = pkkrit.kritname.
    wrk.value1 = pkanketh.value1.
    
    v-yes = no. v-spr = ''.
    if trim(pkkrit.kritspr) <> "" then do:
      if num-entries(pkkrit.kritspr) = 1 then do: v-yes = yes. v-spr = pkkrit.kritspr. end.
      else do:
        if num-entries(pkkrit.kritspr) >= integer(s-credtype) then
           if entry(integer(s-credtype),pkkrit.kritspr) <> "" then do:
             v-yes = yes.
             v-spr = entry(integer(s-credtype),pkkrit.kritspr).
           end.
      end.
    end.
    
    if v-yes then do:
      v-stsname = ''.
      find bookcod where bookcod.bookcod = v-spr and bookcod.code = pkanketh.value1 no-lock no-error.
      if avail bookcod then v-stsname = bookcod.name.
      else do:
        find codfr where codfr.codfr = v-spr and codfr.code = pkanketh.value1 no-lock no-error.
        if avail codfr then v-stsname = codfr.name[1].
      end.
      if v-stsname <> '' then wrk.value1 = v-stsname.
    end.
    
  end.
end.

if coun mod 2 > 0 then coun = truncate(coun / 2,0) + 1.
else coun = coun / 2.

output to pkclnvw.htm.
{html-title.i
 &stream = " "
 &title = " Анкета "
 &size-add = "x-"
}

/*
put unformatted
   "<HTML>" skip
   "<HEAD>" skip
   "<TITLE> Анкета </TITLE>" skip
   "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
   "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
   "<STYLE TYPE=""text/css"" ID=""default"">" skip
   " table \{font:Times New Roman Cyr, Verdana, sans; font-size: x-small; border-collapse: collapse; text-valign:top\}" skip
   "<!-- div.Section1 {page:Section1;} -->
   "</STYLE>" skip
   "</HEAD>" skip
   "<BODY>" skip.
*/

find first cmp no-lock no-error.
put unformatted
  /* "<div class=Section1>" skip */
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<tr style=""font:bold;font-size:xx-small"">" skip
  "<td width=""40%"">" cmp.name "<BR>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " " g-ofc "</td>" skip
  "<td width=""60%"" valign=""center"">АНКЕТНЫЕ ДАННЫЕ</td>" skip
  "</tr></TABLE>" skip.

find first ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
if avail ofc then v-ofcname = ofc.name. else v-ofcname = ''.

put unformatted
  "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
  "<tr align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">" skip
  "<td>N анк</td>" skip
  "<td>ФИО</td>" skip
  "<td>дата рег</td>" skip
  "<td>кто рег</td>" skip
  "</tr>" skip
  "<tr valign=""top"" style=""font-size:x-small"" align=""center"">" skip
  "<td>" s-pkankln "</td>" skip
  "<td>" pkanketa.name "</td>" skip
  "<td>" pkanketa.rdt format "99/99/9999" "</td>" skip
  "<td>" v-ofcname "</td>" skip
  "</tr>" skip
  "</TABLE>" skip.

put unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""2"" align=""center"">" skip
  "<tr align=""center"" valign=""top"">" skip
  "<td width=""50%"">" skip.

put unformatted
  "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
  "<tr align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">" skip
  "<td>критерий</td>" skip
  "<td>данные анкеты</td>" skip
  "</tr>" skip.

for each wrk no-lock:
  
  put unformatted
    "<tr valign=""top"" style=""font-size:xx-small"" align=""left"">" skip
    "<td>" wrk.kritname "</td>" skip
    "<td>" wrk.value1 "</td>" skip
    "</tr>" skip.
  
  if wrk.id = coun then do:
    put unformatted
      "</TABLE>" skip
      "</td>" skip
      "<td width=""50%"">" skip
      "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"">" skip
      "<tr align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">" skip
      "<td>критерий</td>" skip
      "<td>данные анкеты</td>" skip
      "</tr>" skip.
  end.
  
end. /* for each wrk */

put unformatted
  "</TABLE>" skip
  "</td></tr>" skip
  "</TABLE>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofcname2 = ofc.name. else v-ofcname2 = ''.

put unformatted
  "<br clear=all style='page-break-before:always'>" skip
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR style=""font-size:12px""><TD>" skip
     "<b>Данное Заявление является неотъемлемой частью анкеты. </b><br><br><br>" skip
     "<b>Я, " pkanketa.name " понимаю и соглашаюсь с тем, что: </b><br> " skip
     "1.  Заявление-анкета является неотъемлемой частью пакета документов для получения потребительского кредита (далее - 'Кредит'). <br>" skip
     "2.  Принятие АО 'Метрокомбанк' (далее - 'Банк') к рассмотрению заявления-анкеты не означает возникновения у Банка обязательств по предоставлению кредита.<br>" skip
     "3.  В случае принятия положительного решения и предоставления кредита я обязуюсь выполнять все условия, предусмотренные Договором о предоставлении потребительского кредита (далее - 'Договор').<br>" skip
     "<b>4. Я подтверждаю достоверность предоставленных мною данных, а также уполномочиваю Банк проверять предоставленную мною, а также любую иную касающуюся предмета данного заявления-анкеты и в целом правоотношений между мною и Банком информацию, в том числе охраняемую законом, обращаясь в государственные органы, организации Республики Казахстан и зарубежных стран посредством направления запросов в письменной, электронной и иной форме, от моего имени.  <br></b> " skip
     "5.  Я согласен с тем, что за рассмотрение настоящего Заявления-анкеты Банк взимает комиссию согласно тарифам. Банк вправе отказать мне в предоставлении кредита без объяснения причин отказа, и возврата комиссии за рассмотрение моей заявки. <br>" skip
     "6.  В случае предоставления недостоверных данных Банк имеет право передавать информацию о заявителе в другие финансовые институты и правоохранительные органы Республики Казахстан и зарубежных стран.  <br>" skip
     "7.  При заключении Договора я обязуюсь предоставить своему работодателю безотзывное заявление на перечисление последним Банку части моей заработной платы в счет погашения задолженности по Договору.  <br>" skip
     "<b>8. Уклонение заявителя от выполнения предусмотренных Договором обязанностей влечет ответственность, предусмотренную законодательством Республики Казахстан.   <br> </b>" skip
     "9. Сведения, содержащиеся в настоящей анкете, а также затребованные Банком документы предоставлены исключительно для получения кредита, однако Банк оставляет за собой право использовать их как доказательства при судебных разбирательствах.   <br>" skip
     "<b>10. . Подтверждаю, что сведения, содержащиеся в настоящем Заявлении-анкете, являются верными и точными на нижеуказанную дату и обязуюсь незамедлительно уведомить Банк в случае изменения указанных сведений, а также о любых обстоятельствах, способных повлиять на выполнение мной обязательств по кредиту.  </b><br>" skip
     "11. Я уведомлен и согласен с осуществлением Банком фотографической съемки.<br><br>" skip.

put unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<tr align=""left"" valign=""center"">" skip /* style=""font-size:xx-small"" */
  "<td colspan=3>""<u>&nbsp;" day(g-today) "&nbsp;</u>""&nbsp;&nbsp;<u>&nbsp;" v-month[month(g-today)] "&nbsp;</u>&nbsp;&nbsp;" year(g-today) "г.</td>" skip
  "</tr>" skip
  "<tr align=""left"" valign=""center"">" skip
  "<td colspan=2>Клиент:&nbsp;<u>&nbsp;" pkanketa.name "&nbsp;</u></td>" skip
  "<td>Подпись:&nbsp;_____________________</td>" skip
  "</tr>" skip
  "<tr align=""left"" valign=""center"">" skip
  "<td width=10% align=""center"">&nbsp;<br>МП</td>" skip
  "<td>&nbsp;<br>Менеджер:&nbsp;" v-ofcname2 "</td>" skip
  "<td>&nbsp;<br>Подпись:&nbsp;_____________________</td>" skip
  "</tr>" skip
  "</TABLE>" skip
  "</TD></TR></TABLE>" skip.

{html-end.i " " }

output close.
unix silent cptwin pkclnvw.htm iexplore.
