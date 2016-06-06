/* repjlcall.p
 * MODULE
       Кредиты
 * DESCRIPTION
         Отчет по исполнению решений КК (внутренний аудит)
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
        04/09/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        08/09/2009 galina - перекомпиляция 
*/

{global.i}


def new shared temp-table t-jl
  field bank as char
  field jlnum as integer
  field jldt as date  
  field ofc as char
  field dgl as integer
  field dacc as char
  field cgl as integer
  field cacc as char
  field summ as decimal
  field rem as char
  index ind1 is primary bank dgl cgl.

def buffer b-jl for t-jl.

def var v-dt1 as date.
def var v-dt2 as date.  
def var v-gllist as char init '186050,713014,713040,713060,717000,718000'.
def var i as integer.
def stream v-out.


update v-dt1 label 'Период с' format '99/99/9999' validate (v-dt1 <= g-today, " Дата должна быть не позже текущей!") 
       v-dt2 label '  по' format '99/99/9999' validate (v-dt2 <= g-today, " Дата должна быть не позже текущей!") skip
       skip with side-label row 5 centered frame dat.

{r-brfilial.i &proc = "repjl(txb.bank, v-dt1, v-dt2)"}

find first t-jl no-lock no-error.
if not avail t-jl then return.
output stream v-out to jl.xls.
{html-title.i
 &title = "METROCOMBANK" &stream = "stream v-out" &size-add = "x-"}
put stream v-out unformatted
"<TABLE border=""1"" cellpadding=""10"" cellspacing=""0"">" skip.
put stream v-out unformatted 
     "<tr style=""font:bold"" align=""center"" >"
     "<td bgcolor=""#C0C0C0"">№</td>"
     "<td bgcolor=""#C0C0C0"">Дата</td>"
     "<td bgcolor=""#C0C0C0"">Исполнитель</td>"
     "<td bgcolor=""#C0C0C0"">ДСГК</td>"
     "<td bgcolor=""#C0C0C0"">Счет дебета</td>"
     "<td bgcolor=""#C0C0C0"">КСГК</td>"
     "<td bgcolor=""#C0C0C0"">Счет кредита</td>"
     "<td bgcolor=""#C0C0C0"">Сумма</td>"
     "<td bgcolor=""#C0C0C0"">Примечание</td></tr>" skip.


for each t-jl break by t-jl.bank:

  if first-of(t-jl.bank) then do:
    find first txb where txb.bank = t-jl.bank no-lock no-error.
    
    put stream v-out unformatted 
      "<tr style=""font:bold"" align=""left"">"
      "<td bgcolor=""#C0C0C0"" colspan = ""9"">" txb.info "</td>" skip.
  do i = 1 to num-entries(v-gllist):
     find first b-jl where b-jl.bank = t-jl.bank and (b-jl.dgl =  integer(entry(i,v-gllist)) or  b-jl.cgl =  integer(entry(i,v-gllist))) no-lock no-error.
     if avail b-jl then do:
        
        case i:
           when 1  then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Начисленная пеня 186050</td></tr>" skip.
           when 2 then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Начисленные проценты (внесистемно) 717000</td></tr>" skip.

           when 3 then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Начисленные штрафы (внесистемно) 718000</td></tr>" skip.

           when 4 then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Списаный основной долг 713014</td></tr>" skip.

           when 5 then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Списанные проценты 713040</td></tr>" skip.

           when 6 then put stream v-out unformatted 
                      "<tr style=""font:bold"" align=""left"">"
                      "<td colspan = ""9"">Штрафы списанные за баланс 713060</td></tr>" skip.

        end. /*case*/
        for each b-jl where b-jl.bank = t-jl.bank and (b-jl.dgl =  integer(entry(i,v-gllist)) or  b-jl.cgl =  integer(entry(i,v-gllist))) no-lock:
           put stream v-out unformatted 
             "<tr>"
             "<td>" string(b-jl.jlnum) "</td>"
             "<td>" string(b-jl.jldt,'99/99/9999') "</td>"
             "<td>" b-jl.ofc "</td>"
             "<td>" string(b-jl.dgl) "</td>"
             "<td>" string(b-jl.dacc) "</td>"
             "<td>" string(b-jl.cgl) "</td>"
             "<td>" string(b-jl.cacc) "</td>"
             "<td>" replace(trim(string(b-jl.summ,'>>>>>>>>>>>>>9.99')),'.',',') "</td>"
             "<td>" b-jl.rem "</td></tr>" skip.
        end.
     end. 
  end.   
    end. 
end.

put stream v-out unformatted "</table></body></html>" skip.
output stream v-out close.
unix silent("cptwin jl.xls excel").
unix silent rm -f jl.xls.


unix silent('cptwin /data/log/bxcif-del.log wordpad').
  