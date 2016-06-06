/* p_kredmon.p
 * MODULE
        Кредитный модуль - PUSH отчеты
 * DESCRIPTION
        Задолжники по кредитам - ЮРИДИЧЕСКИЕ ЛИЦА
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        r_krmon (input datums, input v-sel)
 * MENU
        4-4-3-8
 * AUTHOR
        01/04/03 marinav
 * CHANGES
        -----------------------------------------------------------------
        26.08.2003 marinav Изменен формат вывода чисел
        25/05/2004 madiar - добавил возможность выбора - формировать отчет только по физ. или только по юр. лицам.
        16/06/2004 madiar - добавил индекс и поле bank в wrk.
                            Отчет выводится не в кучу, а по филиалам
        29/07/2004 madiar - Убрал запрос на ввод даты
        30/07/2004 madiar - Добавил shared переменную mesa - показ прогресса формирования отчета
        12.11.2004 saltanat - Добавила 2 поля: "Наличие блокировки счетов", "Номер ссудного счета".
        17/11/2004 madiar,saltanat - Добавили поле aassum - заблокированная сумма
        09/12/2004 madiar - Добавил поле bal16 - для штрафов
        07/02/2005 madiar - Разбиваем кредиты на три группы - КИК, с днем погашения сегодня, и все остальные.
        08/02/2005 madiar - Исправил текст в отчете
        21/02/2005 madiar - Добавил список тек счетов клиента
        08/04/2005 madiar - Для физ.лиц добавил список тек счетов клиента в валюте кредита и остатки по ним
        28/04/2005 madiar - по F4 - выход из меню выбора отчета
        07/06/2005 madiar - Добавил индексированный ОД и %%
        -----------------------------------------------------------------
        25/04/2005 sasco  - Переделал в формат PUSH-отчетов, сделал для юридических лиц v-sel = 0
        01/11/2005 madiar - Добавил внебаланс
        21/11/2005 madiar - добавил поле wrk.respman
        15/02/2006 Natalya D. - добавлены 2 поля: Начисленные % за балансом и Начисленные штрафы за балансом
        05/04/2006 sasco - удалил запрос на дату и выбор типа отчета, так как это PUSH отчет, не работающий с вводом с экрана
                         - нарисовал кучу no-undo
                         - убрал расширение .p из запуска в r-branch.i
        03/07/2006 u00121 - добавил индекс idx1-wrk в таблицу wrk
        10/07/2006 Natalya D. - добавила поля "Комиссия за неисполь.кред.линию" "7МРП" "Комис-я бизнес-кредит"
        28/05/2007 madiyar - оптимизация
        25/08/2011 dmitriy - добавил поле kommis в wrk
*/


{global.i}
{push.i}

def var coun as int init 1 no-undo.
def var dayc1 as int init 0 no-undo.
def var dayc2 as int init 0 no-undo.
define variable datums  as date format '99/99/9999' label 'На' no-undo.
define variable sumbil as decimal format '->,>>>,>>9.99' no-undo.
define variable sumpen as decimal format '->,>>>,>>9.99' no-undo.
def var v-sel as char init '0' no-undo.

def new shared var mesa as int init 0 no-undo.

datums = vdt. /* PUSH - параметр */

v-sel = "0". /* юридические лица - 0, физические - 1 */

def new shared temp-table wrk no-undo
    field lon    like bank.lon.lon
    field cif    like bank.lon.cif
    field name   like bank.cif.name
    field bank   as   char
    field phones as   char
    field fu     as   char
    field rdt    like bank.lon.rdt
    field duedt  like bank.lon.rdt
    field opnamt like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field bal1   like bank.lon.opnamt
    field dt1    as   inte
    field bal2   like bank.lon.opnamt
    field dt2    as   inte
    field bal3   like bank.lon.opnamt
    field accs   as   char
    field balkzt as   deci
    field balusd as   deci
    field baleur as   deci
    field bal16  as   deci
    field bal13  as   deci
    field bal4   as   deci
    field bal14  as   deci
    field bal5   as   deci
    field bal30  as   deci
    field bal25  as   deci
    field mrp7   as   deci
    field buscr  as   deci
    field iod    as   deci
    field iprc   as   deci
    field aasbl  as   char
    field aassum as   deci
    field is-kik as   logi
    field is-today as logi
    field respman  as char
    field kommis   as   deci
    index ind1 is-kik bank crc bal3
    index ind2 is-today bank crc bal3
    index idx1-wrk bank crc.

