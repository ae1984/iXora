/* scublrep.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Балансовая стоимость ЦБ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        11-9-4-4
 * BASES
        BANK
 * AUTHOR
        24.05.2004 tsoy
 * CHANGES
        31.05.2004 tsoy  в некоторых колонках изменил дебет на остатки по счетам
        16.06.2004 tsoy  взял остатки по счетам, а также с минусом дисконт и отр. корректировка
        17.06.2004 tsoy  изменеия для 2 группы тоже учитвать корректировки
        18.06.2004 tsoy  новый столбец учетный курс
        21.06.2004 tsoy  Добавил дату погашения
        28.07.04   tsoy  Добавил дополнительные поля, (Доходность к погашению, Дата выплаты купона,
                                                     Дней до погашения, Дней до выплаты купона).
        28.07.04   tsoy  Доходность  4 знака после запятой
        01.09.04   tsoy  Ставка  4 знака после запятой
        17.02.05   tsoy  Добавил дату покупки.
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко

*/


{global.i}
{nbankBik.i}
def var i as integer.
def var j as integer.
def var v-grpname as char.
def var v-hdr as char.

def stream v-out.

def temp-table t-scu
field t-scu_scu            like scu.scu
field t-scu_grp            like scu.grp
field t-scu_cat            as integer
field t-scu_gl             like scu.gl
field t-scu_type           as char
field t-scu_nin            as char
field t-scu_mdate          as date
field t-scu_crc            like crc.crc
field t-scu_ccrc           as char
field t-scu_cnt            as integer
field t-scu_parval         as deci
field t-scu_discont        as deci
field t-scu_prem           as deci
field t-scu_prem_bay       as deci
field t-scu_prem_cumm      as deci
field t-scu_pol_corr       as deci
field t-scu_otr_corr       as deci
field t-scu_balsum         as deci
field t-scu_balsumrate     as deci
field t-scu_intrate        as deci
field t-scu_close_yeld     as deci
field t-scu_coupondate     as char
field t-scu_daytoclose     as deci
field t-scu_daytocopon     as deci
field t-scu_date           as date.


def var v-date as date.

def frame f-date
   v-date label "Дата"
with side-labels centered row 7 title "Параметры отчета".


output stream v-out to scuclrep.html.

update  v-date with frame f-date.
for each scu no-lock:

   /*не учитываем закрытые счета*/
   find sub-cod  where sub-cod.acc = scu.scu
          and sub-cod.sub = 'scu' and sub-cod.d-cod = 'clsa' no-lock no-error.
   if avail sub-cod and sub-cod.ccod <> 'msc' and sub-cod.rdt <= v-date then do:
        next.
   end.

   create t-scu.
        t-scu.t-scu_scu       =  scu.scu.
        t-scu.t-scu_grp       =  scu.grp.
        t-scu.t-scu_gl        =  scu.gl.

        /* обьединяем гос. и негос. ЦБ*/
        t-scu.t-scu_cat  =  1.
        if  scu.grp = 10 or scu.grp = 20  then do:
            t-scu.t-scu_cat  =  1.
        end.

        if  scu.grp = 30 or scu.grp = 40  then do:
            t-scu.t-scu_cat  =  2.
        end.

        if  scu.grp = 50 or scu.grp = 60  then do:
            t-scu.t-scu_cat  =  3.
        end.

        find deal where deal.deal = scu.scu no-lock no-error.
        if avail deal then do:

             t-scu.t-scu_mdate  = deal.maturedt.
             t-scu.t-scu_type   = deal.rem[3].

             find codfr where codfr.codfr EQ 'secur'
               and codfr.code = deal.rem[3] no-lock no-error.
               if available codfr then t-scu.t-scu_nin =  codfr.name[1].

             t-scu.t-scu_cnt  = deal.ncrc[2].

             t-scu_intrate    = deal.intrate.
             t-scu_close_yeld = deal.dval[1].
             t-scu_coupondate = deal.info[2].
             t-scu_daytoclose = deal.dval[2].
             t-scu_daytocopon = deal.dval[3].
             t-scu_date       = deal.regdt.

             find dfb where dfb.dfb = deal.atvalueon[1] no-lock no-error.
             if available dfb
             then do:
                  find crc where crc.crc = dfb.crc no-lock no-error.
                  t-scu_ccrc = crc.code.
                  t-scu_crc = crc.crc.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 1
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_parval   =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 4
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_discont   =  histrxbal.dam - histrxbal.cam.
             end.


             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 5
                                        no-lock no-error.

             if avail  histrxbal then do:
                  t-scu.t-scu_prem    =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 9
                           no-lock no-error.

             if avail histrxbal then do:
                  t-scu.t-scu_prem_bay   =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 2
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_prem_cumm   =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 17
                                        no-lock no-error.
             if avail  histrxbal then do:
                    t-scu.t-scu_pol_corr   =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 18
                           no-lock no-error.

             if avail histrxbal then do:
                    t-scu.t-scu_otr_corr   =  histrxbal.dam - histrxbal.cam.
             end.


             if t-scu.t-scu_cat  =  1 or t-scu.t-scu_cat  =  2 then do:
                  t-scu.t-scu_balsum      = abs(t-scu.t-scu_parval)   - abs(t-scu.t-scu_discont)   + abs(t-scu.t-scu_prem) +
                                            abs(t-scu.t-scu_prem_bay) + abs(t-scu.t-scu_prem_cumm) + abs(t-scu.t-scu_pol_corr) - abs(t-scu.t-scu_otr_corr).
             end. else do:
                  t-scu.t-scu_balsum      = abs(t-scu.t-scu_parval) - abs(t-scu.t-scu_discont) + abs(t-scu.t-scu_prem) +
                                            abs(t-scu.t-scu_prem_bay) + abs(t-scu.t-scu_prem_cumm).
             end.

             find last crchis where crchis.regdt  <= v-date
                         and crchis.crc = t-scu.t-scu_crc no-lock no-error.

             if avail crchis and t-scu.t-scu_crc <> 1 then
                 t-scu.t-scu_balsumrate = abs(t-scu.t-scu_balsum - t-scu.t-scu_prem_cumm) * crchis.rate[1].
             else
                 t-scu.t-scu_balsumrate = abs(t-scu.t-scu_balsum - t-scu.t-scu_prem_cumm).
       end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Балансовая стоимость ЦБ</h2>" skip.
