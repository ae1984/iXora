/* 1sbdat.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Расшифровка Отчет 1-СБ
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        1sbdat.p
 * MENU
        8-2-14-3
 * AUTHOR
        14.01.2004 nadejda - переделано полностью в соответствии с 1sb.p
 * CHANGES
	15/12/2005 nataly добавила филиал в г.Актобе
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09.10.2006 u00600 - изменила выбор филиалов r-brfilial.i
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

if td = 0 then return.*/



def new shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field stroka as integer
  field sum as deci extent 3
  field sumfin as deci extent 3
  field proc as deci extent 3
  field procavg as deci extent 3
  index main is primary unique punkt stroka clnsts
  index stroka clnsts stroka .


def var v-sum as deci.
def var v-proc as deci.
/*def new shared var v-bankname as char.*/
def var v-gl as char.
def var i as integer.
def var p as integer.
def var m as integer.
def var n as integer.


def var v-punktname as char extent 2 init
  ["Привлечено денег на счета вкладов юридических и физических лиц за отчетный период, всего<BR>в том числе",
   "Остатки денег на счетах вкладов юридических и физических лиц на конец отчетного периода, всего<BR>в том числе"].

def var v-strokaname as char extent 6 init
["",
 "до востребования",
 "условные",
 "срочные, всего",
 "краткосрочные",
 "долгосрочные"
].

/* сектора экономики, учитываемые в отчете 1-СБ - через ; сектора юрлиц, затем 9 для физлиц */
def var v-secekstr as char init "6,7,8;9".
def new shared var v-secek as char extent 2.

find sysc where sysc.sysc = "1sbsek" no-lock no-error.
if avail sysc and sysc.chval <> "" then v-secekstr = sysc.chval.

v-secek[1] = entry (1, v-secekstr, ";").
if num-entries (v-secekstr, ";") > 1 then v-secek[2] = entry (2, v-secekstr, ";").


/* счета ГК для обработки - через запятую 4 первых цифры счета, 
   через ^ после счета номер строки в каждом пункте 1-СБ :
     2 - до востребования
     3 - условные
     4 - срочные, делиться по срокам будут дальше

*/
def var v-gls as char init "2205^2,2211^2,2208^3,2219^3,2206^4,2215^4,2207^4,2217^4,2223^4".

def new shared temp-table t-gl 
  field gl like bank.gl.gl
  field glstr as char
  field stroka as integer
  index main is primary unique stroka gl.

find sysc where sysc.sysc = "1sbgls" no-lock no-error.
if avail sysc and sysc.chval <> "" then v-gls = sysc.chval.

do i = 1 to num-entries (v-gls):
  for each gl where gl.totlev = 1 no-lock:
    v-gl = entry (i, v-gls).
    m = integer(entry(2, v-gl, "^")).
    v-gl = entry(1, v-gl, "^").
    if string (gl.gl) begins v-gl then do:
      create t-gl.
      t-gl.gl = gl.gl.
      t-gl.glstr = v-gl.
      t-gl.stroka = m.
    end.
  end.
end.



/*if not connected ("comm") then run conncom.

for each comm.txb where comm.txb.consolid = true and (if td = 1 then true else comm.txb.txb = td - 2) no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run sh1sbdat (comm.txb.bank).
end.
    
if connected ("ast")  then disconnect "ast".*/

{r-brfilial.i &proc = "sh1sbdat(comm.txb.bank)" }   


/* итоговые суммы */
def buffer b-data for t-data.


do p = 1 to 2:
  do m = 1 to 2:
    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = m
           t-data.stroka = 4.

    for each b-data where b-data.punkt = t-data.punkt and b-data.clnsts = t-data.clnsts and 
             lookup(string(b-data.stroka), "5,6") > 0:
      do i = 1 to 3:
        t-data.sum[i] = t-data.sum[i] + b-data.sum[i].
        t-data.proc[i] = t-data.proc[i] + b-data.proc[i].
      end.
    end.

    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = m
           t-data.stroka = 1.

    for each b-data where b-data.punkt = t-data.punkt and b-data.clnsts = t-data.clnsts and 
             lookup(string(b-data.stroka), "2,3,4") > 0:
      do i = 1 to 3:
        t-data.sum[i] = t-data.sum[i] + b-data.sum[i].
        t-data.proc[i] = t-data.proc[i] + b-data.proc[i].
      end.
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




/* Вывод отчета  */

/*if td = 1 then do:
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<BR>" + "Консолидированный отчет".
end.*/

v-dt = v-dte + 1.


def var v-file as char init "sh1sb.html".
output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
  "<P align=""center"" style=""font:bold"">Расшифровка по вкладам клиентов в СКВ и ставках вознаграждения по ним</P>" skip
  "<P align=""center"" style=""font:bold"">за период c " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") "</P>" skip
  "<P align=""center"" style=""font:bold"">" v-bankname "</P>" skip.


put unformatted   
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
    "<TD>7</TD>" skip
    "<TD>8</TD>" skip
    "<TD>9</TD>" skip
    "<TD>10</TD>" skip
    "<TD>11</TD>" skip
    "<TD>12</TD>" skip
  "</TR>" skip.


n = 0.

/* цикл по каждому пункту */
do p = 1 to 2:
  /* цикл по строкам в каждом пункте */
  do m = 1 to 6:
    /* шифр строки по порядку */
    n = n + 1.

    put unformatted "<TR" if m = 1 then " style=""font:bold""" else "" ">"  skip
      "<TD>" if m = 1 then v-punktname[p] else v-strokaname[m] "</TD>" skip
      "<TD align=""center"">" string(n, "99") "</TD>" skip.

    /* цикл по юр/физ лицам */
    do i = 1 to 2:
      find t-data where t-data.punkt = p and t-data.stroka = m and t-data.clnsts = i no-error.
      if not avail t-data then do:
        do td = 1 to 6:
          put unformatted "<TD>&nbsp;</TD>" skip.
        end.
      end.
      else
        do td = 1 to 3:
          put unformatted 
            "<TD>" if t-data.sumfin[td] = 0 then "&nbsp;" else replace(string(t-data.sumfin[td], ">>>>>>>>>>>9"), ".", ",") "</TD>" skip
            "<TD>" if t-data.sumfin[td] = 0 then "&nbsp;" else replace(string(t-data.procavg[td], ">>>>>>>>>>>9.9"), ".", ",") "</TD>" skip.
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




/*
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
 "условные",
 "срочные, всего",
 "краткосрочные",
 "долгосрочные",
 "Остатки денег на счетах вкладов юридических и физических лиц на конец отчетного периода, всего",
 "до востребования",
 "условные",
 "срочные, всего",
 "краткосрочные",
 "долгосрочные"].

*/

