/* clonsb.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Остатки на депозитных счетах по ОСТАВШЕМУСЯ сроку
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        clondat.p
 * MENU
        8-2-14-10
 * BASES
        BANK COMM
 * AUTHOR
        09.04.2004 valery данный отчет является клоном отчета 1sb.p
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i}


def new shared var v-dtb as date. /*Начальная дата периода*/
def new shared var v-dte as date. /*Конечная дата периода*/
def var v-month as integer.
def var v-god as integer.
def var v-dt as date.
def var v-jur as char init "1,2,3,4,5,6,7,8".
def new shared var v-norezid as logical init yes.
/*
def var td as integer.
*/

{vc-defdt.i}

update 
  v-dte label "  ВВЕДИТЕ ДАТУ ОТЧЕТА " format "99/99/9999" skip(1)
  v-jur label " Сектора экономики ЮЛ " format "x(30)" skip
  v-norezid label " Учитывать нерезидентов ?" format "да/нет" skip
  with centered row 5 side-label frame f-dt.

v-dtb = v-dte.


/*
td = 0.
run sel2 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", 
   " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. Головной офис, г.Алматы | 2. Филиал в г.Астане | 3. Филиал в г.Уральске | 4. Филиал в г.Атырау ", output td).

if td = 0 then return.
*/


def new shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field stroka as integer
  field sum as deci extent 4
  field sumfin as deci extent 4
  field proc as deci extent 4
  field procavg as deci extent 4
  index main is primary unique punkt stroka clnsts
  index stroka clnsts stroka .


def var v-sum as deci.
def var v-proc as deci.
def var v-gl as char.
def var i as integer.
def var p as integer.
def var m as integer.
def var n as integer.


def var v-punktname as char extent 1 init
  ["Остатки денег на счетах вкладов юридических и физических лиц на отчетную дату"].

def var v-strokaname as char extent 10 init
["",                                /*1*/
 "до востребования, текущие счета", /*2*/
 "",                      /*3*/
 "<b>срочные </b>", /*4*/
 " до 1 мес.",           /*5*/
 " от 1 до 3 мес.",      /*6*/
 " от 3 мес. до 6 мес",  /*7*/
 " от 6 мес. до 12 мес", /*8*/
 " от 1 года до 5 лет",  /*9*/
 " от 5 лет и более"].   /*10*/

/* сектора экономики, учитываемые в отчете 1-СБ - через ; сектора юрлиц, затем 9 для физлиц */
def new shared var v-secek as char extent 2.
v-secek[1] = v-jur.
v-secek[2] = "9".


/* счета ГК для обработки - через запятую 4 первых цифры счета, 
   через ^ после счета номер строки в каждом пункте 1-СБ :
     2 - до востребования 2205,2211, текущие счета 2203,2204,2209,2221
     3 - условные 2208,2219
     4 - срочные, делиться по срокам будут дальше 2206,2215,2207,2217,2223

*/
def var v-gls as char init "2205^2,2211^2,2203^2,2204^2,2209^2,2221^2,2208^4,2219^4,2206^4,2215^4,2207^4,2217^4,2223^4".

def new shared temp-table t-gl 
  field gl like bank.gl.gl
  field glstr as char
  field stroka as integer
  field crc like gl.crc
  index main is primary unique stroka gl.

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
      t-gl.crc = gl.crc.        
    end.
  end.
end.


{r-brfilial.i &proc = "clondat (comm.txb.bank)"}
/*
if not connected ("comm") then run conncom.

for each comm.txb where comm.txb.consolid = true and (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("ast") then disconnect "ast".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run clondat.p (comm.txb.bank).
end.


if connected ("ast")  then disconnect "ast".
*/

/* итоговые суммы */

def buffer b-data for t-data.

/*
do p = 4 to 4:
  do m = 1 to 2:

message p m 4. 

    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = m
           t-data.stroka = 4.

    for each b-data where b-data.punkt = t-data.punkt and b-data.clnsts = t-data.clnsts and 
             lookup(string(b-data.stroka), "5,6,7,8,9,10") > 0:
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
*/

/* приводим суммы к тысячам */
for each t-data:
  do i = 1 to 4:
    t-data.sumfin[i] = round (t-data.sum[i] / 1000, 0).
  end.
end.


/*
if v-select = 1 then do:
  find first cmp no-lock no-error.
  v-bankname1 = cmp.name + "<BR>" + "Консолидированный отчет".
end.
else do:
  find txb where txb.consolid and txb.txb = v-select - 2 no-lock no-error.
  v-bankname1 = txb.name.
end.
*/
v-dt = v-dte + 1.


def var v-file as char init "1sb.html".
output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}


/* Раздел 2 */ 

put unformatted   
  "<P>" v-bankname "</P>" skip
  "<P align=""left"" style=""font:bold""> Вклады по оставшимся срокам погашения<BR>за " string(v-dte, "99/99/9999") "</P>" skip
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD rowspan=""2"">&nbsp;</TD>" skip
    "<TD colspan=""4"">юр.лиц в валюте:</TD>" skip
    "<TD colspan=""4"">физ.лиц в валюте:</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD colspan=""1"">KZT</TD>" skip
    "<TD colspan=""1"">USD</TD>" skip
    "<TD colspan=""1"">EUR</TD>" skip
    "<TD colspan=""1"">RUR</TD>" skip
    "<TD colspan=""1"">KZT</TD>" skip
    "<TD colspan=""1"">USD</TD>" skip
    "<TD colspan=""1"">EUR</TD>" skip
    "<TD colspan=""1"">RUR</TD>" skip
  "</TR>" skip.

/* цикл по каждому пункту раздела 2 */
do p = 4 to 4:
  /* цикл по строкам в каждом пункте */
  do m = 1 to 10:
    if m = 1 or m = 3 then next.
    
    put unformatted "<TR" if m = 1 then " style=""font:bold""" else "" ">"  skip
      "<TD>" if m = 1 then v-punktname[1] else v-strokaname[m] "</TD>" skip.

    /* цикл по юр/физ лицам */
    do i = 1 to 2:
      find t-data where t-data.punkt = p and t-data.stroka = m and t-data.clnsts = i no-error.
      if not avail t-data then do:
        do v-select = 1 to 4:
          put unformatted "<TD>&nbsp;</TD>" skip.
        end.

      end.
      else
        do v-select = 1 to 4:
          put unformatted 
            "<TD>" if t-data.sumfin[v-select] = 0 then "&nbsp;" else replace(string(t-data.sumfin[v-select], ">>>>>>>>>>>9"), ".", ",") "</TD>" skip.
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


