/* lnnb.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Отчет по кредитному портфелю с разбивкой по срокам до погашения
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
        09/08/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        21/01/2008 madiyar - добавил суммы по начисленному вознаграждению
        07/02/2008 madiyar - выбор: по срокам до погашения или по первоначальным срокам кредитов
        08/02/2008 madiyar - добавил суммы по просроченному начисленному вознаграждению
        20/02/2008 madiyar - добавил суммы по просроченному ОД
        12/03/2008 madiyar - добавил таблицу по просрочкам
        21/07/2008 madiyar - изменения в сроках
        05/09/2008 madiyar - изменения в сроках по просрочкам
        08/09/2008 madiyar - исправил ошибку
        27.10.09 marinav -   разбит срок от 1 до 3 месяцев
        01/11/2012 kapar - ТЗ №1566,№1143
        22.07.2013 dmitriy - ТЗ 1971
*/

{global.i}

def var dt as date no-undo.
dt = g-today - 1.

def var v-sel as char no-undo.
run sel2 ("Выбор :", " 1. Отчет по срокам до погашения | 2. Отчет по первоначальным срокам кредитов ", output v-sel).
if v-sel <> '1' and v-sel <> '2' then return.

update dt format "99/99/9999" label " За дату" validate (dt < g-today, "Дата должна быть раньше текущей!") " " with side-labels centered row 8 frame frdt.

define new shared temp-table wrk no-undo
  field des as char
  field sroks as integer
  field srokf as integer
  field sts as deci
  field sum as deci extent 3
  field sum_pod as deci extent 3
  field sum_nprc as deci extent 3
  field sum_pprc as deci extent 3
  index idx is primary sroks sts
  index idx2 sroks srokf sts.

define new shared temp-table wrkprov no-undo
  field sroks as integer
  field sum as deci extent 3
  field sum41 as deci extent 3
  index idx is primary sroks.

define new shared temp-table wrkpr no-undo
  field sroks as int
  field srokf as int
  field sts as deci
  field sum_pod as deci extent 3
  field sum_pprc as deci extent 3
  index idx is primary sroks sts.

message " Формируется отчет... ".

for each lonstat no-lock:
  /* подготавливаем первую таблицу */
  create wrk.
  assign wrk.des = "до 7 дней"
         wrk.sroks = 0
         wrk.srokf = 7
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 0.
  create wrk.
  assign wrk.des = "7 - 30 дней"
         wrk.sroks = 7
         wrk.srokf = 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 7.
  create wrk.
  assign wrk.des = "31 - 60 дней"
         wrk.sroks = 30
         wrk.srokf = 2 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 30.
  create wrk.
  assign wrk.des = "61 - 90 дней"
         wrk.sroks = 2 * 30
         wrk.srokf = 3 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 60.
  create wrk.
  assign wrk.des = "3 - 6 месяцев"
         wrk.sroks = 3 * 30
         wrk.srokf = 6 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 3 * 30.
  create wrk.
  assign wrk.des = "6 - 9 месяцев"
         wrk.sroks = 6 * 30
         wrk.srokf = 9 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 6 * 30.
  create wrk.
  assign wrk.des = "9 - 12 месяцев"
         wrk.sroks = 9 * 30
         wrk.srokf = 12 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 9 * 30.
  create wrk.
  assign wrk.des = "1 - 2 года"
         wrk.sroks = 12 * 30
         wrk.srokf = 24 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 12 * 30.
  create wrk.
  assign wrk.des = "2 - 3 года"
         wrk.sroks = 24 * 30
         wrk.srokf = 36 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 24 * 30.
  create wrk.
  assign wrk.des = "3 - 5 лет"
         wrk.sroks = 36 * 30
         wrk.srokf = 60 * 30
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 36 * 30.
  create wrk.
  assign wrk.des = "свыше 5 лет"
         wrk.sroks = 60 * 30
         wrk.srokf = 2147483647 /* integer больше не бывает */
         wrk.sts = lonstat.prc.
  create wrkprov.
  wrkprov.sroks = 60 * 30.

  /* подготавливаем вторую таблицу, по просрочкам */
  create wrkpr.
  assign wrkpr.sroks = 0
         wrkpr.srokf = 7
         wrkpr.sts = lonstat.prc.
  create wrkpr.
  assign wrkpr.sroks = 8
         wrkpr.srokf = 30
         wrkpr.sts = lonstat.prc.
  create wrkpr.
  assign wrkpr.sroks = 31
         wrkpr.srokf = 60
         wrkpr.sts = lonstat.prc.
  create wrkpr.
  assign wrkpr.sroks = 61
         wrkpr.srokf = 90
         wrkpr.sts = lonstat.prc.
  create wrkpr.
  assign wrkpr.sroks = 91
         wrkpr.srokf = 180
         wrkpr.sts = lonstat.prc.
  create wrkpr.
  assign wrkpr.sroks = 181
         wrkpr.srokf = 100000000
         wrkpr.sts = lonstat.prc.
