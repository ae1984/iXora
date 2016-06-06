/* ptrko.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по принятым платежам за период в разрезе видов платежей (ARP)
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
        11/05/05 kanat
 * CHANGES
        12/05/05 kanat   - добавил разделение налоговых платежей на обычные, таможенные и паспортные
        02/05/05 kanat   - добавил обработку новой temp-table ttax2 для налогов ОМП
        05/09/05 kanat   - переделал обработку коммунальных платежей
        12/12/05 marinav - добавила КБК = 106105
        05/07/06 u00121  - убрал lookup  из  условий поиска, проставил no-undo
        01/08/2006 Evgeniy u00568 - переделал всвязи с тем, что пенсионные отправляются в ГЦВП
*/


{global.i}
{get-dep.i}
{comm-txb.i}

def var seltxb as int no-undo.
seltxb = comm-cod().

def var v-date-begin as date no-undo.
def var v-date-fin as date no-undo.
def var v-dt as date no-undo.

define temp-table ttax no-undo like tax
    field dep like ppoint.depart
    field name like commonls.bn.

define temp-table ttax1 no-undo like tax
    field dep like ppoint.depart
    field name like commonls.bn.

define temp-table ttax2 no-undo like tax
    field dep like ppoint.depart
    field name like commonls.bn.

define temp-table tcommpl no-undo like commonpl
    field name as char
    field prc as decimal.

define temp-table tcommpl1 no-undo like commonpl
    field name as char.

define temp-table payment2 no-undo like p_f_payment.
define temp-table payment1 no-undo like p_f_payment.
define temp-table almpay no-undo like almatv.

def var v-sum1 as decimal no-undo.
def var v-sum2 as decimal no-undo.
def var v-sum3 as decimal no-undo.
def var v-sum4 as decimal no-undo.


def var dlm as char init "|" no-undo.

def var v-report-name as char no-undo.
def var usrnm as char no-undo.
def var v-grp as char no-undo.
def var v-sum as decimal no-undo.

def var v-grps as char no-undo.
v-grps = "1,3,4,5,6,7,8,9".

def var v-kbks as char init "105102,105105,105106,105107,105241,105242,105243,105244,105245,105246,105247,105248,105249,105250,105251,105255,105258,105259,105260,105261,105269,105270,105271,105272,105273,105274,105275,105276,105277,105278,105279,105280,105281,105283,105284,105285,105286,105287,105402,106101,106102,106103,106104,106105,106201,106202,106203,106204,203101" no-undo.
def var v-ompkbks as char init "108104,108105,108106,108107,108108,108110,108111" no-undo.

def temp-table ttmps no-undo
    field grp as integer
    field arp as char
    field type as integer
    field kol as decimal
    field sum as decimal
    field comsum as decimal
    field name as char
    field sumprc as decimal
    index idx-ttmps type arp.

v-date-begin = g-today.
v-date-fin = v-date-begin.

update v-date-begin format '99/99/9999' label " Начальная дата "
       v-date-fin format '99/99/9999' label " Конечная дата "
with centered frame df.

def var i as int no-undo.
def var v-grpi as int no-undo.
def var pens_or_soc like commonpl.abk.

/* Коммунальные платежи */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Коммунальные платежи"  skip.
  put  unformatted fill("*",80) skip.
output close.
do v-dt = v-date-begin to v-date-fin:
  do i = 1 to num-entries(v-grps):
    v-grpi = int(entry(i,v-grps)).
    for each commonpl where commonpl.txb = seltxb   and commonpl.date = v-dt and
          commonpl.deluid = ?   and commonpl.grp = v-grpi no-lock.
      find first commonls where commonls.txb = seltxb and commonls.grp = commonpl.grp and commonls.type = commonpl.type and commonls.visible = yes no-lock no-error.
      if avail commonls then
      do:
        create tcommpl.
        buffer-copy commonpl to tcommpl.
        assign
          tcommpl.name = commonls.bn
          tcommpl.prc = commonls.comprc.
      end.
    end.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each tcommpl no-lock break by tcommpl.arp.
  accumulate tcommpl.sum (sub-count by tcommpl.arp).
  accumulate tcommpl.sum (sub-total by tcommpl.arp).
  accumulate tcommpl.comsum (sub-total by tcommpl.arp).
  if last-of (tcommpl.arp) then
  do:
    create ttmps.
    assign
      ttmps.type = 1
      ttmps.arp  = tcommpl.arp
      ttmps.grp  = tcommpl.grp
      ttmps.kol  = (accum sub-count by tcommpl.arp tcommpl.sum)
      ttmps.sum  = (accum sub-total by tcommpl.arp tcommpl.sum)
      ttmps.comsum = (accum sub-total by tcommpl.arp tcommpl.comsum)
      ttmps.name = tcommpl.name
      ttmps.sumprc = (accum sub-total by tcommpl.arp tcommpl.sum) * tcommpl.prc.
  end.
