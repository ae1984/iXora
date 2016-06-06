/* r-fsvz.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Полученные и непогашенные внешние заимствования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.8.2.
 * AUTHOR
        27.12.2012 dmitriy
 * BASES
        BANK COMM
 * CHANGES

*/

{global.i}

def new shared var v-dt as date.
def new shared var v-reptype as integer no-undo.
def new shared var v-prov_type as integer no-undo.
v-reptype = 1.
v-prov_type = 1.

def new shared temp-table wrk
   field cif as char
   field cifname as char
   field country as char
   field lontype as char
   field object  as char
   field gl as int
   field bal as deci
   field crc as int
   field amt as deci
   field ost as deci
   field opndt as date
   field duedt as date
   field prolong as date
   field rate as deci
   field month-cr as deci.


def var summm as decimal extent 5.
def var profit as decimal extent 4.
def var v-branch as char.
def var v-bankn   as char no-undo.
def var i as int.
def var file1 as char.
def var v-prolong as char.
def var v-tg1000 as logi init yes format "Да/Нет".
def var v-1000 as int.
def var v-tgrank as char.
def var v-cifname as char.
def var v-country as char.
def var v-object as char.
def var v-num as char.
def var v-pogash as char.
def var v-pravo as char.
def var v-obesp as char.
def var v-type as char.
def var v-opndt as char.
def var v-duedt as char.

find first sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-bankn = sysc.chval.

define frame fr1
    v-dt      format  "99/99/9999"  label  "За дату" skip
    v-tg1000  format  "Да/Нет"      label  "В тыс.тг"
with side-labels centered row 15 title "ФС_ВЗ".

update v-dt   v-tg1000  with frame fr1.

if v-tg1000 then do: v-1000 = 1000. v-tgrank = "тыс. тенге". end.
else do: v-1000 = 1. v-tgrank = "тенге". end.


{r-brfilial.i &proc = "r-fsvz2"}

file1 = "r-fsvz.html".
output to value(file1).
{html-title.i}


put unformatted "<html><head><title></title>" skip
         "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
         "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""
         style=""border-collapse: collapse"">"
         skip.

put unformatted  "<tr align=""center""><td>Полученные и непогашенные внешние заимствования, в том числе привлеченные посредством дочерних организаций банков
                  <br> за " v-dt " , отчет сформирован в " v-tgrank

           "</td></tr><br><br>"
         skip(2).
put unformatted "<br><br><tr></tr>".


put unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
          style=""border-collapse: collapse" ">" skip
          "<tr style=""font:bold" "" ">"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">№</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Наименование<br>кредитора-<br>нерезидента</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Страна<br>кредитора-<br>нерезидента</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">из них привлеченные<br>банком посредством<br>дочерней<br>организации</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Вид заимствования<br>(займы, гранты,<br>облигации<br>и так далее)</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Цель заимствования</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Номер<br>кредитного<br>соглашения</td>"
          "<td bgcolor=""#CCCCCC"" colspan=""3"" align=""center"">Срок действия кредитного соглашения</td>"
          "<td bgcolor=""#CCCCCC"" colspan=""2"" align=""center"">Сумма заимствования по условиям<br>кредитного соглашения</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Ставка<br>вознаграждения</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Порядок погашения<br>основного долга</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Безусловное право<br>требования кредитора<br>досрочного погашения займа</td>"
          "<td bgcolor=""#CCCCCC"" colspan=""2"" align=""center"">Обеспечение</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">Получено<br>заемных средств</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">Освоено<br>заемных средств</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Всего погашено основного<br>долга с начала получения<br>заемных средств (тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Погашено<br>в отчетном месяце<br>(тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" rowspan=""2"" align=""center"">Дата фактического<br>погашения  (прекращение<br>действия обязательства)</td>"
          "<td bgcolor=""#CCCCCC"" colspan=""2"" align=""center"">Остаток основного<br>долга заемных средств<br>на конец отчетного периода</td>"
          "</tr>"
          "<tr>"
          "<td bgcolor=""#CCCCCC"" align=""center"">дата начала</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">дата конечного<br>срока погашения</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">дата окончания<br>срока пролонгации</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">сумма</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">вид<br>валюты</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">вид</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">сумма<br>(тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">сумма<br>(тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">сумма<br>(тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">сумма<br>(тысяч тенге)</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">номер<br>балансового<br>счета</td>"
          "</tr>"
          "<tr>"
          "<td bgcolor=""#CCCCCC"" align=""center""></td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">1</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">2</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">3</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">4</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">5</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">6</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">7</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">8</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">9</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">10</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">11</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">12</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">13</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">14</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">15</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">16</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">17</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">18</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">19</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">20</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">21</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">22</td>"
          "<td bgcolor=""#CCCCCC"" align=""center"">23</td>"
          "</tr>".


i = 1.
for each wrk no-lock:
    if wrk.prolong = ? then v-prolong = "".
    else v-prolong = string(wrk.prolong).
    if wrk.cif = "a12145" then do: /* в настоящий момент операции не автоматизированы, поэтому данные жестко заданы */
        v-cifname = "Компания ""MAGLINK LIMITED""".
        v-country = "Кипр".
        v-object = "Использование средств в соответствии с Уставом Банка".
        v-num = "б/н".
        v-pogash = "В конце срока".
        v-pravo = "Нет".
        v-obesp = "Без обеспечения".
        v-type = "Субординированный займ".
        v-opndt = "30.06.2011".
        v-duedt = "01.07.2021".

    end.
    find first crc where crc.crc = wrk.crc no-lock no-error.
    put unformatted
          "<tr>"
          "<td align=""center"">" i "</td>"
          "<td align=""center"">" v-cifname "</td>"
          "<td align=""center"">" v-country "</td>"
          "<td align=""center"">"  "</td>"
          "<td align=""center"">" v-type "</td>"
          "<td align=""center"">" v-object "</td>"
          "<td align=""center"">" v-num "</td>"
          "<td align=""center"">" v-opndt "</td>"
          "<td align=""center"">" v-duedt "</td>"
          "<td align=""center"">" v-prolong "</td>"
          "<td align=""center"">" wrk.amt / v-1000 "</td>"
          "<td align=""center"">" crc.code "</td>"
          "<td align=""center"">" wrk.rate "</td>"
          "<td align=""center"">" v-pogash "</td>"
          "<td align=""center"">" v-pravo "</td>"
          "<td align=""center"">" v-obesp "</td>"
          "<td align=""center""> 0,00 </td>"
          "<td align=""center"">" wrk.amt / v-1000 "</td>"
          "<td align=""center"">" wrk.amt / v-1000 "</td>"
          "<td align=""center"">" (wrk.amt - wrk.ost) / v-1000 "</td>"
          "<td align=""center"">" wrk.month-cr / v-1000 "</td>"
          "<td align=""center""> </td>"
          "<td align=""center"">" wrk.ost / v-1000 " </td>"
          "<td align=""center"">" substr(string(wrk.gl),1,4) "</td>"
          "</tr>".
    i = i + 1.
end.

{html-end.i " "}
output close.
unix silent cptwin value(file1) excel.
unix silent rm value(file1)