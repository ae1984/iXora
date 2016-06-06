/* msfocoef.p
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
        29/07/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        05/09/2011 madiyar - поправил расчет
        25/10/2011 madiyar - фиксируем даты начала истории
        31/10/2011 madiyar - изменение по фиксированным датам
        31/01/2012 madiyar - записываем в историю привязку займов к пулам
        18/06/2012 kapar - ТЗ N1149 Новые группы
        25/07/2012 kapar - ТЗ N1149 изменение
        25/12/2012 madiyar - вывод коэффициентов по пулу "Астана-Бонус"
*/

{mainhead.i}

def new shared temp-table wrk no-undo like msfoc
    field sk5 as deci.


def new shared var dt0rep as date no-undo.
def var nm as integer no-undo.
def var ny as integer no-undo.

nm = month(g-today) + 1.
ny = year(g-today).
if nm = 13 then assign nm = 1 ny = ny + 1.
dt0rep = date(nm,1,ny).

update " Дата: " dt0rep validate (dt0rep > g-today and day(dt0rep) = 1,"Число должно быть позже сегодняшнего и 1-ое!") no-label with centered row 13 frame frd.

def new shared var v-sum_msb as deci no-undo.
v-sum_msb = 0.

def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.

def new shared temp-table wrksk no-undo
    field dtrep as date
    field dt as date
    field sk as deci
    field sk5 as deci
    index idx is primary dtrep.

/*
run txbs("msfosk1").
*/

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk1.
end.
if connected ("txb") then disconnect "txb".

def stream rep.

output stream rep to repsk.htm.

put stream rep unformatted "<html><head><title>Собственный капитал</title>"
             "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
             "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
    "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Для коэфф. на дату</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата СК</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">СК</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">5% от СК</td>"
    "</tr>" skip.

for each wrksk:
    wrksk.sk5 = round(wrksk.sk / 20,2).
    put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" string(wrksk.dtrep,"99/99/9999") "</td>" skip
        "<td align=""center"">" string(wrksk.dt,"99/99/9999") "</td>" skip
        "<td>" replace(trim(string(wrksk.sk,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrksk.sk5,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin repsk.htm excel.

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

/*
run txbs("msfocoef2").
*/

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfocoef2.
end.
if connected ("txb") then disconnect "txb".

def var v-dthis_st as date no-undo.
def var v-dthis_fin as date no-undo.
def var i as integer no-undo.
def stream rep.
def var n as integer no-undo.
def var v-sumcoeff as deci no-undo.
find first wrk no-lock.
v-dthis_fin = wrk.dt.

do i = 1 to 10:
    /*
    if i >= 6 then do:
        ny = year(dt0rep) - 1.
        v-dthis_st = date(month(dt0rep),day(dt0rep),ny).
    end.
    else do:
        if i = 4 then do:
            nm = month(dt0rep) - 6.
            ny = year(dt0rep).
            if nm < 1 then do:
                nm = nm + 12.
                ny = ny - 1.
            end.
            v-dthis_st = date(nm,day(dt0rep),ny).
        end.
        else do:
            ny = year(dt0rep) - 3.
            v-dthis_st = date(month(dt0rep),day(dt0rep),ny).
        end.
    end.

    for each msfoc where msfoc.poolId = v-poolId[i] and msfoc.dt > v-dthis_st and msfoc.dt < v-dthis_fin no-lock:
        create wrk.
        buffer-copy msfoc to wrk.
    end.
    */

    /*
    if i = 4 then v-dthis_st = 01/01/2011.
    else v-dthis_st = 07/01/2010.
    */

    if i = 4 then v-dthis_st = 01/01/2011.
    else
    if i >= 6 then v-dthis_st = 07/01/2010.
    else v-dthis_st = 07/01/2008.

    for each msfoc where msfoc.poolId = v-poolId[i] and msfoc.dt >= v-dthis_st and msfoc.dt < v-dthis_fin no-lock:
        create wrk.
        buffer-copy msfoc to wrk.
    end.
end.


do i = 1 to 10:
    output stream rep to value("rep" + string(i) + ".htm").

    put stream rep unformatted "<html><head><title>" + v-poolName[i] + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream rep unformatted "<h3>Пул " + v-poolName[i] + "</h3><br><br>" skip.

    put stream rep unformatted
        "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">На дату</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма пула</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Просроч. сумма пула</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Спис. сумма пула<br>за предыдущий месяц</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Восст. сумма пула<br>за предыдущий месяц</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Чистые списания и<BR>просроченные обязательства</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Коэфф. среднего<BR>списания</td>"
        "</tr>" skip.

    v-sumcoeff = 0. n = 0.
    for each wrk where wrk.poolId = v-poolId[i]:
        put stream rep unformatted
            "<tr>" skip
            "<td align=""center"">" string(wrk.dt,"99/99/9999") "</td>" skip
            "<td>" replace(trim(string(wrk.amtAll,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.amtPr,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.amtSp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.amtVosst,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk.amtPr + wrk.amtSp - wrk.amtVosst,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        if wrk.amtAll > 0 then do:
            wrk.coeff = round((wrk.amtPr + wrk.amtSp - wrk.amtVosst) / wrk.amtAll * 100,2).
            n = n + 1.
            v-sumcoeff = v-sumcoeff + wrk.coeff.
        end.
        else wrk.coeff = ?.
        put stream rep unformatted
            "<td>" if wrk.coeff = ? then '' else replace(trim(string(wrk.coeff,'->>>>>>>>9.99')),'.',',') "</td>" skip
            "</tr>" skip.
    end.

    if n > 0 then do:
        find first wrk where wrk.poolId = v-poolId[i] and wrk.dt = dt0rep no-error.
        if avail wrk then wrk.coeffr = round(v-sumcoeff / n,2).
        else message "Не найдена запись в таблице коэффициентов за " + string(dt0rep) + " по пулу '" + v-poolName[i] + "'!" view-as alert-box error.
        put stream rep unformatted
            "<tr>" skip
            "<td colspan=6>Средневзвешенный коэффициент</td>" skip
            "<td>" replace(trim(string(wrk.coeffr,'->>>>>>>>9.99')),'.',',') "</td>" skip
            "</tr>" skip.
    end.
    /* else message "Нет коэффициентов за прошлые периоды по пулу '" + v-poolName[i] + "'!" view-as alert-box error. */

    output stream rep close.
    unix silent value("cptwin " + "rep" + string(i) + ".htm excel").
end.

def var v-save as logi no-undo.
v-save = no.

update " Сохранить коэффициенты? " v-save no-label with centered row 13 frame frs.

/*
message "v-dthis_fin=" v-dthis_fin view-as alert-box.
*/

if v-save then do transaction:
    for each wrk where wrk.dt >= v-dthis_fin:
        find first msfoc where msfoc.poolId = wrk.poolId and msfoc.dt = wrk.dt exclusive-lock no-error.
        if not avail msfoc then create msfoc.
        if wrk.dt = dt0rep then buffer-copy wrk to msfoc.
        else buffer-copy wrk except wrk.coeffr to msfoc.
    end.
end.
