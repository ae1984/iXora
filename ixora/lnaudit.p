/* lnaudit.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Кредитный портфель для аудита (цикл по всем филиалам)
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
        09.01.04 marinav
 * CHANGES
        23/07/2004 madiyar - отчет теперь формирует временную таблицу
        15/12/2004 madiyar - изменения везде понемногу
        19/01/2005 madiyar - добавил номер договора банковского займа
        20/01/2005 madiyar - добавил поле и колонку - денежные залоги
        09/02/2006 Natalya D. - Добавила поля "Начисленные % за балансом", "Штрафы", "Начисленные штрафы за балансом".
        23/02/2006 madiyar - подправил текст в шапке отчета
        13/04/06 marinav   - проверка , если есть ли готовый отчет, то его и открываем
        15/09/2006 madiyar - no-undo
        29/09/2006 madiyar - разделил на три отчета - юр, физ и бд
        31/10/2006 madiyar - добавил еще консолидированный
        26/12/07 marinav - добавлены адреса и телефоны
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        08/05/2008 madiyar - добавил полученные проценты
        27/01/2010 galina - берем курс из crchis по rdt
        14/04/2010 madiyar - отсроченные штрафы
        15/04/2010 madiyar - убрал три столбца с адресами и телефоном
        11/05/2010 galina - добавила столбец "Статус КД"
        19/05/2010 madiyar - добавил историческую ставку
        09/07/2010 aigul - добавила сортировку по МСБ, добавила вывод классификации и рейтинга
        4/08/2010 aigul - добавление информации о клиентах связанных с банком особыми отношениями
        05/08/2010 madiyar - подправил шаренную таблицу
        23.08.2010 marinav - добавлены отрасль  и сектор эк-ки
        02/01/2011 madiyar - добавил колонку с провизиями на вознаграждение
        11/01/2011 madiyar - подправил провизии
        01/02/2011 madiyar - выводим три уровня провизий по отдельности и в тенге
        04/04/2011 madiyar - поправил шапку отчета
        20/04/2001 lyubov - в поле "№ бал. счета" выводится 7-мизначный счет ГК, добавлено поле "Лица, связанные с банком особыми отношениями"
        02/06/2011 madiyar - дата выдачи, дата договора
        30/07/2011 madiyar - провизии МСФО
        01/08/2011 madiyar - добавил шаренные переменные для совместимости
        24/11/2011 kapar - добавил столбцы - «Общее обесп Уровень 34», «Амортизация дисконта» и «Дисконт по займам»
        05/11/2011 kapar - дополнение к 5% СК
        17/01/2011 kapar - ТЗ №1255
        03/02/2012 dmitriy - добавил столбец "Отраслевая направленность займа"
        05/07/2012 Luiza  - добавила колонку код сегментации
        18/06/2012 kapar - ТЗ N1149 Новые группы
        20/07/2012 dmitriy - добавил столбцы "Отрасль экономики (детализация)", "Финансируемая отр.эк", "Фин.отр.эк (дет)"
        25/07/2012 kapar - ТЗ N1149 изменение
        17/09/2013 Sayat(id01143) - ТЗ № 2057 от 27/08/2013 добавлено поле lndrhar (характеристика по динамическому резерву)
*/

{global.i}
def var d1 as date no-undo.
def var cntsum as decimal no-undo extent 22.
def new shared var v-reptype as integer no-undo.
v-reptype = 1.

def new shared temp-table wrk no-undo
    field bank as char
    field gl like lon.gl
    field name as char
    field schet_gk as char
    field cif like lon.cif
    field lon like lon.lon
    field grp like lon.grp
    field clnsegm as char
    field pooln as char
    field bankn as char
    field crc like crc.crc
    field rdt like lon.rdt
    field isdt as date
    field duedt like lon.duedt
    field dprolong as date
    field prolong as int
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field pogosh as deci
    field prosr_od as deci
    field dayc_od as int
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field ind_od_kzt as deci
    field pogashen as logi format "да/нет"
    field prem as deci
    field prem_his as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci
    field dayc_prc as int
    field ind_prc as deci
    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field pol_prc_kzt_all as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field ind_prc_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field penalty_otsr as deci
    field uchastie as logi format "да/нет"
    field obessum_kzt as deci
    field obesdes as char
    field sumgarant as deci
    field sumdepcrd as deci
    field obesall as deci
    field obesall_lev19 as deci
    field neobesp as deci
    field otrasl as char
    field otrasl1 as char
    field finotrasl as char
    field finotrasl1 as char
    field rezprc_afn as deci
    field rezsum_afn as deci
    field rezsum_od as deci
    field rezsum_prc as deci
    field rezsum_pen as deci
    field rezsum_msfo as deci
    field num_dog like loncon.lcnt  /* номер договора */
    field tgt   as char
    field dtlpay as date
    field lpaysum as deci
    field kdstsdes as char
    field kodd  as char
    field rate  as char
    field valdesc  as char
    field valdesc_ob  as char
    field dt  as date
    field rel as char
    field bal11 as deci
    field lneko as char
    field rezid as char
    field val as char
    field scode as char
    field dpnv as date
    field nvng as deci
    field amr_dk  as deci /*Амортизация дисконта*/
    field zam_dk  as deci /*Дисконт по займам*/
    field bal34 as deci
    field lnprod as char
    field napr as char
    field nsumkr as deci
    field nsumkr_kzt as deci
    field lndrhar as char
    index ind is primary bank cif.

