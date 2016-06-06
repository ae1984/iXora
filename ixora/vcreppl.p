/* vcreppl.p
 * MODULE
        Название Программного Модуля
        Валютный контроль
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Реестр платежей за период по всем контрактам по экспорту и/или импорту
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
        11.11.2002 nadejda
 * CHANGES
        24.05.2003 nadejda - убраны параметры -H -S из коннекта
        06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcreppldat.p
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09/11/2010 madiyar - убрал -H,-S
        22/11/2010 aigul - сделала отчет консолидированным и добавила поиск по типу контракта
        15/03/2012 id00810 - добавила v-bankname для печати
*/


{vc.i}

{global.i}
{comm-txb.i}
{sum2str.i}

def var s-vcourbank as char.
def var v-dep2  as char.


def new shared temp-table t-docsa
  field cif as char
  field bank as char
  field  ppname as char
  field docs like vcdocs.docs
  field dndate like vcdocs.dndate
  field pcrc like vcdocs.pcrc
  field crckod as char
  field sum like vcdocs.sum
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
def var v-cttype as char no-undo.
def var v-txbbank as char.
def var v-bankname as char no-undo.
form
  skip(1)
  v-dtb label " Начало периода " format "99/99/9999" skip
  v-dte label "  Конец периода " format "99/99/9999" skip(1)
  v-reptype label "  E) экспорт   I) импорт   A) все " format "x"
     validate(index("eEiIaA", v-reptype) > 0, "Неверный тип контракта !")
  "  " skip (1)
  v-cttype label "Тип конракта"  format "x(3)" validate (can-find(first codfr where codfr.codfr = 'vccontr' and codfr.code = v-cttype no-lock) or v-cttype = 'ALL', " Не верный тип контракта!") help " Введите код контракта (F2 - поиск)" skip
  with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.
v-cttype = 'ALL'.
v-dtb = g-today.
v-dte = g-today.
update v-dtb v-dte  v-reptype v-cttype with frame f-dt.

v-reptype = caps(v-reptype).
displ v-reptype with frame f-dt.

/*s-vcourbank = comm-txb().*/
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-vcourbank = trim(sysc.chval).
find first sysc where sysc.sysc = 'bankname' no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

def var v-sel as int.
def var v-banklist as char.
def var v-txblist as char.
def var v-bank as char.
v-banklist = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. ЦО | 2. Актобе | 3. Кустанай | 4. Тараз | 5. Уральск | 6. Караганда | 7. Семск | 8. Кокчетав | 9. Астана | 10. Павлодар | 11. Петропавловск | 12. Атырау | 13. Актау | 14. Жезказган | 15. Усть-Каман | 16. Чимкент | 17. Алматы".
v-txblist = "ALL,TXB00,TXB01,TXB02,TXB03,TXB04 ,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
v-sel = 0.
if s-vcourbank = "TXB00" then do:
    run sel2("ФИЛИАЛЫ",v-banklist,output v-sel).
    if v-sel > 0 then v-bank = entry(v-sel,v-txblist).
    else return.
    /* расчеты во временную таблицу */
    /* коннект к текущему банку */
    find first comm.txb where (comm.txb.bank = v-bank or v-bank = "ALL") and comm.txb.consolid = true no-lock no-error.
    if avail txb then run vcreppldat1 (v-reptype, v-bank, 0, v-dtb, v-dte, '1,5', v-cttype).
end.
if s-vcourbank <> "TXB00" then do:
    /* расчеты во временную таблицу */
    /* коннект к текущему банку */
    find first txb where txb.consolid = true and txb.bank = s-vcourbank no-lock no-error.
    if avail txb then run vcreppldat1 (v-reptype, s-vcourbank, 0, v-dtb, v-dte, '1,5', v-cttype).
end.
/* вывод отчета в HTML */

if s-vcourbank = "TXB00" then v-txbbank = 'АО ' + v-bankname.
if v-bank <> "TXB00" and s-vcourbank = "TXB00" then do:
    find first txb where txb.bank = v-bank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.
if s-vcourbank <> "TXB00" then do:
    find first txb where txb.bank = s-vcourbank no-lock no-error.
    if avail txb then v-txbbank = txb.info.
