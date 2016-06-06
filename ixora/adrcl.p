/* adrcl.p
 * MODULE
        Быстрые деньги
 * DESCRIPTION
        Отчет по клиентам программы Быстрые деньги
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
        20/01/05 kanat
 * CHANGES
*/

{comm-txb.i}
{global.i}

def var seltxb as int.
seltxb = comm-cod().

def var uu as char format "x(8)".
def var name as char format "x(30)".
def var v-mname as char.

def var v-ben-rnn as char format "x(12)".
def var v-ben-knp as char.

def var v-count1 as integer.
def var v-addr as char.

    update v-addr label 'Часть адреса клиента:' format 'x(50)' skip
    with side-label row 5 centered frame dataa .

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then
v-mname = ofc.name.
else do:
message "Неверный логин менеджера" view-as alert-box title "Внимание".
return.
end.

output to clrep.htm.
{html-start.i}

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Отчет по адресам клиентов, обслуживающихся по программе БЫСТРЫЕ ДЕНЬГИ <BR></FONT></P></B><BR>" 
   "<B>Исполнитель: </B>" v-mname ". <BR>" skip
   "<B>Дата: </B>" string(g-today) ". <BR>" skip
   "<B>Время: </B>" string(time,"HH:MM:SS") ". <BR><BR>" skip.

put unformatted
   "<TABLE width=""50%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR bgcolor=""#95B2D1"" align=""center"" valign=""top"">" skip
     "<TD><B>CIF</B></FONT></TD>" skip
     "<TD><B>Клиент</B></FONT></TD>" skip
     "<TD><B>Адрес клиента</B></FONT></TD>" skip
   "</TR>".                            

for each lon where (lon.grp = 90 or lon.grp = 92) no-lock.
for each cif where cif.cif = lon.cif no-lock.

if (cif.addr[1] matches "*" + v-addr + "*") or
   (cif.addr[2] matches "*" + v-addr + "*") or
   (cif.addr[3] matches "*" + v-addr + "*") then do:

v-count1 = v-count1 + 1.


put unformatted     "<TR><TD><B>" cif.cif "</B></TD>" skip  
                    "<TD>" cif.name "</TD>" skip
                    "<TD>" cif.addr[1]  " "  cif.addr[2]  " "  cif.addr[3]  "</TD></TR>" skip.

end.
end.
end.

put unformatted     "<TR bgcolor=""#95B2D1""><TD><B>ИТОГО</B></TD>" skip  
                    "<TD><B>" v-count1 "</B></TD>" skip
                    "<TD></TD></TR>" skip.

output close.

unix silent value("cptwin clrep.htm excel").
pause 0.


