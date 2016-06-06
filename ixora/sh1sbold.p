/* sh1sbold.p
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

/* sh1sb.p
   Расшифровка к 1-СБ - вариант для сведения со старой 700: условные раскиданы по срочным

   13.05.2003 nadejda
*/

{mainhead.i}


def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-month as integer.
def var v-god as integer.

{vc-defdt.i}

update 
  v-dtb label " НАЧАЛЬНАЯ ДАТА ПЕРИОДА " format "99/99/9999" skip
  v-dte label "  КОНЕЧНАЯ ДАТА ПЕРИОДА " format "99/99/9999" 
  with centered row 5 side-label frame f-dt.

def new shared temp-table t-data
  field clnsts as integer
  field stroka as integer
  field itog as logical init no
  field kr as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field ost as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field kr% as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field ost% as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  index main is primary unique stroka clnsts.

def var v-sum as deci.
def var v-summa as deci.
def var v-gl as char.
def var i as integer.

def var v-strokaname as char extent 12 init
["Привлечено денег на счета вкладов юридических и физических лиц за отчетный период, всего",
 "до востребования",
 "срочные, всего",
 "краткосрочные",
 "долгосрочные",
 "Остатки денег на счетах вкладов юридических и физических лиц на конец отчетного периода, всего",
 "до востребования",
 "срочные, всего",
 "краткосрочные",
 "долгосрочные"].

/*
if not connected ("comm") then run conncom.

for each comm.txb where comm.txb.consolid = true and comm.txb.txb = 0 no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run sh1sbdat.p (comm.txb.bank).
end.
    
if connected ("ast")  then disconnect "ast".
*/


{r-branch.i &proc = "sh1sbolddat (comm.txb.bank)"}


/* итоговые суммы */
def buffer bt-data for t-data.

create t-data.
assign t-data.clnsts = 1
       t-data.stroka = 3
       t-data.itog = yes.
for each bt-data where bt-data.clnsts = t-data.clnsts and lookup(string(bt-data.stroka), "4,5") > 0:
  do i = 1 to 3:
    t-data.kr[i] = t-data.kr[i] + bt-data.kr[i].
    t-data.kr%[i] = t-data.kr%[i] + bt-data.kr%[i].
    t-data.ost[i] = t-data.ost[i] + bt-data.ost[i].
    t-data.ost%[i] = t-data.ost%[i] + bt-data.ost%[i].
  end.
end.

create t-data.
assign t-data.clnsts = 2
       t-data.stroka = 3
       t-data.itog = yes.
for each bt-data where bt-data.clnsts = t-data.clnsts and lookup(string(bt-data.stroka), "4,5") > 0:
  do i = 1 to 3:
    t-data.kr[i] = t-data.kr[i] + bt-data.kr[i].
    t-data.kr%[i] = t-data.kr%[i] + bt-data.kr%[i].
    t-data.ost[i] = t-data.ost[i] + bt-data.ost[i].
    t-data.ost%[i] = t-data.ost%[i] + bt-data.ost%[i].
  end.
end.

create t-data.
assign t-data.clnsts = 1
       t-data.stroka = 1
       t-data.itog = yes.
for each bt-data where bt-data.clnsts = t-data.clnsts and lookup(string(bt-data.stroka), "2,3") > 0:
  do i = 1 to 3:
    t-data.kr[i] = t-data.kr[i] + bt-data.kr[i].
    t-data.kr%[i] = t-data.kr%[i] + bt-data.kr%[i].
    t-data.ost[i] = t-data.ost[i] + bt-data.ost[i].
    t-data.ost%[i] = t-data.ost%[i] + bt-data.ost%[i].
  end.
end.

create t-data.
assign t-data.clnsts = 2
       t-data.stroka = 1
       t-data.itog = yes.
