/* r-paym.p
 * MODULE
        Отчет по переводам без открытия счета
        Метроэкспресс SWIFT
 * DESCRIPTION
        Отчет
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT
        r-paim1.p
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM
 * AUTHOR
        27.04.09 marinav
 * CHANGES
        08.10.09 marinav - убрала взаимозачеты
*/

def new shared temp-table paym no-undo 
    field dt as int
    field name as char
    field type as char
    field country as char
    field crc like bank.crchis.crc
    field cnt as int
    field sum like translat.summa
    index main dt name type country crc.


def var v-cnt as int.
def var v-sum as int.

def new shared var dt1     as date.
def new shared var dt2     as date.

function mon_str returns char (input v-mon as int) .
   if v-mon = 1 then return "январь".
   if v-mon = 2 then return "февраль".
   if v-mon = 3 then return "март".
   if v-mon = 4 then return "апрель".
   if v-mon = 5 then return "май".
   if v-mon = 6 then return "июнь".
   if v-mon = 7 then return "июль".
   if v-mon = 8 then return "август".
   if v-mon = 9 then return "сентябрь".
   if v-mon = 10 then return "октябрь".
   if v-mon = 11 then return "ноябрь".
   if v-mon = 12 then return "декабрь".
end.

form dt1 label ' Укажите период с' format '99/99/9999' dt2 label ' по' format '99/99/9999' skip(1)
with side-label row 5 width 48 centered frame dat.

update dt1 dt2 with frame dat.


def new shared var v-eknp as char.
def new shared var v-iso as char.


/* исходящие - отправленные, сделать по всем филиалм разбранчевку */

{r-branch.i &proc = "r-paym1"}


/* входящие - полученные для филиала, только в ЦО */
for each remtrz where drgl = 105210 and rsub = 'arp' and remtrz.valdt1 >= dt1 and remtrz.valdt1 <= dt2  no-lock.
    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.rem and ccode = 'eknp'  no-lock no-error.
    if avail sub-cod then v-eknp = sub-cod.rcode. else v-eknp = "".
    if substr(v-eknp,5,1) = '9' then do:
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.rem and d-cod = 'iso3166' no-lock no-error.
        if avail sub-cod then v-iso = sub-cod.ccode. else v-iso = "".
        find last crchis where crchis.crc = remtrz.fcrc and crchis.rdt <= remtrz.valdt1 no-lock no-error.
        find first paym where paym.dt = month(remtrz.valdt1) and paym.name = 'SWIFT' and paym.type = 'полученные' and paym.country = v-iso and paym.crc = remtrz.fcrc no-lock no-error.
        if not avail paym then do:
           create paym.
           assign paym.dt = month(remtrz.valdt1) paym.name = 'SWIFT' paym.type = 'полученные' paym.country = v-iso paym.crc = remtrz.fcrc.
        end.
        assign paym.cnt = paym.cnt + 1 paym.sum = paym.sum + remtrz.amt * crchis.rate[1].
    end.
end.


/* входящие - полученные для ЦО, только в ЦО */

