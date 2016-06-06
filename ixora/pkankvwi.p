/* pkankvwi.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
       Печать интернет анкеты
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-4-1
 * AUTHOR
        16.05.2005 tsoy
 * CHANGES
        21/10/2005 madiar - перенес подписи после юридической части
        14/05/08 marinav - поменяла текст заявления
*/


{global.i}
{pk.i}

def input parameter p-title as char.

def shared temp-table t-anks
  field ln like pkanketa.ln
  field rnn like pkanketa.rnn
  field rating like pkanketa.rating
  index ln is primary unique ln
  index rnn rnn.


def var v-repfile as char init "repanketa.htm".
def var v-refusname as char format "x(40)".
def var v-stsname as char.
def var v-i as integer.
def var v-str as char.
def var v-len2 as integer init 25.
def var v-kredkom as char.
def var v-yes as logical.
def var v-ankrat as char init "elenal,damitov".
def var v-ofc as char init ''.

def temp-table t-ankkrit like pkanketh
  field kritln like pkkrit.ln
  field kritname like pkkrit.kritname
  index main bank ln kritln
  index value1 kritcod value1.

find sysc where sysc.sysc = "pkvrat" no-lock no-error.
if avail sysc then v-ankrat = sysc.chval.

for each t-ankkrit. delete t-ankkrit. end.

for each t-anks,
    each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype
               and t-anks.ln = pkanketh.ln no-lock,
    first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock:
 
      create t-ankkrit.
      buffer-copy pkanketh to t-ankkrit.

      assign t-ankkrit.kritln = pkkrit.ln
             t-ankkrit.kritname = pkkrit.kritname.
end.

for each t-ankkrit where t-ankkrit.value1 <> "" break by t-ankkrit.kritcod by t-ankkrit.value1:
  if first-of (t-ankkrit.kritcod) then do:
    find first pkkrit where pkkrit.kritcod = t-ankkrit.kritcod no-lock no-error.
    v-yes = (pkkrit.kritspr <> "").
  end.

  if first-of (t-ankkrit.value1) and v-yes then do:
    v-yes = yes.
    find bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = t-ankkrit.value1 no-lock no-error.
    if avail bookcod then v-stsname = bookcod.name.
    else do:
      find codfr where codfr.codfr = pkkrit.kritspr and codfr.code = t-ankkrit.value1 no-lock no-error.
      if avail codfr then v-stsname = codfr.name[1].
                     else v-yes = no.
    end.
  end.

  if not v-yes then next.

  t-ankkrit.value1 = v-stsname.
end.

output to value(v-repfile).
{html-title.i 
 &stream = " "
 &title = " Интернет Анкета"
 &size-add = "x-"
}

find first cmp no-lock no-error.

if s-credtype <> '6' then
put unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD>" cmp.name "<BR>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " " g-ofc "<BR></TD></TR>" skip
  "<TR><TD>" skip
  "<P align=""center""><B>" p-title "</B></P>" skip.
else
put unformatted
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR style=""font:bold;font-size:xx-small""><TD>" cmp.name "<BR>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " "
     g-ofc "<span style='mso-tab-count:1'>           </span><span
style='mso-tab-count:1'>            </span>" p-title "</TD><TD>" "</TD></TR>" skip.

