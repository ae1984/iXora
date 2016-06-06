/* pkankvw.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Печать анкет по выборке во временной таблице
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-3, 4-x-4-1
 * AUTHOR
        17.02.2003 nadejda
 * CHANGES
        09.12.2003 nadejda - добавлена печать даты решения Кредитного Комитета
        23.02.2004 nadejda - печать сведений о рейтинге только для старших менеджеров (перечисленных в настройках)
        07.04.2004 nadejda - исправлена ошибка - был выключен не только рейтинг, но и признаки проставления данных авто и менеджером
        17/11/2004 madiar  - заворачивание после 25-го символа - убрал для замечаний менеджера
        25.11.2004 saltanat - * Т/З №1209 * Потребкредиты *
                              Убрала поле "Цель кредита". В "Кред.ком." добавила имя менеджера. Вместо логина сделала вывод Фам. менеджера
                              Убрала поле "Ссудный счет". Уменьшила шрифты. Чтобы печатать на 1стр. в ширину нужно выбрать формат печати - 16К                      
        17.05.05   marinav - введение столбца соц рейтинга
        17/05/2005 madiar  - изменения в справочниках - исправил вывод значений из справочников
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
def var v-spr as char.
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

      /*
      if pkkrit.kritspr = "" or (pkkrit.kritspr <> "" and pkanketh.value1 = "") then 
        t-ankkrit.value1 = pkanketh.value1.
      else do:
        find bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = pkanketh.value1 no-lock no-error.
        if avail bookcod then t-ankkrit.value1 = bookcod.name.
        else do:
          find codfr where codfr.codfr = pkkrit.kritspr and codfr.code = pkanketh.value1 no-lock no-error. 
          if avail codfr then t-ankkrit.value1 = codfr.name[1].
          else t-ankkrit.value1 = pkanketh.value1.
        end.
      end.
      */
end.

