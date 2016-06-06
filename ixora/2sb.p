/* 2sb.p
 * MODULE
         2SB
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
       19/08/03 nataly был переведен отчет из формата WORD в EXCEL
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       02/08/2004 madiyar - учет уровней индексации
       04/08/2004 madiyar - пропускать кредиты нерезидентов
       18.03.2005 marinav - признак юр/физ лица теперь берется из ecdivis (раньше lneko)
       06/06/2005 madiyar - погашение 1го уровня - пропускать шаблоны по переносу на просрочку и обратно
       04/08/2005 madiyar - выключил учет индексации
       18/08/2006 Natalya D. - оптимизация. Повторяющиеся запросы скомпоновала в один. Нахождение сумм на уровнях 1,7,8
                               сделала через процедуру lonball. Реально работает быстрее, чем через atl-dat1.
       08/11/2010 madiyar - не создавалась строка 44, исправил
        23/09/09 kapar - ТЗ1142
*/


{global.i}

def new shared  var summa as decimal format 'zzz,zzz,zzz,zz9.99'.
def var summa1 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var summa2 as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
define variable bilance  as decimal format 'zzz,zzz,zzz,zz9.99' init 0.
def var v-cif as char format "x(30)".
def var v-gl as char.
def var i as int.
define variable v-dt     as date format "99/99/9999".
define variable v-dtn     as date format "99/99/9999".
def buffer b-aaa  for aaa.

v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

v-dtn = date('01' + substring(string(v-dt),3)) - 1.

def new shared temp-table vsb2
             field nn as int
             field name as char
             field sumnk as decimal format 'z,zzz,zzz,zz9-'
             field sumnkp as decimal format 'z,zzz,zzz,zz9-'
             field sumdk as decimal format 'z,zzz,zzz,zz9-'
             field sumdkp as decimal format 'z,zzz,zzz,zz9-'
             field sumvk as decimal format 'z,zzz,zzz,zz9-'
             field sumvkp as decimal format 'z,zzz,zzz,zz9-'
             field sumnd as decimal format 'z,zzz,zzz,zz9-'
             field sumndp as decimal format 'z,zzz,zzz,zz9-'
             field sumdd as decimal format 'z,zzz,zzz,zz9-'
             field sumddp as decimal format 'z,zzz,zzz,zz9-'
             field sumvd as decimal format 'z,zzz,zzz,zz9-'
             field sumvdp as decimal format 'z,zzz,zzz,zz9-'.

