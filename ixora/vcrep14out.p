/* vcrep14out.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 14 
        Вывод временной таблицы в Excel
 * RUN
        
 * CALLER
        vcrep14.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-5-2, 15-4-x-2
 * AUTHOR
        04.11.2002 nadejda
 * CHANGES
        18.01.2004 nadejda - вывод 3 и 4 строки изменен в соответствии с новым форматом отчета
        20.01.2004 nadejda - по новой форме не надо строку 2 
        13.02.2004 nadejda - ничего подобного, строка 2 все равно требуется!
        08.07.2004 saltanat - включен shared переменная v-contrtype для того чтобы для отчета Приложения 14-1 выводить 
                   данные только по экспорту.
*/


{vc.i}

{global.i}

def input parameter p-filename as char.
def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-contrtype as char.

def shared temp-table t-rep14
  field kodstr as integer
  field expsum as deci
  field expsumkzt as deci
  field impsum as deci
  field impsumkzt as deci
  index kodstr is primary unique kodstr.


def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtcurs as date.
def var v-kurname as char.
def var v-kurpos as char.
def var v-depname as char.
def var v-deppos as char.

def var v-monthname as char init 
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-stroka14 as char extent 14 init 
   ["Количество оформленных паспортов сделок в отчетном периоде (штук)",
   "Общая сумма по оформленным в отчетном периоде паспортам сделок",
   "Общая сумма задолженности нерезидента перед резидентом по паспортам сделок на конец отчетного периода",
   "Общая сумма задолженности резидента перед нерезидентом по паспортам сделок на конец отчетного периода",
   "Фактически оплачено/получено резидентом платежей за отчетный период",
   "1) авансовые платежи (предоплата),<BR>из них:",
   "&nbsp;&nbsp;авансовые платежи, по которым поставка товаров не была осуществлена до конца отчетного периода",
   "2) платежи после отгрузки товаров,<BR>из них",
   "&nbsp;&nbsp;платежи против поставок товаров в предыдущие отчетные периоды",
   "&nbsp;&nbsp;платежи против поставок товаров в текущем отчетном периоде",
   "3) возврат ранее переведенных денег",
   "4) иные поступления",
   "Фактически оплачено/получено платежей по документарным формам расчетов за отчетный период",
   "Просроченная сумма задолженности нерезидента перед резидентом по паспортам сделок на конец отчетного периода"].

def var v-stroka141 as char extent 14 init 
   ["Количество оформленных за отчетный период паспортов сделок(штук)",
   "Общая сумма по оформленным в отчетном периоде паспортам сделок",
   "Общая сумма задолженности нерезидента перед резидентом по паспортам сделок на конец отчетного периода",
   "Общая сумма задолженности резидента перед нерезидентом по паспортам сделок на конец отчетного периода",
   "Фактически получено резидентом платежей за отчетный период",
   "1) авансовые платежи (предоплата)<BR>из них:",
   "&nbsp;&nbsp;авансовые платежи, по которым поставка товаров не была осуществлена до конца отчетного периода",
   "2) платежи после отгрузки товаров,<BR>из них",
   "&nbsp;&nbsp;платежи против поставок товаров в предыдущие отчетные периоды",
   "&nbsp;&nbsp;платежи против поставок товаров в текущем отчетном периоде",
   "3) возврат ранее переведенных денег",
   "4) иные поступления",
   "Фактически получено резидентом платежей по документарным формам расчетов за отчетный период",
   "Просроченная сумма задолженности нерезидента перед резидентом по паспортам сделок на конец отчетного периода"].

def stream vcrpt.
output stream vcrpt to value(p-filename).

function sum2str returns char (p-kod as integer, p-value as decimal).
  def var v-sumstr as char.
  if p-value <> 0 then do:
    if p-kod = 1 then v-sumstr = trim(string(integer(p-value), ">>>>>>>>>>>>>>9")).
    else v-sumstr = replace(trim(string(p-value, "->>>>>>>>>>>>>>9.99")), ".", ",").
  end.
  else v-sumstr = "&nbsp;".
  return v-sumstr.
