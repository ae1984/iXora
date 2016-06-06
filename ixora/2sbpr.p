/* 2sbpr.p
 * MODULE
        Название Программного Модуля
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
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       25/04/2012 evseev  - rebranding. Название банка из sysc.
       27/04/2012 evseev  - повтор
*/


{global.i}
{nbankBik.i}

def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-summa as char format "x(10)".
def var i as int.
def var crlf as char.
def new shared  variable v-dt     as date format "99/99/9999".
def new shared  variable v-dtn    as date format "99/99/9999".

def new shared temp-table vsb2
             field nn as int
             field name as char
             field sumnk as decimal format 'z,zzz,zzz,zz9-'
             field sumnkp as decimal format 'z,zzz,zzz,zz9-'
             field sumdk as decimal format 'z,zzz,zzz,zz9-'
             field sumdkp as decimal format 'z,zzz,zzz,zz9-'
             field sumvk as decimal format 'z,zzz,zzz,zz9-'
             field sumvkp as decimal format 'z,zzz,zzz,zz9-'
             field sumnd as decimal format 'z,zzz,zzz,zz9-'
             field sumndp as decimal format 'z,zzz,zzz,zz9-'
             field sumdd as decimal format 'z,zzz,zzz,zz9-'
             field sumddp as decimal format 'z,zzz,zzz,zz9-'
             field sumvd as decimal format 'z,zzz,zzz,zz9-'
             field sumvdp as decimal format 'z,zzz,zzz,zz9-'.

v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip with side-label row 5 centered frame dat .

v-dtn = date('01' + substring(string(v-dt),3)) - 1.
crlf = chr(10) + chr(13).

i = 1.
repeat :
  create vsb2.
  nn  = i.
  sumnk = 0.
  sumnkp = 0.
  sumdk = 0.
  sumdkp = 0.
  sumvk = 0.
  sumvkp = 0.
  sumnd = 0.
  sumndp = 0.
  sumdd = 0.
  sumddp = 0.
  sumvd = 0.
  sumvdp = 0.
  if i = 1 then vsb2.name = 'Займы, предоставленные юридическим и физическим лицам за отчетный период, всего'.
  if i = 2 then vsb2.name = ' - краткосрочные'.
  if i = 3 then vsb2.name = ' - долгосрочные'.
  if i = 4 then vsb2.name = 'Ссудная задолженность на конец отчетного периода '.
  if i = 5 then vsb2.name = ' - краткосрочные'.
  if i = 6 then vsb2.name = ' - долгосрочные'.
  i = i + 1.
  if i = 7 then leave.
end.

{r-brfilial.i &proc = "2sbpr_b"}



define stream m-out.
output stream m-out to 2sbpr.html.

put stream m-out "<html><head><title>" + v-nbankru + "</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" crlf skip.

put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf.

put stream m-out "<tr align=""center""><td><h3>Расшифровка по займам, предоставленным клиентам в СКВ, и ставках вознаграждения по ним за "
                 string(v-dt) "</h3></td></tr><br><br>"
                 crlf crlf.
 put stream m-out "<br><br><tr></tr>" skip.


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3></td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=3>Шифр строки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=6>Юридическим лицам в валюте</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=6>Физическим лицам в валюте</td>"
                  "</tr>" skip.

       put stream m-out
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>доллар США</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>ЕВРО</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>другие виды СКВ</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>доллар США</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>ЕВРО</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>другие виды СКВ</td>"
                  "</tr>" skip.

       put stream m-out
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" >%</td>"
                  "</tr> ".


for each vsb2:
        put stream m-out "<tr align=""right"">"
               "<td align=""left""> " vsb2.name format "x(90)" "</td>"
               "<td align=""center""> " string(nn) "</td>"
               "<td > " round(sumnk / 1000, 0) format 'zzzzzzzzz9-' "</td>"
               "<td > " if round(sumnkp * 100 / sumnk,1) = ? then 0 else round(sumnkp * 100 / sumnk,1) format 'zzzzz9.9' "</td>"
               "<td > " round(sumdk / 1000, 0) format 'zzzzzzzzz9-' "</td>"
               "<td > " if round(sumdkp * 100 / sumdk,1) = ? then 0 else round(sumdkp * 100 / sumdk,1) format 'zzzzz9.9' "</td>"
               "<td > " round(sumvk / 1000, 0) format 'zzzzzzzzz9-' "</td>"
               "<td > " if round(sumvkp * 100 / sumvk,1) = ? then 0 else round(sumvkp * 100 / sumvk,1) format 'zzzzz9.9' "</td>"
               "<td > " round(sumnd / 1000, 0) format 'zzzzzzzzz9-' "</td>"
               "<td > " if round(sumndp * 100 / sumnd,1) = ? then 0 else round(sumndp * 100 / sumnd,1) format 'zzzzz9.9'  "</td>"
               "<td > " round(sumdd / 1000, 0) format 'z,zzz,zzzzz9-' "</td>"
               "<td > " if round(sumddp * 100 / sumdd,1) = ? then 0 else round(sumddp * 100 / sumdd,1) format 'zzzzz9.9'  "</td>"
               "<td > " round(sumvd / 1000, 0) format 'zzzzzzzzz9-'  "</td>"
               "<td > " if round(sumvdp * 100 / sumvd,1) = ? then 0 else round(sumvdp * 100 / sumvd,1) format 'zzzzz9.9' "</td>"
               "</tr>" crlf skip .

end.


put stream m-out "</table></tr></table>" skip.
put stream m-out "</body></html>" crlf.
output stream m-out close.
unix silent cptwin 2sbpr.html excel.exe.



