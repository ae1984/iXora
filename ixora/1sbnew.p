/* 1sbnew.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Отчет 1-СБ Период указывается с ... по ... включительно!!! 
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        1sbnewdat.p
 * MENU
        
 * BASES
        BANK COMM 
 * AUTHOR
        marinav
 * CHANGES
*/

{mainhead.i}


def new shared var v-dtb as date.
def new shared var v-dte as date.
def var v-month as integer.
def var v-god as integer.
def var v-dt as date.
def var td as integer.
def var k as integer.

{vc-defdt.i}

update 
  v-dtb label " НАЧАЛЬНАЯ ДАТА ПЕРИОДА " format "99/99/9999" skip
  v-dte label "  КОНЕЧНАЯ ДАТА ПЕРИОДА " format "99/99/9999" 
  with centered row 5 side-label frame f-dt.


td = 0.
/*run sel2 (" ВЫБЕРИТЕ ОФИС/ФИЛИАЛ БАНКА ", 
   " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | 1. Головной офис, г.Алматы | 2. Филиал в г.Астане | 3. Филиал в г.Уральске | 4. Филиал в г.Атырау | 5. Филиал в г.Актобе | 6. Филиал в г.Караганда ", output td).

if td = 0 then return.*/



def new shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field stroka as integer
  field sum as deci format "->>>,>>>,>>>,>>9.99" extent 4
  field sumfin as deci format "->>>,>>>,>>>,>>9.99" extent 4
  field proc as deci format "->>>,>>>,>>>,>>9.99" extent 4
  field procavg as deci format "->>>,>>>,>>>,>>9.99" extent 4
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


def var v-strokaname as char extent 9 init
["",
 "до <br> востребования",
 "условные",
 "срочные,<br> всего",
 "до 1 мес.",
 "от 1 <br> до 3 мес.",
 "от 3 мес. <br> до 1 года",
 "от 1 года <br> до 5 лет",
 "от 5 лет <br> и более"].


def var v-crcname as char extent 4 init
["тенге",
"долларах США",
"ЕВРО",
"др.валюте"].


/* сектора экономики, учитываемые в отчете 1-СБ - через ; сектора юрлиц, затем 9 для физлиц */
def var v-secekstr as char init "1,2,3,4,5,6,7,8;9".
def new shared var v-secek as char extent 2.

find sysc where sysc.sysc = "1sbseknew" no-lock no-error.
if avail sysc and sysc.chval <> "" then v-secekstr = sysc.chval.

v-secek[1] = entry (1, v-secekstr, ";").
if num-entries (v-secekstr, ";") > 1 then v-secek[2] = entry (2, v-secekstr, ";").


/* счета ГК для обработки - через запятую 4 первых цифры счета, 
   через ^ после счета номер строки в каждом пункте 1-СБ :
     2 - до востребования
     3 - условные
     4 - срочные, делиться по срокам будут дальше

*/
def var v-gls as char init "2203^2,2204^2,2205^2,2209^2,2211^2,2221^2,2208^3,2219^3,2206^4,2207^4,2215^4,2217^4,2223^4".

def new shared temp-table t-gl 
  field gl like bank.gl.gl
  field glstr as char
  field stroka as integer
  index main is primary unique stroka gl.

find sysc where sysc.sysc = "1sbglsnew" no-lock no-error.
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

{r-brfilial.i &proc = "1sbnewdat(comm.txb.bank)" } 


/* итоговые суммы */
def buffer b-data for t-data.


do p = 1 to 4:
  do m = 1 to 2:
    create t-data.
    assign t-data.punkt = p
           t-data.clnsts = m
           t-data.stroka = 4.

    for each b-data where b-data.punkt = t-data.punkt and b-data.clnsts = t-data.clnsts and 
             lookup(string(b-data.stroka), "5,6,7,8,9") > 0:
      do i = 1 to 4:
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
      do i = 1 to 4:
        t-data.sum[i] = t-data.sum[i] + b-data.sum[i].
        t-data.proc[i] = t-data.proc[i] + b-data.proc[i].
      end.
    end.
  end.
end.

/* окончательный расчет % ставок */
for each t-data:
  do i = 1 to 4:
    if t-data.sum[i] > 0 then t-data.procavg[i] = t-data.proc[i] / t-data.sum[i].

    t-data.sumfin[i] = round (t-data.sum[i] / 1000, 0).
    t-data.procavg[i] = round (t-data.procavg[i], 2).
  end.
end.
/*
output to 1sb.txt.
for each t-data.
    displ t-data .
end.
output close.
*/

