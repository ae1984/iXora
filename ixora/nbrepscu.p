/* nbrepscu.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Балансовая стоимость ЦБ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        11-9-4-7
 * BASES
        BANK
 * AUTHOR
        06.09.2004 tsoy
 * CHANGES
        09.09.2004 tsoy Добавил упорядочивание по валюте
        04.10.2004 tsoy Покупная 8 разрядов
        18.02.2005 tsoy Добавил Номинал и валюту номинала
        10.03.2005 tsoy поменял местами колонки
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/


{global.i}
{nbankBik.i}
def var i as integer.
def var j as integer.
def var k as integer.

def var v-h-scu_count     as deci.
def var v-scu_gdp_cnt     as deci.
def var v-scu_gdp_interes as deci.
def var v-scu_pdp_cnt     as deci.
def var v-scu_pdp_interes as deci.
def var v-scu_udp_cnt     as deci.
def var v-scu_udp_interes as deci.



def var v-grpname as char.
def var v-hdr as char.


def var v-h-scu_gdp_cnt     as deci.
def var v-h-scu_gdp_interes as deci.
def var v-h-scu_pdp_cnt     as deci.
def var v-h-scu_pdp_interes as deci.
def var v-h-scu_udp_cnt     as deci.
def var v-h-scu_udp_interes as deci.

def stream v-out.

def temp-table t-scu
field t-scu_scu            like scu.scu
field t-scu_kodcb          like deal.rem[3]
field t-scu_nin            as char
field t-scu_count          as integer
field t-scu_purchsale      as decimal
field t-scu_parcrc         as integer
field t-scu_parcrccode     as char
field t-scu_emit           as char
field t-scu_emttype        as integer
field t-scu_emtvid         as integer
field t-scu_cat            as integer
field t-scu_crc            as integer
field t-scu_gdp_cnt        as integer
field t-scu_gdp_interes    as decimal
field t-scu_pdp_cnt        as integer
field t-scu_pdp_interes    as decimal
field t-scu_udp_cnt        as integer
field t-scu_udp_interes    as decimal
field t-scu_purch_date     as date
field t-scu_close_date     as date
field t-scu_sale_date      as date
field t-scu_lst            as char.

def buffer b-t-scu for t-scu.
def var v-date as date.

def var v-total as decimal.
def var v-interes as decimal.

def frame f-date
   v-date label "Дата"
with side-labels centered row 7 title "Параметры отчета".

output stream v-out to nbrepscu.html.

update  v-date with frame f-date.

for each scu no-lock:

   /*не учитываем закрытые счета*/
   find sub-cod  where sub-cod.acc = scu.scu
          and sub-cod.sub = 'scu' and sub-cod.d-cod = 'clsa' no-lock no-error.
   if avail sub-cod and sub-cod.ccod <> 'msc' and sub-cod.rdt <= v-date then do:
        next.
   end.

   find deal where deal.deal = scu.scu no-lock no-error.
   if avail deal then do:

    create t-scu.
        t-scu.t-scu_scu       =  scu.scu.

        find codfr where codfr.codfr = 'secur'
             and codfr.code = deal.rem[3] no-lock no-error.
             if available codfr then t-scu.t-scu_nin =  codfr.name[1].

             t-scu.t-scu_count       = deal.ncrc[2].
             t-scu.t-scu_purchsale   = deal.ncrc[1].

             find dfb where dfb.dfb = deal.atvalueon[1] no-lock no-error.
             if available dfb
             then do:
                  t-scu.t-scu_parcrc = dfb.crc.
                  find crc where crc.crc = t-scu.t-scu_parcrc no-lock.
                  t-scu.t-scu_parcrccode = crc.code.

             end.

             t-scu.t-scu_kodcb       = deal.rem[3].
             t-scu.t-scu_purch_date  = deal.regdt.
             t-scu.t-scu_close_date  = deal.maturedt.

             t-scu.t-scu_emit        =  deal.atvalueon[3].
             t-scu.t-scu_crc         = scu.crc.

             if deal.dval[4] = 0 then
                  t-scu.t-scu_emttype  = 1.
             else
                  t-scu.t-scu_emttype  = integer (deal.dval[4]).

             if deal.dval[5] = 0 then
                 t-scu.t-scu_emtvid   = 1.
             else
                 t-scu.t-scu_emtvid   = integer (deal.dval[5]).


             t-scu.t-scu_lst = deal.info[3].

             v-total   = 0.
             v-interes = 0.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 1
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  abs(histrxbal.dam - histrxbal.cam).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 4
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total - abs( histrxbal.dam - histrxbal.cam ).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 5
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total + abs( histrxbal.dam - histrxbal.cam ).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 9
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total + abs( histrxbal.dam - histrxbal.cam ).
            end.


            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 17
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total + abs( histrxbal.dam - histrxbal.cam ).
            end.


            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 18
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total - abs( histrxbal.dam - histrxbal.cam ).
            end.


            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 2
                           no-lock no-error.

            if avail histrxbal then do:
                 v-total   =  v-total + abs( histrxbal.dam - histrxbal.cam ).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 5
                           no-lock no-error.

            if avail histrxbal then do:
                 v-interes   =  abs( histrxbal.dam - histrxbal.cam ).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 9
                           no-lock no-error.

            if avail histrxbal then do:
                 v-interes   =  v-interes + abs( histrxbal.dam - histrxbal.cam ).
            end.

            find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = scu.crc
                           and histrxbal.lev = 2
                           no-lock no-error.

            if avail histrxbal then do:
                 v-interes   =  v-interes + abs( histrxbal.dam - histrxbal.cam ).
            end.


        find last crchis where crchis.regdt  <= v-date
                    and crchis.crc = scu.crc no-lock no-error.

        if avail crchis and scu.crc <> 1 then do:
            v-total   = v-total   * crchis.rate[1].
            v-interes = v-interes * crchis.rate[1].
        end.

        if  scu.grp = 10 or scu.grp = 20  then do:
            t-scu.t-scu_cat  =  1.
            t-scu.t-scu_pdp_cnt      =  v-total .
            t-scu.t-scu_pdp_interes  =  v-interes.
        end.

        if  scu.grp = 30 or scu.grp = 40  then do:
            t-scu.t-scu_cat  =  2.
            t-scu.t-scu_gdp_cnt      =  v-total .
            t-scu.t-scu_gdp_interes  =  v-interes.
        end.

        if  scu.grp = 50 or scu.grp = 60  then do:
            t-scu.t-scu_cat  =  3.
            t-scu.t-scu_udp_cnt     =  v-total .
            t-scu.t-scu_udp_interes =  v-interes.
        end.
   end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Сведения о структуре портфеля ценных бумаг</h2>" skip.
