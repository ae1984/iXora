/* vcpril6out.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 6 - уведомление о просроченной лицензии
        Вывод временной таблицы в IE
 * RUN
        
 * CALLER
        vcpril6.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-4-1-9, 15-4-2-11, 15-4-3-7
 * AUTHOR
        29.09.2003 nadejda
 * CHANGES
        05.12.2004 saltanat - Поменяла О А О на А О.
        24.01.2006 u00600   - изменения в связи с новыми требованиями Нац.Банка
*/

{vc.i}

{global.i}

def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-printall as logical.

def shared var s-vcourbank as char.
def shared var v-dtrep as date.

def shared temp-table t-contrs
  field contract like vccontrs.contract
  field ctnum as char
  field ctdate as date
  field expimp as char
  field partner as char
  field partnname as char
  field partnaddr as char
  field licid like vcrslc.rslc
  field licnum as char
  field licdt as date
  field liclastdt as date
  field licsum as decimal
  field liccrc as char
  field cif like bank.cif.cif
  field cifname as char
  field okpo as char
  field rnn as char
  field addr as char
  index main is primary unique cifname cif ctdate ctnum contract licdt licnum licid.

def shared temp-table t-docs
  field licid like vcrslc.rslc
  field ln as integer
  field data20 as date
  field sum20 as deci
  field crc20 as char
  field data30 as date
  field sum30 as deci
  field crc30 as char
  index ln is primary unique licid ln.


def var p-filename as char init "vcpril6.html" no-undo.
def var v-name as char no-undo.
def var v-title as char no-undo.
def var i as integer no-undo.
def var v-liclast like vcrslc.rslc no-undo.
def var v-ofcname as char no-undo.
def var v-monthname as char init 
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

find last t-contrs no-error.
if avail t-contrs then do:
  v-liclast = t-contrs.licid.
end.
else do:
  message skip " Нет контрактов, соответствующих заданным параметрам !" skip(1) view-as alert-box button ok title " ОШИБКА !".
  return.
end.


def stream vcrpt.
output stream vcrpt to value(p-filename).


/* подписи */
def var v-kurname as char no-undo.
def var v-kurpos as char no-undo.
/*
def var v-depname as char.
def var v-deppos as char.
*/
find sysc where sysc.sysc = "vc-kur" no-lock no-error.
if avail sysc then do:
  v-kurname = entry(1, trim(sysc.chval)).
  v-kurpos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений о кураторе Департамента валютного контроля!". pause 3.
  v-kurpos = "".
  v-kurname = "".
end.

/*
find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then do:
  v-depname = entry(1, trim(sysc.chval)).
  v-deppos = entry(2, trim(sysc.chval)).
end.
else do:
  message "Нет сведений об ответственном лице валютного контроля!". pause 3.
  v-deppos = "".
  v-depname = "".
end.
*/

find ofc where ofc.ofc = g-ofc no-lock no-error.
v-ofcname = entry(1, ofc.name, " ").
if num-entries(ofc.name, " ") > 2 then 
  v-ofcname = v-ofcname + " " + caps(substr(entry(num-entries(ofc.name, " ") - 1, ofc.name, " "), 1, 1)) + ".".
else 
  v-ofcname = v-ofcname + " ".

if num-entries(ofc.name, " ") > 1 then 
  v-ofcname = v-ofcname + caps(substr(entry(num-entries(ofc.name, " "), ofc.name, " "), 1, 1)) + ".".

{html-title.i 
 &stream = " stream vcrpt "
 &size-add = "x-"
 &title = " Приложение 3 к Правилам лицензирования"
}

for each t-contrs:
  put stream vcrpt unformatted
     "<B>" skip
     "<P align=""right"" style=""font-size:x-small""><FONT face=""Times New Roman Cyr, Verdana, sans"">"
       "ПРИЛОЖЕНИЕ 3<BR>"
       "к Правилам осуществления<BR>"
       "валютных операций<BR>"
       "в Республике Казахстан<BR>"
       "</FONT></P>" skip
     /*"<P align=""right""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
       "<U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U> филиал<BR>"
       "Национального Банка Республики Казахстан<BR>"
       "</FONT></P>" skip*/
     "<P align=""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
       "Информация об истечении срока исполнения обязательств по<BR>лицензированной операции, предусматривающей проведение платежей<BR>между резидентами и нерезидентами по коммерческим кредитам.</FONT></P>" skip.

  put stream vcrpt unformatted
   "<P align=""center""><TABLE width=""95%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
     "<TR>" skip
       "<TD width=""50%"">наименование лицензиата</TD>" skip
       "<TD>" t-contrs.cifname "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>код ОКПО лицензиата (для юридических лиц)</TD>" skip
       "<TD>" if t-contrs.okpo = "" then "&nbsp;" else t-contrs.okpo "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>РНН лицензиата</TD>" skip
       "<TD>" t-contrs.rnn "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>почтовый адрес, телефон, факс</TD>" skip
       "<TD>" if t-contrs.addr <> "" then t-contrs.addr else "&nbsp;" "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>номер и дата выдачи лицензии Национального Банка</TD>" skip
       "<TD>" t-contrs.licnum " от " string (t-contrs.licdt, "99/99/9999") "</TD>" skip
     "</TR>" skip.


   put stream vcrpt unformatted
     "<TR>" skip
       "<TD>срок действия лицензии Национального Банка</TD>" skip
       "<TD>" string(t-contrs.liclastdt, "99/99/9999") "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>валюта и сумма лицензии</TD>" skip
       "<TD>" string(t-contrs.licsum, "->>>>>>>>>>>>>>9.99") "&nbsp;" t-contrs.liccrc "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>тип сделки (экспорт/импорт)</TD>" skip
       "<TD>" if t-contrs.expimp = "e" then "экспорт" else "импорт" "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>наименование и местонахождение контрагента по сделке </TD>" skip
       "<TD>" t-contrs.partnname "<BR>" t-contrs.partnaddr "</TD>" skip
     "</TR>" skip
     "<TR>" skip
       "<TD>реквизиты контракта</TD>" skip
       "<TD>" t-contrs.ctnum " от " string(t-contrs.ctdate, "99/99/9999") "</TD>" skip
     "</TR>" skip
   "</TABLE></P>" skip.

