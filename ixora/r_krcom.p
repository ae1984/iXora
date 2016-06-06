/* r_krcom.p
 * MODULE
        Кредитный Модуля
 * DESCRIPTION
        Анализ кредитного портфеля
 * RUN
        Сособ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-2-5-7 Сокращенный отчет
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        02.09.2003 marinav - добавление среднемесячной выручки
        26.11.2003 marinav - оставлены только юр лица, остальные - сводными цифрами по признаку lnsegm
        27.11.2003 marinav - убрала итоги
        12.02.2004 nadejda - добавлен обслуживающий менеджер
        01.01.2004 nadejda - сделан выбор филиал/консолид для ЦО, филиалы видят только свои данные
                             выведена рашифровка всех видов кредитов, кроме Быстрых денег
        08/06/2004 madiar  - добавил две колонки - "дней до ближ погашения" и "Уведомление"
        09/07/2004 madiar  - изменил сегментацию - объединил все потреб.кредиты кроме быстрых денег в один сегмент
        19/07/2004 madiar  - по запросу КД вернул прежнюю сегментацию
        26/08/2004 madiar  - десятичный разделитель - запятая
        31/08/2004 madiar  - везде в put stream... добавил unformatted
        01/09/2004 madiar  - раскомментарил cptwin
        04/11/2004 madiar  - добавил поле cif в wrk
        19/01/2005 madiar  - добавил колонку "Номер договора банковского займа"
        28/04/2005 madiar  - добавил колонку "Сс счет"
        17/05/2005 madiar  - добавил колонку "Объект кредитования"
        03/08/2005 madiar  - добавил поле wrk.balans_kzt - остаток долга в тенге
        20/01/2006 madiar  - добавил вывод отрасли экономики
        20/01/2006 madiar  - добавил вывод группы кредита
        02/09/2013 galina - ТЗ1918 перекомпиляция
*/

{global.i}

def new shared var d1 as date.
def var coun as int init 1.
def var cnt as decimal extent 30.
def var prc as decimal extent 30.
def var srk as decimal extent 30.
def var vsrk as decimal init 0.
def buffer b-crchis for bank.crchis.

prc[1] = 0. prc[2] = 0. prc[3] = 0.

def new shared temp-table  wrk
    field lon    like bank.lon.lon
    field grp    like bank.lon.grp
    field cif    like bank.cif.cif
    field name   like bank.cif.name
    field gua    like bank.lon.gua
    field segm   as char
    field amoun  like bank.lon.opnamt
    field aaa1   like bank.lon.opnamt
    field aaa2   like bank.lon.opnamt
    field aaa3   like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field balans_kzt like bank.lon.opnamt
    field akkr like bank.lon.opnamt
    field garan like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field dt1    like bank.lon.rdt
    field dt2    like bank.lon.rdt
    field dt3    like bank.lon.rdt
    field duedt  like bank.lon.rdt
    field rez    like bank.lonstat.prc
    field srez   like bank.lon.opnamt
    field zalog  like bank.lon.opnamt
    field sr  as char
    field srok   as deci
    field tgt   as char                  /* объект кредитования */
    field num_dog like bank.loncon.lcnt  /* номер договора */
    field otrasl as char                 /* отрасль */
    field rate as decimal                /* курс на день выдачи */
    field obes as char                   /* вид обеспечения */
    field col_prolon as integer          /* кол-во пролонгаций */
    field sum_dolg as decimal            /* сумма просроченной задолженности */
    field sum_dox as decimal             /* сумма  */
    field ofc as char format "x(70)"     /* обслуживает менеджер */
    index main is primary crc desc balans desc grp.

define temp-table wrk1
   field code as char
   field crc like bank.lon.crc
   field coun as inte
   field summ as deci
   index main code crc.

    /*для долларов*/
       cnt[1] = 0.   /*заявленная*/
       cnt[2] = 0.   /*реальная*/
       cnt[3] = 0.   /**/
   /*для тенге*/
       cnt[4] = 0.
       cnt[5] = 0.
       cnt[6] = 0.
   /*для ЕВРО*/
       cnt[7] = 0.
       cnt[8] = 0.
       cnt[9] = 0.


d1 = g-today.
update d1 label " Отчет за дату" format "99/99/9999"
                  skip with side-label row 5 centered frame dat .


