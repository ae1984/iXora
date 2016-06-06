/* scanrep.p
 * MODULE
        Отчет по клиентам с признаками сканирования 
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.11.13.2
 * AUTHOR
        18.02.2005 saltanat
 * CHANGES
        
*/

{global.i}
{get-dep.i}

def var bdate as date .
def var edate as date initial today.
def var i     as integer initial 0.
def var v-dep as inte.
def var v-depname as char.

define temp-table trep 
        field dep    as inte
        field name   like cif.name
        field cif    like cif.cif
        field rdt    as char       
index idx dep cif.

update "Введите период" bdate label "С " edate label "ПО "
with centered row 8 frame fr.

for each sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "scann" no-lock:
    if sub-cod.rcode = '' then next.
    if date(entry(2,sub-cod.rcode)) < bdate or date(entry(2,sub-cod.rcode)) > edate then next.
    
    find cif where cif.cif = sub-cod.acc no-lock no-error.
    if not avail cif then next.
    
    v-dep = get-dep(cif.fname,g-today).
    
    find trep where trep.cif = cif.cif no-lock no-error.
    if avail trep then next.
    create trep.
    assign trep.dep = v-dep
           trep.cif = cif.cif
           trep.name = cif.name
           trep.rdt  = entry(2,sub-cod.rcode).     
end.

output to scnreport.html .

{html-title.i}
put unformatted "<P align = ""center""><FONT style=""font:bold;font-size:16px"">"
                "<B>Отчет по подключившемся клиентам<br>за период с " + string(bdate, "99/99/9999") + " по " + string(edate, "99/99/9999")
                "</B></FONT></P>" skip.
put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                "<TR style=""font:bold;font-size:14px"" align=""center"" bgcolor=""#868686"">"
                "<TD> No.                  </TD>"
                "<TD> Клиент </TD>"
                "<TD> Наименование клиента </TD>"
                "<TD> Дата подключения </TD></TR>" skip .

for each trep break by trep.dep by trep.cif by date(trep.rdt).

    if first-of(trep.dep) then do:
       i = 0 .
       
       find first ppoint where ppoint.depart = trep.dep no-lock no-error.
       if avail ppoint then v-depname = ppoint.name.
       else next.
       
       put unformatted "<TR style=""font-size:14px"" align = ""center"" bgcolor=""#C0C0C0"">"
	                    "<TD colspan = 4><b>" v-depname "</b></TD>"
                       "</TR>" skip.
    end.

        i = i + 1 .

    put unformatted "<TR style=""font-size:14px"">"
                    "<TD>" i         "</TD>"
                    "<TD>" trep.cif  "</TD>"
                    "<TD>" trep.name "</TD>"
                    "<TD>" trep.rdt  "</TD>"
                    "</TR>" skip. 
end.

output close.

unix silent cptwin scnreport.html iexplore.









                