def buffer b-jl for jl.
for each jl where jl.gl = 105210 and jl.dc = 'd' and jl.crc ne 1 and jl.jdt >= dt1 and jl.jdt <= dt2 no-lock.
    find first b-jl where b-jl.jh = jl.jh and b-jl.ln <> jl.ln and  (b-jl.dam + b-jl.cam) = (jl.dam + jl.cam)  no-lock no-error.
    find first gl where gl.gl = b-jl.gl and gl.sub = 'arp' no-lock no-error.
    if avail gl then do:
       find first trxcods where trxh = b-jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = 'secek' and trxcods.code = '9' no-lock no-error.
       if avail trxcods then do:
          if (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches "*взаимо*" or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches "*возмещен*"
          or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches "*сворачивание*" or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches
          "*покрытие*" or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches "*доход*" or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches
          "*сальдирование*" or (jl.rem[1] + jl.rem[2] + jl.rem[3]) matches "*комиссия*"  then next.
  
          find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt no-lock no-error.
          v-sum = (jl.dam + jl.cam)  * crchis.rate[1].
           create paym.
           assign paym.dt = month(jl.jdt) paym.name = 'SWIFT' paym.type = 'полученные' paym.country = string(jl.jh) paym.crc = b-jl.crc.
           assign paym.cnt = 1 paym.sum = v-sum.
       end.
    end.
 end.




for each translat where translat.date >= dt1 and translat.date <= dt2 and translat.stat >= 2 and translat.stat <= 4 no-lock :
    find last crchis where crchis.crc = translat.crc and crchis.rdt <= translat.date no-lock no-error.
       find first paym where paym.dt = month(translat.date) and paym.name = 'Метроэкспресс' and paym.type = 'отправленные' and paym.country = 'RU' and paym.crc = translat.crc no-lock no-error.
       if not avail paym then do:
          create paym.
          assign paym.dt = month(translat.date) paym.name = 'Метроэкспресс' paym.type = 'отправленные' paym.country = 'RU' paym.crc = translat.crc.
       end.
       assign paym.cnt = paym.cnt + 1 paym.sum = paym.sum + translat.summa * crchis.rate[1].

end.


for each r-translat where r-translat.date >= dt1 AND r-translat.date <= dt2 and r-translat.stat <= 2  no-lock :
    find last crchis where crchis.crc = r-translat.crc and crchis.rdt <= r-translat.date no-lock no-error.
       find first paym where paym.dt = month(r-translat.date) and paym.name = 'Метроэкспресс' and paym.type = 'полученные' and paym.country = 'RU' and paym.crc = r-translat.crc no-lock no-error.
       if not avail paym then do:
          create paym.
          assign paym.dt = month(r-translat.date) paym.name = 'Метроэкспресс' paym.type = 'полученные' paym.country = 'RU' paym.crc = r-translat.crc.
       end.
       assign paym.cnt = paym.cnt + 1 paym.sum = paym.sum + r-translat.summa * crchis.rate[1].
end.



define stream rep.
output stream rep to rep.html.
find first cmp.


put stream rep unformatted

    "<html>" skip
    "<head>" skip
          "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
          "<title>Отчет</title>" skip
             "<style type= text/css>" skip
             "TABLE \{ border-collapse: collapse; \}" skip
             "</style>" skip
    "</head>" skip
    "<body>" skip



    "<table width= 40% border= 0 cellspacing= 0 cellpadding= 0>" skip
    "<tr align= center>" skip
    "<td colspan=3>Дата формирования отчета " + string(today, "99/99/99") + "</td>" skip
    "</tr>" skip
    "<tr>" skip
    "<td>Период</td>" skip
    "<td colspan=2>" dt1 "-" dt2 "</td>" skip
    "</tr>" skip
    "</table><br><br>"skip



    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0  >" skip
    "<tr style= 'font:bold; font-size:x-small;' bgcolor= #C0C0C0 align= center>" skip
    "<td>Месяц</td>" skip
    "<td>Наименование<br>системы<br>переводов денег</td>" skip
    "<td>Вид перевода<br>денег</td>" skip
    "<td>Код страны, куда<br>отправлен/откуда<br>получен перевод<br>денег</td>" skip
    "<td>Код<br>валюты</td>" skip
    "<td>Количество<br>переводов<br>(единиц)</td>" skip
    "<td>Сумма (<br>в тенге)</td>" skip
    "</tr>" skip.



  for each paym.
    find first crc where crc.crc = paym.crc no-lock no-error.
    put stream rep unformatted "<tr><td>" mon_str(paym.dt) "</td>"
                                   "<td>" paym.name "</td>"
                                   "<td>" paym.type "</td>"
                                   "<td>" paym.country "</td>"
                                   "<td>" crc.code "</td>"
                                   "<td>" paym.cnt "</td>"
                                   "<td>" paym.sum "</td></tr>" skip.
  end.





put stream rep unformatted "</table></body></html>".

output stream rep close.
unix silent cptwin rep.html excel.



