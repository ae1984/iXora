/* scanrep.p
 * MODULE
        Отчет по сканированным платежам
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
        5.11.13.1
 * AUTHOR
        05.01.2005 suchkov
 * CHANGES
        18.02.2005 saltanat - Сделала разбивку по ЦО и рко.
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
        field acc    like aaa.aaa
        field clamt  as   decimal initial 0
        field clcoun as   integer initial 0
        field gramt  as   decimal initial 0
        field grcoun as   integer initial 0
index idx dep.


update "Введите период" bdate label "С " edate label "ПО " 
with centered row 8 frame fr.

for each remtrz where remtrz.rdt >= bdate and remtrz.rdt <= edate and remtrz.source = "SCN" no-lock .

        find aaa where aaa.aaa = remtrz.sacc no-lock .
        if not avail aaa then next.
        
        find first cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then v-dep = get-dep(cif.fname,g-today).
        else v-dep = 1.
                                     
        find trep where trep.acc = aaa.aaa and trep.dep = v-dep no-error .
        if not available trep then do:
                find cif where cif.cif = aaa.cif no-lock .
                create trep. 
	            assign trep.dep  = v-dep
	                   trep.name = cif.name 
	                   trep.cif  = cif.cif  
	                   trep.acc  = aaa.aaa  .
        end.
        if remtrz.cover = 2 then assign trep.gramt = trep.gramt + remtrz.amt trep.grcoun = trep.grcoun + 1 .
                            else assign trep.clamt = trep.clamt + remtrz.amt trep.clcoun = trep.clcoun + 1 .
        
end.
  
output to scnreport.html .

{html-title.i}
put unformatted "<P align = ""center""><FONT style=""font:bold;font-size:16px"">"
                "<B>Отчет по сканированным слатежам<br>за период с " + string(bdate, "99/99/9999") + " по " + string(edate, "99/99/9999")
                "</B></FONT></P>" skip.
put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                "<TR style=""font:bold;font-size:14px"" align=""center"" bgcolor=""#868686"">"
                "<TD rowspan=3> No.                  </TD>"
                "<TD rowspan=3> Наименование клиента </TD>"
                "<TD rowspan=3> Счет                 </TD>"
                "<TD colspan=6> Сканированные платежи</TD></TR>"
                "<TR style=""font:bold;font-size:14px"" align=""center"" bgcolor=""#868686"">"
                "<TD colspan=2> Клиринг              </TD>"
                "<TD colspan=2> Гросс                </TD>"
                "<TD colspan=2> Итого                </TD></TR>" 
                "<TR style=""font:bold;font-size:14px"" align=""center"" bgcolor=""#868686"">"
                "<TD> Сумма      </TD>"
                "<TD> Количество </TD>"
                "<TD> Сумма      </TD>"
                "<TD> Количество </TD>"
                "<TD> Сумма      </TD>"
                "<TD> Количество </TD></TR>" skip .

for each trep break by trep.dep by trep.cif .

    if first-of(trep.dep) then do:
       i = 0 .
       
       find first ppoint where ppoint.depart = trep.dep no-lock no-error.
       if avail ppoint then v-depname = ppoint.name.
       else next.
       
       put unformatted "<TR style=""font-size:14px"" align = ""center"" bgcolor=""#C0C0C0"">"
	                    "<TD colspan = 9><b>" v-depname "</b></TD>"
                       "</TR>" skip.
    end.

        i = i + 1 .

    put unformatted "<TR style=""font-size:14px"">"
                    "<TD>" i                               "</TD>"
                    "<TD>"       trep.name                 "</TD>"
                    "<TD>&nbsp;" trep.acc                  "</TD>"
                    "<TD>"       trep.clamt                "</TD>"
                    "<TD>"       trep.clcoun               "</TD>"
                    "<TD>"       trep.gramt                "</TD>"
                    "<TD>"       trep.grcoun               "</TD>"
                    "<TD>"       trep.clamt + trep.gramt   "</TD>"
                    "<TD>"       trep.clcoun + trep.grcoun "</TD>"
                    "</TR>" skip.

end.

output close.

unix silent cptwin scnreport.html excel.









                