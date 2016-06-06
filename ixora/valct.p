/* vcctcard.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Отчет по контрактам
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.3.9
 * AUTHOR
        22.02.05 saltanat
 * CHANGES
*/

{global.i}
def var v-year as inte format 'zzzz'.
def var v-sta as char format 'x(1)'.
def var i as inte init 0.
def temp-table tmp
    field ctnum as char
    field psnum as char
    field name  as char
    field sts   as char.

v-year = year(g-today).
v-sta = 'C'.

update v-year label 'Год              '
              validate (v-year >= 1991 and v-year <= year(g-today), 'Год должен быть между 1991 и текущим!') skip
       v-sta  label 'Статус контрактов'
              help 'A-активный; C-закрытый; N-новый'
              validate (upper(v-sta) = 'A' or upper(v-sta) = 'N' or upper(v-sta) = 'C' or v-sta = '','Нет такого типа контракта!')
with  centered side-label row 8 title " ДАННЫЕ " frame fr.       

for each vccontrs where year(vccontrs.ctdate) = v-year 
                    and if v-sta = '' then true else upper(vccontrs.sts) begins upper(v-sta) no-lock:
    for each vcps where vcps.contract = vccontrs.contract no-lock:
        find cif where cif.cif = vccontrs.cif no-lock no-error.
        if not avail cif then next.
        create tmp.
        assign tmp.ctnum = vccontrs.ctnum
               tmp.psnum = vcps.dnnum
               tmp.name = cif.name
               tmp.sts  = vccontrs.sts.
    end.
end.

i = 0.

output to scnreport.html .

{html-title.i}

put unformatted "<P align = ""center""><FONT style=""font:bold;font-size:16px"">"
                "<B>Отчет по контрактам " + string(v-year) + "года </B></FONT></P>" skip.

put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                "<TR style=""font:bold;font-size:14px"" align=""center"" bgcolor=""#868686"">"
                  "<TD> No </TD>"
                  "<TD> No контракта </TD>"
                  "<TD> No п/сделки </TD>"
                  "<TD> Наименование клиента </TD>"
                  "<TD> Статус </TD>"
                "</TR>" skip.
for each tmp by tmp.ctnum by tmp.psnum by tmp.name:
i = i + 1. 
put unformatted "<TR style=""font:bold;font-size:14px"" align=""center"">"
                  "<TD>" i "</TD>"
                  "<TD>" tmp.ctnum "</TD>"
                  "<TD>" tmp.psnum "</TD>"
                  "<TD>" tmp.name "</TD>"
                  "<TD>" tmp.sts "</TD>"
                "</TR>" skip .
end.

output close.

unix silent cptwin scnreport.html iexplore.