for each bt-data where bt-data.clnsts = t-data.clnsts and lookup(string(bt-data.stroka), "2,3") > 0:
  do i = 1 to 3:
    t-data.kr[i] = t-data.kr[i] + bt-data.kr[i].
    t-data.kr%[i] = t-data.kr%[i] + bt-data.kr%[i].
    t-data.ost[i] = t-data.ost[i] + bt-data.ost[i].
    t-data.ost%[i] = t-data.ost%[i] + bt-data.ost%[i].
  end.
end.



/* окончательный расчет % ставок */
for each t-data:
  do i = 1 to 3:
    if t-data.kr[i] > 0 then t-data.kr%[i] = t-data.kr%[i] / t-data.kr[i].
    if t-data.ost[i] > 0 then t-data.ost%[i] = t-data.ost%[i] / t-data.ost[i].
  end.
end.


/* Вывод расшифровки 1-СБ */
def var v-file as char init "sh1sbold.htm".
output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
  "<P align=""center"" style=""font:bold"">Расшифровка по вкладам клиентов в СКВ и ставках вознаграждения по ним</P>" skip
  "<P align=""left"" style=""font:bold"">за период c " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</P>" skip
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD rowspan=""3"">&nbsp;</TD>" skip
    "<TD rowspan=""3""><BR><BR><BR>Шифр<BR>строки</TD>" skip
    "<TD colspan=""6"">юридических лиц в валюте:</TD>" skip
    "<TD colspan=""6"">физических лиц в валюте:</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD colspan=""2"">Доллар США</TD>" skip
    "<TD colspan=""2"">ЕВРО</TD>" skip
    "<TD colspan=""2"">Другие виды СКВ</TD>" skip
    "<TD colspan=""2"">Доллар США</TD>" skip
    "<TD colspan=""2"">ЕВРО</TD>" skip
    "<TD colspan=""2"">Другие виды СКВ</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>взвешенная<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD>А</TD>" skip
    "<TD>Б</TD>" skip
    "<TD>1</TD>" skip
    "<TD>2</TD>" skip
    "<TD>3</TD>" skip
    "<TD>4</TD>" skip
    "<TD>5</TD>" skip
    "<TD>6</TD>" skip
    "<TD>7</TD>" skip
    "<TD>8</TD>" skip
    "<TD>9</TD>" skip
    "<TD>10</TD>" skip
    "<TD>11</TD>" skip
    "<TD>12</TD>" skip
  "</TR>" skip.

/* кредитовые поступления */
for each t-data:
  if t-data.clnsts = 1 then
    put unformatted "<TR>" skip
      "<TD>" v-strokaname[t-data.stroka] "</TD>" skip
      "<TD>" string(t-data.stroka, "99") "</TD>" skip.
  
  do i = 1 to 3:
    put unformatted 
      "<TD>" replace(string(t-data.kr[i] / 1000, ">>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
      "<TD>" replace(string(t-data.kr%[i], ">>>>>>>>>>>9.99"), ".", ",") "</TD>" skip.
  end.

  if t-data.clnsts = 2 then do:
    put unformatted "</TR>" skip.

    if t-data.itog then
      put unformatted 
        "<TR><TD>в том числе:</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>" skip
          "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip.
  end.
end.

/* остатки */
for each t-data:
  if t-data.clnsts = 1 then
    put unformatted "<TR>" skip
      "<TD>" v-strokaname[t-data.stroka + 5] "</TD>" skip
      "<TD>" string(t-data.stroka + 5, "99") "</TD>" skip.
  
  do i = 1 to 3:
    put unformatted 
      "<TD>" replace(string(t-data.ost[i] / 1000, ">>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
      "<TD>" replace(string(t-data.ost%[i], ">>>>>>>>>>>9.99"), ".", ",") "</TD>" skip.
  end.

  if t-data.clnsts = 2 then do:
    put unformatted "</TR>" skip.

    if t-data.itog then
      put unformatted 
        "<TR><TD>в том числе:</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD>" skip
          "<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>" skip.
  end.
end.

put unformatted 
  "</TABLE>" skip.

{html-end.i " "}
output close.
unix silent cptwin value(v-file) excel.