end.
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Реестр валютных переводов"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>РЕЕСТР ВАЛЮТНЫХ ПЕРЕВОДОВ<BR>за период с " + string(v-dtb, "99/99/9999") +
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>N</B></FONT></TD>" skip
     /*"<TD><FONT size=""2""><B>Bank</B></FONT></TD>" skip*/
     "<TD><FONT size=""2""><B>Импортер/Экспортер</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>РНН</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Трет лицо</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Контракт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>экс/ имп</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Тип кон</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Паспорт сделки</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма платежа</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма возврата аванс. платежа</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Получатель/Отправитель</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Код вал</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>КНП</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пр 14</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Пр 14 авт</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Прим</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted "<P><B><tr align=""left""><font size=""3"">" v-txbbank "</tr></B></FONT></P>" skip.
for each t-docsa /*break by t-docsa.depart t-docsa.ppname by t-docsa.dndate by t-docsa.crckod by t-docsa.sum
      by t-docsa.sumret by t-docsa.docs*/ no-lock:
      /*message t-docsa.ppname "-" t-docsa.depart view-as alert-box.*/
  /*if first-of(/t-docsa.depart/ t-docsa.ppname) then do:
    put stream vcrpt unformatted "<TR><TD colspan=""17""><FONT size=""2""><B>" + t-docsa.ppname + "</B></FONT></TD></TR>" skip.
    /find txb.ppoint where txb.ppoint.depart = v-pdepart no-lock no-error.
    put stream vcrpt unformatted "<TR><TD colspan=""17""><FONT size=""2""><B>" + ppoint.name + "</B></FONT></TD></TR>" skip./
    v-numstr = 0.
  end.*/
  v-numstr = v-numstr + 1.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip
      "<TD align=""left"">" + string(v-numstr) + "</TD>" skip
      /*"<TD align=""left"">" + t-docsa.bank + "</TD>" skip*/
      "<TD align=""left"">" + t-docsa.cifname + "</TD>" skip
      "<TD align=""center"">" + t-docsa.rnn + "</TD>" skip
      "<TD align=""center"">&nbsp;</TD>" skip
      "<TD align=""left"">" + t-docsa.contrnum + "</TD>" skip
      "<TD align=""center"">" + t-docsa.ctei + "</TD>" skip
      "<TD align=""center"">" + t-docsa.cttype + "</TD>" skip
      "<TD align=""left"">" + t-docsa.psnum + "</TD>" skip
      "<TD align=""center"">" + string(t-docsa.dndate, "99/99/99") + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-docsa.sum) + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-docsa.sumret) + "</TD>" skip
      "<TD align=""left"">" + t-docsa.partname + "</TD>" skip
      "<TD align=""center"">" + t-docsa.crckod + "</TD>" skip
      "<TD align=""center"">" + t-docsa.knp + "</TD>" skip
      "<TD align=""center"">" + t-docsa.kod14 + "</TD>" skip
      "<TD align=""center"">" + t-docsa.kod14a + "</TD>" skip
      "<TD align=""left"">" + t-docsa.info + "</TD>" skip
      "</TR>" skip.

 /* if last-of(/t-docsa.depart/ t-docsa.ppname) then do:
    put stream vcrpt unformatted
      "<TR><TD colspan=""17"">&nbsp;</TD></TR>" skip.
  end.*/
end.

put stream vcrpt unformatted
    "</TABLE>" skip
    "<BR><BR>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR><TD colspan=""9""><FONT size=""2""><B>Всего по вычисленным кодам 14</B></FONT></TD></TR>" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>ВСЕГО по П/С</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>6</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>7</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>9</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>10</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>11</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>12</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>13</B></FONT></TD>" skip
   "</TR>" skip.

def temp-table t-deps
  field depart as integer
  field name as char.

