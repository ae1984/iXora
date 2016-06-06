/* lcmonrep.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Monthly Report
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
        16.07.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        13.08.2012 Lyubov - подправила сумму комиссий
        03.01.2013 Lyubov - убарала вывод в эксель, т.к. тут он не нужен
        05.09.2013 Lyubov - ТЗ 2072, ищем последний курс до даты проводки

*/

{global.i}

def var v-sum     as deci.
def var v-per     as inte.

def temp-table wrk
field ref     as char
field appl    as char
field bnf     as char
field issdt   as char
field expdt   as char
field cov     as char
field confr   as char
field covlct  as char
field avw     as char
field orgamt  as deci
field curamt  as deci
field comamt  as deci
field sts     as char .

define stream m-out.
output stream m-out to month_rep.htm.
put stream m-out unformatted "<html><head><title>Monthly Report</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>FORTEBANK</h3><br>" skip.
put stream m-out unformatted "<h3>Monthly Report</h3><br>" skip.

put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                        "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Ref-nce</TD>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Appl</TD>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Bnf</TD>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Issue Date</TD>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Expiry Date</TD>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Cover</TD>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Confirm-n</TD>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Cover Locat.</TD>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Avail. with</TD>"
/*10 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Original Amt</TD>"
/*11 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Current Amt</TD>"
/*12 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Commission Amt</TD>"
/*13 */                 "<td bgcolor=""#C0C0C0"" align=""center"">Status</TD>"
                        "</TR>" skip.

for each lc where lc.rwhn >= date(month(g-today),1,year(g-today)) no-lock:
    create wrk.
    assign wrk.ref = lc.lc
           wrk.appl = lc.cif
           wrk.issdt = string(lc.rwhn)
           wrk.sts = lc.lcsts.

    find first lch where lch.lc = lc.lc and lch.kritcod = 'Cover' no-lock no-error.
    if avail lch then do:
        wrk.cov = if lch.value1 = '1' then 'Uncovered' else 'Covered'.
        if lch.value1 = '0' then do:
            if lc.lc begins 'PG' then wrk.covlct = '224011'.
            else if lc.lc begins 'IMLC' or lc.lc begins 'SBLC' then wrk.covlct = '285511'.
        end.
    end.
    find first lch of lc where lch.lc = lc.lc and lch.kritcod = 'Benef' no-lock no-error.
    if avail lch then wrk.bnf = lch.value1.

    find first lch of lc where lch.lc = lc.lc and lch.kritcod = 'Dtexp' no-lock no-error.
    if avail lch then wrk.expdt = lch.value1.

    find first lch of lc where lch.lc = lc.lc and lch.kritcod = 'Amount' no-lock no-error.
    if avail lch then wrk.orgamt = deci(lch.value1).

    find first lch of lc where lch.lc = lc.lc and lch.kritcod = 'Confir' no-lock no-error.
    if avail lch then wrk.confr = if lch.value1 = '0' then 'Confirmed' else 'Without'.

    find first lch of lc where lch.lc = lc.lc and lch.kritcod = 'AvlWith' no-lock no-error.
    if avail lch then wrk.avw = lch.value1.

    v-sum = 0.
    for each lcres where lcres.lc = lc.lc and lcres.com = yes no-lock:
       v-sum = v-sum + lcres.amt.
    end.
    wrk.curamt = wrk.orgamt.
    find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
    if avail lch and lch.value1 ne '' then do:
        v-per = int(entry(1,lch.value1, '/')).
        if v-per > 0 then do:
            wrk.curamt = wrk.curamt + (wrk.curamt * (v-per / 100)).
        end.
    end.
    wrk.comamt = 0.
    for each lcres where lcres.lc = lc.lc and lcres.com = yes no-lock:
        find last crchis where crchis.crc = lcres.crc and crchis.rdt <= lcres.jdt no-lock no-error.
        wrk.comamt = wrk.comamt + lcres.amt * crchis.rate[1].
    end.
    for each lceventres where lceventres.lc = lc.lc and lceventres.com = yes no-lock:
        find last crchis where crchis.crc = lceventres.crc and crchis.rdt <= lceventres.jdt no-lock no-error.
        wrk.comamt = wrk.comamt + lceventres.amt * crchis.rate[1].
    end.
    for each lcpayres where lcpayres.lc = lc.lc and lcpayres.com = yes no-lock:
        find last crchis where crchis.crc = lcpayres.crc and crchis.rdt <= lcpayres.jdt no-lock no-error.
        wrk.comamt = wrk.comamt + lcpayres.amt * crchis.rate[1].
    end.
    for each lcamendres where lcamendres.lc = lc.lc and lcamendres.com = yes no-lock:
        find last crchis where crchis.crc = lcamendres.crc and crchis.rdt <= lcamendres.jdt no-lock no-error.
        wrk.comamt = wrk.comamt + lcamendres.amt * crchis.rate[1].
    end.
end.

for each wrk no-lock:
put stream m-out unformatted
                  "<tr>" skip
/*1 */            "<td align=""center"">" wrk.ref "</TD>" skip
/*2 */            "<td>" wrk.appl "</td>" skip
/*3 */            "<td>" wrk.bnf "</td>" skip
/*4 */            "<td>" wrk.issdt "</td>" skip
/*5 */            "<td>" wrk.expdt "</td>" skip
/*6 */            "<td align=""center"">" wrk.cov "</td>" skip
/*7 */            "<td align=""right"">" wrk.confr "</td>" skip
/*8 */            "<td>" wrk.covlct "</td>" skip
/*9 */            "<td>" wrk.avw "</td>" skip
/*10 */           "<td align=""right"">" replace(trim(string(wrk.orgamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*11 */           "<td align=""right"">" replace(trim(string(wrk.curamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*12 */           "<td align=""right"">" replace(trim(string(wrk.comamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*13 */           "<td>" wrk.sts "</td>" skip
                  "</tr>" skip.
end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2' no-lock no-error.
if avail bookcod then run mail(bookcod.name, "FORTEBANK <abpk@fortebank.kz>", "Monthly Report", "", "1", "", "month_rep.htm").