/* pkpog1.p
 * MODULE
         Потребит кредитование
 * DESCRIPTION
        Список погашенных кредитов
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
        21/10/2009 marinav
 * CHANGES
        28/07/2011 madiyar - r-branch.i -> r-brfilial.i
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

{mainhead.i}
{comm-txb.i}
{nbankBik.i}
define var s-ourbank as char no-undo.
s-ourbank = comm-txb().

def var coun as int no-undo.
def var v-amtdue  as deci format '>>>>>>>>>>>9.9999' .
def var v-amtprov  as deci format '>>>>>>>>>>>9.9999' .
def new shared var datums as date no-undo format '99/99/9999' label 'С'.
def new shared var datums2 as date no-undo format '99/99/9999' label 'по'.


def new shared temp-table wrk no-undo
    field name     like bank.cif.name
    field fu       as   char
    field fil      as   char
    field lon      like bank.lon.lon
    field crc      like bank.crc.code
    field opnamt   like bank.lon.opnamt
    field opnamtKZ like bank.lon.opnamt
    field prem     like bank.lon.prem
    field rdt      like bank.lon.rdt
    field duedt    like bank.lon.rdt
    field dtcls    like bank.lnsch.stdat
    field amtdue   like bank.lon.opnamt
    field amtprov  like bank.lon.opnamt
    field pr_ref   as   char
    field gl       like bank.lon.gl.




datums2 = date(month(g-today),1,year(g-today)) - 1.
datums = date(month(datums2),1,year(datums2)).
update datums format '99/99/9999' validate(datums <= g-today, "Дата не может быть позже текущей!")
       datums2 format '99/99/9999' validate(datums2 <= g-today, "Дата не может быть позже текущей!") skip
       with side-label row 5 centered frame dat.

hide message no-pause.


{r-brfilial.i &proc = "pkpog2"}



find first cmp no-lock no-error.
define stream m-out.
output stream m-out to srok.htm.

put stream m-out unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 skip.

put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>"
                 skip.


put stream m-out unformatted "<tr align=""center""><td><h3> Погашенные кредиты с " string(datums,"99/99/9999") " по " string(datums2,"99/99/9999") "</h3></td></tr><BR><BR>" skip
                 "<TR><TD>&nbsp;</TD></TR>" skip(1).

put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>" skip
/*                  "<td bgcolor=""#C0C0C0"" align=""center"">Физ Юр</td>" */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Выданная сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Выданная сумма <br> в KZT</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата окончания</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата факт <br> погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД <br> в KZT на <br>дату погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма резерва</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Признак <br> реф-ия</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет Г/К</td>"
                  "</tr>" skip.

coun = 1.
for each wrk break by wrk.fil by wrk.name.

        put stream m-out unformatted "<tr align=""right"">" skip
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
/*               "<td align=""left""> " wrk.fu format "x(5)" "</td>"*/
               "<td align=""left""> " wrk.fil format "x(60)" "</td>"
               "<td align=""left"">&nbsp;" wrk.lon format "x(10)" "</td>"
               "<td align=""left""> " wrk.crc "</td>"
               "<td> " wrk.opnamt format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.opnamtKZ format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.prem format '>9' "</td>" skip
               "<td> " wrk.rdt "</td>" skip
               "<td> " wrk.duedt "</td>"
               "<td> " wrk.dtcls "</td>"
               "<td> " replace(trim(string(wrk.amtdue,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
               "<td> " replace(trim(string(wrk.amtprov,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
               "<td> " wrk.pr_ref "</td>" skip
               "<td> " wrk.gl "</td>" skip
               "</tr>" skip.
         v-amtdue = v-amtdue + wrk.amtdue.
         v-amtprov = v-amtprov + wrk.amtprov.
         coun = coun + 1.
end.

        put stream m-out unformatted "<tr bgcolor=""#C0C0C0"" align=""right"">" skip
               "<td> </td>"
               "<td  align=""left"" > <b>ИТОГО </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td> </td>"
               "<td><b> " replace(trim(string(v-amtdue,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
               "<td><b> " replace(trim(string(v-amtprov,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
               "<td> </td>"
               "<td> </td>"
               "</tr>" skip.

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

unix silent cptwin srok.htm excel.


