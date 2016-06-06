/* checkgl.p
 * MODULE
        Платежные системы
 * DESCRIPTION
        Автоматизация чеков TEXAKABANK сч. ГК 287011(000076805)
 * RUN
        checkgl.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        26/08/2004 saltanat
 * CHANGES
        03.09.2004 saltanat - включила обработку платежей по выдаче чека для 2-х чеков
        06.09.2004 saltanat - включен вывод Итого и вывод отчета в Ехсел. 
        10.09.2004 saltanat - внесла учет данных за 1999 год.
*/
{mainhead.i}

def buffer tjl for jl.
def buffer vjl for jl.

def temp-table checks
    field jh     like ujo.jh
    field number like ujo.chk
    field dop    as   char format 'x(4)'
    field g_date like jl.whn
    field drsum  like jl.dam
    field crsum  like jl.cam
    field d_date like jl.whn
    field ost    as   char.

def var mon     as inte init 1.
def var v-dtb   as date.
def var v-dte   as date.
def var v-chk1  as char.
def var v-chk2  as char.
def var v-itog1 as deci init 0.
def var v-itog2 as deci init 0.
def var v-itog3 as deci init 0.
def var v-ost   as deci init 0.

form
   skip(1)
      /*v-dtb label ' Начало периода' format '99/99/9999' skip*/
      v-dte label ' На дату ' format '99/99/9999' skip(1)
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

v-dtb = 01/01/1999.
v-dte = g-today.

update v-dte with frame f-dt.

create checks.
assign checks.jh     = 1    
       checks.number = 2441
       checks.g_date = 01/28/1999
       checks.crsum  = 10.
v-itog1 = v-itog1 + checks.crsum.

create checks.
assign checks.jh     = 2    
       checks.number = 2690
       checks.g_date = 11/19/1999
       checks.crsum  = 110.
v-itog1 = v-itog1 + checks.crsum.

create checks.
assign checks.jh     = 3    
       checks.number = 2718
       checks.g_date = 12/09/1999
       checks.crsum  = 50.
v-itog1 = v-itog1 + checks.crsum.

for each ujo where (ujo.chk > 0) and ( ujo.whn >= v-dtb ) and ( ujo.whn <= v-dte ) and (ujo.jh > 0) no-lock:

find first jl where (ujo.jh = jl.jh) and (jl.gl = 287011) and (jl.dc = 'c')  no-lock no-error.
if avail jl then do:
find first tjl where (tjl.jh = jl.jh) and (tjl.gl = 100100) and (tjl.dam = jl.cam) no-lock no-error.
if avail tjl then do:
   v-chk1 = string(ujo.chk).

   if length(v-chk1) = 8 then do:
      v-chk2 = substr(v-chk1,5,4).
      v-chk1 = substr(v-chk1,1,4).
      create checks.
      assign checks.jh = ujo.jh
             checks.number = integer(v-chk2)
             checks.dop    = v-chk1
             checks.g_date = jl.whn
             checks.crsum  = jl.cam
             checks.d_date = ?
             checks.drsum  = 0
             checks.ost    = ''.
   end.

   create checks.
   assign checks.jh     = ujo.jh
          checks.number = integer(v-chk1)
          checks.dop    = v-chk2
          checks.g_date = jl.whn
          checks.crsum  = jl.cam
          checks.d_date = ?
          checks.drsum  = 0
          checks.ost    = ' '.

   v-itog1 = v-itog1 + jl.cam.
   v-chk1  = ''.
   v-chk2  = ''.
end. /* tjl */
end. /* jl  */
end. /* ujo */

for each ujo where (ujo.chk > 0) and ( ujo.whn >= v-dtb ) and ( ujo.whn <= v-dte ) and (ujo.jh > 0) no-lock:
find first jl where (ujo.jh = jl.jh) and (jl.gl = 287011) and (jl.dc = 'd') no-lock no-error.
if avail jl then do:
find first tjl where (tjl.jh = jl.jh) and (tjl.gl = 105210) and (tjl.dam = jl.cam) no-lock no-error.
if avail tjl then do:
find checks where checks.number = ujo.chk no-error.
if avail checks then do:
   checks.drsum  = jl.dam.
   checks.d_date = jl.whn.
   v-itog2       = v-itog2 + jl.dam.