message " Формируется отчет...".


/* 01.01.2004 nadejda - сделан выбор филиал/консолид для ЦО, филиалы видят только свои данные */
{r-brfilial.i &proc = "kredkom (d1)"}
/**/

/* 01.01.2004 nadejda - переделано на вызов r-brfilial.i
run r_krcom1 (d1).
*/

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.regdt le d1 no-lock no-error.
find last b-crchis where b-crchis.crc = 11 and b-crchis.regdt le d1 no-lock no-error.

define stream m-out.
output stream m-out to rpt.html.

{html-title.i &stream = "stream m-out"}


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
                 "<tr align=""left""><td><h3>Кредитный портфель за "
                 string(d1) "</h3></td></tr>" skip(1)
                 "<tr><td>&nbsp;<br><b>" v-bankname "</b><br><br><br></td></tr>" skip.

       put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Код заемщика</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Вид<BR>кредита</td>"
                  "<td>Группа<BR>кредита</td>"
                  "<td>Отрасль<br>экономики</td>"
                  "<td>Сс счет</td>"
                  "<td>Срок</td>"
                  "<td>Объект<BR>кредитования</td>"
                  "<td>Одобренная<BR>сумма</td>"
                  "<td>N договора<BR>банк. займа</td>"
                  "<td>Аккредитив</td>"
                  "<td>Гарантия</td>"
                  "<td>Сумма остатка<BR>займа</td>"
                  "<td>Валюта</td>"
                  "<td>Сумма остатка<BR>займа (KZT)</td>"
                  "<td>% ставка</td>"
                  "<td>Остаток на<BR>тенговом счете</td>"
                  "<td>Остаток на<BR>долл счете</td>"
                  "<td>Остаток на<BR>ЕВРО счете</td>"
                  "<td>Дата выдачи<BR>займа</td>"
                  "<td>Дата последней<BR>проплаты</td>"
                  "<td>Дата след.<BR>проплаты по гр</td>"
                  "<td>Дата погашения<BR>займа</td>"
                  "<td>Обеспечение<BR>USD</td>"
                  "<td>Резерв %</td>"
                  "<td>Сформированная<BR>сумма резервов</td>"
                  "<td>Среднемесячная<BR>выручка</td>"
                  "<td>Срок</td>"
                  "<td>Обслуживает менеджер</td>"
                  "<td>Дней до<BR>ближ. погашения</td>"
                  "<td>Уведомление</td>"
                  "</tr>" skip.