def new shared var v-sum_msb as deci no-undo.
def new shared var v-dt as date no-undo.
def new shared var v-pool as char no-undo extent 10.
def new shared var v-poolName as char no-undo extent 10.
def new shared var v-poolId as char no-undo extent 10.


d1 = g-today.
update d1 label ' На дату' format '99/99/9999' validate (d1 <= g-today, " Дата должна быть не позже текущей!") skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 6, " Тип отчета - 1, 2, 3, 4 или 5") help "1 - Юр, 2 - Физ, 3 - БД, 4 - MCБ, 5 - все"
       skip with side-label row 5 centered frame dat.

   def var fname as char.
   def var quar as inte.

   if month(d1) <= 12 then quar = 4.
   if month(d1) <= 9 then quar = 3.
   if month(d1) <= 6 then quar = 2.
   if month(d1) <= 3 then quar = 1.

   fname  = "/data/reports/push/audit-" + string(year(d1)) + "-" + string(month(d1)) + "-" + string(quar) + "-" + string(day(d1)) + '-rep' + string(v-reptype,"9") + ".html".

   FILE-INFO:FILE-NAME = fname.
   IF FILE-INFO:FILE-TYPE ne ?
     THEN do : unix silent value ("cptwin " + fname + " excel"). return. end.


def new shared var d-rates as deci no-undo extent 20.
def new shared var c-rates as deci no-undo extent 20.
for each crc no-lock:
  find last crchis where crchis.crc = crc.crc and crchis.rdt < d1 no-lock no-error.
  if avail crchis then d-rates[crc.crc] = crchis.rate[1].
  c-rates[crc.crc] = crc.rate[1].
end.

{r-brfilial.i &proc = "lnaudit1(d1)"}

define stream m-out.
output stream m-out to lnaudit.htm.
put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3> METROCOMBANK</h3><br>" skip.
put stream m-out unformatted "<h3>КРЕДИТНЫЙ ПОРТФЕЛЬ</h3><br>" skip.
put stream m-out unformatted "<h3>Отчет на " string(d1) "</h3><br><br>" skip.

       put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
/*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>N бал. счета</td>"
/*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Наименование заемщика</td>"
/*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Код<BR>заемщика</td>"
/*4 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Филиал</td>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Группа</td>"
/*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Характеристика актива по динамическому резерву</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Продукт</td>"
/*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>N договора<BR>банк. займа</td>"
/*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Объект<BR>кредитования</td>"
/*8 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Валюта<BR>кредита</td>"
/*9 */                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дата<BR>договора</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дата<BR>выдачи</td>"
/*10*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Срок<BR>погашения</td>"
/*11*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дата<BR>пролонгации</td>"
/*12*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Кол-во<BR>пролонгаций</td>"
/*13*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Одобренная<BR>сумма (в валюте)</td>"
/*14*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Одобренная<BR>сумма (в тенге)</td>"
/*15*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Остаток ОД<BR>(в валюте)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Сумма погашенного ОД<BR>(в валюте)</td>"
/*16*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Просроченный<BR>ОД(в валюте)</td>"
/*17*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дней<BR>просрочки</td>"
/*18*/                 /* "<td bgcolor=""#C0C0C0"" align=""center"">Индекс. ОД</td>"*/
/*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Остаток ОД<BR>(в тенге)</td>"
/*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Проср. ОД(в тенге)</td>"
/*21*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Индекс. ОД</td>"
/*22*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Погашен</td>"
/*23*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Ставка</td>"
/*24*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисл. %<BR>(в валюте)</td>"
                        /*
                        "<td bgcolor=""#C0C0C0"" align=""center"">Получ. %<BR>(в валюте)</td>"
                        */