for each t-docsa where t-docsa.cttype = "1" and ((t-docsa.p14sum6 <> 0) or (t-docsa.p14sum7 <> 0) or
     (t-docsa.p14sum9 <> 0) or (t-docsa.p14sum10 <> 0) or (t-docsa.p14sum11 <> 0) or
     (t-docsa.p14sum12 <> 0) or (t-docsa.p14sum13 <> 0))
     break by t-docsa.depart by t-docsa.pcrc :
  if first-of(t-docsa.depart) then do:
    put stream vcrpt unformatted "<TR><TD colspan=""17""><FONT size=""2""><B>" + t-docsa.ppname + "</B></FONT></TD></TR>" skip.
    /*find ppoint where ppoint.depart = t-docsa.depart no-lock no-error.
    put stream vcrpt unformatted "<TR><TD colspan=""9""><FONT size=""2""><B>" + ppoint.name + "</B></FONT></TD></TR>" skip.*/
    create t-deps.
    t-deps.depart = t-docsa.depart.
    /*t-deps.name = ppoint.name.*/
    t-deps.name = t-docsa.ppname.
  end.

  accumulate t-docsa.p14sum6 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum7 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum9 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum10 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum11 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum12 (sub-total by t-docsa.depart by t-docsa.pcrc).
  accumulate t-docsa.p14sum13 (sub-total by t-docsa.depart by t-docsa.pcrc).

  if last-of(t-docsa.pcrc) then do:
    find ncrc where ncrc.crc = t-docsa.pcrc no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD align=""center"">" + ncrc.code + "</TD>" skip
      "<TD align=""right"">" +
          sum2str(
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum6) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum9) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum10) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum12) -
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum11)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum6)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum7)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum9)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum10)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum11)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum12)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum13)) + "</TD>" skip
   "</TR>" skip.
  end.
end.

put stream vcrpt unformatted
  "<TR><TD colspan=""9"">&nbsp;</TD></TR><TR><TD colspan=""9""><B>ВСЕГО ПО ОФИСУ</B></TD></TR>" skip.

for each t-docsa where t-docsa.cttype = "1" and ((t-docsa.p14sum6 <> 0) or (t-docsa.p14sum7 <> 0) or
     (t-docsa.p14sum9 <> 0) or (t-docsa.p14sum10 <> 0) or (t-docsa.p14sum11 <> 0) or
     (t-docsa.p14sum12 <> 0) or (t-docsa.p14sum13 <> 0))
     break by t-docsa.pcrc :

  accumulate t-docsa.p14sum6 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum7 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum9 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum10 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum11 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum12 (sub-total by t-docsa.pcrc).
  accumulate t-docsa.p14sum13 (sub-total by t-docsa.pcrc).

  if last-of(t-docsa.pcrc) then do:
    find ncrc where ncrc.crc = t-docsa.pcrc no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD align=""center"">" + ncrc.code + "</TD>" skip
      "<TD align=""right"">" +
          sum2str(
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum6) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum9) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum10) +
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum12) -
            (accum sub-total by t-docsa.pcrc t-docsa.p14sum11)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum6)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum7)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum9)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum10)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum11)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum12)) + "</TD>" skip
      "<TD align=""right"">" + sum2str((accum sub-total by t-docsa.pcrc t-docsa.p14sum13)) + "</TD>" skip
   "</TR>" skip.
  end.
end.

def temp-table t-summ
  field depart as integer
  field crc like ncrc.crc
  field summ as decimal init 0
  field sumkod as deci extent 13.


put stream vcrpt unformatted
  "<TR><TD colspan=""9"">&nbsp;</TD></TR>" skip
  "<TR><TD colspan=""9""><FONT size=""2""><B>Всего по кодам 14, проставленным в документах</B></FONT></TD></TR>" skip.

put stream vcrpt unformatted
  "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>ВСЕГО по П/С</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>6</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>7</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>9</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>10</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>11</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>12</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>13</B></FONT></TD>" skip
  "</TR>" skip.

v-strsum = "6,06,7,07,8,08,9,09,10,11,12,13".
v-strsum0 = "6,7,9,10,11,12,13".

