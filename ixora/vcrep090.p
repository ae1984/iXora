/* vcrep090.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* vcrepaas.p Валютный контроль
   Отчет по 090 счетам (экспортная выручка юрлиц) с остатками > 0

   03.12.2002 nadejda создан
  
*/

{global.i}

def var v-listlgr as char init "185".

function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  if p-value = 0 then vp-str = "&nbsp;".
  else vp-str = trim(string(p-value, "->>>,>>>,>>>,>>>,>>9.99")).
  return vp-str.
end.

message "Формируется отчет...".

output to vcrep090.htm.

{html-title.i 
 &stream = " "
 &title = "ВЕДОМОСТЬ СЧЕТОВ. Экспортная выручка юридических лиц"
 &size-add = "x-"
}

put unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ВЕДОМОСТЬ СЧЕТОВ С НЕНУЛЕВЫМ ОСТАТКОМ<BR>" skip
   "экспортная выручка юридических лиц" skip
   "<BR><BR>на " + string(g-today, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Группа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>(название)</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код валюты</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Остаток</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Блокир. ср-ва</B></FONT></TD>" skip
   "</TR>" skip.

find sysc where sys.sysc = "vc-egr" no-lock no-error.
if avail sysc then v-listlgr = trim(sysc.chval).
else message " Не найден параметр VC-EGR в таблице SYSC ! " view-as alert-box.

for each aaa where lookup(aaa.lgr, v-listlgr) > 0 and 
      (aaa.cbal <> 0 or aaa.hbal <> 0) no-lock.
  find lgr where lgr.lgr = aaa.lgr no-lock no-error.
  find crc where crc.crc = aaa.crc no-lock no-error.

  put unformatted
   "<TR valign=""top"">" skip 
      "<TD align=""center"">" + aaa.aaa + "</TD>" skip
      "<TD align=""center"">" + aaa.lgr + "</TD>" skip
      "<TD align=""left"">" + lgr.des + "</TD>" skip
      "<TD align=""center"">" + crc.code + "</TD>" skip
      "<TD align=""right"">" + sum2str(aaa.cbal) + "</TD>" skip
      "<TD align=""right"">" + sum2str(aaa.hbal) + "</TD>" skip
    "</TR>" skip.
end.
put unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

{html-end.i}

output close.

hide message no-pause.

unix silent cptwin vcrep090.htm iexplore.

pause 0.