/* сбор раздела 1 по имеющимся данным */
def var v-razdel1 as char extent 4 init
  ["Депозиты до востребованя в валюте",
   "Депозиты со сроком до 1 года в валюте",
   "Депозиты со сроком от 1 года до 5 лет",
   "Депозиты со сроком более 5 лет"
].

def var v-strrazdel1 as char extent 3 init
["всего",
 "юридические лица",
 "физические лица"].

def temp-table t-razdel1
  field punkt as integer
  field stroka as integer
  field srok as integer
  field sum as deci extent 4
  field sumfin as deci extent 4
  field proc as deci extent 4
  field procavg as deci extent 4
  index main is primary unique punkt stroka srok.

def buffer b-razdel1 for t-razdel1.

do p = 1 to 4:
  /* создание пунктов */
  do m = 2 to 3:
    /* юр/физ лица */
    do i = 1 to 4:
      /* по срокам */
      create t-razdel1.
      assign t-razdel1.punkt = p
             t-razdel1.stroka = m
             t-razdel1.srok = i.

      for each t-data where t-data.punkt = t-razdel1.punkt and 
                            t-data.clnsts = t-razdel1.stroka - 1:
        if ((i = 1) and (lookup(string(t-data.stroka), "2") > 0)) or
           ((i = 2) and (lookup(string(t-data.stroka), "5,6,7") > 0)) or
           ((i = 3) and (lookup(string(t-data.stroka), "8,3") > 0)) or
           ((i = 4) and (lookup(string(t-data.stroka), "9") > 0)) then do: 
          do n = 1 to 4:
            /* по валютам */
            t-razdel1.sum[n] = t-razdel1.sum[n] + t-data.sum[n].
            t-razdel1.proc[n] = t-razdel1.proc[n] + t-data.proc[n].
          end.
        end.
      end.
    end.
  end.

  /* создание первой итоговой строки */
  do i = 1 to 4:
    /* по срокам */
    create t-razdel1.
    assign t-razdel1.punkt = p
           t-razdel1.stroka = 1
           t-razdel1.srok = i.

    for each b-razdel1 where b-razdel1.punkt = t-razdel1.punkt and b-razdel1.srok = t-razdel1.srok and 
             lookup(string(b-razdel1.stroka), "2,3") > 0:
      do n = 1 to 4:
        t-razdel1.sum[n] = t-razdel1.sum[n] + b-razdel1.sum[n].
        t-razdel1.proc[n] = t-razdel1.proc[n] + b-razdel1.proc[n].
      end.
    end.
  end.
end.

/* окончательный расчет % ставок */
for each t-razdel1:
  do i = 1 to 4:
    if t-razdel1.sum[i] > 0 then t-razdel1.procavg[i] = t-razdel1.proc[i] / t-razdel1.sum[i].

    t-razdel1.sumfin[i] = round (t-razdel1.sum[i] / 1000, 0).
    t-razdel1.procavg[i] = round (t-razdel1.procavg[i], 1).
  end.
end.

v-dt = v-dte + 1.

def var v-file as char init "1sb.html".
output to value(v-file).

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
  "<P align=""center"" style=""font:bold"">Форма N 1. Отчет о вкладах и ставках вознаграждения по ним</P>" skip
  "<P align=""center"" style=""font:bold"">на " string(v-dt, "99/99/9999") " года</P>" skip
  "<P align=""center"" style=""font:bold"">" v-bankname "</P>" skip.

/* Раздел 1 */ 

put unformatted   
  "<P align=""left"" style=""font:bold"">Раздел 1. Деньги, привлеченные во вклады</P>" skip
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD rowspan=""2"" colspan=""2"">&nbsp;</TD>" skip
    "<TD colspan=""3"">Остатки денег на счетах вкладов <br> на " string(v-dtb, "99/99/9999") "</TD>" skip
    "<TD colspan=""3"">Привлечено денег на счета вкладов <br> за отчетный период, в том числе</TD>" skip
    "<TD colspan=""3"">Отозвано денег со счетов вкладов <br> за отчетный период, в том числе</TD>" skip
    "<TD colspan=""3"">Остатки денег на счетах вкладов <br> на " string(v-dte + 1, "99/99/9999") "</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip.
  
do i = 1 to 4:
put unformatted   
    "<TD> всего</TD>" skip
    "<TD> юрид.лица</TD>" skip
    "<TD> физ.лица</TD>" skip.
end.
put unformatted  "</TR>" skip.

/* цикл по срокам*/

