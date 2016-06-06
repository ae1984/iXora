/* r-klasif.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредитного портфеля
 * RUN
        r-klasif
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT

 * INHERIT
        r-klasif1(input datums)
 * MENU
        4-2-5-11
 * AUTHOR
        01/06/03 marinav
 * CHANGES
        25.08.03 marinav Добавлены правильные курсы валют, изменен формат вывода отчета
        29.09.03 marinav Дополнительный отчет (сводные цифры)
        19.11.03 marinav Еще один Дополнительный отчет (сводные цифры)
        02.03.04 marinav Немного поменян внешний вид отчета
        25.03.2004 marinav добавлены полученные проценты
        26/05/2004 madiyar - При запросе курсов выводятся текущие учетные курсы валют с возможностью редактирования
        16/07/2004 madiyar - Выводятся учетные курсы валют на введенную дату с возможностью редактирования
        03/08/2004 madiyar - добавил колонки "Дата выдачи кредита", "В т.ч. индексация в тыс.тенге" (по ОД и %%)
        10/08/2004 madiyar - Исправил съехавшие после добавления колонок итоговые суммы
        13/08/2004 madiyar - В процессе отладки закомментировал cptwin, и так и выложил на реальную. Теперь исправил
        02/11/2004 madiyar - Добавил во всех put'ах unformatted, добавил индексы во временной таблице
        02/12/2004 madiyar - Накопление итоговых сумм производится в тенге, а не в тысячах тенге, для уменьшения ошибки округления
        01/02/2005 madiyar - Исправил заголовок
        08/04/2005 madiyar - добавил отрасль
        27/05/2005 madiyar - добавил колонку "адрес" по обеспечению, описание обеспечения выводится полностью
        29/09/2005 marinav - добавлено поле залогодатель
        22/12/2005 madiyar - label "за дату", обеспечение уже в тенге
        08/02/2006 madiyar - r-branch -> r-brfilial
        30/05/2006 madiyar - наименование клиента в каждой строчке, no-undo
        14/07/2006 MARINAV - требования КИК
        29/09/2006 madiyar - разделил на три отчета - юр, физ и бд
        31/10/2006 madiyar - теперь формируется еще и консолидированный пуш
        01/11/2006 madiyar - в отчете были слишком длинные строки, дорисовал skip-ов
        05/03/2008 madiyar - евро 11 -> 3
        09/06/2010 galina - убрала столбец КИК
        09/07/2010 aigul - добавила сортировку по МСБ, добавила вывод классификации и рейтинга, суммы обеспечения
        20.07.2010 marinav - добавление счета ГК
        4/08/2010 aigul - добавление информации о клиентах связанных с банком особыми отношениями
        05/08/2010 madiyar - p-brfilial.i -> r-brfilial.i
        31/08/2010 madiyar - ответственный менеджер
        02/01/2011 madiyar - добавил колонку с провизиями на вознаграждение
        11/01/2011 madiyar - подправил провизии
        01/02/2011 madiyar - еще раз подправил провизии
        14.04.2011 aigul добавила код займа для бух-ов
        19.04.2011 Luiza Расширила формат вывода данных до ->>>>>>>>>>>>>>9.99.
        21.04.2011 aigul - поставила точку после skip 304 строка
        02/06/2011 madiyar - дата выдачи, дата договора
        01/08/2011 madiyar - провизии МСФО
        07/11/2011 kapar - добавил столбцы - «Амортизация дисконта» и «Дисконт по займам»
        23/11/2011 kapar -  добавил столбец - «сумма в тыс. тенге (34 ур)»
        17/01/2011 kapar - ТЗ №1255
        03/02/2012 dmitriy - добавил столбец "Отраслевая направленность займа"
        07/03/2013 sayat(id01143) - ТЗ 1655 в блоке "Обеспечение" добавлены 2 столбца "Номер договора залога" и "Дата договора залога"
*/


def shared var g-today as date.
def var coun as int no-undo init 1.
def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
define variable datums as date no-undo format '99/99/9999' label 'На'.
define variable v-sum1 as decimal no-undo extent 10 format '->>>,>>>,>>9.99'.
define variable v-sum2 as decimal no-undo extent 10 format '->>>,>>>,>>9.99'.
define variable v-sum3 as decimal no-undo extent 10 format '->>>,>>>,>>9.99'.
define var i as inte no-undo.


