/* r-cas.p
 * MODULE
        Обороты по счетам ГК 100100
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        22/05/07 marinav
 * CHANGES
        20/07/07 id00004 изменил надпись Бухгалтер-кассир на Бухгалтер по просьбе Крупкиной Н.
*/

{mainhead.i}

def new shared var v-from as date .
def new shared var v-to as date .
def new shared var v-glacc as int format ">>>>>>".
def var v-sum as deci.
 
     update
              v-from label "  С"  help " Задайте начальную дату отчета" skip
              v-to   label " ПО"  help " Задайте конечную дату отчета" skip
              with row 8 centered  side-label frame opt title "Задайте период отчета".
     hide frame  opt.


def new shared temp-table t-cas
    field jl as int
    field jdt as date
    field des as char  
    field dam as deci
    field cam as deci
    field ofc as char
    field point as char
    field crc as inte
    index pointcrc point crc jl. 
   
v-glacc = 100100.
    
{r-branch.i &proc = "r-cas2 (txb.name)"}

find first cmp.
define stream rep.
output stream rep to cas.htm.

put stream rep unformatted "<html><head><title>МКО НАРОДНЫЙ КРЕДИТ</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

put stream rep unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream rep unformatted "<tr align=""center""><td><h3>КАССОВАЯ КНИГА за период  " string(v-from) " по " string(v-to) "<BR>".
put stream rep unformatted "<br><br></h3></td></tr><tr></tr>" skip.


find last glday where glday.gl = v-glacc and glday.gdt < v-from  and glday.crc = 1 no-lock no-error.
if avail glday then do:
       put stream rep unformatted "<br><tr><td><table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"                  
                  "<td align=""left"" colspan=3>Остаток общей кассы на начало периода</td>"
                  "<td>" replace(trim(string(glday.bal, "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "<td></td><td></td>"
                   skip.
       put stream rep "</table>" skip.
       v-sum = glday.bal.
end.

for each t-cas break by t-cas.point .

    if first-of( t-cas.point )  then do:
       put stream rep unformatted "<tr align=""center""><td><h3>"  t-cas.point "<BR>".
       put stream rep unformatted "<br><br></h3></td></tr>" skip.
       put stream rep unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"                  
                  "<td>Дата</td>"
                  "<td>Номер <br> документа</td>"
                  "<td>Назначение Платежа</td>"
                  "<td>Дебет</td>"
                  "<td>Кредит</td>"
                  "<td>Кассир</td>"
                   skip.
    end.

     put stream rep unformatted "<tr align=""right"">"
               "<td align=""left"">&nbsp;" t-cas.jdt "</td>" skip
               "<td >" t-cas.jl "</td>" skip
               "<td align=""left"">&nbsp;" t-cas.des "</td>" skip
               "<td>" replace(trim(string(t-cas.dam, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(t-cas.cam, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" t-cas.ofc "</td>" skip
               "</tr>".      

    accumulate t-cas.dam (total by t-cas.point).
    accumulate t-cas.cam (total by t-cas.point).

    if last-of( t-cas.point )  then do:
      put stream rep unformatted "<tr align=""right"">"
               "<td><b>Итого</td><td></td><td></td>" skip
               "<td><b>" replace(trim(string((accum total by t-cas.point t-cas.dam), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td><b>" replace(trim(string((accum total by t-cas.point t-cas.cam), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td></td>" skip
               "</tr>".      
      put stream rep unformatted "<tr align=""right"">"
               "<td><b>Остаток кассы</td><td></td><td></td>" skip
               "<td></td>" skip
               "<td><b>" replace(trim(string(((accum total by t-cas.point t-cas.dam) - (accum total by t-cas.point t-cas.cam)), "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td></td>" skip
               "</tr>".      
      put stream rep "</table>" skip.

       put stream rep unformatted "<br><tr><td><table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr></tr><tr><td align=""right"" colspan=6>Бухгалтер ___________________________________________________</td></tr>"
                  "<tr><td align=""right"" colspan=6>Главный бухгалтер ___________________________________________________</td></tr><tr></tr>"
                   skip.
       put stream rep "</table>" skip.
      v-sum = v-sum + (accum total by t-cas.point t-cas.dam) - (accum total by t-cas.point t-cas.cam).
    end.

end.

       put stream rep unformatted "<br><tr><td><table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"                  
                  "<td align=""left"" colspan=3>Остаток общей кассы на конец периода</td>"
                  "<td>" replace(trim(string(v-sum, "->>>>>>>>>>>9.99")),".",",") "</td>"
                  "<td></td><td></td>"
                   skip.
       put stream rep "</table>" skip.

put stream rep "</table></body></html>" skip.
output stream rep close.

unix silent cptwin cas.htm excel.