put stream v-out unformatted  "<br>" + v-nbankru + "<br>" skip.
put stream v-out unformatted  "<br> По состоянию на " string(v-date) "<br>" skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

put stream v-out unformatted "<tr style=""font:bold"" align=""center"" >"
                         "<td rowspan = 3>N п/п </td>"
                         "<td rowspan = 3>Наименование эмитента</td>"
                         "<td rowspan = 3>Наименовние ЦБ</td>"
                         "<td rowspan = 3>Национальный <br> идентификационный <br>код или международный <br>номер</td>"
                         "<td colspan = 2>Количество ценных бумаг,(штук)</td>"
                         "<td rowspan = 3>Номинал ЦБ*</td>"
                         "<td rowspan = 3>Валюта номинальной стоимости*</td>"
                         "<td colspan = 6>Балансовая стоимость (нетто) (в тысячах тенге) </td>"
                         "<td colspan = 3>Дата</td>"
                         "<td rowspan = 3>Листинг/Рейтинг</td>"
                         "</tr>"
                          skip.

put stream v-out unformatted "<tr style=""font:bold"" align=""center"" >"
                         "<td rowspan = 2>Всего</td>"
                         "<td rowspan = 2>в том числе ЦБ, <br>переданные в РЕПО <br>или обременные <br> иным образом</td>"
                         "<td colspan = 2>ЦБ Имеющиеся в наличии для продажи</td>"
                         "<td colspan = 2>ЦБ Пердназначенные для торговли</td>"
                         "<td colspan = 2>ЦБ Удерживаемые до погашения</td>"
                         "<td rowspan = 2>Приобретения</td>"
                         "<td rowspan = 2>Предполагаемой<br>продажи</td>"
                         "<td rowspan = 2>Погашения</td>"
                         "</tr>"
                          skip.

