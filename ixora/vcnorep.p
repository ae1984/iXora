/* vcnorep.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет сверок кор.счетов по пунктам 15.3.4 и 5.3.8
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
        01/10/2004 saltanat
 * CHANGES
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09/11/2010 madiyar - убрал -H,-S
        29/11/2010 aigul - добавление полей cif, bank, ppname, ctype для талицы t-docsa
        29/11/2010 aigul - удаление полей cif, bank, ppname, ctype из талицы t-docsa
*/
{vc.i}

{global.i}
{comm-txb.i}
{sum2str.i}

def var s-vcourbank as char.

def new shared temp-table t-docsa
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field pcrc like vcdocs.pcrc
  field crckod as char
  field sum    like vcdocs.sum
  field sumret like vcdocs.sum
  field knp as char
  field kod14 as char
  field kod14a as char
  field p14sum6 as deci init 0.00
  field p14sum7 as deci init 0.00
  field p14sum9 as deci init 0.00
  field p14sum10 as deci init 0.00
  field p14sum11 as deci init 0.00
  field p14sum12 as deci init 0.00
  field p14sum13 as deci init 0.00
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field cttype as char
  field ctei as char
  field psnum as char
  field partname as char.

def var v-dtb as date.
def var v-dte as date.
def var i as integer.
def var v-numstr as integer.
def var v-strsum as char.
def var v-strsum0 as char.
def var v-strsumret as char.
def var v-reptype as char init "A".

def new shared temp-table t-remtrz
    field  remtrz   like remtrz.remtrz
    field  rdt      like remtrz.rdt
    field  amt      like vcdocs.sum
    field  sacc     like remtrz.sacc
    field  scif     like cif.cif
    field  scifname like cif.name
    field  tcrc     like remtrz.tcrc.

find last cls no-lock no-error.
if avail cls then do:
   v-dtb = cls.whn.
   v-dte = cls.whn.
end.

v-reptype = "A".
s-vcourbank = comm-txb().

/* Выбираем данные из базы ВК во временную таблицу */
/* коннект к текущему банку */
find txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
if connected ("txb") then disconnect "txb".
connect value(" -db " + replace(txb.path,"/data/","/data/b") + " -ld txb -U " + txb.login + " -P " + txb.password).

run vcreppldat (v-reptype, s-vcourbank, 0, v-dtb, v-dte, '1,5').

if connected ("txb") then disconnect "txb".


/* Выбираем данные из платежных систем во временную таблицу */

run plisx.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Сверка корр.счетов и п.15.3.4"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Сверка корреспондентских счетов и платежей ВК<BR>за дату " + string(v-dtb, "99/99/9999") + "</B></FONT></P>" skip
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Исходящие платежи, существующие в Прагме но не введенные в базу ВК</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Исходящие платежи, которых нет в Прагме. */
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>RMZ</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер счета отпр.</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Найменование клиента</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Валюта платежа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма платежа</B></FONT></TD>" skip
   "</TR>" skip.

for each t-remtrz no-lock.
    find first t-docsa where t-remtrz.tcrc = t-docsa.pcrc
                         and (t-remtrz.amt = t-docsa.sum or t-remtrz.amt = t-docsa.sumret) no-lock no-error.
    if avail t-docsa then do:
       delete t-docsa.
       delete t-remtrz.
    end.
    else do:
       put stream vcrpt unformatted
	   "<TR align=""center"">" skip
	     "<TD><FONT size=""2"">" + t-remtrz.remtrz + "</FONT></TD>" skip
	     "<TD><FONT size=""2"">" + t-remtrz.sacc   + "</FONT></TD>" skip
	     "<TD><FONT size=""2"">" + t-remtrz.scif   + "</FONT></TD>" skip
	     "<TD><FONT size=""2"">" + t-remtrz.scifname + "</FONT></TD>" skip
	     "<TD><FONT size=""2"">" + string(t-remtrz.tcrc)   + "</FONT></TD>" skip
	     "<TD><FONT size=""2"">" + string(t-remtrz.amt)    + "</FONT></TD>" skip
	   "</TR>" skip.
    end.
end.

put stream vcrpt unformatted
"</TABLE>" skip.

/* Платежи введенные в ВК, но не ушедшие с корр. счета */
put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Платежи введенные в базу ВК, но не ушедшие с корр. счета</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Импортер</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>РНН</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Трет лицо</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Контракт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Тип кон</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Паспорт сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма платежа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Экспортер</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Код вал</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>КНП</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пр 14</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пр 14 авт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прим</B></FONT></TD>" skip
   "</TR>" skip.

k:
for each t-docsa where t-docsa.ctei ne "e" and not (t-docsa.sumret <> 0) break by t-docsa.depart by t-docsa.dndate by t-docsa.crckod by t-docsa.sum
      by t-docsa.sumret by t-docsa.docs:
find t-remtrz where t-remtrz.tcrc = t-docsa.pcrc
                and t-remtrz.amt = t-docsa.sum no-lock no-error.
if avail t-remtrz then do:
   delete t-remtrz.
   delete t-docsa.
end.
else do:
  for each que where que.pid = "F" and que.con ne "F" no-lock.
  find remtrz where remtrz.remtrz = que.remtrz
                and remtrz.tcrc   = t-docsa.pcrc
                and remtrz.amt    = t-docsa.sum no-lock no-error.
  if avail remtrz then do:
     delete t-docsa.
     next k.
  end.
  end.

  if first-of(t-docsa.depart) then do:
    find ppoint where ppoint.depart = t-docsa.depart no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD colspan=""17""><FONT size=""2""><B>" + ppoint.name + "</B></FONT></TD></TR>" skip.
    v-numstr = 0.
  end.
  v-numstr = v-numstr + 1.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip
      "<TD align=""left"">" + string(v-numstr) + "</TD>" skip
      "<TD align=""left"">" + t-docsa.cifname + "</TD>" skip
      "<TD align=""center"">" + t-docsa.rnn + "</TD>" skip
      "<TD align=""center"">&nbsp;</TD>" skip
      "<TD align=""left"">" + t-docsa.contrnum + "</TD>" skip
      "<TD align=""center"">" + t-docsa.cttype + "</TD>" skip
      "<TD align=""left"">" + t-docsa.psnum + "</TD>" skip
      "<TD align=""center"">" + string(t-docsa.dndate, "99/99/99") + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-docsa.sum) + "</TD>" skip
      "<TD align=""left"">" + t-docsa.partname + "</TD>" skip
      "<TD align=""center"">" + t-docsa.crckod + "</TD>" skip
      "<TD align=""center"">" + t-docsa.knp + "</TD>" skip
      "<TD align=""center"">" + t-docsa.kod14 + "</TD>" skip
      "<TD align=""center"">" + t-docsa.kod14a + "</TD>" skip
      "<TD align=""left"">" + t-docsa.info + "</TD>" skip
      "</TR>" skip.

  if last-of(t-docsa.depart) then do:
    put stream vcrpt unformatted
      "<TR><TD colspan=""17"">&nbsp;</TD></TR>" skip.
  end.
end.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.

















































































