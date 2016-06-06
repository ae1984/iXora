/* ctgcoef.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет коэффициентов по пулам для провизий МСФО
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
        23/08/2012 kapar
 * BASES
        BANK COMM
 * CHANGES
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
*/

{mainhead.i}

def new shared var v-dt as date no-undo.
def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.
def var t-dt as date no-undo.
def var m-dt as date no-undo.
def var k as int extent 10.
def var p-sum as deci extent 10.
def var v-sumpd     as deci.
def var v-sumpool   as deci.
def var v-restcoef  as deci.
def var v-pd        as deci.
def var v-pdhis     as deci.
def var v-clsumpool as deci.
def var v-nclsumpool as deci.
def var v-nclsumpool1 as deci.
def var v-clprov    as deci.
def var v-nclprov   as deci.
def var v-nclprov1  as deci.
def var v-mindt as date extent 10.
def var nd as int.

run mondays(month(g-today), year(g-today), output nd).
v-dt = date(month(g-today), nd, year(g-today)) + 1.

update " Дата: " v-dt format "99/99/9999" validate (day(v-dt) = 1,"Число должно быть 1-ое!") no-label with centered row 13 frame frd title "Расшифровка".

v-pool[1] = "27,67".
v-poolName[1] = "Ипотечные займы".
v-poolId[1] = "ipoteka".
v-pool[2] = "28,68".
v-poolName[2] = "Автокредиты".
v-poolId[2] = "auto".
v-pool[3] = "20,60".
v-poolName[3] = "Прочие потребительские кредиты".
v-poolId[3] = "flobesp".
v-pool[4] = "90,92".
v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
v-poolId[4] = "metro".
v-pool[5] = "81,82".
v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
v-poolId[5] = "sotr".
v-pool[6] = "16,26,56,66".
v-poolName[6] = "Метро-экспресс МСБ".
v-poolId[6] = "express-msb".
v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
v-poolName[8] = "Инидивид. МСБ".
v-poolId[8] = "individ-msb".
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".
v-pool[10] = "95,96".
v-poolName[10] = "Ипотека «Астана бонус»".
v-poolId[10] = "astana-bonus".

v-mindt[1] = date(1,1,2013).
v-mindt[2] = date(7,1,2008).
v-mindt[3] = date(7,1,2008).
v-mindt[4] = date(1,1,2011).
v-mindt[5] = date(7,1,2008).
v-mindt[6] = date(7,1,2010).
v-mindt[7] = date(7,1,2010).
v-mindt[8] = date(7,1,2010).
v-mindt[9] = date(7,1,2010).
v-mindt[10] = date(8,1,2012).

function getDate returns date (input f-dt as date).
    def var nm as integer no-undo.
    def var ny as integer no-undo.
    nm = month(f-dt) + 1. ny = year(f-dt).
    if nm = 13 then assign nm = 1 ny = ny + 1.
    return date(nm,1,ny).
end function.

def var i as integer no-undo.
def var j as integer no-undo.

for each ctgprov no-lock :
        accum dt ( minimum ).