for each t-ankkrit where t-ankkrit.value1 <> "" break by t-ankkrit.kritcod by t-ankkrit.value1:
  if first-of (t-ankkrit.kritcod) then do:
    find first pkkrit where pkkrit.kritcod = t-ankkrit.kritcod no-lock no-error.
    v-yes = no.
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
  end.

  if first-of (t-ankkrit.value1) and v-yes then do:
    v-yes = yes.
    find bookcod where bookcod.bookcod = v-spr and bookcod.code = t-ankkrit.value1 no-lock no-error.
    if avail bookcod then v-stsname = bookcod.name.
    else do:
      find codfr where codfr.codfr = v-spr and codfr.code = t-ankkrit.value1 no-lock no-error. 
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
 &title = " Отобранные анкеты"
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
      "<TD>рейтинг</TD>" skip
      "<TD>ФИО</TD>" skip
      "<TD>причина отказа/ выдано</TD>" skip
      "<TD>банк</TD>" skip
      "<TD>код клиента</TD>" skip
      "<TD>ссудный счет</TD>" skip
      "<TD>сумма кредита</TD>" skip
      "<TD>цель кредита</TD>" skip
      "<TD>кред.комитет</TD>" skip
      "<TD>статус</TD>" skip
      "<TD>дата рег</TD>" skip
      "<TD>кто рег</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" style=""font:bold;font-size:x-small"" align=""left"">"
      "<TD>" string(pkanketa.ln) "</TD>" skip
      "<TD>" string(pkanketa.rating) "</TD>" skip
      "<TD>" pkanketa.name "</TD>" skip
      "<TD>" v-refusname "</TD>" skip
      "<TD>" pkanketa.bank "</TD>" skip
      "<TD>" pkanketa.cif "</TD>" skip
      "<TD>&nbsp;" pkanketa.lon "</TD>" skip
      "<TD>" replace(trim(string(pkanketa.summa, ">>>,>>>,>>>,>>9.99")), ",", "&nbsp;") "</TD>" skip
      "<TD>" pkanketa.goal "</TD>" skip
      "<TD>" string(date(v-kredkom), "99/99/9999")  "</TD>" skip
      "<TD style=""font-size:xx-small"">" v-stsname "</TD>" skip
      "<TD>" string(pkanketa.rdt, "99/99/9999") "</TD>" skip
      "<TD>" pkanketa.rwho "</TD>" skip
    "</TR>" skip.
  end.
  /* 25.11.2004 saltanat - Потребкредиты */
  else do:

  find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
  if avail ofc then v-ofc = ofc.name.
  else v-ofc = ''.

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
      "<TD>рейтинг</TD>" skip
      "<TD>ФИО</TD>" skip
      "<TD>причина<BR>отказа/ выдано</TD>" skip
      "<TD>банк</TD>" skip
      "<TD>код<BR>клиента</TD>" skip
      "<TD>сумма<BR>кредита</TD>" skip
      "<TD>кред.комитет</TD>" skip
      "<TD>статус</TD>" skip
      "<TD>дата рег</TD>" skip
      "<TD>кто рег</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" style=""font-size:xx-small"" align=""left"">"
      "<TD>" string(pkanketa.ln) "</TD>" skip
      "<TD>" string(pkanketa.rating) "</TD>" skip
      "<TD>" pkanketa.name "</TD>" skip
      "<TD>" v-refusname "</TD>" skip
      "<TD>" pkanketa.bank "</TD>" skip
      "<TD>" pkanketa.cif "</TD>" skip
      "<TD>" replace(trim(string(pkanketa.summa, ">>>,>>>,>>>,>>9.99")), ",", "&nbsp;") "</TD>" skip
      "<TD>" v-kredkom "</TD>" skip
      "<TD>" v-stsname "</TD>" skip
      "<TD>" string(pkanketa.rdt, "99/99/9999") "</TD>" skip
      "<TD>" v-ofc "</TD>" skip
    "</TR>" skip.
  end.
  
  put unformatted 
    "<TR><TD colspan=11>"
      "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" align=""center"">" skip
      "<TR align=""center"" valign=""top"" style=""font:bold;font-size:xx-small"">"
        "<TD>критерий</TD>" skip
        "<TD>данные анкеты</TD>" skip
        "<TD>данные из других баз</TD>" skip
        "<TD>данные АКИ</TD>" skip.

  if lookup(g-ofc, v-ankrat) > 0 then
     put unformatted 
        "<TD>рейтинг</TD>" skip
        "<TD>соц рейт</TD>" skip.

  put unformatted 
      "<TD>пр</TD>" skip
      "<TD>прA</TD>" skip.

   put unformatted 
      "</TR>" skip.

  for each t-ankkrit where t-ankkrit.ln = pkanketa.ln use-index main:
    if length(t-ankkrit.value2) < v-len2 or t-ankkrit.kritcod = "commentary" then v-str = t-ankkrit.value2.
    else do:
      v-str = substr(t-ankkrit.value2, 1 , v-len2).
      do v-i = 1 to int (length(t-ankkrit.value2) / v-len2) + 1:
        v-str =  v-str + "<BR>" +  substr(t-ankkrit.value2, v-i * v-len2 + 1, v-len2).
      end.
      if substr(v-str, length(v-str) - 3, 4) = "<BR>" then
        v-str = substr(v-str, 1, length(v-str) - 4).
    end.
    
    put unformatted 
         "<TR valign=""top"" style=""font-size:xx-small"">"
         "<TD align=""left"">" t-ankkrit.kritname "</TD>" skip
         "<TD align=""left"">&nbsp;" t-ankkrit.value1 "</TD>" skip
         "<TD align=""left"">&nbsp;" v-str "</TD>" skip.
    
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
         "<TD align=""left"">&nbsp;" v-str  "</TD>" skip.

    if lookup(g-ofc, v-ankrat) > 0 then
      put unformatted 
         "<TD align=""center"">" string(t-ankkrit.rating, "->>>9")  "</TD>" skip
         "<TD align=""center"">" string(t-ankkrit.resdec[5], "->>>9")  "</TD>" skip.

    put unformatted 
       "<TD align=""center"">" t-ankkrit.value3 "</TD>" skip
       "<TD align=""center"">" t-ankkrit.value4 "</TD>" skip.

    put unformatted 
      "</TR>" skip.
  end.
  put unformatted "</TABLE></TD></TR></TABLE><BR>" skip.
end.

put unformatted 
  "</TD></TR>"
  "</TABLE>" skip.

{html-end.i " " }

output close.
unix silent cptwin value(v-repfile) iexplore.



