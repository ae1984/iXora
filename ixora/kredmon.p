/* kredmon.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Задолжники по кредитам
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
        26.08.2003 marinav Изменен формат вывода чисел
        25/05/2004 madiyar - добавил возможность выбора - формировать отчет только по физ. или только по юр. лицам.
        16/06/2004 madiyar - добавил индекс и поле bank в wrk.
                            Отчет выводится не в кучу, а по филиалам
        29/07/2004 madiyar - Убрал запрос на ввод даты
        30/07/2004 madiyar - Добавил shared переменную mesa - показ прогресса формирования отчета
        12.11.2004 saltanat - Добавила 2 поля: "Наличие блокировки счетов", "Номер ссудного счета".
        17/11/2004 madiyar,saltanat - Добавили поле aassum - заблокированная сумма
        09/12/2004 madiyar - Добавил поле bal16 - для штрафов
        07/02/2005 madiyar - Разбиваем кредиты на три группы - КИК, с днем погашения сегодня, и все остальные.
        08/02/2005 madiyar - Исправил текст в отчете
        21/02/2005 madiyar - Добавил список тек счетов клиента
        08/04/2005 madiyar - Для физ.лиц добавил список тек счетов клиента в валюте кредита и остатки по ним
        28/04/2005 madiyar - по F4 - выход из меню выбора отчета
        07/06/2005 madiyar - Добавил индексированный ОД и %%
        01/11/2005 madiyar - Добавил внебаланс
        21/11/2005 madiyar - добавил поле wrk.respman
        15/02/2006 Natalya D. - добавлены 2 поля: Начисленные % за балансом и Начисленные штрафы за балансом
        06/04/2006 madiyar - добавил no-undo в описание таблицы wrk
        05/07/2006 suchkov - добавил индекс в табл. wrk
        10/07/2006 Natalya D. - добавила поля "Комиссия за неисполь.кред.линию" "7МРП" "Комис-я бизнес-кредит"
        14/03/2011 madiyar - r-branch.i -> r-brfilial.i
        10/08/2011 dmitriy - добавил в отчет столбец "Комиссия за обслуживание кредита" и поле commis в wrk
*/

{mainhead.i}

def var coun as int no-undo init 1.
def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
define variable datums as date no-undo format '99/99/9999' label 'На'.
define variable sumbil as decimal no-undo format '->,>>>,>>9.99'.
define variable sumpen as decimal no-undo format '->,>>>,>>9.99'.
def var v-sel as char no-undo init '0'.

def new shared var mesa as int init 0.


datums = g-today.
/*update datums label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .*/
run sel2 ("Выбор :", " 1. Физические лица | 2. Юридические лица ", output v-sel).
if v-sel = '0' then return.
if v-sel = "2" then v-sel = "0".

message " Формируется отчет...".

def new shared temp-table wrk no-undo
    field lon      like bank.lon.lon
    field cif      like bank.lon.cif
    field name     like bank.cif.name
    field bank     as   char
    field phones   as   char
    field fu       as   char
    field rdt      like bank.lon.rdt
    field duedt    like bank.lon.rdt
    field opnamt   like bank.lon.opnamt
    field balans   like bank.lon.opnamt
    field crc      like bank.lon.crc
    field prem     like bank.lon.prem
    field bal1     like bank.lon.opnamt
    field dt1      as   inte
    field bal2     like bank.lon.opnamt
    field dt2      as   inte
    field bal3     like bank.lon.opnamt
    field accs     as   char
    field balkzt   as   deci
    field balusd   as   deci
    field baleur   as   deci
    field bal16    as   deci
    field bal13    as   deci
    field bal4     as   deci
    field bal14    as   deci
    field bal5     as   deci
    field bal30    as   deci
    field bal25    as   deci
    field mrp7     as   deci
    field buscr    as   deci
    field iod      as   deci
    field iprc     as   deci
    field aasbl    as   char
    field aassum   as   deci
    field is-kik   as   logi
    field is-today as   logi
    field respman  as   char
    field kommis   as   deci
    index ind1 is-kik bank crc bal3
    index ind2 is-today bank crc bal3
    index idx1-wrk bank crc.

def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.