end.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "АО ""TEXAKABANK"". Приложение 14"
 &size-add = "x-"
}

if p-contrtype <> "5" then do:
put stream vcrpt unformatted 
   "<B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""center"">"
     "Приложение 14</P>"
     "<FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""center"">"
     "<P align=""right""><I>к Инструкции об организации экспортно-импортного валютного<BR>"
     "контроля в Республике Казахстан, утвержденной постановлением<BR>"
     "Правления Национального Банка Республики Казахстан N 343<BR>"
     "от 05.09.2001г. и приказом Министра государственных доходов<BR>"
     "Республики Казахстан N 1409 от 10.10.2001г.</I></P></FONT>" skip
     "<P align = ""center"">" skip
       "за " + entry(v-month, v-monthname) + " "
        string(v-god, "9999") + " года</P></FONT></B>" skip
   "<P align = ""right""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
     "тыс. долл. США</FONT></P>"
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Показатели</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Код строки</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>Экспорт</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>Импорт</B></FONT></TD>" skip
   "</TR>" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>Всего</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в том числе<BR>платежи в тенге</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Всего</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в том числе<BR>платежи в тенге</B></FONT></TD>" skip
   "</TR>" skip.

for each t-rep14:
  /* 20.01.2004 nadejda - по новой форме не надо строку 2 */
/*  if t-rep14.kodstr = 2 then next.*/

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" + v-stroka14[t-rep14.kodstr] + "</TD>" skip
      "<TD align=""center"">&nbsp;" + string(t-rep14.kodstr, "99") + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.expsum) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.expsumkzt) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.impsum) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.impsumkzt) + "</TD>" skip
    "</TR>" skip.
end.
end.
else do:
put stream vcrpt unformatted 
   "<B><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""center"">"
     "Приложение 14-1</P>"
     "<FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""center"">"
     "<P align=""right""><I>к Инструкции об организации<BR>"
     "экспортно-импортного валютного контроля<BR>"
     "в Республике Казахстан</I></P></FONT>" skip
     "<P align = ""center""> Информация о результатах экспортного валютного контроля<BR>" 
                            "по экспорту отдельных товаров<BR>"
       "за " + entry(v-month, v-monthname) + " "
        string(v-god, "9999") + " года</P>"
     "<P align = ""left""> АО ""TEXAKABANK"" </P></FONT></B>" skip
   "<P align = ""right""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
     "тысяч долларов США</FONT></P>"
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Показатели</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Код строки</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>Экспорт</B></FONT></TD>" skip
   "</TR>" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>Всего</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>в том числе<BR>платежи в тенге</B></FONT></TD>" skip
   "</TR>" skip.

for each t-rep14:
  /* 20.01.2004 nadejda - по новой форме не надо строку 2 */
/*  if t-rep14.kodstr = 2 then next.*/

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD>" + v-stroka141[t-rep14.kodstr] + "</TD>" skip
      "<TD align=""center"">&nbsp;" + string(t-rep14.kodstr, "99") + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.expsum) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-rep14.kodstr, t-rep14.expsumkzt) + "</TD>" skip
    "</TR>" skip.
end.
end.

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

find ofc where ofc.ofc = g-ofc no-lock no-error.

find first cmp no-lock no-error.

put stream vcrpt unformatted
  "</TABLE>" skip
  "<BR><BR>" skip
  "<B><P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" +
     v-kurpos + " _________________________ " +
     v-kurname + "<BR><BR>" skip
     v-deppos + " _________________________ " +
     v-depname + "<BR><BR>" skip
     cmp.name skip.

if p-printbank and cmp.code = 0 then
  put stream vcrpt unformatted "<BR>" + entry(1, cmp.addr[1]).

if p-printdep then 
  put stream vcrpt unformatted "<BR>" + p-depname.

put stream vcrpt unformatted
  "</FONT></P></B>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin " + p-filename + " excel").

pause 0.