def new shared var v-reptype as integer no-undo.
v-reptype = 1.

datums = g-today.
update datums label ' За дату' format '99/99/9999' skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - МСБ, 5 - Все"
       with side-label row 5 centered frame dat.

def var v-repname as char no-undo extent 5.
v-repname[1] = "юр".
v-repname[2] = "физ".
v-repname[3] = "БД".
v-repname[4] = "МСБ".
v-repname[5] = "все".

def new shared temp-table wrk no-undo
    field num    as inte
    field lon    like bank.lon.lon
    field cif    like bank.lon.cif
    field name   like bank.cif.name
    field rdt    as inte
    field regdt  like bank.lon.rdt
    field isdt  as date
    field ddt like bank.lon.rdt
    field grp like bank.lon.grp
    field opnamt like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field balansi like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field sts    like bank.lonstat.prc
    field bal1   like bank.lon.opnamt  /*Нач доходы*/
    field balprci like bank.lon.opnamt  /*в т.ч. индексация*/
    field bal11   like bank.lon.opnamt  /*Пол доходы*/
    field bal2   like bank.lon.opnamt   /* Провизии необ  */
    field lcnt_dk as char /*№ договора*/
    field amr_dk  as deci /*Амортизация дисконта*/
    field zam_dk  as deci /*Дисконт по займам*/
    field bal_afn like bank.lon.opnamt  /* Провизии АФН */
    field bal_msfo like bank.lon.opnamt
    field prov_od as deci
    field prov_prc as deci
    field prov_pen as deci
    field kod    as   inte  /* Обесп*/
    field crcz    as   inte  /* Обесп*/
    field v-name as char
    field v-addr as char
    field v-zal as char
    field bal4   like bank.lon.opnamt
    field bal5  like bank.lon.opnamt
    field ecdiv  as char
    field kodd  as char
    field rate  as char
    field bal34 as deci
    field lnprod as char

    field rating  as decimal
    field rating_ob  as decimal
    field valdesc  as char
    field valdesc_ob  as char
    field gl as char
    field rel as char
    field ofc as char
    field kod_buham as int
    field napr as char
    field zaldognum as char
    field zaldogdt as date
    /*field lntreb as char*/
    index ind1 is primary sts rdt lon name desc
    index ind2 cif kod.

define temp-table wrk1 no-undo
  field type as inte     /*тип Стандарт Субстандарт Безнадеж*/
  field sts  like bank.lonstat.prc  /*статус 0, 5, 10, 15, 20, 25,50, 100*/
  field rdt  as inte                /* год выдачи*/
  field type1 as inte             /* тип 1- сумма кредита 2- необх провизии 3-создан провизии 4-обеспечение */
  field bal1  like bank.lon.opnamt
  index idx1 rdt
  index idx2 rdt sts type1
  index idx3 sts type1 rdt.

def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.

def var v-cur  as deci no-undo init 1.
def var v-curd as deci no-undo.
def var v-cure as deci no-undo.
def var v-curr as deci no-undo.

if datums = g-today then do:
  find first crc where crc.crc = 2 no-lock no-error.
  if avail crc then v-curd = crc.rate[1].
  find first crc where crc.crc = 3 no-lock no-error.
  if avail crc then v-cure = crc.rate[1].
  find first crc where crc.crc = 4 no-lock no-error.
  if avail crc then v-curr = crc.rate[1].
end.

if datums < g-today then do:
  find last crchis where crchis.crc = 2 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-curd = crchis.rate[1].
  find last crchis where crchis.crc = 3 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-cure = crchis.rate[1].
  find last crchis where crchis.crc = 4 and crchis.rdt <= datums no-lock no-error.
  if avail crchis then v-curr = crchis.rate[1].
end.

display skip(1)
        v-curd label ' Курс доллара ...... ' format 'zz9.99' skip
        v-cure label ' Курс ЕВРО ......... ' format 'zz9.99' skip
        v-curr label ' Курс рубля ........ ' format 'zz9.99' skip(1)
        with row 8 centered  side-labels frame opt title " Курсы на " + string(datums,"99/99/9999") + ": " .
update v-curd v-cure v-curr with frame opt.

{r-brfilial.i &proc = "r-klasif2(input datums)"}

