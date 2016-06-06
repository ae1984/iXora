/* 700hҐкуп.p
 * MODULE 
        Отчет для Генеральной бухгалтерии.
 * DESCRIPTION 
        отчет по приложению 700Н к балансу . Отчет для Генеральной бухгалтерии.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT
        700h.p
 * MENU 
        8-8-3-10
 * BASES
        BANK COMM
 * AUTHOR  
        28.10.09 marinav 
 * CHANGES
*/
 

def new shared stream vcrpt.
def new shared var vasof as date.
def new shared var v-pass as char.

def var v-bank as char.
def var p-code as int.


def var sum as decimal.

 def new shared temp-table temp
  field  kod  as char
  field  gl  as char format 'x(7)'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 


{global.i}

for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

output stream vcrpt to rpt.html.


if not g-batch then do:
update vasof label 'Введите отчетную дату' validate (vasof le g-today, 
                " Дата не может быть больше текущего закрытого ОД " 
         + string(g-today)) 
            with row 8 centered  side-label frame opt.
end.
 hide frame opt.

def var v-sel as char.
run sel2("Выберите отчет", "1. По Алматы и Астане |2. По остальным филиалам", output v-sel).

display '   Ждите...   '  with row 5 frame ww centered .


if v-sel = '1' then do:
for each comm.txb where comm.txb.consolid and  lookup(string(comm.txb.txb),"0,16,8") > 0 no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run 700h_reg1.
end.
end.
    
if v-sel = '2' then do:
for each comm.txb where comm.txb.consolid and  lookup(string(comm.txb.txb),"0,16,8") = 0 no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    run 700h_reg1.
end.
end.

if connected ("txb")  then disconnect "txb".

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

if v-sel = '1' then
put stream vcrpt unformatted "<b>  Приложение к форме ежедневного баланса банков второго уровня (700H) за "  +
   string(vasof)  + " (в тыс.тенге) свод по Алматы и Астане </b>" .
  
if v-sel = '2' then
put stream vcrpt unformatted "<b>  Приложение к форме ежедневного баланса банков второго уровня (700H) за "  +
   string(vasof)  + " (в тыс.тенге) свод по филиалам, кроме Алматы и Астаны</b>" .
  

put stream vcrpt unformatted
   "<TABLE width=""45%"" border=""1"" cellspacing=""0"" cellpadding=""1"">" skip
/*     "<TD><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip*/
     "<TD><FONT size=""1""><p align=""center""><B>Счет ГК</B></p></FONT></TD>" skip
     "<TD><FONT size=""1""><p align=""center""><B>Сумма</B></p></FONT></TD>" skip
     "</TR>" skip.

for each temp break by temp.gl.
  ACCUMULATE temp.val (total  by temp.gl).


  if last-of(temp.gl) then  do:

  sum =  ACCUMulate total  by (temp.gl) temp.val  .
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .
  put stream vcrpt unformatted
/*     "<TD><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip*/
      "<TD>" + temp.gl + "</TD>" skip
     "<TD>" + replace(string(sum,'-zzzzzzzzz9.99'),'.',',') + "</TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.
 end.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin rpt.html excel").

pause 0.