def var v-am1 as decimal init 0 no-undo.
def var v-am2 as decimal init 0 no-undo.
def var v-am3 as decimal init 0 no-undo.

/*run comm-con.
run r_krmon(input datums, input v-sel).*/
{r-branch.i &proc = "kredmon1 (input datums, input v-sel)"}

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to value(vfname).
output stream m-out to value(g-ofc).

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">" skip.


put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<tr align=""center""><td><h3>Задолженность по ссудным счетам клиентов за " string(datums) "<BR>".

if v-sel = "0" then put stream m-out unformatted "(Юридические лица)".
else put stream m-out unformatted "(Физические лица)".

put stream m-out unformatted "</h3></td></tr><br><br>" skip(1).

       put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>".
       if v-sel = "0" then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Телефоны</td>".
       put stream m-out "<td bgcolor=""#C0C0C0"" align=""center"">Дата окончания</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Просрочка ОД</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней просрочки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Просрочка %</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней просрочки</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (ОД)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные %%<br>за балансом</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (%)</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс ОД</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс %%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные штрафы<br>за балансом</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (Штрафы)</td>" skip.

       if v-sel = "0" then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Тек счета (KZT)</td>".
       else put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Тек счета<BR>(в валюте кредита)</td>"
                                         "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на счетах<BR>в валюте кредита</td>" skip.

       if v-sel = "0" then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на<BR>KZT счетах</td>"
                               "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на<BR>USD счетах</td>"
                               "<td bgcolor=""#C0C0C0"" align=""center"">Остаток на<BR>EUR счетах</td>".
       put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Наличие блокировки счетов</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Cсудный счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Заблокированная<BR>сумма</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный<BR>менеджер</td></tr>" skip.

/* Кредиты КИК */

