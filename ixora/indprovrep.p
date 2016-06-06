/* indprovrep.p
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
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
 * BASES
        BANK
 * CHANGES
*/

def shared var g-today as date.
def var v-dt as date .
def var v-pool as char extent 10.
def var v-poolName as char extent 10.
def var v-poolId as char extent 10.
def var k as int extent 10.
def var v-numdog as char.
def var v-name as char.
def var v-clnumdog as char.
def var nd as int.

/*v-pool[1] = "27,67".
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
*/

run mondays(month(g-today), year(g-today), output nd).
v-dt = date(month(g-today), nd, year(g-today)) + 1.

def var i as integer no-undo.
def var j as integer no-undo.
def var v-crcname as char.
def var v-crcname1 as char.
def var rates as deci extent 20.

for each crc no-lock :
    rates[crc.crc] = crc.rate[1].
end.


def stream rep.
output stream rep to value("indprovrep.htm").

put stream rep unformatted "<html><head><title> Список индивидуально резервируемых займов </title>"
             "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
             "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted "<h3> Список индивидуально резервируемых займов </h3>" skip.

put stream rep unformatted
        "<table border=""1"" cellpadding=""12"" cellspacing=""0"" style=""border-collapse: collapse"">"
        "<tr style=""font:bold"">"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код клиента</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Наименование клиента</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Ссудный счет</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№ договора</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кред.линия</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№ дог. КЛ</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма ссудной задолжности</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма провизий</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма ссудной задолжности</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма провизий</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма ссудной задолжности(в тенге)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма провизий(в тенге)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма ссудной задолжности(в тенге)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Общая сумма провизий(в тенге)</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Количество дней просрочки</td>"
        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Реструктуризован ли займ</td>"
        "</tr>" skip.


for each indprov where indprov.dt = v-dt by indprov.cif by indprov.lon:
    v-numdog = ''. v-name = ''. v-clnumdog = ''.
    find first lon where lon.lon = indprov.lon no-lock no-error.
    find first cif where cif.cif = indprov.cif no-lock no-error.
    if avail cif then v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
    find first loncon where loncon.lon = indprov.lon no-lock no-error.
    if avail loncon then v-numdog = loncon.lcnt.
    find first loncon where loncon.lon = indprov.clmain no-lock no-error.
    if avail loncon then v-clnumdog = loncon.lcnt.

    put stream rep unformatted
        "<tr>"
        "<td align=""center"">" string(indprov.dt,"99/99/9999") "</td>"
                "<td>" indprov.cif "</td>"
                "<td>" v-name "</td>"
                "<td>&nbsp;" indprov.lon "</td>"
                "<td>&nbsp;" v-numdog "</td>"
                "<td>&nbsp;" indprov.clmain "</td>"
                "<td>&nbsp;" v-clnumdog  "</td>"
                "<td>" replace(trim(string(indprov.sum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.provsum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.allsum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.allprovsum,'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.sum * rates[lon.crc],'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.provsum * rates[lon.crc],'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.allsum * rates[lon.crc],'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" replace(trim(string(indprov.allprovsum * rates[lon.crc],'>>>>>>>>>>>9.99')),'.',',') "</td>"
                "<td>" indprov.daypr "</td>".
    if indprov.restr = 1 then put stream rep unformatted "<td> Да </td>".
    else put stream rep unformatted "<td> Нет </td>".
    put stream rep unformatted "</tr>" skip.
end.
put stream rep unformatted "</table></body></html>" skip.
output stream rep close.
unix silent value("cptwin " + "indprovrep.htm excel").