for each t-anks:
  find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype
               and pkanketa.ln = t-anks.ln no-lock no-error.

  v-refusname = "".
  do v-i = 1 to num-entries(pkanketa.refusal):
    for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(v-i, pkanketa.refusal) no-lock:
      if v-refusname <> "" then v-refusname = v-refusname + ", ".
      v-refusname = v-refusname + bookcod.name.
    end.
  end.

  v-stsname = "".
  find bookcod where bookcod.bookcod = "pkstsank" and bookcod.code = pkanketa.sts no-lock no-error.
  if avail bookcod then v-stsname = bookcod.name.

  if s-credtype <> '6' then do:
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
  if avail pkanketh and pkanketh.rescha[3] <> "" and num-entries(pkanketh.rescha[3]) > 1 then
    v-kredkom = trim(entry(2, pkanketh.rescha[3])).
  else v-kredkom = "".

  put unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
    "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
      "<TD>N анк</TD>" skip
      "<TD>ФИО</TD>" skip
      "<TD>дата рег</TD>" skip
      "<TD>кто рег</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" style=""font:bold;font-size:x-small"" align=""left"">"
      "<TD>" string(pkanketa.ln) "</TD>" skip
      "<TD>" pkanketa.name "</TD>" skip
      "<TD>" string(pkanketa.rdt, "99/99/9999") "</TD>" skip
      "<TD>" pkanketa.rwho "</TD>" skip
    "</TR>" skip.
  end.

  else do:

  find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
  if avail ofc then v-ofc = ofc.name.
  else v-ofc = pkanketa.rwho.

  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
  if avail pkanketh and pkanketh.rescha[3] <> "" and num-entries(pkanketh.rescha[3]) > 1 then do:
    v-kredkom = trim(entry(2, pkanketh.rescha[3])).
    v-kredkom = string(date(v-kredkom), "99/99/9999").
    if num-entries(pkanketh.rescha[3]) > 5 then do:
       /*find ofc where ofc.ofc = trim(entry(6,pkanketh.rescha[3])) no-lock no-error.
       if avail ofc then*/
          v-kredkom = v-kredkom + ". " + trim(entry(6,pkanketh.rescha[3])). /*ofc.name. ФИО Кред.ком. оф.*/
       if avail pkanketa and pkanketa.resch[4] <> '' then
          v-kredkom = v-kredkom + ". " + pkanketa.rescha[4].
    end.
  end.
  else v-kredkom = "".

  put unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""2"" align=""center"">" skip
    "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
      "<TD>N анк</TD>" skip
      "<TD>ФИО</TD>" skip
      "<TD>дата рег</TD>" skip
      "<TD>кто рег</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" style=""font-size:xx-small"" align=""left"">"
      "<TD>" string(pkanketa.ln) "</TD>" skip
      "<TD>" pkanketa.name "</TD>" skip
      "<TD>" string(pkanketa.rdt, "99/99/9999") "</TD>" skip
      "<TD>" v-ofc "</TD>" skip
    "</TR>" skip.
  end.

  if s-credtype <> '6' then
  put unformatted
    "<TR><TD colspan=13>"
      "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
      "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
        "<TD>критерий</TD>" skip
        "<TD>данные анкеты</TD>" skip.
  else
  put unformatted
    "<TR><TD colspan=11>"
      "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
      "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
        "<TD>критерий</TD>" skip
        "<TD>данные анкеты</TD>" skip.
   put unformatted
      "</TR>" skip.

  for each t-ankkrit where t-ankkrit.ln = pkanketa.ln use-index main:
    if length(t-ankkrit.value2) < v-len2 or t-ankkrit.kritcod = "commentary" then v-str = t-ankkrit.value1 + " " + t-ankkrit.value2 .
    else do:
      v-str = substr(t-ankkrit.value2, 1 , v-len2).
      do v-i = 1 to int (length(t-ankkrit.value2) / v-len2) + 1:
        v-str =  v-str + "<BR>" +  substr(t-ankkrit.value2, v-i * v-len2 + 1, v-len2).
      end.
      if substr(v-str, length(v-str) - 3, 4) = "<BR>" then
        v-str = substr(v-str, 1, length(v-str) - 4).
    end.
    /* некоторые критерии клиенту видеть не надо  */
        if t-ankkrit.kritcod = "age2"      then next.
        if t-ankkrit.kritcod = "alseco"    then next.
        if t-ankkrit.kritcod = "jobp"      then next.
        if t-ankkrit.kritcod = "sovmorg"   then next.
        if t-ankkrit.kritcod = "sovmdolzh" then next.
        if t-ankkrit.kritcod = "sovmpr"    then next.
        if t-ankkrit.kritcod = "family1"   then next.
        if t-ankkrit.kritcod = "nedvtyp0"  then next.
        if t-ankkrit.kritcod = "nedvland"  then next.
        if t-ankkrit.kritcod = "nedvz"     then next.
        if t-ankkrit.kritcod = "autoage"   then next.
        if t-ankkrit.kritcod = "nedvauto"  then next.
        if t-ankkrit.kritcod = "clnkorp"   then next.
        if t-ankkrit.kritcod = "acc1"      then next.
        if t-ankkrit.kritcod = "acc2"      then next.
        if t-ankkrit.kritcod = "clntxb"    then next.
        if t-ankkrit.kritcod = "almadolg"  then next.
        if t-ankkrit.kritcod = "blacklst"  then next.
        if t-ankkrit.kritcod = "akires"    then next.
        if t-ankkrit.kritcod = "gcvpres"   then next.
        if t-ankkrit.kritcod = "gcvpsum"   then next.

    if s-credtype <> '6' then do:
    put unformatted
      "<TR valign=""top"">"
         "<TD align=""left"">" t-ankkrit.kritname "</TD>" skip
         "<TD align=""left"">&nbsp;" t-ankkrit.value1 "</TD>" skip.
    end.
    else do:
    put unformatted
      "<TR valign=""top"" style=""font-size:xx-small"">"
         "<TD align=""left"">" t-ankkrit.kritname "</TD>" skip
         "<TD align=""left"">&nbsp;" t-ankkrit.value1 "</TD>" skip.
    end.

    if length(t-ankkrit.rescha[2]) < v-len2 then v-str = t-ankkrit.rescha[2].
    else do:
      v-str = substr(t-ankkrit.rescha[2], 1 , v-len2).
      do v-i = 1 to int (length(t-ankkrit.rescha[2]) / v-len2) + 1:
        v-str =  v-str + "<BR>" +  substr(t-ankkrit.rescha[2], v-i * v-len2 + 1, v-len2).
      end.
      if substr(v-str, length(v-str) - 3, 4) = "<BR>" then
        v-str = substr(v-str, 1, length(v-str) - 4).
    end.

    put unformatted
      "</TR>" skip.
  end.
  put unformatted "</TABLE></TD></TR></TABLE><BR>" skip.
end.

put unformatted
  "</TD></TR>"
  "</TABLE>" skip.

put unformatted
      "<br clear=all style='mso-special-character:line-break;page-break-before:always'> "  skip.

put unformatted
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
     "11. Я уведомлен и согласен с осуществлением Банком фотографической съемки.<br><br>" skip
     "Дата ""_____""   ___________________  200___г. <br>                              "  skip
     "Клиент:_____________________________________________________________________ <br>"  skip
     "Подпись:________________________________________  <br>                           "  skip
     "Подпись менеджера:____________________________________________________  <br>     "  skip.

{html-end.i " " }

output close.
unix silent cptwin value(v-repfile) iexplore.