end.
/*else do:
   create checks.
   assign checks.jh     = ujo.jh
          checks.number = ujo.chk
          checks.g_date = ?
          checks.crsum  = 0
          checks.d_date = jl.whn
          checks.drsum  = jl.dam
          checks.ost    = ' '.
end.*/ /* checks */
end. /* tjl */
end. /* jl  */
end. /* ujo */


for each ujo where (ujo.chk > 0) and ( ujo.whn >= v-dtb ) and ( ujo.whn <= v-dte ) and (ujo.jh > 0) no-lock:
find first jl where (ujo.jh = jl.jh) and (jl.gl = 287011) and (jl.dc = 'd') no-lock no-error.
if avail jl then do:
find first tjl where (tjl.jh = jl.jh) and (tjl.gl = 100100) and (tjl.dam = jl.cam) no-lock no-error.
if avail tjl then do:
find checks where checks.number = ujo.chk no-error.
if avail checks then do:
   checks.drsum  = jl.dam.
   checks.d_date = jl.whn.
   checks.ost    = 'stop pmnt'.
   v-itog2       = v-itog2 + jl.dam.
end.
/*else do:
   create checks.
   assign checks.jh     = ujo.jh
          checks.number = ujo.chk
          checks.g_date = ?
          checks.crsum  = 0
          checks.d_date = jl.whn
          checks.drsum  = jl.dam
          checks.ost    = 'stop pmnt'.
end.*/ /* checks */
end. /* tjl */
end. /* jl  */
end. /* ujo */
/*
for each checks.
v-ost      = ABSOLUTE(checks.crsum - checks.drsum).
checks.ost = string(v-ost).
v-itog3    = v-itog3 + v-ost.
end.
*/

v-itog3 = ABSOLUTE(v-itog1 - v-itog2).

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "РАСШИФРОВКА ДЕБИТОРСКОЙ И КРЕДИТОРСКОЙ ЗАДОЛЖЕННОСТИ"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>РАСШИФРОВКА ДЕБИТОРСКОЙ И КРЕДИТОРСКОЙ ЗАДОЛЖЕННОСТИ,<BR>
       ЧИСЛЯЩЕЙСЯ НА СЧЕТЕ 076805  на " /*+ string(v-dtb, "99/99/9999") +
              " по "*/ + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Вывод в отчет неакцептованных контрактов */

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Дата выдачи чека</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер чека</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Номер доп.чека</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дебет</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Кредит</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата списания</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Остаток</B></FONT></TD>" skip
   "</TR>" skip.

for each checks by checks.g_date.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + if checks.g_date = ? then ' ' else string(checks.g_date, "99/99/9999") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(checks.number) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + checks.dop + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(checks.drsum) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(checks.crsum) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if checks.d_date = ? then ' ' else string(checks.d_date, "99/99/9999") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + checks.ost + "</FONT></TD>" skip
   "</TR>" skip (1).
end.

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Итого</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" + ' ' + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + ' ' + "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(v-itog2) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(v-itog1) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" + ' '+ "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(v-itog3) + "</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

/* *** EXCEL  *** */
output to vcdata.csv.

put unformatted "РАСШИФРОВКА ДЕБИТОРСКОЙ И КРЕДИТОРСКОЙ ЗАДОЛЖЕННОСТИ, ЧИСЛЯЩЕЙСЯ НА СЧЕТЕ 076805  за период с "
                string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999") skip(1).
put unformatted 'Дата выдачи чека' ' ; '
                'Номер чека' ' ; '
	        'Номер доп.чека' ' ; '
	        'Дебет' ' ; '
	        'Кредит' ' ; '
	        'Дата списания' ' ; '
	        'Остаток' skip.

put fill('=',75) format 'x(75)' skip.
for each checks by checks.g_date.
put unformatted if checks.g_date = ? then ' ' else string(checks.g_date, "99/99/9999") ' ; '  
                checks.number ' ; '
                checks.dop    ' ; '
                checks.drsum  ' ; '
                checks.crsum  ' ; '
                if checks.d_date = ? then ' ' else string(checks.d_date, "99/99/9999") ' ; '
                checks.ost skip.
end.
put unformatted 'Итого'  ' ; '  
                ' '      ' ; '
                ' '      ' ; '
                v-itog2  ' ; '
                v-itog1  ' ; '
                ' '      ' ; '
                v-itog3.
                                       
output close.

unix silent cptwin vcdata.csv excel.


pause 0.