end.


/* Социальные платежи */
do i = 1 to 2:
  for each tcommpl1 exclusive-lock:
    delete tcommpl1.
  end.

  output  to "ptrko.log" append.
    put  unformatted fill("*",80) skip.
    put  unformatted string(time, "HH:MM:SS") + " Социальные платежи"  skip.
    put  unformatted fill("*",80) skip.
  output close.

  do v-dt = v-date-begin to v-date-fin:
    for each commonpl where commonpl.txb = seltxb and commonpl.date = v-dt and commonpl.deluid = ? and commonpl.grp = 15 no-lock.
      if   ( i = 1  /*пен*/ and commonpl.abk = 1)
        or ( i = 2  /*соц*/ and commonpl.abk <> 1) then do:
        create tcommpl1.
        buffer-copy commonpl to tcommpl1.
      end.
    end.
  end.

  output  to "ptrko.log" append.
    put  unformatted string(time, "HH:MM:SS") skip.
  output close.

  for each tcommpl1 no-lock break by tcommpl1.arp.
    accumulate tcommpl1.sum (sub-count by tcommpl1.arp).
    accumulate tcommpl1.sum (sub-total by tcommpl1.arp).
    accumulate tcommpl1.comsum (sub-total by tcommpl1.arp).

    if last-of (tcommpl1.arp) then
    do:
      find first commonls where commonls.txb = seltxb and commonls.grp = tcommpl1.grp and commonls.arp = tcommpl1.arp and commonls.visible = no no-lock no-error.
      if avail commonls then
      do:
        create ttmps.
        if i = 1 then
          assign
            ttmps.type = 9
            ttmps.name = "Пенсионные платежи".
        else
          assign
            ttmps.type = 8
            ttmps.name = "Социальные платежи".

        assign
          ttmps.arp  = tcommpl1.arp
          ttmps.grp  = tcommpl1.grp
          ttmps.kol  = (accum sub-count by tcommpl1.arp tcommpl1.sum)
          ttmps.sum  = (accum sub-total by tcommpl1.arp tcommpl1.sum)
          ttmps.comsum = (accum sub-total by tcommpl1.arp tcommpl1.comsum)

          ttmps.sumprc = (accum sub-total by tcommpl1.arp tcommpl1.sum) * commonls.comprc.
      end.
    end.
  end.
  output  to "ptrko.log" append.
    put  unformatted string(time, "HH:MM:SS") skip.
  output close.
end.

/* Налоговые платежи */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Налоговые платежи"  skip.
  put  unformatted fill("*",80) skip.
output close.

do v-dt = v-date-begin to v-date-fin:
  for each tax where tax.txb = seltxb and tax.date = v-dt and tax.duid = ? no-lock.
    if (lookup(string(tax.kb), v-kbks) = 0 and lookup(string(tax.kb), v-ompkbks) = 0) then
    do:
      create ttax.
      buffer-copy tax to ttax.
    end.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each ttax no-lock.
  accumulate ttax.sum (count).
  accumulate ttax.sum (total).
  accumulate ttax.comsum (total).
end.

create ttmps.
assign
  ttmps.type = 2
  ttmps.kol = (accum count ttax.sum)
  ttmps.sum = (accum total ttax.sum)
  ttmps.comsum = (accum total ttax.comsum)
  ttmps.name = "Налоги ".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.


/* Налоговые (таможенные) платежи */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Налоговые (таможенные) платежи "  skip.
  put  unformatted fill("*",80) skip.
output close.

def var v-kbki as int no-undo.
do v-dt = v-date-begin to v-date-fin:
  do i = 1 to num-entries(v-kbks):
    v-kbki = int(entry(i,v-kbks)).
    for each tax where tax.txb = seltxb and tax.date = v-dt and tax.kb = v-kbki and tax.duid = ? no-lock.
      create ttax1.
      buffer-copy tax to ttax1.
    end.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each ttax1 no-lock.
  accumulate ttax1.sum (count).
  accumulate ttax1.sum (total).
  accumulate ttax1.comsum (total).
end.

