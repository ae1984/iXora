/* msforep.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Прогноз провизий МСФО
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
        26/12/2011 madiyar - добавил колонку с наименованием
        31/01/2012 madiyar - используем историю привязки займов к пулам
*/

{mainhead.i}

def new shared temp-table wrk no-undo
    field bank as char
    field poolId as char
    field cif as char
    field cifn as char
    field lon as char
    field crc as integer
    field ost as deci extent 3
    field ost_kzt as deci extent 3
    field ost_pro as deci extent 3
    field msfo1 as deci extent 3
    field msfo1_kzt as deci extent 3
    field msfo2 as deci extent 3
    field msfo2_kzt as deci extent 3
    index idx is primary bank poolId cif.

def new shared var v-dt as date no-undo.
def var nm as integer no-undo.
def var ny as integer no-undo.

nm = month(g-today) + 1.
ny = year(g-today).
if nm = 13 then assign nm = 1 ny = ny + 1.
v-dt = date(nm,1,ny).

update " Дата: " v-dt validate (day(v-dt) = 1,"Число должно быть 1-ое!") no-label with centered row 13 frame frd.

def new shared var v-pool as char no-undo extent 9.
def new shared var v-poolName as char no-undo extent 9.
def new shared var v-poolId as char no-undo extent 9.

def new shared var v-sum_msb as deci no-undo.
v-sum_msb = 0.

/*
run txbs("msfosk2").
*/
for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk2.
end.
if connected ("txb") then disconnect "txb".

v-sum_msb = round(v-sum_msb / 20,2).

message "v-sum_msb=" + trim(string(v-sum_msb,">>>,>>>,>>>,>>9.99")) view-as alert-box.

do transaction:
    find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnmsfo" exclusive-lock no-error.
    if not avail pksysc then do:
        create pksysc.
        assign pksysc.credtype = '0'
               pksysc.sysc = 'lnmsfo'
               pksysc.des = "МСФО - 5% СК".
    end.
    assign pksysc.daval = g-today
           pksysc.inval = time
           pksysc.deval = v-sum_msb.
    find current pksysc no-lock.
end.

v-pool[1] = "27,67".
v-poolName[1] = "Ипотечные займы".
v-poolId[1] = "ipoteka".
v-pool[2] = "28,68".
v-poolName[2] = "Автокредиты".
v-poolId[2] = "auto".
v-pool[3] = "20,60".
v-poolName[3] = "Потребительские кредиты Обеспеченные".
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
v-pool[7] = "10,14,15,24,25,50,54,55,64,65".
v-poolName[7] = "Кредиты МСБ".
v-poolId[7] = "msb".
v-pool[8] = "10,14,15,24,25,50,54,55,64,65".
v-poolName[8] = "Инидивид. МСБ".
v-poolId[8] = "individ-msb".
v-pool[9] = "11,21,70,80".
v-poolName[9] = "факторинг, овердрафты".
v-poolId[9] = "factover".

run txbs("msforep2").

def stream rep.
output stream rep to rep.htm.

put stream rep unformatted "<html><head><title></title>"
             "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
             "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
    "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Пул</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КодКл</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ФИО/Наименование</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сс.счет</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОД</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">%%</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Пеня</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ОД (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">%% (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Пеня (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО ОД</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО %%</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО Пеня</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО ОД (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО %% (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">МСФО Пеня (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО ОД</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО %%</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО Пеня</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО ОД (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО %% (KZT)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ПрогнозМСФО Пеня (KZT)</td>"
    "</tr>" skip.

for each wrk no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td>" wrk.bank "</td>" skip
        "<td>" wrk.poolId "</td>" skip
        "<td>" wrk.cif "</td>" skip
        "<td>" wrk.cifn "</td>" skip
        "<td>&nbsp;" wrk.lon "</td>" skip
        "<td>" wrk.crc "</td>" skip
        "<td>" replace(trim(string(wrk.ost[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost_kzt[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost_kzt[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost_kzt[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1_kzt[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1_kzt[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo1_kzt[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2_kzt[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2_kzt[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.msfo2_kzt[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "</tr>" skip.
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.

