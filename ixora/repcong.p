/* repcong.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
            10/10/2012 Luiza
 * BASES
        BANK
 * CHANGES
                24/06/2013 Luiza  -  ТЗ 1921
*/


{mainhead.i}

def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var v-sel2 as int no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.

define new shared temp-table wrk no-undo
    field txb as char
    field fil as char
    field num as int
    field podr as int
    field podrname as char
    field id as char
    field fio as char
    field f as char
    field kol as int
    index ind1 is primary txb id .

define new shared temp-table wrk1 no-undo
    field txb as char
    field fil as char
    field num as int
    field podr as int
    field podrname as char
    field id as char
    field fio as char
    field f as char
    field kol as int
    field doc as char
    index ind1 is primary txb id .


def var v as int.
def new shared var ch as char.
def new shared var v-id as char.
def new shared var v-ful1 as logic format "да/нет".

run sel2 (" ОТЧЕТ ", "1. Операционный отдел  |2. Отдел кассовых операций |3. ОО / ОКО |4. id |5. ВЫХОД ", output v-sel2).
if keyfunction (lastkey) = "end-error" then return.
case v-sel2:
    when 1 then ch = "Операционного отдела".
    when 2 then ch = "Отдела кассовых операций".
    when 3 then ch = "ОО / ОКО".
    when 4 then do:
        displ v-id label "id сотрудника" format "x(7)" validate(v-id <> "", "Некорректное id!") skip
        with side-label row 6 centered frame vid.
        update v-id with frame vid.

        hide frame dat.
        ch = "".
    end.
end.
dt2 = g-today.
dt1 = dt2.

displ dt1 label " С " format "99/99/9999" validate( dt1 <= g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate( dt2 >= dt1, "Некорректная дата!") skip
      v-ful1 label " С расшифровкой " skip
with side-label row 6 centered frame dat.

update dt1 with frame dat.
update dt2 v-ful1 with frame dat.

hide frame dat.

{r-brfilial.i &proc = "repcong1"}

/*run txbs ("repcong1").*/
hide message no-pause.
v = 1.
for each wrk.
    wrk.num = v.
    v = v + 1.
end.
if v-fil-int > 1 then v-fil-cnt = "консолидированный отчет".

def stream v-out.
def stream v-out1.
output stream v-out to rep.html.
put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h3>Отчет по загруженности работников " ch " за период с " string(dt1) " по " string(dt2) " (" v-fil-cnt ")" "</h3>" skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
put stream v-out unformatted "<tr align=center>"
 "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>№ п/п</B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Подразделение </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id работника </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ФИО<br>работника </B></FONT></TD>"  skip
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> количество <br> проводок </B></FONT></TD>" skip
"</tr>" skip.
for each wrk break by wrk.txb:
    if first-of(wrk.txb) then do:
        if v-fil-int > 1 then put stream v-out  unformatted "<TR> <td><TD bgcolor=""#95B2D1""><align=""left"">" wrk.fil "</TD></td></TR>" skip.
    end.
    put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk.num "</TD>" skip
    "<TD align=""left"">" wrk.podrname "</TD>" skip
    "<TD align=""left"">" wrk.id "</TD>" skip
    "<TD align=""left"">" wrk.fio "</TD>" skip
    "<TD align=""left"">" wrk.kol "</TD>" skip.
    /*"<TD align=""left"">" wrk.f "</TD>" skip.*/
end.
put stream v-out unformatted "</table>".
output stream v-out close.
unix silent value("cptwin rep.html excel").

if v-ful1 then do:
    output stream v-out1 to rep1.html.
    put stream v-out1 unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out1 unformatted  "<h3>Отчет по загруженности работников " ch " за период с " string(dt1) " по " string(dt2) " (" v-fil-cnt ")" "</h3>" skip.

    put stream v-out1 unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out1 unformatted "<tr align=center>"
     "<TD bgcolor=""#95B2D1""><FONT size=""2""><B>№ п/п</B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> Подразделение </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> id работника </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> ФИО<br>работника </B></FONT></TD>"  skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> количество <br> проводок </B></FONT></TD>" skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> транз </B></FONT></TD>" skip
         "<TD bgcolor=""#95B2D1""><FONT size=""2""><B> докум </B></FONT></TD>" skip
    "</tr>" skip.
    for each wrk1 break by wrk1.txb:
        if first-of(wrk1.txb) then do:
            if v-fil-int > 1 then put stream v-out1  unformatted "<TR> <td><TD bgcolor=""#95B2D1""><align=""left"">" wrk1.fil "</TD></td></TR>" skip.
        end.
        put stream v-out1  unformatted "<TR> <TD><align=""left"">" wrk1.num "</TD>" skip
        "<TD align=""left"">" wrk1.podrname "</TD>" skip
        "<TD align=""left"">" wrk1.id "</TD>" skip
        "<TD align=""left"">" wrk1.fio "</TD>" skip
        "<TD align=""left"">" wrk1.kol "</TD>" skip
        "<TD align=""left"">" wrk1.f "</TD>" skip
        "<TD align=""left"">" wrk1.doc "</TD>" skip.
    end.
    put stream v-out1 unformatted "</table>".
    output stream v-out1 close.
    unix silent value("cptwin rep1.html excel").
end.
hide message no-pause.
return.