create ttmps.
assign
  ttmps.type = 3
  ttmps.kol = (accum count ttax1.sum)
  ttmps.sum = (accum total ttax1.sum)
  ttmps.comsum = (accum total ttax1.comsum)
  ttmps.name = "Налоги (таможенные) ".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

/* Налоговые (паcпортные) платежи */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Налоговые (паcпортные) платежи "  skip.
  put  unformatted fill("*",80) skip.
output close.

do v-dt = v-date-begin to v-date-fin:
  do i = 1 to num-entries(v-ompkbks):
    v-kbki = int(entry(i,v-ompkbks)).
    for each tax where tax.txb = seltxb and tax.date = v-dt and tax.kb = v-kbki and tax.duid = ? no-lock.
      create ttax2.
      buffer-copy tax to ttax2.
    end.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each ttax2 no-lock.
  accumulate ttax2.sum (count).
  accumulate ttax2.sum (total).
  accumulate ttax2.comsum (total).
end.

create ttmps.
assign
  ttmps.type = 4
  ttmps.kol = (accum count ttax2.sum)
  ttmps.sum = (accum total ttax2.sum)
  ttmps.comsum = (accum total ttax2.comsum)
  ttmps.name = "Налоги (паспортные) ".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

/* В пенсионные фонды платежи  */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " В пенсионные фонды платежи "  skip.
  put  unformatted fill("*",80) skip.
output close.

do v-dt = v-date-begin to v-date-fin:
  for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-dt and p_f_payment.deluid = ? and p_f_payment.cod <> 400 no-lock.
    create payment1.
    buffer-copy p_f_payment to payment1.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each payment1 no-lock.
  accumulate payment1.amt (count).
  accumulate payment1.amt (total).
  accumulate payment1.comiss (total).
end.

create ttmps.
assign
  ttmps.type = 5
  ttmps.kol = (accum count payment1.amt)
  ttmps.sum = (accum total payment1.amt)
  ttmps.comsum = (accum total payment1.comiss)
  ttmps.name = "В пенсионные фонды платежи".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.


/* Пенсионные платежи (прочие) */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Пенсионные платежи (прочие) "  skip.
  put  unformatted fill("*",80) skip.
output close.

do v-dt = v-date-begin to v-date-fin:
  for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-dt and p_f_payment.deluid = ? and p_f_payment.cod = 400 no-lock.
    create payment2.
    buffer-copy p_f_payment to payment2.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each payment2 no-lock.
  accumulate payment2.amt (count).
  accumulate payment2.amt (total).
  accumulate payment2.comiss (total).
end.

create ttmps.
assign
  ttmps.type = 6
  ttmps.kol = (accum count payment2.amt)
  ttmps.sum = (accum total payment2.amt)
  ttmps.comsum = (accum total payment2.comiss)
  ttmps.name = "Пенсионные (прочие) платежи".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.


/* Платежи АЛМАТВ */
output  to "ptrko.log" append.
  put  unformatted fill("*",80) skip.
  put  unformatted string(time, "HH:MM:SS") + " Платежи АЛМАТВ "  skip.
  put  unformatted fill("*",80) skip.
output close.

do v-dt = v-date-begin to v-date-fin:
  for each almatv where almatv.txb = seltxb and almatv.dtfk = v-dt and almatv.deluid = ? no-lock.
    create almpay.
    buffer-copy almatv to almpay.
  end.
end.

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.

for each almpay no-lock.
  accumulate almpay.summfk (count).
  accumulate almpay.summfk (total).
  accumulate almpay.cursfk (total).
end.

create ttmps.
assign
  ttmps.type = 7
  ttmps.kol = (accum count almpay.summfk)
  ttmps.sum = (accum total almpay.summfk)
  ttmps.comsum = (accum total almpay.cursfk)
  ttmps.name = "Платежи АЛМАТВ".

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.