find first wrk no-lock no-error.
if not avail wrk then return.

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.


put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<tr><td><h3>Классификация кредитного портфеля за " string(datums) " (" v-repname[v-reptype] ")</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Отрасль</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Год выдачи кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата договора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата выдачи</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дата окончания</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Группа</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Продукт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Сумма по договору</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Остаток долга</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Индексация ОД<BR>в тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>% ставка</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Начисленные доходы</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Индексация %<BR>в тыс.тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Полученные доходы</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Статус</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Необходимая сумма провизий</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>№ договора</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Амортизация дисконта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Дисконт по займам</td>"

                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Провизии АФН (KZT)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Провизии МСФО (KZT)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Провизии МСФО ОД (KZT)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Провизии МСФО %% (KZT)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Провизии МСФО Штрафы (KZT)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=8>Обеспечение</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>сумма в тыс. тенге (34 ур)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Рейтинг</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Классификация</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Счет ГК</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Лица связанные с банком особыми отношениями</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Ответств. менеджер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Код займа для ГБ</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Отраслевая<br>направленность займа</td></tr>" skip.
                  /*"<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>КИК</td></tr>" skip.*/

       put stream m-out unformatted "<tr style=""font:bold"">"
                  /* Сумма по договору */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  /* Остаток долга */
                  "<td bgcolor=""#C0C0C0"" align=""center"">В валюте кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">В тыс тенге</td>"
                  /* Начисленные доходы */
                  "<td bgcolor=""#C0C0C0"" align=""center"">В валюте кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">в тыс тенге</td>"
                  /* Необходимая сумма провизий */
                  "<td bgcolor=""#C0C0C0"" align=""center"">в тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">в тыс тенге</td>"
                  /* Обеспечение */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">наименование</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">адрес</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">залогодатель</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">стоимость обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">сумма в тыс тенге (19 ур)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">№ договора залога</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">дата договора залога</td>"
                  /* Классификация */
                  "<td bgcolor=""#C0C0C0"" align=""center"">Финансовое состояние</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Качество предост. обеспечения</td></tr>" skip.

