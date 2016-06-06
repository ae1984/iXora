/* calxls.p
 * MODULE
    Кредитный модуль
 * DESCRIPTION
        Просмотр календарей погашения кредитов
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
 * AUTHOR
        18/10/2004 madiyar
 * CHANGES
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        16/10/2010 madiyar - добавил столбцы
        27/10/2010 aigul - исправила вывод Суммы кредита на начало и на конец при отсрочке ОД
        28/10/2010 aigul - вывести только те записи где ОД или проценты или комиссия не равны 0
        11/11/2010 aigul - изменила "итого" на "Сомалыќ белгісі/ Суммарное значение"
        09/04/2011 madiyar - при совпадении дат в двух или более графиках ОД или %% выводится сумма таких записей
        21/05/2012 kapar - ТЗ ДАМУ
        12/10/2012 ernur - перекомпиляция
*/

{global.i}

def shared var s-lon like lon.lon.
def stream rep.
def var coun as int no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-itogo as deci no-undo extent 3.
output stream rep to rpt.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

find lon where lon.lon = s-lon no-lock.
find first cif where cif.cif = lon.cif no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
find first cmp no-lock no-error.

find first lons where lons.lon = lon.lon no-lock no-error.

v-sum = lon.opnamt.
v-sum1 = lon.opnamt.
def temp-table wrk no-undo
  field dt as date
  field ost as deci
  field od as deci
  field prc as deci
  field koms as deci
  field fin as decimal
  index idx is primary dt.

v-itogo = 0.

for each lnsch where lnsch.lnn = s-lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock:
    find first wrk where wrk.dt = lnsch.stdat exclusive-lock no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.dt = lnsch.stdat
               wrk.ost = v-sum.
    end.
    wrk.od = wrk.od + lnsch.stval.
    v-sum = v-sum - lnsch.stval.
    v-itogo[1] = v-itogo[1] + lnsch.stval.
end.

for each lnsci where lnsci.lni = s-lon and lnsci.flp = 0 and lnsci.f0 > 0 no-lock:
    find first wrk where wrk.dt = lnsci.idat exclusive-lock no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.dt = lnsci.idat.
    end.
    wrk.prc = wrk.prc + lnsci.iv-sc.
    v-itogo[2] = v-itogo[2] + lnsci.iv-sc.
end.

/*aigul*/
for each wrk exclusive-lock:
    if wrk.od = 0 and wrk.prc <> 0 then wrk.ost = v-sum1.
    v-sum1 = v-sum1 - wrk.od.
end.
/**/
if avail lons then do:
    for each lnscs where lnscs.lon = s-lon and lnscs.sch no-lock:
        find first wrk where wrk.dt = lnscs.stdat exclusive-lock no-error.
        if not avail wrk then do:
            create wrk.
            assign wrk.dt = lnscs.stdat.
        end.
        wrk.koms = wrk.koms + lnscs.stval.
        v-itogo[3] = v-itogo[3] + lnscs.stval.
    end.
end.

def var v-ccode as char no-undo.
find first sub-cod where sub-cod.acc=lon.lon and sub-cod.d-cod='lnprod' no-lock no-error.
if available sub-cod then v-ccode = sub-cod.ccode.

put stream rep unformatted
    "<h2>" cmp.name format "x(40)" "</h2><BR>" skip
    "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
    "Ссудный счет: " lon.lon "<BR>" skip
    "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.