do i = 1 to 44:
    create vsb2.
    nn  = i.
    sumnk = 0.
    sumnkp = 0.
    sumdk = 0.
    sumdkp = 0.
    sumvk = 0.
    sumvkp = 0.
    sumnd = 0.
    sumndp = 0.
    sumdd = 0.
    sumddp = 0.
    sumvd = 0.
    sumvdp = 0.

    if i = 1 then name = '1. Ссудная задолженность и просроченная задолженность по займа, предоставленным юридическим и физическим лицам на начало'.
    if i = 2 then name = 'в том числе по малому предпринимательству'.
    if i = 3 then name = '2. Займы, предоставленные юридическим и физическим лицам зв отчетный период, всего'.
    if i = 4 then name = 'в том числе по малому предпринимательству'.
    if i = 5 then name = '3. Ссудная задолженность и просроченная задолженность, погашенные юридическими и физическими лицами за отчетный период, всего'.
    if i = 6 then name = 'в том числе по малому предпринимательству'.
    if i = 7 then name = '4. Ссудная задолженность и просроченная задолженность по займам, предоставленным юридическим и физическим лицам, на конец отчетного периода, всего'.
    if i = 8 then name = 'в том числе по малому предпринимательству'.
    if i = 9 then name = '5. Курсовая разница, всего'.
    if i = 10 then name = 'в том числе по малому предпринимательству'.
    if i = 11 then name = '6. Другие изменения в объеме займов, предоставленных юридическим и физическим лицам, образовавшихся за отчетный период, всего'.
    if i = 12 then name = 'в том числе по малому предпринимательству'.
    if i = 13 then name = '7. Просроченная задолженность по займам, предоставленным юридическим и физическим лицам, на конец отчетного периода, всего'.
    if i = 14 then name = 'в том числе по малому предпринимательству'.

    if i = 15 then name = '8. Ссудная задолженность и просроченная задолженность по займа, предоставленным юридическим и физическим лицам, на начало отчетного периода, всего   '.
    /*if i = 16 then name = 'в том числе по срокам погашения:'.*/
    if i = 16 then name = 'до 1 месяца'.
    if i = 17 then name = 'от 1 до 3 месяцев'.
    if i = 18 then name = 'от 3 месяцев до 1 года'.
    if i = 19 then name = 'от 1 года до 5 лет'.
    if i = 20 then name = 'от 5 лет и более'.
    if i = 21 then name = '9. Займы, предоставленные юридическим и физическим лицам за отчетный период, всего'.
    /*if i = 23 then name = 'в том числе по срокам погашения:'.*/
    if i = 22 then name = 'до 1 месяца'.
    if i = 23 then name = 'от 1 до 3 месяцев'.
    if i = 24 then name = 'от 3 месяцев до 1 года'.
    if i = 25 then name = 'от 1 года до 5 лет'.
    if i = 26 then name = 'от 5 лет и более'.
    if i = 27 then name = '10. Ссудная задолженность  и просроченная задолженность, погашенные юридическими и физическими лицами за отчетный период, всего'.
    /*if i = 30 then name = 'в том числе по срокам погашения:'.*/
    if i = 28 then name = 'до 1 месяца'.
    if i = 29 then name = 'от 1 до 3 месяцев'.
    if i = 30 then name = 'от 3 месяцев до 1 года'.
    if i = 31 then name = 'от 1 года до 5 лет'.
    if i = 32 then name = 'от 5 лет и более'.
    if i = 33 then name = '11. Ссудная задолженность и просроченная задолженность по займам, предоставленным юридическим и физическим лицам, на конец отчетного периода, всего'.
    /*if i = 37 then name = 'в том числе по срокам погашения:'.*/
    if i = 34 then name = 'до 1 месяца'.
    if i = 35 then name = 'от 1 до 3 месяцев'.
    if i = 36 then name = 'от 3 месяцев до 1 года'.
    if i = 37 then name = 'от 1 года до 5 лет'.
    if i = 38 then name = 'от 5 лет и более'.
    if i = 39 then name = '12. Просроченная задолженность по займам, предоставленным юридическим и физическим лицам, на конец отчетного периода, всего'.
    /*if i = 44 then name = 'в том числе по срокам погашения'.*/
    if i = 40 then name = 'до 1 месяца'.
    if i = 41 then name = 'от 1 до 3 месяцев'.
    if i = 42 then name = 'от 3 месяцев до 1 года'.
    if i = 43 then name = 'от 1 года до 5 лет'.
    if i = 44 then name = 'от 5 лет и более'.

end.

define stream vcrpt.
output stream vcrpt to 2sb.html.

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

put stream vcrpt unformatted "<p align=""center""><b> Отчет о займах и ставках вознаграждения по ним "   skip
    " на   "  + string( v-dt)  + "      в тыс. тенге </b></p>" skip(2).
put stream vcrpt unformatted "<b> 1. Банковские займы </b>" skip.
/*заголовок таблицы*/
{2sb1.i}
put stream vcrpt  unformatted
  "<tr style=""font:bold;"">"
    "<td align=""center"" width=""12%"">А</td>" skip
    "<td align=""center"" width=""5%"">Б</td>" skip
    "<td align=""center"" width=""7%"">01</td>" skip
    "<td align=""center"" width=""7%"">02</td>" skip
    "<td align=""center"" width=""7%"">03</td>" skip
    "<td align=""center"" width=""7%"">04</td>" skip
    "<td align=""center"" width=""7%"">05</td>" skip
    "<td align=""center"" width=""6%"">06</td>" skip
    "<td align=""center"" width=""7%"">07</td>" skip
    "<td align=""center"" width=""7%"">08</td>" skip
    "<td align=""center"" width=""7%"">09</td>" skip
    "<td align=""center"" width=""7%"">10</td>" skip
    "<td align=""center"" width=""7%"">11</td>" skip
    "<td align=""center"" width=""7%"">12</td>" skip
  "</tr>" skip.


/**********************************************************************************/
{r-brfilial.i &proc = "2sb1 (v-dt, v-dtn)"}

/**********************************************************************************/

i = 1.
repeat:
  summa = 0.
  find first vsb2 where nn = i no-lock no-error.
  summa = summa + vsb2.sumdk.
  find first vsb2 where nn = i + 2 no-lock no-error.
  summa = summa + vsb2.sumdk.
  find first vsb2 where nn = i + 4 no-lock no-error.
  summa = summa - vsb2.sumdk.
  find first vsb2 where nn = i + 6 no-lock no-error.
  summa = summa - vsb2.sumdk.
  find first vsb2 where nn = i + 8 no-lock no-error.
  vsb2.sumdk = - summa.
  i = i + 1.
  if i = 3 then leave.