find first cmp no-lock no-error.        

  put stream vcrpt unformatted
    "<P align=""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
    "Настоящим " CAPS(cmp.name) " извещает о</FONT></P>" skip
    /*"<P align=""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
    "<U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</U> извещает о:<BR>"*/
    /*"<P align=""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"*/
    /*"(наименование уполномоченного банка/<BR>филиала уполномоченного банка)"<BR></FONT></P>"*/

  /* платежи и ГТД */
   /*put stream vcrpt unformatted*/
     "<P align=""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
     "необеспечении указанным лицензиатом в срок, установленный в лицензии, обязательств по лицензированной операции, предусматривающей проведение платежей/поставок между резидентами и нерезидентами по коммерческим кредитам, поступлении платежей после истечения срока лицензии (ненужное зачеркнуть)</FONT></P>" skip
     /*"Сведения об исполнении обязательств по контракту приведены ниже:</FONT></P>" skip */
     "<P align=""center""><TABLE width=""95%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
      "<TR style=""font-size:x-small; font:bold"" align=""center"">" skip
        "<TD colspan=""2"">Оплачено/Поставлено резидентом</TD>" skip
        "<TD colspan=""2"">Оплачено/поставлено нерезидентом</TD>" skip
      "</TR>" skip
      "<TR style=""font-size:x-small; font:bold"" align=""center"">" skip
        "<TD>Дата</TD>" skip
        "<TD>Валюта и сумма</TD>" skip
        "<TD>Дата</TD>" skip
        "<TD>Валюта и сумма</TD>" skip
      "</TR>" skip.

  for each t-docs where t-docs.licid = t-contrs.licid:
    put stream vcrpt unformatted 
      "<TR valign=""top"">" skip
          "<TD align=""center"">" if t-docs.data20 = ? then "&nbsp;" else string(t-docs.data20, "99/99/9999") "</TD>" skip
          "<TD align=""right"">" if t-docs.data20 = ? or t-docs.sum20 = 0 then "&nbsp;" else string(t-docs.sum20, "->>>,>>>,>>>,>>9.99") + "&nbsp;" + t-docs.crc20 "</TD>" skip
          "<TD align=""center"">" if t-docs.data30 = ? then "&nbsp;" else string(t-docs.data30, "99/99/9999") "</TD>" skip
          "<TD align=""right"">" if t-docs.data30 = ? or t-docs.sum30 = 0 then "&nbsp;" else string(t-docs.sum30, "->>>,>>>,>>>,>>9.99") + "&nbsp;" + t-docs.crc30  "</TD>" skip
      "</TR>" skip.
  end.

put stream vcrpt unformatted
    "</TD></TR></TABLE></P>" skip. 

    put stream vcrpt unformatted
    "<B>" skip
     "<P align=""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
     "Номер и дата ранее отправленных извещений по лицензии N " t-contrs.licnum  "</BR>" skip 
     "</FONT></P>" skip


  /* подписи */
  /*put stream vcrpt unformatted*/
    "<P><BR><B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
      string(day(g-today), ">9") "&nbsp;<U>&nbsp;" entry(month(g-today), v-monthname) "&nbsp;</U>&nbsp;" string(year(g-today), "9999") "&nbsp;г.<BR><BR>" skip
      v-kurpos " _________________________ "
      v-kurname "<BR><BR>" skip
      "Исполнитель _________________________ "
      v-ofcname "<BR><BR>" skip
      "АО ""TEXAKABANK""<BR>".

  if p-printbank then
    put stream vcrpt unformatted p-bankname skip.

  if p-printdep then
    put stream vcrpt unformatted "<BR>" p-depname skip.

  put stream vcrpt unformatted
    "</FONT></B></P>" skip.

  if t-contrs.licid <> v-liclast then put stream vcrpt unformatted "<BR style=""page-break-before:always"">" skip.
end.


{html-end.i " stream vcrpt "}


output stream vcrpt close.

unix silent value("cptwin " + p-filename + " winword").
pause 0.