put stream v-out unformatted "<tr style=""font:bold"" align=""center"" >"
                         "<td>Всего</td>"
                         "<td>в том числе, <br>суммарное <br>начисленное <br>вознаграждение <br>в нац валюте</td>"
                         "<td>Всего</td>"
                         "<td>в том числе, <br>суммарное <br>начисленное <br>вознаграждение <br>в нац валюте</td>"
                         "<td>Всего</td>"
                         "<td>в том числе, <br>суммарное <br>начисленное <br>вознаграждение <br>в нац валюте</td>"
                         "</tr>"
                          skip.

i = 0.
for each t-scu no-lock break by t-scu.t-scu_emttype by t-scu.t-scu_emtvid by t-scu.t-scu_cat by t-scu.t-scu_crc.

   accumulate t-scu_count (TOTAL).

   v-scu_gdp_cnt     = v-scu_gdp_cnt     + t-scu.t-scu_gdp_cnt.
   v-scu_gdp_interes = v-scu_gdp_interes + t-scu.t-scu_gdp_interes.
   v-scu_pdp_cnt     = v-scu_pdp_cnt     + t-scu.t-scu_pdp_cnt    .
   v-scu_pdp_interes = v-scu_pdp_interes + t-scu.t-scu_pdp_interes.
   v-scu_udp_cnt     = v-scu_udp_cnt     + t-scu.t-scu_udp_cnt    .
   v-scu_udp_interes = v-scu_udp_interes + t-scu.t-scu_udp_interes.