if v-ccode = '07' or v-ccode = '08' or v-ccode = '09' then do:
    put stream rep unformatted
        "<h2>График погашения</h2>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td width=30>N</td>" skip
        "<td width=100>Дата</td>" skip
        "<td width=100>Сумма кредита<br>на начало</td>" skip
        "<td width=100>Сумма ОД</td>" skip
        "<td width=100>Даму %% </td>" skip
        "<td width=100>Сумма вознаграждения,<br>оплачиваемая<br>заемщиком </td>" skip
        "<td width=100>Итого сумма<br>начисленного<br>вознаграждения</td>" skip
        if avail lons then "<td width=100>Комиссия по годовой ставке</td>" else "" skip
        "<td width=100>Ежемесячный<br>платеж</td>" skip
        "<td width=100>Сумма кредита<br>на конец</td>" skip
        "</tr>" skip.

    coun = 1.
    for each wrk where wrk.od <> 0 or wrk.prc <> 0 or wrk.koms <> 0 no-lock: /*aigul - вывести только те записи где ОД или проценты или комиссия не равны 0*/
      put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">" coun "</td>" skip
                 "<td align=""center"">" wrk.dt "</td>" skip
                 "<td align=""right"">" replace(string(wrk.ost, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.od, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(((wrk.prc / lon.prem) * lon.dprem), ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(((wrk.prc / lon.prem) * (lon.prem - lon.dprem)), ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.prc, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 if avail lons then "<td align=""right"">" + replace(string(wrk.koms, ">>>>>>>>>>>9.99"),".",",") + "</td>" else '' skip
                 "<td align=""right"">" replace(string(wrk.od + wrk.prc + wrk.koms, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.ost - wrk.od, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "</tr>" skip.
      coun = coun + 1.
    end.

    put stream rep unformatted
                 "<tr style=""font:bold"">" skip
                 "<td align=""center""></td>" skip
                 "<td align=""center"">Сомалыќ белгісі / Суммарное значение:</td>" skip
                 "<td align=""right""></td>" skip
                 "<td align=""right"">" replace(string(v-itogo[1], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(((v-itogo[2] / lon.prem) * lon.dprem), ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(((v-itogo[2] / lon.prem) * (lon.prem - lon.dprem)), ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(v-itogo[2], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 if avail lons then "<td align=""right"">" + replace(string(v-itogo[3], ">>>>>>>>>>>9.99"),".",",") + "</td>" else '' skip
                 "<td align=""right"">" replace(string(v-itogo[1] + v-itogo[2] + v-itogo[3], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right""></td>" skip
                 "</tr>" skip.
end.
else do:
    put stream rep unformatted
        "<h2>График погашения</h2>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td width=30>N</td>" skip
        "<td width=100>Дата</td>" skip
        "<td width=100>Сумма кредита<br>на начало</td>" skip
        "<td width=100>Сумма ОД</td>" skip
        "<td width=100>Сумма %%</td>" skip
        if avail lons then "<td width=100>Комиссия по годовой ставке</td>" else "" skip
        "<td width=100>Ежемесячный<br>платеж</td>" skip
        "<td width=100>Сумма кредита<br>на конец</td>" skip
        "</tr>" skip.

    coun = 1.
    for each wrk where wrk.od <> 0 or wrk.prc <> 0 or wrk.koms <> 0 no-lock: /*aigul - вывести только те записи где ОД или проценты или комиссия не равны 0*/
      put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">" coun "</td>" skip
                 "<td align=""center"">" wrk.dt "</td>" skip
                 "<td align=""right"">" replace(string(wrk.ost, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.od, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.prc, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 if avail lons then "<td align=""right"">" + replace(string(wrk.koms, ">>>>>>>>>>>9.99"),".",",") + "</td>" else '' skip
                 "<td align=""right"">" replace(string(wrk.od + wrk.prc + wrk.koms, ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(wrk.ost - wrk.od, "->>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "</tr>" skip.
      coun = coun + 1.
    end.

    put stream rep unformatted
                 "<tr style=""font:bold"">" skip
                 "<td align=""center""></td>" skip
                 "<td align=""center"">Сомалыќ белгісі / Суммарное значение:</td>" skip
                 "<td align=""right""></td>" skip
                 "<td align=""right"">" replace(string(v-itogo[1], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right"">" replace(string(v-itogo[2], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 if avail lons then "<td align=""right"">" + replace(string(v-itogo[3], ">>>>>>>>>>>9.99"),".",",") + "</td>" else '' skip
                 "<td align=""right"">" replace(string(v-itogo[1] + v-itogo[2] + v-itogo[3], ">>>>>>>>>>>9.99"),".",",") "</td>" skip
                 "<td align=""right""></td>" skip
                 "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rpt.htm excel.


