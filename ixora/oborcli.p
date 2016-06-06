/* oborcli.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        расчет изменения оборотов по счетам клиентов ЮЛ за заданный период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-2-5-8 
 * AUTHOR
        09/02/04 nataly 
 * CHANGES
        17.02.2004 nadejda - изменила определение департамента клиента - по привязке к департаменту, а не по менеджеру счета
*/

{mainhead.i}

 {comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().
 {get-dep.i}

def var sum_tax as decimal.
def var sum_pf as decimal.
def var sum_com10  as decimal.
def var sum_com20  as decimal.

def var bsum$ as dec format "->>>,>>>,>>9.99".
def var isum$ as dec format "->>>,>>>,>>9.99".
def var ic$ as int.
def var i$ as int format ">>>>>." init 1.
def var i1$ as int format ">>>>>".
def var gr$ as char format "x(3)".
def var q$ as int format ">>>>>".
def var qacc$ as int format ">>>>>".
def var v-dep as char format "x(3)".
def new shared var prz as integer.
def var v-dat as date.
def var  vprofit as char.
def new shared var v-name as char.
def var v-tek as decimal.
/*
def var m1 as integer.
def var m2 as integer.
def var y1 as integer.
def var y2 as integer.
  */
def var dt1 as date.
def var dt11 as date.
def var dt2 as date.
def var dt22 as date.

def buffer bjl for jl.
def temp-table temp 
    field cif  like cif.cif
    field aaa like aaa.aaa
    field fdt as date
    field gl   like jl.gl
    field amt like jl.dam
    field mon as integer
    field jh like jl.jh
    field ofc as char
    field crc like jl.crc
/*    field v-subtot like v-subtot
    field v-tot  like v-tot*/.

def temp-table temp2 
    field cif  like cif.cif
    field totamt1 like jl.dam
    field totamt2 like jl.dam
    field razn as decimal
    field mon as integer
    field ofc as char.


def frame opt 
       v-dep label "Код департамента" 
       /* vprofit  label "Профит-центр" skip*/
       m1 as integer format "z9" label  "1-ый отчетный месяц ..."
       y1 as integer format "9999" label "Год 1-го отчетного м-ца"
       m2 as integer format "z9" label  "2-ой отчетный месяц ..."
       y2 as integer format "9999" label "Год 2-го отчетного м-ца"
       with row 8 centered side-labels.

/*on help of vprofit in frame opt  run uni_help1("sproftcn", "...").
  */
update v-dep 
       /*vprofit*/
       m1
       y1
       m2
       y2
         with frame opt.


if m2 < m1 and y2 < y1 then do:
    message "Неверно задан второй отчетный месяц".
    undo,retry.    
end.
if y2 < y1 then do:
    message "Неверно задан второй отчетный год".
    undo,retry.    
end.

hide frame opt.

find ppoint where ppoint.depart = integer(v-dep)  no-error.
if not available ppoint then do:
    message "Неверный код департамента".
    leave.    
end.

displ "ИДЕТ ФОРМИРОВАНИЕ ОТЧЕТА " string(time,"hh:mm:ss") with row 5.

find ppoint where ppoint.dep = integer(v-dep) no-lock no-error.
if avail ppoint then v-name = ppoint.name.

if m1 = 1 or m1 = 3 or m1 = 5 or m1 = 7 or m1 = 8 or m1 = 10 or m1 = 12  then  do: 
  dt1 = date(m1,1,y1). 
  dt2 = date(m1,31,y1). /*!!! 31*/
end. 
else if m1 = 2 then do:
  dt1 = date(m1,1,y1). dt2 = date(m1,28,y1).
end.
else  do:
  dt1 = date(m1,1,y1). dt2 = date(m1,30,y1). /*!!! 30*/
end.
/*1st month*/
 do v-dat = dt1 to dt2:
 /*учет кредитовых проводок по тенговым счетам*/
    for each bjl no-lock where bjl.jdt = v-dat .
      if bjl.acc = "" then next.
      find aaa where aaa.aaa = bjl.acc no-lock no-error.
      if not avail aaa then  next.
      if aaa.crc <> 1 then next.
     if  substr(string(bjl.gl),1,2) = "22"  and bjl.dc = "c"  
     then do:
   
    find cif where cif.cif = aaa.cif no-lock no-error.
    if integer(cif.jame) mod 1000 <> integer(v-dep) then next.
    
    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
    if not avail sub-cod or sub-cod.ccod <> "0" then next.

      create temp. 
      temp.cif = aaa.cif.
      temp.gl = bjl.gl. 
      temp.aaa = bjl.acc.
      temp.amt = bjl.cam.
      temp.crc = bjl.crc.
      temp.jh = bjl.jh.
      temp.mon = 1 /*month(v-dat)*/.
      temp.ofc = cif.fname.
/*      message temp.gl temp.crc temp.aaa temp.ofc.*/
    end. /*if*/
   end. /* for each bjl*/
 end. /*v-dat*/

/*2nd month*/
if m2 = 1 or m2 = 3 or m2 = 5 or m2 = 7 or m2 = 8 or m2 = 10 or m2 = 12  then  do: 
  dt11 = date(m2,1,y2). 
  dt22 = date(m2,31,y2). /*!!! 31*/
end. 
else if m2 = 2 then do:
  dt11 = date(m2,1,y2). dt22 = date(m2,28,y2).
end.
else  do:
  dt11 = date(m2,1,y2). dt22 = date(m2,30,y2).  /*!!! 30*/
end.

 do v-dat = dt11 to dt22:
 /*учет кредитовых проводок по тенговым счетам*/
    for each bjl no-lock where bjl.jdt = v-dat .
      if bjl.acc = "" then next.
      find aaa where aaa.aaa = bjl.acc no-lock no-error.
      if not avail aaa then  next.
      if aaa.crc <> 1 then next.
     if  substr(string(bjl.gl),1,2) = "22"  and bjl.dc = "c"  
     then do:
       find cif where cif.cif = aaa.cif no-lock no-error.
       if integer(cif.jame) mod 1000 <> integer(v-dep) then next.
       
       find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
       if not avail sub-cod or sub-cod.ccod <> "0" then next.


      create temp. 
      temp.cif = aaa.cif.
      temp.gl = bjl.gl. 
      temp.aaa = bjl.acc.
      temp.amt = bjl.cam.
      temp.crc = bjl.crc.
      temp.jh = bjl.jh.
      temp.mon = 2 /*month(v-dat)*/.
      temp.ofc = cif.fname.
    end. /*if*/
   end. /* for each bjl*/
 end. /*v-dat*/

def var sumgl as decimal.
def var sumcrc1 as decimal.
def var sumcrc2 as decimal.


for each temp break by temp.mon by temp.cif.
 ACCUMULATE temp.amt (total by  temp.mon).
 ACCUMULATE temp.amt (total by  temp.cif).

  if last-of(temp.cif) then  do: 
    sumcrc1 = ACCUMulate total  by (temp.cif) temp.amt.   
   find temp2 where temp2.cif = temp.cif no-error.
   if not avail temp2 then 
    create temp2.
   temp2.cif = temp.cif.
  if temp.mon = 1  then temp2.totamt1= sumcrc1.
  if temp.mon = 2  then temp2.totamt2= sumcrc1.

  end. /*last-of mon*/

end.

for each temp2 break by temp.cif.
    temp2.razn = temp2.totamt2 - temp2.totamt1.
end.
/*вывод результатов*/
def stream vcrpt.
def var p-filename as char init "oborcli.html".
output stream vcrpt  to value(p-filename).


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}


  put stream vcrpt unformatted "<b> ОТЧЕТ ПО ИЗМЕНЕНИЮ СУММ КРЕДИТОВЫХ ОБОРОТОВ ПО ТЕНГОВЫМ СЧЕТАМ ЮЛ ДЕПАРТАМЕНТА " 
      + v-name + "  ЗА ПЕРИОД " +  string(m1) + "."  
                                + string(y1) + "г. - " +  string(m2) + "."  + string(y2) + "г. " + "</b>"  skip.

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip 
     "<TD><FONT size=""1""><B>CIF</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>НАИМЕНОВАНИЕ КЛИЕНТА</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>СУММА ОБОР " + string(m1) + "."  + string(y1) + "г." + "</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>СУММА ОБОР " + string(m2) + "."  + string(y2) + "г." + "</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ИЗМЕНЕНИЕ</B></FONT></TD>" skip
     "</TR>" skip.
  
for each temp2 where break by temp2.razn.
     find cif where cif.cif = temp2.cif no-lock no-error.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .

  put stream vcrpt unformatted
/*     "<TD><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip*/
      "<TD>" + temp2.cif + "</TD>" skip
     "<TD>" + cif.name + "</TD>" skip
      "<TD>" + replace(string(temp2.totamt1,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(temp2.totamt2,"zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip
      "<TD>" + replace(string(temp2.razn,"-zzzzzzzzzzzzz9.99"),".",",") + "</TD>" skip.

      "<TD align=""right"">".


  put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.


{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent cptwin value(p-filename) excel.

pause 0.