/*Формирование файла отчета*************************************************************************************************************************************************************************************************/
find first ttmps no-lock no-error.
if available ttmps then
do:
  output to ptrko.xls.
  {html-start.i " "}

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then
    usrnm = ofc.name.
  else
    usrnm = "UNKNOWN".

  put unformatted
    "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
    "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
    "Анализ платежей без открытия банковского счета (по видам платежей) c " string(v-date-begin) " по " string(v-date-fin) "<BR><BR>" skip
    "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
    "<TR bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip.

  put unformatted
    "<TD><FONT size=""2""><B>Вид платежа</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Комиссия с организации</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Кол-во</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Сумма в тенге</B></FONT></TD>"  skip
    "<TD><FONT size=""2""><B>Комиссия с клиента в тенге</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Комиссия с организации в тенге</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Общая сумма комиссии в тенге</B></FONT></TD>" skip
    "</TR>".

  for each ttmps where ttmps.type = 1 no-lock break by ttmps.arp.

    accumulate ttmps.kol (sub-total by ttmps.arp).
    accumulate ttmps.sum (sub-total by ttmps.arp).
    accumulate ttmps.comsum (sub-total by ttmps.arp).
    accumulate ttmps.sumprc (sub-total by ttmps.arp).

    v-sum1 = v-sum1 + ttmps.kol.
    v-sum2 = v-sum2 + ttmps.sum.
    v-sum3 = v-sum3 + ttmps.comsum.
    v-sum4 = v-sum4 + ttmps.sumprc.

    if last-of(ttmps.arp) then
    do:
      find first commonls where commonls.txb = seltxb and commonls.arp = ttmps.arp and commonls.grp = ttmps.grp no-lock no-error.
      if avail commonls then
      do:
        put unformatted "<TR><TD>" commonls.bn "</TD>" skip
            "<TD>" replace(trim(string(commonls.comprc)), ".", ",") "</TD>" skip
            "<TD>" replace(trim(string((accum sub-total by ttmps.arp ttmps.kol))), ".", ",") "</TD>" skip
            "<TD>" replace(trim(string((accum sub-total by ttmps.arp ttmps.sum))), ".", ",") "</TD>" skip
            "<TD>" replace(trim(string((accum sub-total by ttmps.arp ttmps.comsum))), ".", ",") "</TD>" skip
            "<TD>" replace(trim(string((accum sub-total by ttmps.arp ttmps.sumprc))), ".", ",") "</TD>" skip
            "<TD><B>" replace(trim(string(((accum sub-total by ttmps.arp ttmps.comsum) + (accum sub-total by ttmps.arp ttmps.sumprc)))), ".", ",") "</B></TD></TR>" skip.
      end.
    end.
  end.

  for each ttmps where ttmps.type <> 1 no-lock break by ttmps.type.

    accumulate ttmps.kol (sub-total by ttmps.type).
    accumulate ttmps.sum (sub-total by ttmps.type).
    accumulate ttmps.comsum (sub-total by ttmps.type).

    v-sum1 = v-sum1 + ttmps.kol.
    v-sum2 = v-sum2 + ttmps.sum.
    v-sum3 = v-sum3 + ttmps.comsum.
    v-sum4 = v-sum4 + ttmps.sumprc.

    if last-of(ttmps.type) then
    do:
      put unformatted "<TR bgcolor=""#C0C0C0""><TD>" ttmps.name "</TD>" skip
          "<TD>" 0 "</TD>" skip
          "<TD>"  replace(trim(string((accum sub-total by ttmps.type ttmps.kol))), ".", ",") "</TD>" skip
          "<TD>"  replace(trim(string((accum sub-total by ttmps.type ttmps.sum))), ".", ",") "</TD>" skip
          "<TD>"  replace(trim(string((accum sub-total by ttmps.type ttmps.comsum))), ".", ",") "</TD>" skip
          "<TD>" 0 "</TD>" skip
          "<TD><B>"  replace(trim(string((accum sub-total by ttmps.type ttmps.comsum))), ".", ",") "</B></TD></TR>" skip.
    end.
  end.

  put unformatted "<TR bgcolor=""#C0C0C0""><TD>" "</TD>" skip
      "<TD><B> ВСЕГО </B></TD>" skip
      "<TD><B>" replace(trim(string(v-sum1)), ".", ",") "</B></TD>" skip
      "<TD><B>" replace(trim(string(v-sum2)), ".", ",") "</B></TD>" skip
      "<TD><B>" replace(trim(string(v-sum3)), ".", ",") "</B></TD>" skip
      "<TD><B>" replace(trim(string(v-sum4)), ".", ",") "</B></TD>" skip
      "<TD><B>" replace(trim(string((v-sum3 + v-sum4))), ".", ",") "</B></TD></TR>" skip.

  {html-end.i " "}
  output close.

  unix silent cptwin ptrko.xls excel.
  pause 0.
end. /* if avail ttmps then ... */
else
do:
  message "Платежей не найдено" view-as alert-box title "Внимание".
  return.
end.
/*Формирование файла отчета*************************************************************************************************************************************************************************************************/

output  to "ptrko.log" append.
  put  unformatted string(time, "HH:MM:SS") skip.
output close.