for each wrk break by wrk.sts by wrk.rdt by wrk.lon by wrk.name desc.

  find crc where crc.crc = wrk.crc no-lock no-error.

      v-cur = 1.
      if wrk.crc = 2 then v-cur = v-curd.
      if wrk.crc = 3 then v-cur = v-cure.
      if wrk.crc = 4 then v-cur = v-curr.

        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " wrk.ecdiv "</td>"
               "<td> " wrk.rdt format '>>>9' "</td>"
               "<td> " wrk.regdt "</td>"
               "<td> " wrk.isdt "</td>"
               "<td> " wrk.ddt "</td>"
               "<td> " wrk.grp "</td>"
               "<td> " wrk.lnprod "</td>"
               "<td> " crc.code format 'x(3)' "</td>"
               "<td> " replace(trim(string(wrk.opnamt, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans * v-cur / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balansi * v-cur / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.prem, "->>9.99%")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.bal1, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.bal1 * v-cur / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balprci * v-cur / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.bal11, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " wrk.sts format '->>9' "</td>"
               "<td> " replace(trim(string(round(wrk.balans * v-cur * wrk.sts / 100,2), "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.balans * v-cur * wrk.sts / 100000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"

               "<td> " wrk.lcnt_dk "</td>"
               "<td> " replace(trim(string(wrk.amr_dk, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.zam_dk, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"

               "<td> " replace(trim(string(wrk.bal_afn, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.bal_msfo, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.prov_od, "->>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td> " replace(trim(string(wrk.prov_prc, "->>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
               "<td> " replace(trim(string(wrk.prov_pen, "->>>>>>>>>>>>>>9.99")),".",",") "</td>" skip

               "<td> " wrk.kod format '->>>9' "</td>" skip
               "<td align=""left""> " wrk.v-name "</td>" skip
               "<td align=""left""> " wrk.v-addr "</td>" skip
               "<td align=""left""> " wrk.v-zal "</td>" skip
               "<td> " replace(trim(string(wrk.bal5 / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td> " replace(trim(string(wrk.bal4 / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""left""> " wrk.zaldognum "</td>" skip
               "<td> " wrk.zaldogdt "</td>" skip
               /*"<td align=""left""> " wrk.lntreb "</td>" skip*/
               "<td> " replace(trim(string(wrk.bal34 / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""left""> "wrk.kodd " - " wrk.rate "</td>"
               "<td align=""left""> "wrk.valdesc "</td>"
               "<td align=""left""> "wrk.valdesc_ob "</td>"
               "<td align=""left""> "wrk.gl "</td>"
               "<td align=""left""> "wrk.rel "</td>" skip
               "<td align=""left""> " wrk.ofc "</td>" skip
               "<td align=""left""> " kod_buham "</td>"
               "<td align=""left""> " wrk.napr "</td>"
               "</tr>" skip.

      v-sum1[1] = v-sum1[1] + wrk.balans * v-cur.
      v-sum1[2] = v-sum1[2] + wrk.bal1 * v-cur.
      v-sum1[3] = v-sum1[3] + wrk.balans * v-cur * wrk.sts / 100.
      v-sum1[4] = v-sum1[4] + wrk.bal_afn.
      v-sum1[5] = v-sum1[5] + wrk.bal5.
      v-sum1[6] = v-sum1[6] + wrk.bal4.
      v-sum1[7] = v-sum1[7] + wrk.bal_msfo.
      v-sum1[8] = v-sum1[8] + wrk.amr_dk.
      v-sum1[9] = v-sum1[9] + wrk.zam_dk.
      v-sum1[10] = v-sum1[10] + wrk.bal34.

      coun = coun + 1.

    if last-of (wrk.rdt) then do:
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО " wrk.rdt format '>>>9' " год </b></td> <td></td> <td></td> <td></td>"
                 "<td></td> <td></td> <td></td> <td></td> <td></td> <td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[1] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[2] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[3] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b></b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[8], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[9], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[4], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[7], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[5] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[6] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum1[10] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<br>" skip.
       v-sum2[1] = v-sum2[1] + v-sum1[1].
       v-sum2[2] = v-sum2[2] + v-sum1[2].
       v-sum2[3] = v-sum2[3] + v-sum1[3].
       v-sum2[4] = v-sum2[4] + v-sum1[4].
       v-sum2[5] = v-sum2[5] + v-sum1[5].
       v-sum2[6] = v-sum2[6] + v-sum1[6].
       v-sum2[7] = v-sum2[7] + v-sum1[7].
       v-sum2[8] = v-sum2[8] + v-sum1[8].
       v-sum2[9] = v-sum2[9] + v-sum1[9].
       v-sum2[10] = v-sum2[10] + v-sum1[10].


       find first wrk1 where wrk1.rdt = wrk.rdt no-error.
       if not avail wrk1 then do:
           repeat i = 1 to 6.
               for each lonstat.
                   create wrk1.
                          wrk1.sts = lonstat.prc.
                          wrk1.type = 2.
                          if wrk.sts = 0 then wrk1.type = 1.
                          if wrk.sts = 100 then wrk1.type = 3.
                          wrk1.rdt = wrk.rdt.
                          wrk1.type1 = i.
               end.
           end.
       end.

       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 1 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[1].
       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 2 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[3].
       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 3 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[4].
       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 4 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[5].
       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 5 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[6].
       find first wrk1 where wrk1.rdt = wrk.rdt and wrk1.sts = wrk.sts and wrk1.type1 = 6 no-lock no-error.
       if avail wrk1 then wrk1.bal1 = v-sum1[7].

       v-sum1[1] = 0.
       v-sum1[2] = 0.
       v-sum1[3] = 0.
       v-sum1[4] = 0.
       v-sum1[5] = 0.
       v-sum1[6] = 0.
       v-sum1[7] = 0.
       v-sum1[8] = 0.
       v-sum1[9] = 0.
       v-sum1[10] = 0.

    end.
    if last-of (wrk.sts) then
    do:
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО по статусу " wrk.sts " </b></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[1] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[2] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[3] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b></b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[8], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[9], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[4], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[7], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[5] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[6] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum2[10] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<br>" skip skip.
       v-sum3[1] = v-sum3[1] + v-sum2[1].
       v-sum3[2] = v-sum3[2] + v-sum2[2].
       v-sum3[3] = v-sum3[3] + v-sum2[3].
       v-sum3[4] = v-sum3[4] + v-sum2[4].
       v-sum3[5] = v-sum3[5] + v-sum2[5].
       v-sum3[6] = v-sum3[6] + v-sum2[6].
       v-sum3[7] = v-sum3[7] + v-sum2[7].
       v-sum3[8] = v-sum3[8] + v-sum2[8].
       v-sum3[9] = v-sum3[9] + v-sum2[9].
       v-sum3[10] = v-sum3[10] + v-sum2[10].
       v-sum2[1] = 0.
       v-sum2[2] = 0.
       v-sum2[3] = 0.
       v-sum2[4] = 0.
       v-sum2[5] = 0.
       v-sum2[6] = 0.
       v-sum2[7] = 0.
       v-sum2[8] = 0.
       v-sum2[9] = 0.
       v-sum2[10] = 0.
    end.
end.
       put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО </b></td> <td></td> <td></td> <td></td> <td></td> <td></td><td></td> <td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[1] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[2] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[3] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b></b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[8], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[9], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[4], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[4], "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[5] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[6] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b>" replace(trim(string(v-sum3[10] / 1000, "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<br>" skip skip.

put stream m-out unformatted "</table>" skip.
output stream m-out close.

output stream m-out to rpt1.html.

/******************************************/

/**Данные***/

for each wrk1 where wrk1.type1 ne 4 break by wrk1.sts by wrk1.type1 by wrk1.rdt .

if first-of (wrk1.sts) then put stream m-out unformatted "<tr align=""right""><td align=""center""> " wrk1.sts "</td>".

if first-of (wrk1.type1) then put stream m-out unformatted "<td> </td>".

   put stream m-out unformatted "<td> " replace(trim(string(wrk1.bal1, "->>>>>>>>>>>9")), ".", ",") "</td>".

if last-of (wrk1.sts) then put stream m-out unformatted "</tr>" skip.

end.

put stream m-out unformatted "</table>" skip.


/*шапка*/
put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.
put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>" skip.

put stream m-out unformatted "<tr align=""center""><td><h3>Классификация кредитов за " string(datums)
                 "</h3></td></tr><br><br>" skip.

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Группа кредита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Всего сумма основного долга</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Задолженность по кредитам</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Необходимая сумма резервов</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Сформированная сумма резервов (АФН)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Сформированная сумма резервов (МСФО)</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Cтоимость обеспечения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" > Cтоимость обеспечения (19 уровень)</td></tr>" skip.


/**Данные***/

v-sum1[1] = 0.
v-sum1[2] = 0.
v-sum1[3] = 0.
v-sum1[4] = 0.
v-sum1[5] = 0.
v-sum1[6] = 0.
for each wrk1 break by wrk1.sts by wrk1.type1.

if first-of (wrk1.sts) then put stream m-out unformatted "<tr align=""right""><td align=""center""> " wrk1.sts "</td>" skip.

   if wrk1.type1 = 1 then v-sum1[1] = v-sum1[1] + wrk1.bal1.
   if wrk1.type1 = 2 then v-sum1[2] = v-sum1[2] + wrk1.bal1.
   if wrk1.type1 = 3 then v-sum1[3] = v-sum1[3] + wrk1.bal1.
   if wrk1.type1 = 4 then v-sum1[4] = v-sum1[4] + wrk1.bal1.
   if wrk1.type1 = 5 then v-sum1[5] = v-sum1[5] + wrk1.bal1.
   if wrk1.type1 = 6 then v-sum1[6] = v-sum1[6] + wrk1.bal1.


if last-of (wrk1.sts) then do:
   put stream m-out unformatted "<td> " replace(trim(string(v-sum1[1], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[1], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[2], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[3], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[6], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[4], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                     "<td> " replace(trim(string(v-sum1[5], "->>>>>>>>>>>>>>9")), ".", ",") "</td>"
                    skip.
   v-sum1[1] = 0.
   v-sum1[2] = 0.
   v-sum1[3] = 0.
   v-sum1[4] = 0.
   v-sum1[5] = 0.
   v-sum1[6] = 0.
   put stream m-out unformatted "</tr>" skip.
end.

end.

put stream m-out unformatted "</table>" skip.


output stream m-out close.

unix silent cptwin rpt.html excel.exe.
unix silent cptwin rpt1.html excel.exe.