for each t-deps :
  for each t-docsa where t-docsa.depart = t-deps.depart and
         lookup(t-docsa.kod14, "6,06,7,07,8,08,9,09,10,12") > 0 break by t-docsa.pcrc :
    accumulate t-docsa.sum (sub-total by t-docsa.pcrc).
    if last-of(t-docsa.pcrc) then do:
      create t-summ.
      t-summ.depart = t-deps.depart.
      t-summ.crc = t-docsa.pcrc.
      t-summ.summ = (accum sub-total by t-docsa.pcrc t-docsa.sum).
    end.
  end.

  for each t-docsa where t-docsa.depart = t-deps.depart and
       t-docsa.kod14 = "11" break by t-docsa.pcrc :
    accumulate t-docsa.sum (sub-total by t-docsa.pcrc).
    if last-of(t-docsa.pcrc) then do:
      find t-summ where t-summ.depart = t-deps.depart and t-summ.crc = t-docsa.pcrc no-error.
      if not avail t-summ then do:
        create t-summ.
        t-summ.depart = t-deps.depart.
        t-summ.crc = t-docsa.pcrc.
      end.
      t-summ.summ = t-summ.summ - (accum sub-total by t-docsa.pcrc t-docsa.sum).
    end.
  end.

  for each t-docsa where t-docsa.depart = t-deps.depart and lookup(t-docsa.kod14, v-strsum) > 0
        break by t-docsa.pcrc by integer(t-docsa.kod14):
    if first-of(t-docsa.pcrc) then do:
      find t-summ where t-summ.depart = t-deps.depart and t-summ.crc = t-docsa.pcrc no-error.
      if not avail t-summ then do:
        create t-summ.
        t-summ.depart = t-deps.depart.
        t-summ.crc = t-docsa.pcrc.
      end.
    end.

    accumulate t-docsa.sum + t-docsa.sumret (sub-total by t-docsa.pcrc by integer(t-docsa.kod14)).

    if last-of(integer(t-docsa.kod14)) then
      assign t-summ.sumkod[integer(t-docsa.kod14)] =
        (accum sub-total by integer(t-docsa.kod14) t-docsa.sum + t-docsa.sumret).
  end.


  put stream vcrpt unformatted
    "<TR><TD colspan=""9""><FONT size=""2""><B>" + t-deps.name + "</B></FONT></TD></TR>" skip.

  for each t-summ where t-summ.depart = t-deps.depart break by t-summ.crc :
    if first-of(t-summ.crc) then do:
      find ncrc where ncrc.crc = t-summ.crc no-lock no-error.
      put stream vcrpt unformatted
        "<TR><TD align=""center"">" + ncrc.code + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-summ.summ) + "</TD>" skip.
    end.

    do i = 6 to 13:
      if lookup(string(i), v-strsum0) > 0 then
        put stream vcrpt unformatted "<TD align=""right"">" + sum2str(t-summ.sumkod[i]) + "</TD>" skip.
    end.

    if last-of(t-summ.crc) then
      put stream vcrpt unformatted "</TR>" skip.
  end.
end.


put stream vcrpt unformatted
  "<TR><TD>&nbsp;</TD></TR><TR><TD colspan=""9""><B>ВСЕГО ПО ОФИСУ</B></TD></TR>" skip.

for each t-summ break by t-summ.crc :
  if first-of(t-summ.crc) then do:
    find ncrc where ncrc.crc = t-summ.crc no-lock no-error.
    put stream vcrpt unformatted
      "<TR><TD align=""center"">" + ncrc.code + "</TD>" skip
      "<TD align=""right"">" + sum2str(t-summ.summ) + "</TD>" skip.
  end.

  accumulate t-summ.sumkod[6] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[7] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[9] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[10] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[11] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[12] (sub-total by t-summ.crc).
  accumulate t-summ.sumkod[13] (sub-total by t-summ.crc).


  if last-of(t-summ.crc) then
    put stream vcrpt unformatted
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[6]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[7]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[9]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[10]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[11]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[12]) + "</TD>" skip
      "<TD align=""right"">" + sum2str(accum sub-total by t-summ.crc t-summ.sumkod[13]) + "</TD>" skip
    "</TR>" skip.
end.

put stream vcrpt unformatted
    "</TABLE><BR><BR><P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" skip.

find bankl where bankl.bank = s-vcourbank no-lock no-error.
if avail bankl then
  put stream vcrpt unformatted bankl.name skip.

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.*/

  find cif where string(cif.jss, "999999999999") = t-docsa.rnn no-lock no-error.
  if avail cif then  v-dep2 = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .
  if avail codfr and codfr.name[1] <> "" then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(2, trim(codfr.name[1])) + "<BR>" + entry(1, trim(codfr.name[1])) skip.


put stream vcrpt unformatted
  "</B></FONT></P>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.


