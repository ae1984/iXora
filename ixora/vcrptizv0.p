/* vcrptizv0.p
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
       07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       02.04.2004 nadejda - добавлены колонки суммы в валюте контракта, валюты контракта и курса
       29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
       09/01/2006 nataly - изменила выбор ФИО директора РКО
*/

/* vcrptizv0.p - Валютный контроль 
   Извещение платежах по контракту - из временной таблицы в HTML

   10.11.2002 nadejda создан
*/

{vc.i}

{global.i}
{sum2str.i}

def input parameter p-typcon as char.

def shared var s-vcourbank as char.

def shared temp-table t-docsa 
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field crckod as char
  field sum like vcdocs.sum
  field sumret like vcdocs.sum
  field crckodk as char
  field sumk like vcdocs.sum
  field sumretk like vcdocs.sum
  field cursdoc-con as decimal
  field info as char
  field cifname as char
  field rnn as char
  field contrnum as char
  field psnum as char
  field partname as char.

def var v-dep2 as char.
def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-sumret as deci.
def var v-contrnum as char.
def var v-psnum as char.
def var v-cifname as char.
def var v-partnername as char.
def var v-numstr as integer.

def stream vcrpt.
output stream vcrpt to vcizv.htm.

if p-typcon = "i" then
  v-contrnum = "О ПРОВЕДЕННЫХ ПЛАТЕЖАХ ПО ИМПОРТНЫМ СДЕЛКАМ".
else 
  v-contrnum = "О ПОСТУПЛЕНИИ ВЫРУЧКИ ПО ЭКСПОРТНЫМ СДЕЛКАМ".

{html-title.i 
 &stream = " stream vcrpt "
 &title = " "
 &size-add = "xx-"
}


put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>ИЗВЕЩЕНИЕ<BR>" + v-contrnum + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

if p-typcon = "i" then
  put stream vcrpt unformatted 
     "<TR align=""center"" style=""font:bold"">" skip
       "<TD rowspan=2>N</TD>" skip
       "<TD rowspan=2>Импортер</TD>" skip
       "<TD rowspan=2>РНН</TD>" skip
       "<TD rowspan=2>Третье<br>лицо</TD>" skip
       "<TD rowspan=2>Контракт</TD>" skip
       "<TD rowspan=2>Паспорт сделки</TD>" skip
       "<TD rowspan=2>Экспортер</TD>" skip
       "<TD rowspan=2>Дата</TD>" skip
       "<TD colspan=2>Сумма оплач. импорта</TD>" skip
       "<TD colspan=2>Сумма возврата аванс. платежа</TD>" skip
       "<TD rowspan=2>Код валюты<br>платежа</TD>" skip
       "<TD rowspan=2>Код валюты<br>контракта</TD>" skip
       "<TD rowspan=2>Курс<br>пересчета</TD>" skip
       "<TD rowspan=2>Прим</TD>" skip
     "</TR>" skip.

else 
  put stream vcrpt unformatted 
     "<TR align=""center"" style=""font:bold"">" skip
       "<TD rowspan=2>N</TD>" skip
       "<TD rowspan=2>Экспортер</TD>" skip
       "<TD rowspan=2>РНН</TD>" skip
       "<TD rowspan=2>Третье<br>лицо</TD>" skip
       "<TD rowspan=2>Контракт</TD>" skip
       "<TD rowspan=2>Паспорт сделки</TD>" skip
       "<TD rowspan=2>Импортер</TD>" skip
       "<TD rowspan=2>Дата поступл./ возврата эксп. выручки</TD>" skip
       "<TD colspan=2>Сумма поступл. эксп. выручки</TD>" skip
       "<TD colspan=2>Сумма возврата аванс. платежа</TD>" skip
       "<TD rowspan=2>Код валюты<br>платежа</TD>" skip
       "<TD rowspan=2>Код валюты<br>контракта</TD>" skip
       "<TD rowspan=2>Курс<br>пересчета</TD>" skip
       "<TD rowspan=2>Прим</TD>" skip
     "</TR>" skip.

put stream vcrpt unformatted 
   "<TR align=""center"" style=""font:bold"">" skip
     "<TD>В валюте<br>платежа</TD>" skip
     "<TD>В валюте<br>контракта</TD>" skip
     "<TD>В валюте<br>платежа</TD>" skip
     "<TD>В валюте<br>контракта</TD>" skip
   "</TR>" skip.

v-numstr = 0.

                    
for each t-docsa by dndate by crckod by sum by sumret by docs:
  v-numstr = v-numstr + 1.
  find cif where string(cif.jss, "999999999999") = t-docsa.rnn no-lock no-error.
  if avail cif then v-dep2 = string(int(cif.jame) - 1000) .

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip 
      "<TD align=""left"">"  string(v-numstr)  "</TD>" skip
      "<TD align=""left"">"  t-docsa.cifname  "</TD>" skip
      "<TD align=""center"">"  t-docsa.rnn  "</TD>" skip
      "<TD align=""center"">&nbsp;</TD>" skip
      "<TD align=""left"">"  t-docsa.contrnum  "</TD>" skip
      "<TD align=""left"">"  t-docsa.psnum  "</TD>" skip
      "<TD align=""left"">"  t-docsa.partname  "</TD>" skip
      "<TD align=""center"">"  string(t-docsa.dndate, "99/99/9999")  "</TD>" skip
      "<TD align=""right"">"  sum2str(t-docsa.sum)  "</TD>" skip
      "<TD align=""right"">"  sum2str(t-docsa.sumk)  "</TD>" skip
      "<TD align=""right"">"  sum2str(t-docsa.sumret)  "</TD>" skip
      "<TD align=""right"">"  sum2str(t-docsa.sumretk)  "</TD>" skip
      "<TD align=""center"">"  t-docsa.crckod  "</TD>" skip
      "<TD align=""center"">"  t-docsa.crckodk  "</TD>" skip
      "<TD align=""right"">"  if t-docsa.cursdoc-con = 1 then "" else trim(string(t-docsa.cursdoc-con, ">>>>>>>>>>>>9.999999"))  "</TD>" skip
      "<TD align=""left"">"  t-docsa.info  "</TD>" skip
      "</TR>" skip.

end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip.

find bankl where bankl.bank = s-vcourbank no-lock no-error.

put stream vcrpt unformatted
  "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip
    bankl.name skip.


  if v-dep2 <> "" then do:
   find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .

  if avail codfr and codfr.name[1] <> "" then   /*if avail sysc then*/
  put stream vcrpt unformatted
    "<BR><BR>" + entry(2, trim(codfr.name[1])) + "<BR>" + entry(1, trim(codfr.name[1])) skip.
  end.
  else do:
   find sysc where sysc.sysc = "vc-dep" no-lock no-error.
    if avail sysc then
   put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.
  end.


put stream vcrpt unformatted
   "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcizv.htm iexplore").

pause 0.