end.

i = 1.
repeat:
  summa = 0.
  find first vsb2 where nn = i no-lock no-error.
  summa = summa + vsb2.sumdd.
  find first vsb2 where nn = i + 2 no-lock no-error.
  summa = summa + vsb2.sumdd.
  find first vsb2 where nn = i + 4 no-lock no-error.
  summa = summa - vsb2.sumdd.
  find first vsb2 where nn = i + 6 no-lock no-error.
  summa = summa - vsb2.sumdd.
  find first vsb2 where nn = i + 8 no-lock no-error.
  vsb2.sumdd = - summa.
  i = i + 1.
  if i = 3 then leave.
end.

for each vsb2:
put stream vcrpt  unformatted
  if (vsb2.nn = 1) or (vsb2.nn = 3) or (vsb2.nn = 5) or (vsb2.nn = 7) or (vsb2.nn = 9) or (vsb2.nn = 11) or
     (vsb2.nn = 13) or (vsb2.nn = 15) or (vsb2.nn = 21) or (vsb2.nn = 27) or (vsb2.nn = 33) or (vsb2.nn = 39) then
    "<tr style=""font:bold;"" font size=""10"" >"
  else
    "<tr>"

    "<td width=""12%"">" vsb2.name "</td>" skip
    "<td align=""center"" width=""5%"">" string(nn) "</td>" skip
    "<td width=""7%"">"  string(round(sumnk / 1000, 0),'zzzzzzzzzzz9')  "</td>" skip
    "<td width=""7%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumnkp * 100 / sumnk,1) = ? then 0 else round(sumnkp * 100 / sumnk,1), 'z9.99'),".",",") "</td>" skip
    "<td width=""7%"">" round(sumdk / 1000, 0) "</td>" skip
    "<td width=""7%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumdkp * 100 / sumdk,1) = ? then 0 else round(sumdkp * 100 / sumdk,1), 'z9.99'),".",",") "</td>" skip
    "<td width=""7%"">" round(sumvk / 1000, 0) "</td>" skip
    "<td width=""6%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumvkp * 100 / sumvk,1) = ? then 0 else round(sumvkp * 100 / sumvk,1), 'z9.99'),".",",") "</td>" skip
    "<td width=""7%"">" round(sumnd / 1000, 0)  "</td>" skip
    "<td width=""7%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumndp * 100 / sumnd,1) = ? then 0 else round(sumndp * 100 / sumnd,1), 'z9.99'),".",",") "</td>" skip
    "<td width=""7%"">" round(sumdd / 1000, 0) "</td>" skip
    "<td width=""7%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumddp * 100 / sumdd,1) = ? then 0 else round(sumddp * 100 / sumdd,1), 'z9.99'),".",",") "</td>" skip
    "<td width=""7%"">" round(sumvd / 1000, 0) "</td>" skip
    "<td width=""7%"">" if (vsb2.nn = 9) or (vsb2.nn = 10) or (vsb2.nn = 12) or (vsb2.nn = 11) then '' else replace(string(if round(sumvdp * 100 / sumvd,1) = ? then 0 else round(sumvdp * 100 / sumvd,1), 'z9.99'),".",",") "</td>" skip
  "</tr>" skip.

if nn = 14 then do:

put stream vcrpt unformatted
  "</TABLE>" .
put stream vcrpt unformatted "<p>&nbsp;</p>" skip.

/*заголовок таблицы2*/
put stream vcrpt unformatted "<b> 2. Займы по срокам погашения </b>" skip.
{2sb2.i}
put stream vcrpt  unformatted
  "<tr style=""font:bold;"">"
    "<td align=""center"" width=""12%"">А</td>" skip
    "<td align=""center"" width=""5%"">Б</td>" skip
    "<td align=""center"" width=""7%"">01</td>" skip
    "<td align=""center"" width=""7%"">02</td>" skip
    "<td align=""center"" width=""7%"">03</td>" skip
    "<td align=""center"" width=""7%"">04</td>" skip
    "<td align=""center"" width=""7%"">05</td>" skip
    "<td align=""center"" width=""6%"">06</td>" skip
    "<td align=""center"" width=""7%"">07</td>" skip
    "<td align=""center"" width=""7%"">08</td>" skip
    "<td align=""center"" width=""7%"">09</td>" skip
    "<td align=""center"" width=""7%"">10</td>" skip
    "<td align=""center"" width=""7%"">11</td>" skip
    "<td align=""center"" width=""7%"">12</td>" skip
  "</tr>" skip.

end.
end.

{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin 2sb.html excel").


