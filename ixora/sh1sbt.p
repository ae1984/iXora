/* sh1sbt.p
 * MODULE
	Финансовые отчеты
 * DESCRIPTION
	формирование расшифровки СКВ по 1СБт
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        8-2-14-4
 * AUTHOR
        18/02/2004 valery
 * CHANGES
	05/08/2004 valery
		запретил вывод в поля "других видах валют", раньше туда выводились рубли, но они оказывается не являются СКВ, на всякий случай
		я не убрал код который собирает рубли, а просто вывожу вместо данных пустые строки, может в будующем понадобится :)
	15/12/2005 nataly добавила филиал в г.Актобе
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09.10.2006 u00600 - изменила выбор филиалов r-brfilial.i
        29.02.2012 Lyubov - воспользовалась кодом 05/08/2004 valery, оставленным для подобного случая
*/




{mainhead.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-month as integer.
def var v-god as integer.
def var v-dt as date.
def var td as integer.

{vc-defdt.i}

update
  v-dtb label " НАЧАЛЬНАЯ ДАТА ПЕРИОДА " format "99/99/9999" skip
  v-dte label "  КОНЕЧНАЯ ДАТА ПЕРИОДА " format "99/99/9999"
  with centered row 5 side-label frame f-dt.


td = 0.
/*run sel2 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ",
   " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. Головной офис, г.Алматы | 2. Филиал в г.Астане | 3. Филиал в г.Уральске | 4. Филиал в г.Атырау | 5. Филиал в г.Актобе ", output td).

if td = 0 then return. */



def new shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field sum as deci extent 3 format "zzz,zzz,zzz,zzz,zz9.99"
  field sumfin as deci extent 3
  field proc as deci extent 3
  field procavg as deci extent 3
  index main is primary unique punkt clnsts
  index clnsts clnsts.



def var v-sum as deci.
def var v-proc as deci.
/*def new shared var v-bankname as char.*/
def var v-gl as char.
def var i as integer.
def var p as integer.
def var m as integer.
def var n as integer.



/* сектора экономики, учитываемые в отчете 1-СБt - через ; сектора юрлиц, затем 9 для физлиц */
def var v-secekstr as char init "6,7,8;9" /* "7"*/ .
def new shared var v-secek as char extent 2.

find sysc where sysc.sysc = "1sbtsek" no-lock no-error.
if avail sysc and sysc.chval <> "" then v-secekstr = sysc.chval.

v-secek[1] = entry (1, v-secekstr, ";").
if num-entries (v-secekstr, ";") > 1 then v-secek[2] = entry (2, v-secekstr, ";").

def var v-gls as char init "2203,2204,2209,2221".

def new shared temp-table t-gl
  field gl like bank.gl.gl
  field glstr as char
  index main is primary unique gl.

find sysc where sysc.sysc = "1SBTGL" no-lock no-error.
if avail sysc and sysc.chval <> "" then v-gls = sysc.chval.

do i = 1 to num-entries (v-gls):
  for each gl where gl.totlev = 1 no-lock:
    v-gl = entry (i, v-gls).
    v-gl = entry(1, v-gl).
    if string (gl.gl) begins v-gl then do:
	      create t-gl.
	      t-gl.gl = gl.gl.
	      t-gl.glstr = v-gl.
    end.
  end.
end.


/*if not connected ("comm") then run conncom.


for each comm.txb where comm.txb.consolid = true and (if td = 1 then true else comm.txb.txb = td - 2) no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password).
    run 1sbtdat.p (comm.txb.bank, no).
end.


if connected ("ast")  then disconnect "ast".*/

{r-brfilial.i &proc = "1sbtdat(comm.txb.bank, no)" }



/* итоговые суммы */
def buffer b-data for t-data.
do p = 1 to 4:
    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = 0.

    for each b-data where b-data.punkt = t-data.punkt and b-data.clnsts > 0:
      do i = 1 to 3:
        t-data.sum[i] = t-data.sum[i] + b-data.sum[i].
        t-data.proc[i] = t-data.proc[i] + b-data.proc[i].
      end.
    end.
end.

/* окончательный расчет % ставок */
for each t-data:
  do i = 1 to 3:
    if t-data.sum[i] > 0 then t-data.procavg[i] = t-data.proc[i] / t-data.sum[i].

    t-data.sumfin[i] = round (t-data.sum[i] / 1000, 0).
    t-data.procavg[i] = round (t-data.procavg[i], 1).
  end.
end.



/* расчет курсовой разницы - ОстКон - (ОстНач + ОборКредит - ОборДебет) */

p = 5.
  do i = 0 to 2:
    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = i.

    do n = 2 to 3:
      find b-data where b-data.punkt = 4  and b-data.clnsts = i no-error.
      if avail b-data then t-data.sumfin[n] = t-data.sumfin[n] + b-data.sumfin[n].

      find b-data where b-data.punkt = 1 and b-data.clnsts = i no-error.
      if avail b-data then t-data.sumfin[n] = t-data.sumfin[n] - b-data.sumfin[n].

      find b-data where b-data.punkt = 2 and b-data.clnsts = i no-error.
      if avail b-data then t-data.sumfin[n] = t-data.sumfin[n] - b-data.sumfin[n].

      find b-data where b-data.punkt = 3 and b-data.clnsts = i no-error.
      if avail b-data then t-data.sumfin[n] = t-data.sumfin[n] + b-data.sumfin[n].

    end.
  end.


/* сбор раздела 1 по имеющимся данным */
def var v-razdel1 as char extent 6 init
  ["", "1. Поступило денег на текущие счета юридических и физических лиц за отчетный период, всего<BR>в том числе", "",
   "2. Остатки на текущих счетах юридических и физических лиц на конец отчетного периода, всего<BR>в том числе"].

def var v-strrazdel1 as char extent 3 init
["",
 "юридические лица",
 "физические лица"].





/*if td = 1 then do:
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<BR>" + "Консолидированный отчет".
end.*/

v-dt = v-dte + 1.

def var v-file as char init "1sb.html".
output to value(v-file).


{html-title.i
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted
  "<P align=""center"" style=""font:bold"">Расшифровка по текущим счетам клиентов в СКВ и ставках вознаграждения по ним</P>" skip
  "<P align=""center"" style=""font:bold"">на " string(v-dt, "99/99/9999") " года</P>" skip
  "<P align=""center"" style=""font:bold"">" v-bankname "</P>" skip.


put unformatted
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD rowspan=""3"">&nbsp;</TD>" skip
    "<TD rowspan=""3""><BR><BR><BR>Шифр<BR>строки</TD>" skip
    "<TD colspan=""6"">Текущие счета клиентов в валюте:</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD colspan=""2"">доллар США</TD>" skip
    "<TD colspan=""2"">ЕВРО</TD>" skip
    "<TD colspan=""2"">другие СКВ</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>годовая<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>годовая<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
    "<TD>сумма</TD>" skip
    "<TD>средне<BR>годовая<BR>ставка<BR>вознаг<BR>раждения,<BR>%</TD>" skip
  "</TR>" skip.

put unformatted
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD>А</TD>" skip
    "<TD>Б</TD>" skip
    "<TD>1</TD>" skip
    "<TD>2</TD>" skip
    "<TD>3</TD>" skip
    "<TD>4</TD>" skip
    "<TD>5</TD>" skip
    "<TD>6</TD>" skip
  "</TR>" skip.
n = 0.
/* цикл по каждому пункту раздела 1 */
do p = 2 to 4:
if p = 3 then next.
  /* цикл по строкам в каждом пункте */
  do m = 1 to 3:
    /* шифр строки : первая строка этого отчета (по разделу 1) имеет шифр 01, далее по порядку */
    n = n + 1.
    put unformatted "<TR" if m = 1 then " style=""font:bold""" else "" ">" skip
      "<TD>" if m = 1 then v-razdel1[p] else v-strrazdel1[m] "</TD>" skip
      "<TD align=""center"">" string(n, "99") "</TD>" skip.

      find t-data where t-data.punkt = p and t-data.clnsts= m - 1 no-error.
      if  avail t-data then
        do td = 1 to 3:
	/*05/08/2004 valery*/
	if td = 4 then do:
          put unformatted
		"<TD>&nbsp;</TD><TD>&nbsp;</TD>" skip.
	end.  /****************/
	else
	do:
          put unformatted
            "<TD>" if t-data.sumfin[td] = 0 then "&nbsp;" else replace(string(t-data.sumfin[td], "->>>>>>>>>>>9"), ".", ",") "</TD>" skip.
          put unformatted
        	    "<TD>" if t-data.sumfin[td] = 0 then "&nbsp;" else replace(string(t-data.procavg[td], "->>>>>>>>>>>9.9"), ".", ",") "</TD>" skip.
	end.
        end.
    put unformatted "</TR>" skip.
  end. /* do m */
end. /* do p */
put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.
unix silent cptwin value(v-file) excel.

pause 0.
