/* scuclrep.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Балансовая стоимость ЦБ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        11-9-4-3
 * BASES
        BANK
 * AUTHOR
        24.05.2004 tsoy
 * CHANGES
        31.05.2004 tsoy  в некоторых колонках изменил дебет на остатки по счетам
        16.06.2004 tsoy  взял остатки по счетам, а также с минусом дисконт и отр. корректировка
        17.06.2004 tsoy  значения по модулю
        18.06.2004 tsoy  точность цены 4 знака
        21.06.2004 tsoy  Добавил дату погашения
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{global.i}
{nbankBik.i}
def var i as integer.
def var j as integer.
def var v-grpname as char.

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
field t-scu_price          as deci
field t-scu_sum            as deci.

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
        t-scu.t-scu_price     =  0.

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

             t-scu.t-scu_cnt      =  deal.ncrc[2].

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

                    if avail  histrxbal then do:
                                t-scu.t-scu_parval   =  abs(histrxbal.dam - histrxbal.cam) .
                                t-scu.t-scu_price    =  abs(histrxbal.dam - histrxbal.cam) .
                    end.

             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 4
                                        no-lock no-error.

                    if avail  histrxbal then do:
                                t-scu.t-scu_price    =  t-scu.t-scu_price - abs(histrxbal.dam - histrxbal.cam).
                    end.

             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 5
                                        no-lock no-error.

                    if avail  histrxbal then do:
                                t-scu.t-scu_price    =  t-scu.t-scu_price + abs(histrxbal.dam - histrxbal.cam).
                    end.

             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 17
                                        no-lock no-error.

                    if avail  histrxbal then do:
                                t-scu.t-scu_price    =  t-scu.t-scu_price + abs(histrxbal.dam - histrxbal.cam).
                    end.


             find last histrxbal where histrxbal.dt      <=  v-date
                                        and histrxbal.sub = 'scu'
                                        and histrxbal.acc = deal.deal
                                        and histrxbal.crc = t-scu.t-scu_crc
                                        and histrxbal.lev = 18
                                        no-lock no-error.

                    if avail  histrxbal then do:
                                t-scu.t-scu_price    =  t-scu.t-scu_price - abs(histrxbal.dam - histrxbal.cam).
                    end.

             t-scu.t-scu_sum      = t-scu.t-scu_price / t-scu.t-scu_cnt.

       end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Стоимость ЦБ по чистым ценам</h2>" skip.
put stream v-out unformatted  "<br>" string(v-date) skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>N</td>"
                         "<td>N счета scu</td>"
                         "<td>Вид ценных<br>бумаг</td>"
                         "<td>НИН</td>"
                         "<td>Дата погашения</td>"
                         "<td>Валюта</td>"
                         "<td>Количество</td>"
                         "<td>Номинальная<br>стоимость</td>"
                         "<td>Стоимость<br>по чистой цене</td>"
                         "<td>Чистая цена</td>"
                         "</tr>"
                          skip.
j = 0.
for each t-scu break by t-scu.t-scu_cat by t-scu.t-scu_crc by t-scu_mdate.

  if first-of (t-scu.t-scu_cat) then do:
    i = 0.
    v-grpname = "".

    if t-scu.t-scu_cat = 1 then do:
        v-grpname = "ЦБ, предназначенные для торговли".
    end.

    if t-scu.t-scu_cat = 2 then do:
        v-grpname = "ЦБ, имеющиеся в наличии для для продажи".
    end.

    if t-scu.t-scu_cat = 3 then do:
        v-grpname = "ЦБ, удерживаемые до погашения".
    end.

    if  v-grpname <> "" then do:
       j = j + 1.
    end.

    if v-grpname <> ""  then do:
           put stream v-out unformatted
                           "<tr>"                               skip
                           "<td colspan=""10""><b>" string(j) ". " v-grpname "</b></td>" skip
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
                         "<td>"  t-scu_mdate  format "99.99.9999"  "</td>"   skip
                         "<td>"  t-scu_ccrc    "</td>"   skip
                         "<td>"  t-scu_cnt     "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_parval) , "->>>>>>>>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_price)  ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_sum)    , "->>>>>>>>>>>>>>9.9999")),".",",")   "</td>"   skip
                         "</tr>" skip.
end.
output stream v-out close.
unix silent value("cptwin scuclrep.html excel").