/*25*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Проср. %<BR>(в валюте)</td>"
/*26*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дней<BR>просрочки</td>"
/*30*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленные %<br>за балансом<br>(в валюте)</td>"

/*28*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисл. %<BR>(в тенге)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисл. и получ. % в текущем году <BR>(в тенге)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Получ. % за весь период <BR>(в тенге)</td>"
/*29*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Проср. %<BR>(в тенге)</td>"
/*27*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Индекс. %</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Начисленные %<br>за балансом<br>(в тенге)</td>"
/*31*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Индекс. %<BR>(в тенге)</td>"
/*32*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Последняя дата<BR>уплаты %</td>"
/*33*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Штрафы</td>"
/*34*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Штрафы начисленные<br>за балансом</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Отсроченные<br>штрафы</td>"
/*35*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Участие<BR>заинтер. стороны</td>"
/*36*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Сумма залога<BR>(без гарантий и депозитов), тенге</td>"
/*37*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Вид залога</td>"
/*38*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Сумма гарантий,<BR>тенге</td>"
/*39*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Сумма депозитов,<BR>тенге</td>"
/*40*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Общее<BR>обеспечение</td>"
/*41*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Общее обесп<BR>Уровень 19</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Общее обесп<BR>Уровень 34</td>"
/*42*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Необеспеченная<BR>часть, тенге</td>"
/*43*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Отрасль<BR>экономики</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Отрасль экономики <BR> (детализация)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Финансируемая <BR> отрасль <BR> экономики</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Финансируемая отрасль <BR> экономики <BR> (детализация)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Амортизация<BR>дисконта</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Дисконт<BR>по займам</td>"
/*44*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>%<BR>резерва АФН</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Резерв<BR>АФН (KZT)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Резерв МСФО ОД,<BR>(KZT)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Резерв МСФО %%,<BR>(KZT)</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Резерв МСФО Пеня,<BR>(KZT)</td>"
/*45*/                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Общая сумма резерва МСФО,<BR>(KZT)</td>" skip
                        /*
                        "<td bgcolor=""#C0C0C0"" align=""center""rowspan=2>В т.ч. Сумма резерва на возн.,<BR>тенге</td>"
                        */
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Рейтинг</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" colspan=2 >Классификация</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Лица связанные с банком особыми отношениями</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"" rowspan=2>Шифр секторов и <br> подсекторов эк-ки</td>"
                        "<td bgcolor=""#C0C0C0"" align=""center"">Отраслевая<br>направленность займа</td></tr>" skip.

  put stream m-out unformatted "<tr style=""font:bold"">"

  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Финансовое состояние</td>"
  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Качество предоставляемого обеспечения</td></tr>" skip.
for each wrk no-lock break by wrk.bank by wrk.cif:

  if first-of(wrk.bank) then put stream m-out unformatted "<tr style=""font:bold""><td colspan=40>" wrk.bank "</td></tr>".
  find first crc where crc.crc = wrk.crc no-lock no-error.
  put stream m-out unformatted
            "<tr>" skip
/*1 */            "<td align=""center"">" wrk.schet_gk "</td>" skip
/*2 */            "<td>" wrk.name "</td>" skip
/*3 */            "<td>" wrk.cif "</td>" skip
/*4 */            "<td>" wrk.bankn "</td>" skip
/*5 */            "<td>" wrk.grp "</td>" skip
/*5 */            "<td>" wrk.lndrhar "</td>" skip
                  "<td>" wrk.lnprod "</td>" skip
/*6 */            "<td>&nbsp;" wrk.num_dog "</td>" skip
/*7 */            "<td>" wrk.tgt "</td>" skip
/*8 */            "<td align=""center"">" crc.code "</td>" skip
/*9 */            "<td>" wrk.rdt format "99/99/9999" "</td>" skip
                  "<td>" wrk.isdt format "99/99/9999" "</td>" skip