find first wrk where wrk.is-kik no-lock no-error.
if avail wrk then do:
  put stream m-out unformatted "<tr bgcolor=""#99ccff"" style=""font:bold""><td colspan=" if v-sel = "0" then "21" else "18" ">КИК</td></tr>"skip.
  sumbil = 0.
  for each wrk no-lock where wrk.is-kik break by wrk.bank by wrk.crc desc by wrk.bal3 desc.

    find crc where crc.crc = wrk.crc no-lock no-error.

        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">" wrk.cif "</td>"
               "<td align=""left"">" wrk.name format "x(60)" "</td>".
        if v-sel = "0" then put stream m-out unformatted "<td align=""left"">" wrk.phones "</td>".
        put stream m-out unformatted "<td align=""left""> " wrk.duedt "</td>"
               "<td>" replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""left"">" crc.code "</td>"
               "<td>" replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" wrk.dt1 format '->>>9' "</td>"
               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"

               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip

               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>&nbsp;" wrk.accs "</td>" skip
               "<td>" replace(trim(string(wrk.balkzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        if v-sel = "0" then put stream m-out unformatted "<td>" replace(trim(string(wrk.balusd, "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "<td>" replace(trim(string(wrk.baleur, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        put stream m-out unformatted "<td align=""left""> " wrk.aasbl "</td>" skip
               "<td>&nbsp;" wrk.lon "</td>" skip
               "<td>" replace(trim(string(wrk.aassum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" wrk.respman "</td>" skip.
        put stream m-out unformatted "</tr>" skip.
        sumbil = sumbil + wrk.bal3.
        sumpen = sumpen + wrk.bal16.
        coun = coun + 1.

    if last-of (wrk.crc) then
    do:
       find crc where crc.crc = wrk.crc no-lock.
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО " crc.des "</b></td>".
       if v-sel = "0" then put stream m-out unformatted "<td></td>".
       put stream m-out unformatted "<td></td> <td></td> <td></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td><td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td> <td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

/* Кредиты с днем погашения */

find first wrk where wrk.is-today and not(wrk.is-kik) no-lock no-error.
if avail wrk then do:
  put stream m-out unformatted "<tr bgcolor=""#99ccff"" style=""font:bold""><td colspan=" if v-sel = "0" then "21" else "18" ">Дата погашения - " g-today format "99/99/9999" "</td></tr>"skip.
  sumbil = 0.
  for each wrk no-lock where wrk.is-today and not(wrk.is-kik) break by wrk.bank by wrk.crc desc by wrk.bal3 desc.

    find crc where crc.crc = wrk.crc no-lock no-error.

        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">" wrk.cif "</td>"
               "<td align=""left"">" wrk.name format "x(60)" "</td>".
        if v-sel = "0" then put stream m-out unformatted "<td align=""left"">" wrk.phones "</td>".
        put stream m-out unformatted "<td align=""left""> " wrk.duedt "</td>"
               "<td>" replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""left"">" crc.code "</td>"
               "<td>" replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" wrk.dt1 format '->>>9' "</td>"
               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"

               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip

               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>&nbsp;" wrk.accs "</td>" skip
               "<td>" replace(trim(string(wrk.balkzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        if v-sel = "0" then put stream m-out unformatted "<td>" replace(trim(string(wrk.balusd, "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "<td>" replace(trim(string(wrk.baleur, "->>>>>>>>>>>9.99")),".",",") "</td>".
        put stream m-out unformatted "<td align=""left""> " wrk.aasbl "</td>" skip
               "<td>&nbsp;" wrk.lon "</td>" skip
               "<td>" replace(trim(string(wrk.aassum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" wrk.respman "</td>" skip.
        put stream m-out unformatted "</tr>" skip.
        sumbil = sumbil + wrk.bal3.
        sumpen = sumpen + wrk.bal16.
        coun = coun + 1.

    if last-of (wrk.crc) then
    do:
       find crc where crc.crc = wrk.crc no-lock.
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО " crc.des "</b></td>".
       if v-sel = "0" then put stream m-out unformatted "<td></td>".
       put stream m-out unformatted "<td></td> <td></td> <td></td> <td></td><td></td> <td></td><td></td><td></td> <td></td><td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td> <td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

/* Все остальные кредиты */

find first wrk where not(wrk.is-kik) and not(wrk.is-today) no-lock no-error.
if avail wrk then do:
  put stream m-out unformatted "<tr bgcolor=""#99ccff"" style=""font:bold""><td colspan=" if v-sel = "0" then "21" else "18" ">Прочие</td></tr>" skip.
  sumbil = 0.
  for each wrk where not(wrk.is-kik) and not(wrk.is-today) break by wrk.bank by wrk.crc desc by wrk.bal3 desc.

    find crc where crc.crc = wrk.crc no-lock no-error.

        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">" wrk.cif "</td>"
               "<td align=""left"">" wrk.name format "x(60)" "</td>".
        if v-sel = "0" then put stream m-out unformatted "<td align=""left"">" wrk.phones "</td>".
        put stream m-out unformatted "<td align=""left""> " wrk.duedt "</td>"
               "<td>" replace(trim(string(wrk.opnamt, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balans, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""left"">" crc.code "</td>"
               "<td>" replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" wrk.dt1 format '->>>9' "</td>"
               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"

               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip

               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>&nbsp;" wrk.accs "</td>" skip
               "<td>" replace(trim(string(wrk.balkzt, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        if v-sel = "0" then put stream m-out unformatted "<td>" replace(trim(string(wrk.balusd, "->>>>>>>>>>>9.99")),".",",") "</td>"
                                "<td>" replace(trim(string(wrk.baleur, "->>>>>>>>>>>9.99")),".",",") "</td>".
        put stream m-out unformatted "<td align=""left""> " wrk.aasbl "</td>" skip
               "<td>&nbsp;" wrk.lon "</td>" skip
               "<td>" replace(trim(string(wrk.aassum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" wrk.respman "</td>" skip.
        put stream m-out unformatted "</tr>" skip.
        sumbil = sumbil + wrk.bal3.
        sumpen = sumpen + wrk.bal16.
        coun = coun + 1.

    if last-of (wrk.crc) then
    do:
       find crc where crc.crc = wrk.crc no-lock.
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО " crc.des "</b></td>".
       if v-sel = "0" then put stream m-out unformatted "<td></td>".
       put stream m-out unformatted "<td></td> <td></td> <td></td> <td></td><td></td> <td></td><td></td><td></td> <td></td><td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td> <td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

put stream m-out unformatted "</table>" skip.
output stream m-out close.

vres = yes. /* успешное формирование файла */
