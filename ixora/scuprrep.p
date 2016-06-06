/* scuprrep.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Амортизация дисконта/премии
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        11-9-4-6
 * BASES
        BANK
 * AUTHOR
        24.05.2004 tsoy
 * CHANGES
        31.05.2004 tsoy  в некоторых колонках изменил дебет на остатки по счетам
        16.06.2004 tsoy  взял остатки по счетам, а также с минусом дисконт и отр. корректировка
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
field t-scu_crc            like crc.crc
field t-scu_ccrc           as char
field t-scu_cnt            as integer
field t-scu_parval         as deci
field t-scu_prem_cumm      as deci
field t-scu_prem_bay       as deci
field t-scu_ds_not_amt     as deci
field t-scu_ds_amt         as deci
field t-scu_ds_sum         as deci
field t-scu_pr_not_amt     as deci
field t-scu_pr_amt         as deci
field t-scu_pr_sum         as deci.

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

             if avail histrxbal then do:
                 t-scu.t-scu_parval   =  histrxbal.dam - histrxbal.cam.
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
                           and histrxbal.lev = 9
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_prem_bay   =  histrxbal.dam - histrxbal.cam.
             end.


             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 4
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_ds_not_amt   =  histrxbal.dam - histrxbal.cam.
             end.


             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 19
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_ds_amt   =  histrxbal.dam - histrxbal.cam.
             end.

             t-scu.t-scu_ds_sum     =  t-scu.t-scu_ds_not_amt + t-scu.t-scu_ds_amt .

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 5
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_pr_not_amt   =  histrxbal.dam - histrxbal.cam.
             end.


             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 20
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_pr_amt   =  histrxbal.dam - histrxbal.cam.
                 else
                    t-scu.t-scu_pr_amt   =  histrxbal.cam.
             end.

             t-scu.t-scu_pr_sum     =  t-scu.t-scu_pr_amt + t-scu.t-scu_pr_not_amt.

       end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Амортизация дисконта/премии </h2>" skip.
put stream v-out unformatted  "<br>" string(v-date) skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td rowspan=""2"">N</td>"
                         "<td rowspan=""2"">N счета scu</td>"
                         "<td rowspan=""2"">Вид ценных<br>бумаг</td>"
                         "<td rowspan=""2"">НИН</td>"
                         "<td rowspan=""2"">Валюта</td>"
                         "<td rowspan=""2"">Количество</td>"
                         "<td rowspan=""2"">Номинальная<br>стоимость</td>"
                         "<td rowspan=""2"">Начисленное<br>вознаграждение</td>"
                         "<td rowspan=""2"">Вознаграждение<br>начисленное<br>до покупки</td>"
                         "<td colspan=""3"" >Дисконт</td>"
                         "<td colspan=""3"" >Премия</td>"
                         "</tr>"
                          skip.
       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>Несамортизированный</td>"
                         "<td>Самортизированный</td>"
                         "<td>Сумма</td>"
                         "<td>Несамортизированный</td>"
                         "<td>Самортизированный</td>"
                         "<td>Сумма</td>"
                         "</tr>"
                          skip.

j = 1.

for each t-scu break by t-scu.t-scu_cat by t-scu.t-scu_crc.

  if first-of (t-scu.t-scu_cat) then do:
    i = 0.
    v-grpname = "".

    if t-scu.t-scu_cat = 1 then do:
        v-grpname = "ЦБ, предназначенные для торговли".
        v-hdr = "<td colspan=""6""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center ><b>120110/120120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174410/174420</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120710/120720</b></td>".
        v-hdr = v-hdr + "<td align=center><b>120510/120520</b></td>".
        v-hdr = v-hdr + "<td align=center><b>420210/420220</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
        v-hdr = v-hdr + "<td align=center><b>120610/120620</b></td>".
        v-hdr = v-hdr + "<td align=center><b>530510/530320</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
    end.

    if t-scu.t-scu_cat = 2 then do:
        v-grpname = "ЦБ, имеющиеся в наличии для для продажи".
        v-hdr = "<td colspan=""6""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center ><b>145210/145220</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174610/174620</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145511/145512</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145311/145312</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145311/145312</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
        v-hdr = v-hdr + "<td align=center>145411/145412</td>".
        v-hdr = v-hdr + "<td align=center><b>530611/530612</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
    end.

    if t-scu.t-scu_cat = 3 then do:
        v-grpname = "ЦБ, удерживаемые до погашения".
        v-hdr = "<td colspan=""6""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center ><b>145110/145120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>174530/174540</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145521/145522</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145321/145322</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145321/145322</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
        v-hdr = v-hdr + "<td align=center>145421/145422</td>".
        v-hdr = v-hdr + "<td align=center><b>530621/530622</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
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
                         "<td>"  t-scu_ccrc    "</td>"   skip
                         "<td>"  t-scu_cnt     "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_parval)    ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem_cumm) ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem_bay)  ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_ds_not_amt),  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_ds_amt)    ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_ds_sum)    ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_pr_not_amt),  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_pr_amt)    ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_pr_sum)    ,  "->>>>>>>>9.99")),".",",")   "</td>"   skip
                         "</tr>" skip.

end.

output stream v-out close.
unix silent value("cptwin scuclrep.html excel").