end.
m-dt = accum minimum ctgprov.dt.
def stream rep.
do i = 1 to 10:
    v-sumpd = 0. v-sumpool = 0. v-restcoef = 0. v-pd = 0. v-clsumpool = 0. v-nclsumpool = 0. v-clprov = 0. v-nclprov = 0. v-nclsumpool1 = 0. v-nclprov1 = 0.

    output stream rep to value("rep" + string(i) + ".htm").

    put stream rep unformatted "<html><head><title>" + v-poolName[i] + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream rep unformatted "<h3>Пул " + v-poolName[i] + "</h3>" skip.

    put stream rep unformatted
        "<table border=""1"" cellpadding=""12"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>период</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" colspan=9>Категория</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Реструктуризация</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Итого сумма пула</td>"
        "</tr><tr>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">0 дней (не просроченные)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 1 до 30 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 31 до 60 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 61 до 90 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 91 до 120 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 121 до 150 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 151 до 180 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">более 180 дней(изменение)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">более 180 дней</td>"
        "</tr>" skip.


    /*t-dt = date(month(v-dt),day(v-dt),year(v-dt) - 1).*/
    t-dt = m-dt.
    repeat while t-dt <= v-dt:
    /*do j = 1 to 13:*/
        for each ctgprov where ctgprov.dt = t-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[i]:
            put stream rep unformatted
                "<tr>"
                "<td align=""center"">" string(ctgprov.dt,"99/99/9999") "</td>"
                "<td>" replace(trim(string(ctgprov.n1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n4,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n5,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n6,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n7,'>>>>>>>>>>>9.99')),'.',',') "</td>".
            if t-dt = v-mindt[i] then put stream rep unformatted "<td> 0 </td>".
            else put stream rep unformatted
                "<td>" replace(trim(string(ctgprov.n8,'>>>>>>>>>>>9.99')),'.',',') "</td>".
            put stream rep unformatted
                "<td>" replace(trim(string(ctgprov.n9,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n10,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n9 + ctgprov.n10,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "</tr>" skip.
        end.
        t-dt = getDate(t-dt).
    end.
    find first ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "ctg" and ctgprov.poolId = v-poolId[i] no-lock no-error.
    if avail ctgprov then do:
        v-sumpool = ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n9 + ctgprov.n10.
        v-clsumpool = ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7.
        v-nclsumpool = ctgprov.n9 + ctgprov.n10.
        v-nclsumpool1 = ctgprov.n11.
    end.
    put stream rep unformatted "</table>".
    put stream rep unformatted
        "<table border=""1"" cellpadding=""9"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<tr>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" colspan=9>Данные для расчета</td></tr>" skip
        "<tr><td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" colspan=9>Коэффициенты вероятности(в долях)</td>"
        "</tr>"
        "<tr>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">дата</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">0 дней (не просроченные)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 1 до 30 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 31 до 60 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 61 до 90 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 91 до 120 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 121 до 150 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">от 151 до 180 дней</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">более 180 дней(изменение)</td>"
        skip.
    do j = 1 to 10:
        p-sum[j] = 0. k[j] = 0.
    end.
    for each ctgprov where ctgprov.dt <= v-dt and ctgprov.tp = "kfc" and ctgprov.poolId = v-poolId[i]:
        if ctgprov.n1 >= 0 then do: p-sum[1] = p-sum[1] + ctgprov.n1. k[1] = k[1] + 1. end.
        if ctgprov.n2 >= 0 then do: p-sum[2] = p-sum[2] + ctgprov.n2. k[2] = k[2] + 1. end.
        if ctgprov.n3 >= 0 then do: p-sum[3] = p-sum[3] + ctgprov.n3. k[3] = k[3] + 1. end.
        if ctgprov.n4 >= 0 then do: p-sum[4] = p-sum[4] + ctgprov.n4. k[4] = k[4] + 1. end.
        if ctgprov.n5 >= 0 then do: p-sum[5] = p-sum[5] + ctgprov.n5. k[5] = k[5] + 1. end.
        if ctgprov.n6 >= 0 then do: p-sum[6] = p-sum[6] + ctgprov.n6. k[6] = k[6] + 1. end.
        if ctgprov.n7 >= 0 then do: p-sum[7] = p-sum[7] + ctgprov.n7. k[7] = k[7] + 1. end.
        if ctgprov.n8 >= 0 then do: p-sum[8] = p-sum[8] + ctgprov.n8. k[8] = k[8] + 1. end.
        /*if ctgprov.n9 >= 0 then do: p-sum[9] = p-sum[9] + ctgprov.n9. k[9] = k[9] + 1. end.*/
        put stream rep unformatted
            "<tr>"
            "<td align=""center"">" string(ctgprov.dt,"99/99/9999") "</td>".
            /*
            "<td>" replace(trim(string(ctgprov.n1,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n2,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n3,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n4,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n5,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n6,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n7,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n8,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n9,'->>>>>>>>>>>9.99')),'.',',') "</td>"
            "</tr>" skip.*/
        if ctgprov.n1 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n1,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted "<td> no </td>".
        if ctgprov.n2 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n2 ,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else  put stream rep unformatted "<td> no </td>".
        if ctgprov.n3 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n3,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else  put stream rep unformatted "<td> no </td>".
        if ctgprov.n4 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n4,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else  put stream rep unformatted "<td> no </td>".
        if ctgprov.n5 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n5,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted  "<td> no </td>".
        if ctgprov.n6 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n6,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted  "<td> no </td>".
        if ctgprov.n7 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n7,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted  "<td> no </td>".
        if ctgprov.n8 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n8,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted  "<td> no </td>".
        /*if ctgprov.n9 >= 0 then put stream rep unformatted
            "<td>" replace(trim(string(ctgprov.n9,'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
        else put stream rep unformatted  "<td> no </td>".*/
        put stream rep unformatted
            "</tr>" skip.
    end.

    put stream rep unformatted
            "<tr>"
            "<td align=""center""> Коэффициент перехода (в долях) </td>".
    if k[1] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[1] / k[1],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted "<td> no </td>".
    if k[2] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[2] / k[2],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else  put stream rep unformatted "<td> no </td>".
    if k[3] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[3] / k[3],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else  put stream rep unformatted "<td> no </td>".
    if k[4] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[4] / k[4],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else  put stream rep unformatted "<td> no </td>".
    if k[5] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[5] / k[5],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted  "<td> no </td>".
    if k[6] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[6] / k[6],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted  "<td> no </td>".
    if k[7] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[7] / k[7],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted  "<td> no </td>".
    if k[8] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[8] / k[8],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted  "<td> no </td>".
    /*if k[9] <> 0 then put stream rep unformatted
            "<td>" replace(trim(string(p-sum[9] / k[9],'->>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>".
    else put stream rep unformatted  "<td> no </td>".*/
    put stream rep unformatted
            "</tr>" skip.

    /*
    for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "kfc" and ctgprov.poolId = v-poolId[i]:
        put stream rep unformatted
            "<tr>"
            "<td align=""center"">Коэффициент<BR>перехода</td>"
            "<td>" replace(trim(string(ctgprov.n1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n4,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n5,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n6,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n7,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n8,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n9,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "</tr>" skip.
    end.
    */

    for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prc" and ctgprov.poolId = v-poolId[i]:
        put stream rep unformatted
            "<tr>"
            "<td align=""center"">Процент резервирования (в %)</td>"
            "<td>" replace(trim(string(ctgprov.n1,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n2,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n3,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n4,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n5,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n6,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n7,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n8,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"
            /*"<td>" replace(trim(string(ctgprov.n9,'>>>>>>>>>>>9.99<<<<<<<<')),'.',',') "</td>"*/
            "</tr>" skip.
    end.

    for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "rzr" and ctgprov.poolId = v-poolId[i]:
        put stream rep unformatted
            "<tr>"
            "<td align=""center"">Сумма резервов<BR>на основной долг</td>"
            "<td>" replace(trim(string(ctgprov.n1,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n2,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n3,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n4,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n5,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n6,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n7,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" replace(trim(string(ctgprov.n8,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            /*"<td>" replace(trim(string(ctgprov.n9,'>>>>>>>>>>>9.99')),'.',',') "</td>"*/
            "</tr>" skip.
        v-sumpd = ctgprov.n1 + ctgprov.n2 + ctgprov.n3 + ctgprov.n4 + ctgprov.n5 + ctgprov.n6 + ctgprov.n7 + ctgprov.n8 /* + ctgprov.n9 + ctgprov.n10*/.
        if lookup(v-poolId[i],'metro,sotr,factover,flobesp') > 0 then v-nclprov1 = 1 * v-nclsumpool1.
        v-nclprov = ctgprov.n9 + ctgprov.n10.
    end.


    if v-sumpool = 0 then v-pd = 0. else v-pd = v-sumpd / v-sumpool.
    v-clprov = v-clsumpool * v-pd.
    if lookup(v-poolId[i],'metro,sotr,factover,flobesp') = 0 then v-nclprov1 = v-nclsumpool1 * v-pd.

    put stream rep unformatted "</table>" skip.
    put stream rep unformatted
        "<table cellpadding=""9"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Итого сумма вероятного перехода</td><td>" replace(trim(string(v-sumpd,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Итого сумма пула</td><td>" replace(trim(string(v-sumpool,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Коэффициент восстановления(RR)</td><td>" replace(trim(string(v-restcoef,'>>>>>>>>>>>9.99<<')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Вероятность дефолта(PD)</td><td>" replace(trim(string(100 * v-pd,'>>>>9.99<<')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Чистый пул</td><td>" replace(trim(string(v-clsumpool,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Обесцененный пул</td><td>" replace(trim(string(v-nclsumpool,'>>>>>>>>>>>9.99')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Обесцененный пул(коллективно)</td><td>" replace(trim(string(v-nclsumpool1,'>>>>>>>>>>>9.99<<')),'.',',') "</td>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Сумма провизий по необесценненному пулу</td><td>" replace(trim(string(v-clprov,'>>>>>>>>>>>9.99<<')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Сумма провизий по обесценненному пулу(индивидуально)</td><td>" replace(trim(string(v-nclprov,'>>>>>>>>>>>9.99<<')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Сумма провизий по обесценненному пулу(коллективно)</td><td>" replace(trim(string(v-nclprov1,'>>>>>>>>>>>9.99<<')),'.',',') "</td></tr>"
        "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">Итого провизии по пулу</td><td>" replace(trim(string(v-clprov + v-nclprov + v-nclprov1,'>>>>>>>>>>>9.99<<')),'.',',') "</td></tr>".
    for each ctgprov where ctgprov.dt = v-dt and ctgprov.tp = "prz" and ctgprov.poolId = v-poolId[i]:
        put stream rep unformatted
            "<tr style=""font:bold""><td colspan=5></td><td colspan=3 align=""right"">PD(факт/истор)</td><td>" replace(trim(string(round(100 * ctgprov.n12,4),'->>>>9.99<<')),'.',',') "</td></tr>" skip.
    end.
    put stream rep unformatted "</table></body></html>" skip.
    output stream rep close.
    unix silent value("cptwin " + "rep" + string(i) + ".htm excel").
end.

