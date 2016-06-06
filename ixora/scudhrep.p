/* scudhrep.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Доходы/расходы по  ЦБ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        11-9-4-5
 * BASES
        BANK
 * AUTHOR
        24.05.2004 tsoy
 * CHANGES
        31.05.2004 tsoy  в некоторых колонках изменил дебет на остатки по счетам
        16.06.2004 tsoy  взял остатки по счетам, а также с минусом дисконт и отр. корректировка
        17.06.2004 tsoy  По 21 уровню остаток по кредиту. если есть конвертация в тенге
        18.06.2004 tsoy  По 22 уровню остаток по кредиту. если есть конвертация в тенге
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/


{global.i}
{nbankBik.i}
def var i as integer.
def var j as integer.
def var v-grpname as char.
def var v-hdr as char.

def stream v-out.

def var v-date as date.

def frame f-date
   v-date label "Дата"
with side-labels centered row 7 title "Параметры отчета".

def  buffer t-histrxbal for histrxbal.

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
field t-scu_prem           as deci
field t-scu_dics_amt       as deci
field t-scu_prem_amt       as deci
field t-scu_yeild_price    as deci
field t-scu_debt_price     as deci
field t-scu_yeild_release  as deci
field t-scu_debt_release   as deci.

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
                           and histrxbal.lev = 11
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_prem   =  histrxbal.cam - histrxbal.dam.
                 else
                    t-scu.t-scu_prem   =  histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 19
                           no-lock no-error.

             if avail histrxbal then do:
                 t-scu.t-scu_dics_amt   =  histrxbal.dam - histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 20
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_prem_amt   =  histrxbal.dam - histrxbal.cam.
                 else
                    t-scu.t-scu_prem_amt   =  histrxbal.cam.
             end.


             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 21
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_yeild_price   =  abs(histrxbal.cam - histrxbal.dam).
                 else do:
                           find last t-histrxbal where t-histrxbal.dt  <=  v-date
                           and t-histrxbal.sub = 'scu'
                           and t-histrxbal.acc = deal.deal
                           and t-histrxbal.crc = 1
                           and t-histrxbal.lev = 21
                           no-lock no-error.
                           if avail t-histrxbal and abs(t-histrxbal.dam - t-histrxbal.cam) = 0 then do:
                               t-scu.t-scu_yeild_price   =  abs(histrxbal.dam - histrxbal.cam).
                           end.  else do:
                               t-scu.t-scu_yeild_price   =  histrxbal.cam.
                           end.
                 end.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 22
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_debt_price   =  histrxbal.dam - histrxbal.cam.
                 else do:
                           find last t-histrxbal where t-histrxbal.dt  <=  v-date
                           and t-histrxbal.sub = 'scu'
                           and t-histrxbal.acc = deal.deal
                           and t-histrxbal.crc = 1
                           and t-histrxbal.lev = 22
                           no-lock no-error.
                           if avail t-histrxbal and abs(t-histrxbal.dam - t-histrxbal.cam) = 0 then do:
                               t-scu.t-scu_debt_price   =  abs(histrxbal.dam - histrxbal.cam).
                           end.  else do:
                               t-scu.t-scu_debt_price   =  histrxbal.cam.
                           end.

                 end.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 23
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_yeild_release   = histrxbal.dam - histrxbal.cam.
                 else
                    t-scu.t-scu_yeild_release   = histrxbal.cam.
             end.

             find last histrxbal where histrxbal.dt      <=  v-date
                           and histrxbal.sub = 'scu'
                           and histrxbal.acc = deal.deal
                           and histrxbal.crc = t-scu.t-scu_crc
                           and histrxbal.lev = 24
                           no-lock no-error.

             if avail histrxbal then do:
                 if t-scu.t-scu_crc = 1 then
                    t-scu.t-scu_debt_release    =  histrxbal.dam - histrxbal.cam.
                 else
                    t-scu.t-scu_debt_release    =  histrxbal.cam.
             end.

       end.
end.

put stream v-out unformatted "<html><head><title>" + v-nbank1 + "</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Доходы/расходы по  ЦБ</h2>" skip.
put stream v-out unformatted  "<br>" string(v-date) skip.

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>N</td>"
                         "<td>N счета scu</td>"
                         "<td>Вид ценных<br>бумаг</td>"
                         "<td>НИН</td>"
                         "<td>Валюта</td>"
                         "<td>Количество</td>"
                         "<td>Номинальная<br>стоимость</td>"
                         "<td>Вознаграждение<br>по ЦБ </td>"
                         "<td>Амортизация<br>дисконта </td>"
                         "<td>Амортизация<br>премиии  </td>"
                         "<td>Доход<br>от изменения<br>стоимости ЦБ</td>"
                         "<td>Расходы<br>от изменения<br>стоимости ЦБ</td>"
                         "<td>Реализованные<br>додходы<br>от изменения<br>стоимости ЦБ</td>"
                         "<td>Реализованные<br>расходы<br>от изменения<br>стоимости ЦБ</td>"
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
        v-hdr = v-hdr + "<td align=center><b>420110/420120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>420210/420220</b></td>".
        v-hdr = v-hdr + "<td align=center><b>530510/530520</b></td>".
        v-hdr = v-hdr + "<td align=center><b>470911/490912</b></td>".
        v-hdr = v-hdr + "<td align=center><b>570911/570912</b></td>".
        v-hdr = v-hdr + "<td align=center><b>473311/473312</b></td>".
        v-hdr = v-hdr + "<td align=center><b>573311/573312</b></td>".
    end.

    if t-scu.t-scu_cat = 2 then do:
        v-grpname = "ЦБ, имеющиеся в наличии для для продажи".
        v-hdr = "<td colspan=""6""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145210/145220</b></td>".
        v-hdr = v-hdr + "<td align=center><b>445210/445220</b></td>".
        v-hdr = v-hdr + "<td align=center><b>445311/445312</b></td>".
        v-hdr = v-hdr + "<td align=center><b>530611/530612</b></td>".
        v-hdr = v-hdr + "<td align=center><b>470921/470922</b></td>".
        v-hdr = v-hdr + "<td align=center><b>570921/570922</b></td>".
        v-hdr = v-hdr + "<td align=center><b>473321/473322</b></td>".
        v-hdr = v-hdr + "<td align=center><b>573321/573322</b></td>".
    end.

    if t-scu.t-scu_cat = 3 then do:
        v-grpname = "ЦБ, удерживаемые до погашения".
        v-hdr = "<td colspan=""6""><b>" + string(j) + ". " + v-grpname + "</b></td>".
        v-hdr = v-hdr + "<td align=center><b>145110/145120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>445110/445120</b></td>".
        v-hdr = v-hdr + "<td align=center><b>445321/445322</b></td>".
        v-hdr = v-hdr + "<td align=center><b>530621/530622</b></td>".
        v-hdr = v-hdr + "<td align=center></td>".
        v-hdr = v-hdr + "<td align=center></td>".
        v-hdr = v-hdr + "<td align=center></td>".
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
                         "<td>"  replace(trim(string(abs(t-scu_parval  )     ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem    )     ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_dics_amt)     ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_prem_amt)     ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_yeild_price)  ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_debt_price)   ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_yeild_release),  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "<td>"  replace(trim(string(abs(t-scu_debt_release) ,  "->>>>>>>>>>>>>>9.99")),".",",")  "</td>"   skip
                         "</tr>" skip.
end.
output stream v-out close.
unix silent value("cptwin scuclrep.html excel").