/*10*/            "<td>" wrk.duedt format "99/99/9999" "</td>" skip
/*11*/            "<td>" wrk.dprolong format "99/99/9999" "</td>" skip
/*12*/            "<td align=""right"">" wrk.prolong "</td>" skip
/*13*/            "<td align=""right"">" replace(trim(string(wrk.opnamt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*14*/            "<td align=""right"">" replace(trim(string(wrk.opnamt_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*15*/            "<td align=""right"">" replace(trim(string(wrk.ostatok,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.pogosh,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*16*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*17*/            "<td align=""right"">" wrk.dayc_od "</td>" skip
/*18*/            /*"<td align=""right"">" replace(trim(string(wrk.ind_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip*/
/*19*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*20*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*21*/            "<td align=""right"">" replace(trim(string(wrk.ind_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*22*/            "<td align=""right"">" wrk.pogashen "</td>" skip
/*23*/            "<td align=""right"">" replace(trim(string(wrk.prem,'>>9.99')),'.',',') "</td>" skip
/*24*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*25*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*26*/            "<td align=""right"">" wrk.dayc_prc "</td>" skip
/*30*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_zabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip

/*28*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.pol_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.pol_prc_kzt_all,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*29*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*27*/            "<td align=""right"">" replace(trim(string(wrk.ind_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.prosr_prc_zab_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*31*/            "<td align=""right"">" replace(trim(string(wrk.ind_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*32*/            "<td>" wrk.prcdt_last format "99/99/9999" "</td>" skip
/*33*/            "<td align=""right"">" replace(trim(string(wrk.penalty,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*34*/            "<td align=""right"">" replace(trim(string(wrk.penalty_zabal,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.penalty_otsr,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*35*/            "<td>" wrk.uchastie "</td>" skip
/*36*/            "<td align=""right"">" replace(trim(string(wrk.obessum_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*37*/            "<td>" wrk.obesdes "</td>" skip
/*38*/            "<td align=""right"">" replace(trim(string(wrk.sumgarant,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*39*/            "<td align=""right"">" replace(trim(string(wrk.sumdepcrd,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*40*/            "<td align=""right"">" replace(trim(string(wrk.obesall,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*41*/            "<td align=""right"">" replace(trim(string(wrk.obesall_lev19,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.bal34,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*42*/            "<td align=""right"">" replace(trim(string(wrk.neobesp,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*43*/            "<td align=""right"">" wrk.otrasl "</td>" skip
                  "<td align=""right"">" wrk.otrasl1 "</td>" skip
                  "<td align=""right"">" wrk.finotrasl "</td>" skip
                  "<td align=""right"">" wrk.finotrasl1 "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.amr_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.zam_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*44*/            "<td align=""right"">" replace(trim(string(wrk.rezprc_afn,'>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.rezsum_afn,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
/*45*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.rezsum_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.rezsum_pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" replace(trim(string(wrk.rezsum_msfo,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                  "<td align=""right"">" wrk.kodd " - " wrk.rate  "</td>" skip
                  "<td align=""right"">" wrk.valdesc  "</td>" skip
                  "<td align=""right"">" wrk.valdesc_ob  "</td>"
                  "<td align=""left""> " wrk.rel "</td>"
                  "<td align=""left""> " wrk.lneko "</td>"
                  "<td align=""right"">" wrk.napr "</td>" skip
                  "</tr>" skip.

  cntsum[1] = cntsum[1] + wrk.opnamt_kzt.
  cntsum[2] = cntsum[2] + wrk.ostatok_kzt.
  cntsum[3] = cntsum[3] + wrk.prosr_od_kzt.
  cntsum[4] = cntsum[4] + wrk.ind_od_kzt.

  cntsum[5] = cntsum[5] + wrk.nach_prc_kzt.
  cntsum[18] = cntsum[18] + wrk.pol_prc_kzt.
  cntsum[6] = cntsum[6] + wrk.prosr_prc_kzt.
  cntsum[7] = cntsum[7] + wrk.ind_prc_kzt.

  cntsum[8] = cntsum[8] + wrk.obessum_kzt.
  cntsum[9] = cntsum[9] + wrk.sumgarant.
  cntsum[10] = cntsum[10] + wrk.sumdepcrd.
  cntsum[11] = cntsum[11] + wrk.obesall.
  cntsum[12] = cntsum[12] + wrk.obesall_lev19.
  cntsum[13] = cntsum[13] + wrk.neobesp.
  cntsum[16] = cntsum[16] + wrk.rezsum_afn.
  cntsum[14] = cntsum[14] + wrk.rezsum_msfo.
  cntsum[15] = cntsum[15] + wrk.prosr_prc_zabal.
  cntsum[17] = cntsum[17] + wrk.penalty_zabal.
  cntsum[19] = cntsum[19] + wrk.penalty_otsr.

  cntsum[20] = cntsum[20] + wrk.amr_dk.
  cntsum[21] = cntsum[21] + wrk.zam_dk.
  cntsum[22] = cntsum[22] + wrk.bal34.

end. /* for each wrk */

put stream m-out unformatted
          "<tr align=""right"" style=""font:bold""><td colspan=14></td>" skip
          "<td>" replace(trim(string(cntsum[1],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=5></td>" skip
          "<td>" replace(trim(string(cntsum[2],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[3],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[4],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=6></td>" skip
          "<td>" replace(trim(string(cntsum[5],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[18],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>"
          "<td>" replace(trim(string(cntsum[6],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>"
          "<td>" replace(trim(string(cntsum[15],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[7],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=2></td>" skip
          "<td>" replace(trim(string(cntsum[17],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[19],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[8],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[9],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[10],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[11],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[12],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[22],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[13],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=4></td>" skip
          "<td>" replace(trim(string(cntsum[20],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td>" replace(trim(string(cntsum[21],'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td></td>" skip
          "<td>" replace(trim(string(cntsum[16],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "<td colspan=3></td>" skip
          "<td>" replace(trim(string(cntsum[14],'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
          "</tr>" skip.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.

unix silent cptwin lnaudit.htm excel.