end.

{r-brfilial.i &proc = "lnnb2 (v-sel,dt)"}

for each wrk:
  if wrk.sum[1] + wrk.sum[2] + wrk.sum[3] + wrk.sum_pod[1] + wrk.sum_pod[2] + wrk.sum_pod[3] <= 0 then delete wrk.
end.

for each wrkpr:
  if wrkpr.sum_pod[1] + wrkpr.sum_pod[2] + wrkpr.sum_pod[3] + wrkpr.sum_pprc[1] + wrkpr.sum_pprc[2] + wrkpr.sum_pprc[3] <= 0 then delete wrkpr.
end.

def var usrnm as char no-undo.
def stream rep.
output stream rep to lnnb.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm "<BR>" skip
    "<b>Дата:</b> " g-today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Кредиты по " if v-sel = '1' then "срокам до погашения" else "первоначальным срокам" ", за " dt format "99/99/9999" "</b></center><BR>" skip
    "<center><b>" v-bankname "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Срок до<br>погашения</td>" skip
    "<td>Статус</td>" skip
    "<td>KZT ОД</td>" skip
    "<td>KZT ОД просрочка</td>" skip
    "<td>KZT %%</td>" skip
    "<td>KZT %% просрочка</td>" skip
    "<td>USD ОД</td>" skip
    "<td>USD ОД просрочка</td>" skip
    "<td>USD %%</td>" skip
    "<td>USD %% просрочка</td>" skip
    "<td>EUR ОД</td>" skip
    "<td>EUR ОД просрочка</td>" skip
    "<td>EUR %%</td>" skip
    "<td>EUR %% просрочка</td>" skip
    "</tr>" skip.

for each wrk no-lock break by wrk.sroks by wrk.sts:
  put stream rep unformatted
    "<tr>" skip
    "<td>" if first-of(wrk.sroks) then "&nbsp;" + wrk.des /*string(wrk.sroks) + ' - ' + string(wrk.srokf)*/ else '' "</td>" skip
    "<td>" wrk.sts "</td>" skip
    "<td>" replace(trim(string(wrk.sum[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pod[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_nprc[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pprc[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pod[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_nprc[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pprc[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pod[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_nprc[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrk.sum_pprc[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
  if last-of(wrk.sroks) then do:
    find first wrkprov where wrkprov.sroks = wrk.sroks no-lock no-error.
    if avail wrkprov then do:
        put stream rep unformatted
            "<tr>" skip
            "<td colspan=""2"">Провизии (тенге) по АФН</td>" skip
            "<td>" replace(trim(string(wrkprov.sum41[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "<td>" replace(trim(string(wrkprov.sum41[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "<td>" replace(trim(string(wrkprov.sum41[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "</tr>" skip.
        put stream rep unformatted
            "<tr>" skip
            "<td colspan=""2"">Провизии (тенге) по МСФО</td>" skip
            "<td>" replace(trim(string(wrkprov.sum[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "<td>" replace(trim(string(wrkprov.sum[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "<td>" replace(trim(string(wrkprov.sum[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td></td><td></td><td></td>" skip
            "</tr>" skip.
    end.
  end.
end.


put stream rep unformatted "</table><br><br><br>" skip.

put stream rep unformatted
    "<center><b>Просроченная задолженность по займам за " dt format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td>Срок до<br>погашения</td>" skip
    "<td>Статус</td>" skip
    "<td>KZT ОД просрочка</td>" skip
    "<td>KZT %% просрочка</td>" skip
    "<td>USD ОД просрочка</td>" skip
    "<td>USD %% просрочка</td>" skip
    "<td>EUR ОД просрочка</td>" skip
    "<td>EUR %% просрочка</td>" skip
    "</tr>" skip.

for each wrkpr no-lock break by wrkpr.sroks by wrkpr.sts:
  put stream rep unformatted
    "<tr>" skip
    "<td>" if first-of(wrkpr.sroks) then "&nbsp;" + string(wrkpr.sroks) + ' - ' + string(wrkpr.srokf) else '' "</td>" skip
    "<td>" wrkpr.sts "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pod[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pprc[1],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pod[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pprc[2],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pod[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "<td>" replace(trim(string(wrkpr.sum_pprc[3],"->>>>>>>>>>>9.99")),'.',',') "</td>" skip
    "</tr>" skip.
end.


put stream rep unformatted "</table></body></html>" skip.
output stream rep close.

hide message no-pause.

unix silent cptwin lnnb.htm excel.

