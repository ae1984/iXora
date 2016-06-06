/* p_garanpog.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Отчет - Гарантии, по которым настал срок погашения
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
        02/09/2013 galina ТЗ 1918
 * BASES
        BANK COMM
 * CHANGES
        03/08/2013 galina - указала базу COMM
        04/08/2013 galina - раскоментировала push.i
        04/08/2013 galina - перекомпеляция
*/

{global.i}
{push.i}
def new shared temp-table t-garanpros
     field filial    as char
     field aaa       like  aaa.aaa
     field regdt     like  aaa.regdt
     field expdt     like  aaa.expdt
     field srok      like  aaa.expdt
     field vid       as    character  format 'x(10)'
     field cif       like  cif.cif
     field name      like  cif.sname
     field crc       like  crc.code
     field ost       like  jl.dam     init 0
     index main is primary filial cif.
def stream m-out.
def var v-amtcrc as deci no-undo.
{r-branch.i &proc = "garanpog_txb(txb.info)"}

/*def var vfname as char init 'test.htm'.*/
output stream m-out to value(vfname).
{html-title.i
 &stream = " stream m-out "
 &size-add = "x-"
 &title = "FORTEBANK"
}

put stream m-out unformatted "<br><br><h3> ForteBank </h3>" skip
                             "<p><b>Просроченные гарантии на " + string(g-today,'99/99/9999') + "</b></p>".
put stream m-out unformatted "<table border=""1"" cellpadding=""11"" cellspacing=""0"" style=""border-collapse: collapse"">"
                             "<tr style=""font:bold"">"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Клиент</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Счет</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Валюта<br></td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Сумма<br>гарантии</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Дата<br>выдачи</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Срок погашения</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Конечная<br>дата гарантии</td>"
                             "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td></tr>" skip.
for each t-garanpros no-lock:
     put stream m-out unformatted  "<tr>"
                                   "<td>" t-garanpros.filial "</td>"
                                   "<td>" t-garanpros.name "</td>"
                                   "<td>" t-garanpros.aaa "</td>"
                                   "<td>" t-garanpros.crc "</td>"
                                   "<td>" replace(trim(string(t-garanpros.ost,'>>>>>>>>>>>>>9.99')),'.',',') "</td>"
                                   "<td>" string(t-garanpros.regdt,'99/99/9999') "</td>"
                                   "<td>" string(t-garanpros.expdt,'99/99/9999') "</td>"
                                   "<td>" string(t-garanpros.srok,'99/99/9999') "</td>"
                                   "<td>" t-garanpros.vid "</td></tr>" skip.


end.
put stream m-out unformatted "<tr><td></td><td></td><td>ИТОГО:</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" skip.
for each t-garanpros  no-lock break by t-garanpros.crc:
   accum t-garanpros.ost (total by t-garanpros.crc).
  if first-of(t-garanpros.crc) then v-amtcrc = 0.
  if last-of(t-garanpros.crc) then put stream m-out unformatted "<tr><td></td><td></td><td></td><td>" t-garanpros.crc "</td>"
                                        "<td>"  replace(trim(string(accum total by (t-garanpros.crc) (t-garanpros.ost),'>>>>>>>>>>>>>9.99')),'.',',') "</td><td></td><td></td><td></td><td></td></tr>" skip.

end.
put stream m-out unformatted "</table></TD></TR></TABLE>" skip.
{html-end.i "stream m-out"}

output stream m-out close.
/*unix silent cptwin value(vfname) excel.*/
vres = yes.