put stream v-out unformatted  "<br>" string(v-date) "<br>" skip.

find last crchis where crchis.regdt  <= v-date
            and crchis.crc = 2 no-lock no-error.

put stream v-out unformatted  "Курс USD <b>" crchis.rate[1] "</b>" skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>N</td>"
                         "<td>N счета scu</td>"
                         "<td>Вид ценных<br>бумаг</td>"
                         "<td>НИН</td>"
                         "<td>Дата покупки</td>"
                         "<td>Дата гашения</td>"
                         "<td>Валюта</td>"
                         "<td>Количество</td>"
                         "<td>Номинальная<br>стоимость</td>"
                         "<td>Дисконт</td>"
                         "<td>Премия</td>"
                         "<td>Вознаграждение<br>начисленное <br> до покупки</td>"
                         "<td>Начисленное<br>вознаграждение</td>"
                         "<td>Положительная<br>корректировка</td>"
                         "<td>Отрицательная<br>корректировка</td>"
                         "<td>Балансовая<br>стоимость ЦБ</td>"
                         "<td>Балансовая<br>стоимость ЦБ<br>(без начисленного <br> вознаграждения)</td>"
                         "<td>По учетному курсу</td>"
                         "<td>%Ставка</td>"
                         "<td>Доходность к погашению</td>"
                         "<td>Дата выплаты купона</td>"
                         "<td>Дней до погашения</td>"
                         "<td>Дней до выплаты купона</td>"
                         "</tr>"
                          skip.
j = 1.
for each t-scu break by t-scu.t-scu_cat by t-scu.t-scu_crc by t-scu.t-scu_mdate.

  accumulate t-scu_balsumrate (TOTAL by t-scu.t-scu_cat).

  if first-of (t-scu.t-scu_cat) then do:
    i = 0.
    v-grpname = "".

    if t-scu.t-scu_cat = 1 then do:
        v-grpname = "ЦБ, предназначенные для торговли".
        v-hdr = "<td colspan=""8""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center ><b>120110/120120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120510/120520</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120610/120620</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120710/120720</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174410/174420</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120810/120820</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120910/120920</b></td>".
        v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
    end.

    if t-scu.t-scu_cat = 2 then do:
        v-grpname = "ЦБ, имеющиеся в наличии для для продажи".
        v-hdr = "<td colspan=""8""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145210/145220</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145311/145312</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145411/145412</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145511/145512</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174610/174620</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145641/145642</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145711/145712</b></td>".
        v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
    end.

    if t-scu.t-scu_cat = 3 then do:
        v-grpname = "ЦБ, удерживаемые до погашения".
        v-hdr = "<td colspan=""8""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145110/145120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145321/145322</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145521/145522</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174530/174540</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174610/174620</b></td>".
        v-hdr = v-hdr + "<td></td>".
        v-hdr = v-hdr + "<td></td>".
        v-hdr = v-hdr + "<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>".
    end.

    if  v-grpname <> "" then do:
       j = j + 1.
    end.

    if v-grpname <> ""  then do:
           put stream v-out unformatted
                           "<tr>"                               skip
                           v-hdr
                           "</tr>"                              skip.

    end.

  end.

  i = i + 1.
  put stream v-out unformatted
                         "<tr>"                          skip
                         "<td>"  string (i)    "</td>"   skip
                         "<td>"  "'" string(t-scu_scu)     "</td>"   skip
                         "<td>"  t-scu_type    "</td>"   skip
                         "<td>"  t-scu_nin     "</td>"   skip
                         "<td>"  string(t-scu_date, "99.99.9999")  "</td>"   skip
                         "<td>"  t-scu_mdate format "99.99.9999"   "</td>"   skip
                         "<td>"  t-scu_ccrc    "</td>"   skip
                         "<td>"  t-scu_cnt     "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_parval   ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_discont  ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem     ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem_bay ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem_cumm),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_pol_corr ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_otr_corr ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_balsum   ),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_balsum - t-scu_prem_cumm),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_balsumrate),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_intrate),  "->>>>>>>>>>>>>>9.9999")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_close_yeld),  "->>>>>>>>>>>>>>9.9999")),".",",")  "</td>"   skip
                         "<td>"  if t-scu_coupondate = ? then "" else string(t-scu_coupondate,  "99.99.9999") "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_daytoclose),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_daytocopon),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "</tr>" skip.
  if last-of (t-scu.t-scu_cat) then do:

   put stream v-out unformatted
                         "<tr>"                          skip
                         "<td> Всего </td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td></td><td></td><td></td><td></td><td></td>"   skip
                         "<td><b>"  replace(trim(string(accum total by (t-scu.t-scu_cat) t-scu_balsumrate,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>"   skip
                         "<td></td><td></td><td></td><td></td><td></td></tr>" skip.

  end.
end.
output stream v-out close.
unix silent value("cptwin scuclrep.html excel").