for each wrk where wrk.grp <> 70 break by wrk.segm by wrk.crc desc by wrk.balans desc.
   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.


  if wrk.segm /*= "07" 01.01.2004 nadejda */ <> "01" then do:
   if first-of (wrk.segm) then do:
     find codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
     put stream m-out unformatted "<tr><td colspan=4>" codfr.name[1] "</td></tr>" skip.
   end.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun format ">>>>>" "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td>" wrk.grp "</td>"
               "<td align=""left""> " wrk.gua format "x(3)" "</td>"
               "<td align=""left""> " wrk.otrasl "</td>" skip
               "<td align=""left"">&nbsp;" wrk.lon "</td>"
               "<td align=""left""> " wrk.sr format "x(20)" "</td>"
               "<td align=""left""> " wrk.tgt "</td>"
               "<td> " replace(string(wrk.amoun, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " wrk.num_dog "</td>"
               "<td> " replace(string(wrk.akkr, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.garan, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format "x(3)" "</td>"
               "<td> " replace(string(wrk.balans_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.prem, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa1, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa2, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa3, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.dt2 "</td>"
               "<td> " wrk.dt3 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.zalog, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.sum_dox, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " wrk.srok format "->>>9" "</td>"
               "<td align=""left"">" wrk.ofc "</td>"
               "<td> " wrk.dt3 - d1 "</td>".
    if wrk.dt3 - d1 <= 2 then put stream m-out unformatted "<td> Call</td></tr>" skip.
    else put stream m-out unformatted "<td> </td></tr>" skip.

    coun = coun + 1.
    end.

    find first wrk1 where wrk1.code = wrk.segm and wrk1.crc = wrk.crc no-error.
    if avail wrk1 then assign wrk1.coun = wrk1.coun + 1
                              wrk1.summ = wrk1.summ + wrk.balans.
    else do:
        create wrk1.
        assign wrk1.code = wrk.segm
               wrk1.crc = wrk.crc
               wrk1.coun = 1
               wrk1.summ = wrk.balans.
    end.

    if wrk.crc = 2 then do:
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.

/*       prc[3] = prc[3] + wrk.balans * wrk.prem.
       prc[4] = prc[4] + wrk.balans * wrk.srok.*/
    end.
    if wrk.crc = 1 then do:
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
/*       prc[3] = prc[3] + wrk.balans / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.*/
    end.
    if wrk.crc = 11 then do:
       cnt[7] = cnt[7] + wrk.amoun.
       cnt[8] = cnt[8] + wrk.balans.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.

  /*  if last-of (wrk.crc) then
    do:
     put stream m-out "<tr align=""right"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td></td><td></td><td></td><td></td><td></td>"
               "<td><b> " cnt[3] format ">>>>>>>>>>>9.99" "</b></td>"
               "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td></td><td></td><td><b> " cnt[6] format ">>>>>>>>>>>9.99" "</b></td>"
               "</tr>" skip.
     cnt[3] = 0. cnt[6] = 0.
    end.
   */
end.
put stream m-out unformatted "<tr></tr><tr></tr></table>" skip.
put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">"
                 skip.

put stream m-out unformatted "<tr align=""left""><td><h3>Овердрафты "
                 string(d1) "</h3></td></tr>"
                 skip(1)
                 "<tr><td>&nbsp;<br><br><br><br></td></tr>" skip.


       put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Код заемщика</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Группа<BR>кредита</td>"
                  "<td>Вид<BR>кредита</td>"
                  "<td>Отрасль<BR>экономики</td>"
                  "<td>Сс счет</td>"
                  "<td>Срок</td>"
                  "<td>Объект<BR>кредитования</td>"
                  "<td>Одобренная<BR>сумма</td>"
                  "<td>N договора<BR>банк. займа</td>"
                  "<td>Аккредитив</td>"
                  "<td>Гарантия</td>"
                  "<td>Сумма остатка<BR>займа</td>"
                  "<td>Валюта</td>"
                  "<td>Сумма остатка<BR>займа (KZT)</td>"
                  "<td>% ставка</td>"
                  "<td>Остаток на<BR>тенговом счете</td>"
                  "<td>Остаток на<BR>долл счете</td>"
                  "<td>Остаток на<BR>ЕВРО счете</td>"
                  "<td>Дата выдачи<BR>займа</td>"
                  "<td>Дата последней<BR>проплаты</td>"
                  "<td>Дата след.<BR>проплаты по гр</td>"
                  "<td>Дата погашения<BR>займа</td>"
                  "<td>Обеспечение<BR>USD</td>"
                  "<td>Резерв %</td>"
                  "<td>Сформированная<BR>сумма резервов</td>"
                  "<td>Среднемесячная<BR>выручка</td>"
                  "<td>Срок</td>"
                  "<td>Обслуживает менеджер</td>"
                  "<td>Дней до<BR>ближ. погашения</td>"
                  "<td>Уведомление</td>"
                  "</tr>" skip.

for each wrk where wrk.grp = 70 break by wrk.segm by wrk.crc desc by wrk.balans desc.
   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.


  if wrk.segm /*= "07" 01.01.2004 nadejda */ <> "01" then do:

   if first-of (wrk.segm) then do:
     find codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
     put stream m-out unformatted "<tr><td colspan=4>" codfr.name[1] "</td></tr>" skip.
   end.

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun format ">>>>>" "</td>"
               "<td align=""center"">" wrk.cif "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td>" wrk.grp "</td>"
               "<td align=""left""> " wrk.gua format "x(3)" "</td>"
               "<td align=""left""> " wrk.otrasl "</td>" skip
               "<td align=""left"">&nbsp;" wrk.lon "</td>"
               "<td align=""left""> " wrk.sr format "x(20)" "</td>"
               "<td align=""left""> " wrk.tgt "</td>"
               "<td> " replace(string(wrk.amoun, ">>>>>>>>>>>9.99" ),'.',',') "</td>"
               "<td> " wrk.num_dog "</td>"
               "<td> " replace(string(wrk.akkr, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.garan, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format "x(3)" "</td>"
               "<td> " replace(string(wrk.balans_kzt, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.prem, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa1, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa2, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.aaa3, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.dt2 "</td>"
               "<td> " wrk.dt3 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.zalog, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.sum_dox, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " wrk.srok format "->>>9" "</td>"
               "<td align=""left"">" wrk.ofc "</td>"
               "<td> " wrk.dt3 - d1 "</td>".
    if wrk.dt3 - d1 <= 2 then put stream m-out unformatted "<td> Call</td></tr>" skip.
    else put stream m-out unformatted "<td> </td></tr>" skip.

    coun = coun + 1.
   end.


    find first wrk1 where wrk1.code = wrk.segm and wrk1.crc = wrk.crc no-error.
    if avail wrk1 then assign wrk1.coun = wrk1.coun + 1
                              wrk1.summ = wrk1.summ + wrk.balans.
    else do:
        create wrk1.
        assign wrk1.code = wrk.segm
               wrk1.crc = wrk.crc
               wrk1.coun = 1
               wrk1.summ = wrk.balans.
    end.

    if wrk.crc = 2 then do:
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if wrk.crc = 1 then do:
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if wrk.crc = 11 then do:
       cnt[7] = cnt[7] + wrk.amoun.
       cnt[8] = cnt[8] + wrk.balans.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
/*    if last-of (wrk.crc) then
    do:
     put stream m-out "<tr align=""rigth"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td></td><td></td><td></td><td></td><td></td>"
               "<td><b> " cnt[3] format ">>>>>>>>>>>9.99" "</b></td>"
               "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td></td><td></td><td><b> " cnt[6] format ">>>>>>>>>>>9.99" "</b></td>"
               "</tr>" skip.
     cnt[3] = 0. cnt[6] = 0.
    end.
 */

end.
put stream m-out unformatted "<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr></table>" skip
                 "</table>" skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
                 "<tr><td></td></tr>" skip.


put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>Вид кредита</td>"
                  "<td>Валюта</td>"
                  "<td>Количество</td>"
                  "<td>Сумма</td>"
                  /*"<td>Сегмент</td>"*/
                  "</tr>" skip.

for each wrk1 break by wrk1.code .

     find codfr where codfr.codfr = "lnsegm" and codfr.code = wrk1.code no-lock no-error.
     find last bank.crc where bank.crc.crc = wrk1.crc no-lock no-error.

     put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " codfr.name[1] format "x(40)"  "</td>"
               "<td align=""left""> "  bank.crc.code format "x(3)" "</td>"
               "<td> " wrk1.coun format ">>>>>" "</td>"
               "<td> " replace(string(wrk1.summ, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               /*"<td>&nbsp;" wrk1.code format "x(8)" "</td>"*/ "</tr>" .
end.
put stream m-out unformatted "<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr></table>" skip.

put stream m-out unformatted
                 "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
                  "<tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ДОЛЛАРАХ США </b></td> <td></td> "
                 "<td align=""right""><b> " replace(string(cnt[1], ">>>>>>>>>>>9.99"),'.',',') "</b></td> "
                 "<td align=""right""><b> " replace(string(cnt[2], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[1] / cnt[2], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr><tr><td></td></tr>" skip.
put stream m-out unformatted
                 "<table border=""1"" cellpadding=""10"" cellspacing=""0"">"
                  "<tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ЕВРО </b></td> <td></td> "
                 "<td align=""right""><b> " replace(string(cnt[7], ">>>>>>>>>>>9.99"),'.',',') "</b></td> "
                 "<td align=""right""><b> " replace(string(cnt[8], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[3] / cnt[8], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr><tr><td></td></tr>" skip.
put stream m-out unformatted
                 "<tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ТЕНГЕ </b></td> <td></td>"
                 "<td align=""right""><b> " replace(string(cnt[4], ">>>>>>>>>>>9.99"),'.',',') "</b></td> "
                 "<td align=""right""><b> " replace(string(cnt[5], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[2] / cnt[5], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr></table></td></tr>" skip.

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

hide message no-pause.
unix silent cptwin rpt.html excel.
