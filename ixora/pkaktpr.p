/* pkaktpr.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Акт приема-передачи
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-4-9-1
 * AUTHOR
        05/02/2007 Natalya D.
 * BASES
        bank
 * CHANGES
        20/04/2007 madiyar - добавил из новой библиотеки
*/

{global.i}
def var dt1 as date format "99/99/9999".
def var dt2 as date format "99/99/9999".
def var d   as date no-undo.
def var v-dep as int no-undo.
def var ofc-name as char no-undo.
def var i as int init 0 no-undo.
def var v-str as char init '' no-undo.
def var v-month as char no-undo.
def var pp-name as char no-undo.
def var v-nbsp as char no-undo.
def temp-table t-lon no-undo
         field lon like lon.lon
         field cif like lon.cif
         field name like cif.name
         field jdt like lonres.jdt. 
update dt1 label " C "dt2 label " ПО "
with frame dat title "Введите период".

do d = dt1 to dt2 :
 for each lonres where lonres.jdt = d and lonres.dc = 'd' no-lock.
     if lookup(lonres.trx,'lon0001,lon0002,lon0003,lon0004,lon0005,lon0006,lon0052') = 0 then next.

     if lonres.who <> g-ofc then next.
     find lon where lon.lon = lonres.lon and (lon.grp = 90 or lon.grp = 92) no-lock no-error.
     if not avail lon then next.
     find cif where cif.cif = lon.cif no-lock no-error.
     if not avail cif then next.

     create t-lon.            
            t-lon.lon = lon.lon.
            t-lon.cif = lon.cif.
            t-lon.name = cif.name.
            t-lon.jdt = lonres.jdt.                       
 end.
end. 

case month(g-today) :
 when 1  then v-month = 'января'.
 when 2  then v-month = 'февраля'.
 when 3  then v-month = 'марта'.
 when 4  then v-month = 'апреля'.
 when 5  then v-month = 'мая'.
 when 6  then v-month = 'июня'.
 when 7  then v-month = 'июля'.
 when 8  then v-month = 'августа'.
 when 9  then v-month = 'сентября'.
 when 10 then v-month = 'октября'.
 when 11 then v-month = 'ноября'.
 when 12 then v-month = 'декабря'.
end.

v-nbsp = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.
output to ord1.html.
{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""3"" border=""0"">" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">" v-nbsp "АКТ</td></tr>" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">" v-nbsp "приема-передачи кредитных досье</td></tr>" skip
                         "<tr><td align=""center"" style=""font:bold;font-size:12.0pt;"">" v-nbsp "за период с " dt1 format "99/99/9999" " по " dt2  format "99/99/9999" "</td></tr>" skip.
    put unformatted "</table>" skip.
    
    put unformatted  "<br><br>".    
    find first cmp.
    put unformatted  "<P style='text-align:justify'>     Настоящий Акт приема-передачи составлен " month(g-today) ' ' v-month ' ' year(g-today) " года в " entry(1, cmp.addr[1]) " и свидетельствует о том," .
    
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    v-dep = ofc.regno mod 1000.
    ofc-name = ofc.name.
    find first ppoint where ppoint.depart = v-dep no-lock no-error.
    if not avail ofc and not avail ppoint then next.
    
    if v-dep = 1 then pp-name = 'Центрального офиса'.
    else pp-name = ppoint.name.

    put unformatted  " что я, менеджер " pp-name " " ofc-name "(" g-ofc ")" " передал(-а), а сотрудник Департамента кредитного администрирования ___________________________________ "
                      "принял (-а) кредитные досье по следующим заемщикам: </P>" skip.
    
    put unformatted  "<br><br>".
    
    put unformatted   "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                  "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                  "<td align=center>N</td>"
                  "<td align=center>ФИО Заемщика</td>"
                  "<td align=center>Дата выдачи кредита</td>"                  
                  "</tr>" skip.
    for each t-lon no-lock.
        i = i + 1.
    put unformatted 
       "<TR align=""center"" style=""font-size:6.5pt"">"
       "<TD>" i "</TD>" skip
       "<TD>" t-lon.name format "x(30)" "</TD>" skip
       "<TD>" t-lon.jdt "</TD>" skip       
       "</TR>" skip.
    end.
    
    do i = 0 to length(ofc-name) - 1 :
       v-str = v-str + '_'.
    end. 
     put unformatted "</table>" skip.     
     put unformatted "<br><br>".
     put unformatted "<br> Настоящий акт составлен в двух экземплярах. " skip.
     put unformatted "<br><br>".          
     put unformatted "<br>Передал(-а)  " ofc-name " /___________/" skip.
     put unformatted "<br>".
     put unformatted "<br>Принял(-а)  " v-str " /___________/" skip.
     put unformatted "<br clear=all style='page-break-before:always'>" skip.


put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin ord1.html winword.