/*run comm-con.
run r_krmon(input datums, input v-sel).*/
{r-brfilial.i &proc = "kredmon1 (input datums, input v-sel)"}
/*run kredmon1_t.p (input datums, input v-sel).*/

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

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
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>".
       if v-sel = "0" then put stream m-out unformatted "<td bgcolor=""#C0C0C0"" align=""center"">Телефоны</td>".
       put stream m-out "<td bgcolor=""#C0C0C0"" align=""center"">Дата окончания<br>срока кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток долга</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"">Просрочка ОД</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней просрочки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (ОД)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс ОД</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"">Просрочка %</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дней просрочки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (%)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные %%<br>за балансом</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Индекс %%</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия за<br>обслуживание кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма долга<br>(без штрафов)</td>"


                  "<td bgcolor=""#C0C0C0"" align=""center"">Штрафы</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисленные штрафы<br>за балансом</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Внебаланс (Штрафы)</td>".
       if v-sel = "0" then do:
          put stream m-out unformatted
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия за<br>неиспользованную<br>кредитную линию</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">7 МРП</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия Бизнес-Кредит</td>" skip.
       end.
       else do:
          put stream m-out unformatted
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия Бизнес-Кредит</td>" skip.
       end.

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
  sumpen = 0.
  for each wrk where wrk.is-kik break by wrk.bank by wrk.crc desc by wrk.bal3 desc.

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
               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

/*               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip*/
               "<td>" replace(trim(string(wrk.bal1 + wrk.bal13 + wrk.iod + wrk.bal2 + wrk.bal14 + wrk.bal4 + wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip.
        if v-sel = "0" then do:
           put stream m-out unformatted
               "<td>" replace(trim(string(wrk.bal25, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.mrp7, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        end.
        else   put stream m-out unformatted
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        put stream m-out unformatted
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
       put stream m-out unformatted "<td></td> <td></td> <td></td> <td></td> <td></td><td></td> <td></td> <td></td> <td></td> <td></td><td></td>" skip
                 "<td></td> <td></td> <td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                /* "<td></td> <td></td>" skip*/
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
       sumpen = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

/* Кредиты с днем погашения */

find first wrk where wrk.is-today and not(wrk.is-kik) no-lock no-error.
if avail wrk then do:
  put stream m-out unformatted "<tr bgcolor=""#99ccff"" style=""font:bold""><td colspan=" if v-sel = "0" then "21" else "18" ">Дата погашения - " g-today format "99/99/9999" "</td></tr>"skip.
  sumbil = 0.
  sumpen = 0.
  for each wrk where wrk.is-today and not(wrk.is-kik) break by wrk.bank by wrk.crc desc by wrk.bal3 desc.

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
               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"

               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.kommis, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

/*               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip*/
               "<td>" replace(trim(string(wrk.bal1 + wrk.bal13 + wrk.iod + wrk.bal2 + wrk.bal14 + wrk.bal4 + wrk.iprc + wrk.kommis, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip.
        if v-sel = "0" then do:
           put stream m-out unformatted
               "<td>" replace(trim(string(wrk.bal25, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.mrp7, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        end.
        else   put stream m-out unformatted
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
           put stream m-out unformatted
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
                 "<td></td> <td></td> <td></td> <td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
       sumpen = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

/* Все остальные кредиты */

find first wrk where not(wrk.is-kik) and not(wrk.is-today) no-lock no-error.
if avail wrk then do:
  put stream m-out unformatted "<tr bgcolor=""#99ccff"" style=""font:bold""><td colspan=" if v-sel = "0" then "21" else "18" ">Прочие</td></tr>"skip.
  sumbil = 0.
  sumpen = 0.
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
               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",")  "</td>"
               "<td>" replace(trim(string(wrk.iod, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt2 format '->>>9' "</td>"

               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.iprc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.kommis, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

/*               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>" skip*/
               "<td>" replace(trim(string(wrk.bal1 + wrk.bal13 + wrk.iod + wrk.bal2 + wrk.bal14 + wrk.bal4 + wrk.iprc + wrk.kommis, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td>" replace(trim(string(wrk.bal16, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",")  "</td>" skip.
        if v-sel = "0" then do:
           put stream m-out unformatted
               "<td>" replace(trim(string(wrk.bal25, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.mrp7, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        end.
        else   put stream m-out unformatted
               "<td>" replace(trim(string(wrk.buscr, "->>>>>>>>>>>9.99")),".",",") "</td>" skip.
        put stream m-out unformatted
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
                 "<td></td> <td></td> <td></td> <td></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumbil, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td align=""right""><b>" replace(trim(string(sumpen, "->>>>>>>>>>>9.99")),".",",") "</b></td>" skip
                 "<td></td><td></td><td></td>" skip.
       if v-sel = "0" then put stream m-out unformatted "<td></td><td></td>".
       put stream m-out unformatted "<td></td><td></td><td></td><td></td>" skip.
       put stream m-out unformatted "</tr>" skip.
       sumbil = 0.
       sumpen = 0.
    end.
  end. /* for each wrk */
end. /* if avail wrk */

put stream m-out unformatted "</table>" skip.
output stream m-out close.

hide message no-pause.

unix silent cptwin rpt.html excel.exe.