if first-of (t-scu_emttype) then do:
        i = i + 1.
        j = 0.
        find codfr where codfr.codfr = 'emittype'
             and codfr.code = string(t-scu.t-scu_emttype) no-lock no-error.

        for each b-t-scu where b-t-scu.t-scu_emttype = t-scu.t-scu_emttype no-lock.

             v-h-scu_count        = v-h-scu_count       + b-t-scu.t-scu_count.
             v-h-scu_gdp_cnt      = v-h-scu_gdp_cnt     + b-t-scu.t-scu_gdp_cnt.
             v-h-scu_gdp_interes  = v-h-scu_gdp_interes + b-t-scu.t-scu_gdp_interes.
             v-h-scu_pdp_cnt      = v-h-scu_pdp_cnt     + b-t-scu.t-scu_pdp_cnt    .
             v-h-scu_pdp_interes  = v-h-scu_pdp_interes + b-t-scu.t-scu_pdp_interes.
             v-h-scu_udp_cnt      = v-h-scu_udp_cnt     + b-t-scu.t-scu_udp_cnt    .
             v-h-scu_udp_interes  = v-h-scu_udp_interes + b-t-scu.t-scu_udp_interes.

        end.

        if available codfr then
        put stream v-out unformatted "<tr>"
                        "<td>" string (i) "</td>"
                        "<td>" codfr.name[1] "</td>"
                        "<td></td>"
                        "<td></td>"
                        "<td><b>" v-h-scu_count "</b></td>"
                        "<td></td>"
                        "<td></td>"
                        "<td></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_gdp_cnt / 1000 , 0)     ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_gdp_interes / 1000 , 0) ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_pdp_cnt / 1000 , 0)     ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_pdp_interes / 1000 , 0) ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_udp_cnt / 1000 , 0)     ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td><b>" replace(trim(string (round(v-h-scu_udp_interes / 1000 , 0) ,  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>"
                        "<td></td>"
                        "<td></td>"
                        "<td></td>"
                        "<td></td>"
                        "</tr>" skip.
end.

if first-of (t-scu_emtvid) then do:
        j = j + 1.
        k = 0.
        find codfr where codfr.codfr = 'emitview'
             and codfr.code = string(t-scu_emtvid) no-lock no-error.

        if available codfr then
        put stream v-out unformatted "<tr>"
                        "<td>'" string (i)  "." string (j) "</td>"
                        "<td>" codfr.name[1] "</td>"
                        "</tr>" skip.
end.

k = k + 1.

put stream v-out unformatted "<tr>"
              "<td>'" string (i)  "." string (j) "." string (k)                   "</td>" skip
              "<td>"  t-scu.t-scu_emit            "</td>" skip
              "<td>" t-scu.t-scu_kodcb            "</td>" skip
              "<td>" t-scu.t-scu_nin                    "</td>" skip
              "<td>" string (t-scu.t-scu_count)         "</td>" skip
              "<td>"                              "</td>" skip
              "<td>" replace(trim(string(t-scu.t-scu_purchsale ,  "->>>>>>>>>>>>>>9.99999999")),".",",")       "</td>" skip
              "<td>" t-scu.t-scu_parcrccode "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_gdp_cnt / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")         "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_gdp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")     "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_pdp_cnt / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")         "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_pdp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")     "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_udp_cnt / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")         "</td>" skip
              "<td>" replace(trim(string(round(t-scu.t-scu_udp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")     "</td>" skip
              "<td>" if t-scu.t-scu_purch_date = ? then "" else string (t-scu.t-scu_purch_date, "99.99.9999")     "</td>" skip
              "<td>" if t-scu.t-scu_sale_date  = ? then "" else string (t-scu.t-scu_sale_date,  "99.99.9999")     "</td>" skip
              "<td>" if t-scu.t-scu_close_date = ? then "" else string (t-scu.t-scu_close_date, "99.99.9999")     "</td>" skip
              "<td>" t-scu.t-scu_lst                     "</td> </tr>" skip.
end.

put stream v-out unformatted "<tr>"
              "<td colspan=4 >Итого портфель ценных бумаг</td>" skip
              "<td>" replace(trim(string (accum total t-scu.t-scu_count      ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>" skip
              "<td>" "</td>" skip
              "<td>" "</td>" skip
              "<td>" "</td>" skip
              "<td><b>" replace(trim(string (round(v-scu_gdp_cnt / 1000 , 0)    ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>" skip
              "<td><b>" replace(trim(string (round(v-scu_gdp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>" skip
              "<td><b>" replace(trim(string (round(v-scu_pdp_cnt / 1000 , 0)    ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>" skip
              "<td><b>" replace(trim(string (round(v-scu_pdp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",") "</b></td>" skip
              "<td><b>" replace(trim(string (round(v-scu_udp_cnt / 1000 , 0)    ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>" skip
              "<td><b>" replace(trim(string (round(v-scu_udp_interes / 1000 , 0),  "->>>>>>>>>>>>>>9.99")),".",",")  "</b></td>" skip
              "<td>" "</td>" skip
              "<td>" "</td>" skip
              "<td>" "</td>" skip
              "<td>" "</td>" skip
              "</tr>" skip.

put stream v-out unformatted  "</table>" skip.

find ofc where ofc.ofc = g-ofc no-lock.

if avail ofc then
    put stream v-out unformatted
    "<br><br>*Не заполняются по акциям эмитентов Республики Казахстан"
    "<br><br>Руководитель       _________________________ <br>"
    "Главный  бухгалтер _________________________"
    "<br><FONT size=""2"">"
    "<br> Исполнитель : " + ofc.name + "<BR>" skip
    "тел : " + ofc.tel[2] + "</FONT></TD></TR>" skip.

output stream v-out close.
unix silent value("cptwin nbrepscu.html excel").



