/* r_proviz.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
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
       01/04/2011
 * BASES
	BANK, COMM
 * CHANGES
    05/11/2011 kapar - дополнение к 5% СК
    06/06/2012 kapar - исправил мелкие ошибки кода
    06/06/2012 kapar - добавил поле "Общая<br>сумма пула</td> на выб. дату"
    18/06/2012 kapar - ТЗ N1149 Новые группы
    25/07/2012 kapar - ТЗ N1149 изменение
    30/01/2013 sayat(id01143) - ТЗ №1677 от 29/01/2013 добавлен вывод в отчет 1-го и 2-го пулов
*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field id       as   char
  field name     as   char
  field n1       as   decimal
  field n11      as   decimal
  field n2       as   decimal
  field n3       as   decimal
  field n4       as   decimal
  field n5       as   decimal
  field n6       as   decimal
  field n7       as   decimal
  field n8       as   decimal
  field n9       as   decimal.

def var usrnm as char no-undo.

/*Прогноз провизий МСФО*/
def new shared temp-table wrk no-undo
    field bank as char
    field poolId as char
    field cif as char
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
def new shared var r-dt as date no-undo.
def var nm as integer no-undo.
def var ny as integer no-undo.

nm = month(g-today) + 1.
ny = year(g-today).
if nm = 13 then assign nm = 1 ny = ny + 1.
v-dt = date(nm,1,ny).

update " Дата: " v-dt no-label with centered row 13 frame frd.
r-dt = v-dt.

def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.
def new shared var v-sum_msb as deci no-undo.
def new shared var t-sum_msb as deci no-undo.
def new shared var f-sum_msb as deci no-undo.

if g-today >= r-dt then do:
    v-dt = date(month(r-dt),1,year(r-dt)).
    v-sum_msb = 0.
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run msfosk2.
    end.
    if connected ("txb") then disconnect "txb".
    f-sum_msb = round(v-sum_msb / 20,2).

    /*t-sum_msb*/
    if month(r-dt) = 1 then v-dt = date(12,1,year(r-dt) - 1 ). else v-dt = date(month(r-dt) - 1,1,year(r-dt)).
    v-sum_msb = 0.
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run msfosk2.
    end.
    if connected ("txb") then disconnect "txb".
    t-sum_msb = round(v-sum_msb / 20,2).
end.
else do:
    /*t-sum_msb*/
    if month(r-dt) = 1 then v-dt = date(12,1,year(r-dt) - 1 ). else v-dt = date(month(r-dt) - 1,1,year(r-dt)).
    v-sum_msb = 0.
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run msfosk2.
    end.
    if connected ("txb") then disconnect "txb".
    t-sum_msb = round(v-sum_msb / 20,2).
end.

/*v-sum_msb*/
v-dt = g-today.
v-sum_msb = 0.
for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run msfosk2.
end.
if connected ("txb") then disconnect "txb".
v-sum_msb = round(v-sum_msb / 20,2).

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

create lnpr.
 lnpr.id = v-poolId[1].
 lnpr.name = v-poolName[1].
create lnpr.
 lnpr.id = v-poolId[2].
 lnpr.name = v-poolName[2].
create lnpr.
 lnpr.id = v-poolId[3].
 lnpr.name = v-poolName[3].
create lnpr.
 lnpr.id = v-poolId[4].
 lnpr.name = v-poolName[4].
create lnpr.
 lnpr.id = v-poolId[5] .
 lnpr.name = v-poolName[5].
create lnpr.
 lnpr.id = v-poolId[6] .
 lnpr.name = v-poolName[6].
create lnpr.
 lnpr.id = v-poolId[7] .
 lnpr.name = v-poolName[7].
create lnpr.
 lnpr.id = v-poolId[8] .
 lnpr.name = v-poolName[8].
create lnpr.
 lnpr.id = v-poolId[9] .
 lnpr.name = v-poolName[9].
create lnpr.
 lnpr.id = v-poolId[10] .
 lnpr.name = v-poolName[10].

run txbs("r_provizf").

v-dt = date(month(r-dt), 1, year(r-dt)).
for each lnpr no-lock:
  find first msfoc where msfoc.poolId = lnpr.id and msfoc.dt = v-dt no-lock no-error.
  if avail msfoc then
   lnpr.n2 = msfoc.coeffr.
end.

def stream repdvk.
output stream repdvk to repdvk.htm.

  put stream repdvk unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream repdvk unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR>" skip.

  put stream repdvk unformatted
      "<BR><b>Классификация ссудного портфеля по МСФО</b><BR>" skip
      "<b>Отчет на " string(v-dt) "</b><br>" skip.

  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">На дату</td>" skip
  "<td valign=""center"">Общая<br>сумма пула<br> на тек. дату</td>" skip
  "<td valign=""center"">Общая<br>сумма пула<br> на выб. дату</td>" skip
  "<td valign=""center"">коэф.<br>средн.<br>списания</td>" skip
  "<td valign=""center"">Факт<br>провизий<br>по МСФО за<br>прошлый месяц</td>" skip
  "<td valign=""center"">Прогноз/факт<br>провизий по<br>МСФО за<br>текущий месяц</td>" skip
  "<td valign=""center"">Увеличение/<br>снижение по<br>МСФО</td>" skip
  "<td valign=""center"">Факт<br>провизий по<br>АФН за<br>прошлый месяц</td>" skip
  "<td valign=""center"">Факт<br>провизий по<br>АФН за<br>текущий месяц</td>" skip
  "<td valign=""center"">Увеличение/<br>снижение по<br>АФН</td>" skip
  "<td valign=""center"">Разница<br>МСФО/АФН</td>" skip.
  put stream repdvk unformatted
  "<table border=1 cellpadding=0 cellspacing=0>" skip
  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
  "<td valign=""center"">1</td>" skip
  "<td valign=""center"">2</td>" skip
  "<td valign=""center"">3</td>" skip
  "<td valign=""center"">4</td>" skip
  "<td valign=""center"">5*</td>" skip
  "<td valign=""center"">6**</td>" skip
  "<td valign=""center"">7</td>" skip
  "<td valign=""center"">8</td>" skip
  "<td valign=""center"">9</td>" skip
  "<td valign=""center"">10</td>" skip
  "<td valign=""center"">11</td>" skip.

  for each lnpr no-lock:
    put stream repdvk unformatted "<tr>" skip.
    put stream repdvk unformatted
    "<td>" lnpr.name "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n1,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n11,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n2,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n3,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(if g-today >= r-dt then lnpr.n4 else (lnpr.n1 * lnpr.n2) / 100 ,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(if g-today >= r-dt then lnpr.n4 - lnpr.n3 else (lnpr.n1 * lnpr.n2) / 100 - lnpr.n3 ,'->>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n6,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n7,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n8,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    put stream repdvk unformatted
    "<td>" replace(trim(string(lnpr.n9,'>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
  end.

  put stream repdvk unformatted "</table></body></html>".
  output stream repdvk close.
  unix silent cptwin repdvk.htm excel.

hide message no-pause.































