do i = 1 to 4:
  /* цикл по валюте по каждому сроку */
  do m = 1 to 5:

    put unformatted "<TR" if m = 1 then " style=""font:bold""" else "" ">" skip
      "<TD " if m = 1 then "colspan=""14"">"  else " rowspan=""2"">"  skip
       if m = 1 then v-razdel1[i] else v-crcname[m - 1] "</TD>" skip.

    /* цикл по срокам */
    if m > 1 then do:

          do n = 1 to 2:
             if n = 1 then put unformatted "<TD> сумма </TD>" .  
                      else put unformatted "<TR><TD> % </TD>" .   
         
          do p = 1 to 4:
             do td = 1 to 3:
 
                find t-razdel1 where t-razdel1.punkt = p and t-razdel1.stroka = td and t-razdel1.srok = i no-error.
                if not avail t-razdel1 then 
                    put unformatted "<TD>&nbsp;</TD>" skip.
                else do:
                   if n = 1 then put unformatted 
                      "<TD align=""right"">" if t-razdel1.sumfin[m - 1] = 0 then "&nbsp;" else replace(string(t-razdel1.sumfin[m - 1], ">>>>>>>>>>>9"), ".", ",") "</TD>" skip.
                   if n = 2 then put unformatted 
                      "<TD align=""right"">" if t-razdel1.sumfin[m - 1] = 0 then "&nbsp;" else replace(string(t-razdel1.procavg[m - 1], ">>9.99"), ".", ",") "</TD>" skip.
                end.
             end.
          end.
         end.
    end.  
    put unformatted "</TR>" skip.
  end. /* do m */
end. /* do i */


put unformatted "</TR></TABLE>" skip.


/* Раздел 2 */ 

put unformatted   
  "<P align=""left"" style=""font:bold"">Раздел 2. Вклады по срокам погашения</P>" skip
  "<P align=""right"" style=""font:bold;font-size:8pt"">в тысячах тенге</P>"
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
    "<TD rowspan=""2"" colspan=""2"">&nbsp;</TD>" skip
    "<TD colspan=""8"">Остатки денег на счетах вкладов на " string(v-dtb, "99/99/9999") " </TD>" skip
    "<TD colspan=""8"">Привлечено денег на счета вкладов за отчетный период, в том числе</TD>" skip
    "<TD colspan=""8"">Отозвано денег со счетов вкладов за отчетный период, в том числе</TD>" skip
    "<TD colspan=""8"">Остатки денег на счетах вкладов на " string(v-dte + 1, "99/99/9999") "</TD>" skip
  "</TR>" skip
  "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip.

  do i = 1 to 4:
    do m = 2 to 9: 
    put unformatted   "<TD >" v-strokaname[m] "</TD>" skip.
    end.
  end.
  put unformatted  "</TR>" skip.

do p = 1 to 4:
  do m = 1 to 3:

    put unformatted "<TR" if m = 1 then " style=""font:bold""" else "" ">"  skip
      "<TD " if m = 1 then ">"  else " rowspan=""2"">"  skip
       if m = 1 then v-crcname[p]  else  v-strrazdel1[m] "</TD>" skip.
    if m = 1 then do:
       do n = 1 to 33:
             put unformatted "<TD>&nbsp;</TD>" skip.           
       end. 
    end.

    if m > 1 then do:
       do n = 1 to 2:
          if n = 1 then put unformatted "<TD> сумма </TD>" .  
                   else put unformatted "<TR><TD> % </TD>" .   
          do td = 1 to 4 :
             do i = 2 to 9:
               find t-data where t-data.punkt = td and t-data.stroka = i and t-data.clnsts = m - 1 no-error.
               if not avail t-data then 
                   put unformatted "<TD>&nbsp;</TD>" skip.           
               else do:
                  if n = 1 then  put unformatted "<TD align=""right"" >" if t-data.sumfin[p] = 0 then "&nbsp;" else replace(string(t-data.sumfin[p], ">>>>>>>>>>>9"), ".", ",") "</TD>" skip.
                  if n = 2 then  put unformatted "<TD align=""right"" >" if t-data.sumfin[p] = 0 then "&nbsp;" else replace(string(t-data.procavg[p], ">>9.99"), ".", ",") "</TD>" skip.
               end.   
             end.
          end.
       put unformatted "</TR>" skip.
       end. 
    end.

    put unformatted "</TR>" skip.
  end. 
end.


put unformatted "</TABLE>" skip.

{html-end.i " "}
output close.
unix silent cptwin value(v-file) excel.

pause 0.
