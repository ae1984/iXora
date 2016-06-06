/* ppen.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Отчет по полученным/возвращенным (списанным) штрафам
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
        23/07/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        30/07/2009 madiyar - исправил ошибку
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{mainhead.i}

def new shared temp-table wrk1 no-undo
    field bank as char
    field bank_city as char
    field jh as integer
    field jdt as date
    field amt as deci
    field who as char
    index idx is primary bank jh.

def new shared temp-table wrk2 no-undo
    field bank as char
    field bank_city as char
    field jh as integer
    field jdt as date
    field amt as deci
    field who as char
    index idx is primary bank jh.

def temp-table t-agg no-undo
    field bank as char
    field bank_city as char
    field num_pen as integer
    field sum_pen as deci
    field num_pen_v as integer
    field sum_pen_v as deci
    index idx is primary bank.

def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def var v-rep as logi no-undo.
def var v-sum as deci no-undo.
def var v-sum_v as deci no-undo.
def var v-num as integer no-undo.
def var v-num_v as integer no-undo.

dt2 = g-today.
dt1 = date(month(dt2),1,year(dt2)).
v-rep = yes.

update dt1 label ' Укажите период с ' format '99/99/9999' dt2 label 'по ' format '99/99/9999' skip
       v-rep label ' Только итоговые суммы ' format 'да/нет' skip
       with side-labels row 5 centered frame dat .
hide frame dat.

{r-brfilial.i &proc = "ppen1"}

def stream rep.
output stream rep to rep.htm.
put stream rep unformatted
    "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<br>" v-bankname "<br>" skip
    "Полученные/возвращенные (списанные) штрафы<br>" skip
    "С " + string(dt1,"99/99/9999") + ' по ' + string(dt2,"99/99/9999") + "<br><br>" skip.

if v-rep then do:
    v-num = 0. v-sum = 0.
    for each wrk1 no-lock break by wrk1.bank:
        v-num = v-num + 1.
        v-sum = v-sum + wrk1.amt.
        if last-of(wrk1.bank) then do:
            create t-agg.
            assign t-agg.bank = wrk1.bank
                   t-agg.bank_city = wrk1.bank_city
                   t-agg.num_pen = v-num
                   t-agg.sum_pen = v-sum.
            v-num = 0.
            v-sum = 0.
        end.
    end.
    v-num = 0. v-sum = 0.
    for each wrk2 no-lock break by wrk2.bank:
        v-num = v-num + 1.
        v-sum = v-sum + wrk2.amt.
        if last-of(wrk2.bank) then do:
            find first t-agg where t-agg.bank = wrk2.bank exclusive-lock no-error.
            if not avail t-agg then do:
                create t-agg.
                assign t-agg.bank = wrk2.bank
                       t-agg.bank_city = wrk2.bank_city.
            end.
            assign t-agg.num_pen_v = v-num
                   t-agg.sum_pen_v = v-sum.
            v-num = 0.
            v-sum = 0.
        end.
    end.
    put stream rep unformatted
        "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Филиал</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Полученные штрафы</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Возвращенные штрафы</td>"
        "</tr>" skip
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Кол-во</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
        "</tr>" skip.
    v-sum = 0. v-sum_v = 0.
    v-num = 0. v-num_v = 0.
    for each t-agg no-lock:
        put stream rep unformatted
            "<tr>"
            "<td>" t-agg.bank_city "</td>"
            "<td>" t-agg.num_pen "</td>"
            "<td>" replace(trim(string(t-agg.sum_pen,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" t-agg.num_pen_v "</td>"
            "<td>" replace(trim(string(t-agg.sum_pen_v,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "</tr>" skip.
        v-sum = v-sum + t-agg.sum_pen.
        v-sum_v = v-sum_v + t-agg.sum_pen_v.
        v-num = v-num + t-agg.num_pen.
        v-num_v = v-num_v + t-agg.num_pen_v.
    end.
    put stream rep unformatted
        "<tr style=""font:bold"">"
        "<td>ИТОГО</td>"
        "<td>" v-num "</td>"
        "<td>" replace(trim(string(v-sum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td>" v-num_v "</td>"
        "<td>" replace(trim(string(v-sum_v,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "</tr></table>" skip.
end.
else do:
    put stream rep unformatted
        "<br><b>Полученные штрафы</b><br>" skip
        "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
        "<td bgcolor=""#C0C0C0"" align=""center""># транз.</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">id</td>"
        "</tr>" skip.
    v-sum = 0.
    for each wrk1 no-lock:
        put stream rep unformatted
            "<tr>"
            "<td>" wrk1.bank_city "</td>"
            "<td>" wrk1.jh "</td>"
            "<td>" string(wrk1.jdt,"99/99/9999") "</td>"
            "<td>" replace(trim(string(wrk1.amt,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" wrk1.who "</td>"
            "</tr>" skip.
        v-sum = v-sum + wrk1.amt.
    end.
    put stream rep unformatted
        "<tr style=""font:bold"">"
        "<td>ИТОГО</td>"
        "<td></td><td></td>"
        "<td>" replace(trim(string(v-sum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td></td>"
        "</tr></table>" skip.

    put stream rep unformatted
        "<br><b>Возвращенные (списанные) штрафы</b><br>" skip
        "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
        "<td bgcolor=""#C0C0C0"" align=""center""># транз.</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Дата</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"">id</td>"
        "</tr>" skip.
    v-sum = 0.
    for each wrk2 no-lock:
        put stream rep unformatted
            "<tr>"
            "<td>" wrk2.bank_city "</td>"
            "<td>" wrk2.jh "</td>"
            "<td>" string(wrk2.jdt,"99/99/9999") "</td>"
            "<td>" replace(trim(string(wrk2.amt,'>>>>>>>>>>>9.99')),'.',',') "</td>"
            "<td>" wrk2.who "</td>"
            "</tr>" skip.
        v-sum = v-sum + wrk2.amt.
    end.
    put stream rep unformatted
        "<tr style=""font:bold"">"
        "<td>ИТОГО</td>"
        "<td></td><td></td>"
        "<td>" replace(trim(string(v-sum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
        "<td></td>"
        "</tr></table>" skip.
end.

put stream rep unformatted "</body></html>".
output stream rep close.

unix silent cptwin rep.htm excel.

