/* loan.p
 * MODULE
        3-4-2-16-19
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
        21.06.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        29.06.2011 aigul - добавила валюту займа
*/
{global.i}
def var v-txblist as char.
def var d1 as date no-undo.
def new shared temp-table wrk
    field i as int
    field bank as char
    field cif as char
    field cname as char
    field lon as char
    field dog as char
    field dt as date
    field sts as char
    field sum as decimal
    field prc as decimal
    field srok as int
    field prc1 as decimal
    field srok1 as int
    field n-prc as decimal
    field a-prc as decimal
    field o-prc as decimal
    field od as decimal
    field perc as decimal
    field days as int
    field a-prc1 as decimal
    field o-prc1 as decimal
    field prbal as decimal
    field przbal as decimal
    field penpog as decimal
    field pensbal as deci
    field penszbal as decimal
    field penna as deci
    field pennazbal as deci
    field prpolkzt as deci
    field prres as char
    field prod as int
    field prpr as int
    field prkol as int
    field prmax as int
    field lcrc as char.
def var i as int.
def var j as int.
i = 0.
j = 0.
d1 = g-today.
def new shared var v-bank as char.
def var v-bname as char.
def new shared var d-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
end.
if connected ("txb") then disconnect "txb".
for each comm.txb where /*comm.txb.bank = "TXB16" and*/ comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,"/data/","/data/b") + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    v-bank = comm.txb.bank.
    run loan1(d1).
    disconnect "txb".
end.



def stream vcps.
output stream vcps to "loan.htm".

put stream vcps unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream vcps unformatted
   "<TABLE  border=""1"" cellspacing=""4"" cellpadding=""0"">" skip
   "<TR align=""center"" valign=""center"" style=""font:boldborder-collapse: collapse""><font size=""4"">" skip
   "<td align=""center"" width = ""10%"">№ </td>"
   "<td align=""center"" width = ""10%"">cif клиента</td>"
   "<td align=""center"" width = ""20%"">ФИО заемщика</td>"
   "<td align=""center"" width = ""40%"">Номер договора</td>"
   "<td align=""center"" width = ""20%"">Дата заключ. Договора</td>"
   "<td align=""center"" width = ""10%"">Валюта займа</td>"
   "<td align=""center"" width = ""20%"">Статус займа</td>"
   "<td align=""center"" width = ""10%"">Сумма выданного займа, в тенге</td>"
   "<td align=""center"" width = ""10%"">Ставка вознаграждения</td>"
   "<td align=""center"" width = ""10%"">Срок кредита в месяцах</td>"
   "<td align=""center"" width = ""10%"" colspan = 3>Сумма вознаграждения, подлежащая выплате за весь период кредитования, рассчитанная по методу:</td>"
   "<td align=""center"" width = ""10%"">Остаток<br>Основного Долга</td>"
   "<td align=""center"" width = ""10%"">Сумма выплаченного вознаграждения <br> на дату</td>"
   "<td align=""center"" width = ""10%"">Кол-во месяцев <br> пользования кредитом</td>"
   "<td align=""center"" width = ""10%"" colspan = 2>Сумма вознаграждения, <br> рассчитанная по факт. кол-ву мес. пользования кредитом</td>"
    "<td align=""center"" width = ""10%"">Начисленные %% в балансе <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Начисленные %% за балансом <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Пеня погашенная <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Пеня списанная балансовая <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Пеня списанная забалансовая <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Пеня начисленная <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Штрафы начисленные за балансом </td>"
    "<td align=""center"" width = ""10%"">Полученные %% в KZT </td>"
    "<td align=""center"" width = ""10%"">Признак реструктуризации <br> на дату</td>"
    "<td align=""center"" width = ""10%"">Дней просрочки ОД </td>"
    "<td align=""center"" width = ""10%"">Дней просрочки %% </td>"
    "<td align=""center"" width = ""10%"">Кол-во просрочек </td>"
    "<td align=""center"" width = ""10%"">Макс.дней находжения в просрочке </td>"
   "</FONT></B>" skip.
put stream vcps unformatted
   "<TR align=""center"">" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2"">'Как по экспресс-кредитам'</TD>" skip
     "<TD rowspan=""2"">Аннуитет</TD>" skip
     "<TD rowspan=""2"">На остаток</TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2"">Аннуитет</TD>" skip
     "<TD rowspan=""2"">На остаток</TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
     "<TD rowspan=""2""></TD>" skip
   "</TR>" skip.
put stream vcps unformatted
   "</TR>" skip.
for each wrk no-lock break by wrk.bank.
    find first comm.txb where comm.txb.bank = wrk.bank and comm.txb.consolid = true no-lock no-error.
    if avail comm.txb then  v-bname = comm.txb.name.
    if first-of(wrk.bank) then do:
            put stream vcps  unformatted "<tr><td>" v-bname "</td>" skip.
        end.
        /*if first-of(wrk.cif) then do:*/
        j = j + 1.
        put stream vcps  unformatted
            "<tr align=""center""><font size=""4"">"
            "<td>" j "</td>" skip
            "<td>" wrk.cif "</td>" skip
            "<td>" wrk.cname "</td>" skip
            "<td>" wrk.dog "</td>" skip
            "<td>" wrk.dt "</td>" skip
            "<td>" wrk.lcrc "</td>" skip
            "<td>" wrk.sts "</td>" skip
            "<td>" wrk.sum "</td>" skip
            "<td>" wrk.prc1 "</td>" skip
            "<td>" wrk.srok1 "</td>" skip
            "<td>" wrk.n-prc "</td>" skip
            "<td>" wrk.a-prc "</td>" skip
            "<td>" wrk.o-prc "</td>" skip
            "<td>" wrk.od "</td>" skip
            "<td>" wrk.perc "</td>" skip
            "<td>" wrk.days "</td>" skip
            "<td>" wrk.a-prc1 "</td>" skip
            "<td>" wrk.o-prc1 "</td>" skip
            "<td>" wrk.prbal "</td>" skip
            "<td>" wrk.przbal "</td>" skip
            "<td>" wrk.penpog "</td>" skip
            "<td>" wrk.pensbal "</td>" skip
            "<td>" wrk.penszbal "</td>" skip
            "<td>" wrk.penna "</td>" skip
            "<td>" wrk.pennazbal "</td>" skip
            "<td>" wrk.prpolkzt "</td>" skip
            "<td>" prres "</td>" skip
            "<td>" wrk.prod "</td>" skip
            "<td>" wrk.prpr "</td>" skip
            "<td>" wrk.prkol "</td>" skip
            "<td>" wrk.prmax "</td>" skip
            "</FONT></tr>" skip.
end.
put stream vcps unformatted
   "</TR>" skip.
put stream vcps unformatted  "</FONT></table><br>".

put stream vcps unformatted  "</body></html>" skip.

output stream vcps close.
unix silent value("cptwin loan.htm excel").

