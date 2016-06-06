/* 700h.p
 * MODULE 
        Отчет для Генеральной бухгалтерии.
 * DESCRIPTION 
        Консолидированный отчет по приложению 700Н к балансу . Отчет для Генеральной бухгалтерии.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT
        700h2.p
 * MENU 
        8-12-16
 * AUTHOR  
        27/08/03 nataly 
 * CHANGES
       25/06/03 nataly были изменены признаки 007, 008, 013, 024,029,032,031,025,137,152 
       08/10/03 nataly temp.gl  с типа integer был заменен на char
       27/03/06 nataly добавлен выбор филиалов
       09/01/08 marinav - rcp на scp  , добавлен вывод в Excel
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

display '   Ждите...   '  with row 5 frame ww centered .


find last cls.


{r-brfilial.i &proc = "700h3(comm.txb.bank,output v-bank, output p-code)" } 

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted "<b>" v-bankname " Приложение к форме ежедневного баланса банков второго уровня (700H) за "  +
   string(vasof)  + " (в тыс.тенге) </b>" .
  
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
