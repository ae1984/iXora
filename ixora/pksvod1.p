/* pksvod1.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Свод по погашениям за период (до и после сегодняшней даты)
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        25.01.2004 nadejda
 * CHANGES
        30.01.2003 nadejda - добавлены сведения о количестве заемщиков без денег на дату платежа, на 14-00 и 20-00 даты платежа
        17.02.2004 nadejda - добавлены поля в таблице для совместимости
        24.02.2004 nadejda - добавлена предоплата для совместимости
        19.04.2004 nadejda - добавлены фактически начисленные проценты для совместимости
*/

{mainhead.i}
{pk.i new}

/**
s-credtype = "6".
**/

{pk-sysc.i}

def var v-dtb as date.
def var v-dte as date.
def var v-dt as date.
def var v-bday as logical.
def var v-sum as decimal init 100.
def var v-count as integer.
def var v-count0 as integer.
def var v-count1 as integer.
def var v-count2 as integer.


v-dtb = g-today.
v-dte = g-today + 10.
form skip(1)
    v-dtb label "     Дата начала периода " format "99/99/9999" 
/*       validate (v-dtb >= g-today, " Дата прогноза должна быть не меньше текущей!")*/
    skip
    v-dte label "     Дата конца периода  " format "99/99/9999" 
       validate (v-dte >= v-dtb, " Дата конца периода должна быть не меньше даты начала!") skip(1)
    v-sum label " Сумма на тек.счете более " format "zzz,zz9.99" 
      validate (v-sum >= 0, " Сумма на счете не может быть отрицательной!") skip(1)
  with side-label row 6 centered title " ПАРАМЕТРЫ ОТЧЕТА " frame dat .

displ v-dtb v-dte v-sum with frame dat.
update v-dtb with frame dat.
update v-dte v-sum with frame dat.

def temp-table t-svod
  field dt as date
  field countdt as integer
  field count as integer
  field count0 as integer
  field count1 as integer
  field count2 as integer
  field bday as logical
  index main is primary unique dt.

def new shared temp-table  wrk
    field lon    like lon.lon
    field aaa    like aaa.aaa
    field cif    like lon.cif
    field name   like cif.name
    field rdt    like lon.rdt
    field duedt  like lon.rdt
    field opnamt like lon.opnamt
    field balans like lon.opnamt
    field balans1 like lon.opnamt
    field balans2 like lon.opnamt
    field balacc like lon.opnamt
    field baltim like lon.opnamt
    field baleven like lon.opnamt
    field crc    like crc.code
    field prem   like lon.prem
    field dolg1  as decimal
    field dolg2  as decimal
    field pena   as decimal
    field predopl as decimal
    field ballev2 as decimal
    index main opnamt desc
    index bal balans balans1.

/* рабочие дни */
def var v-weekbeg as int.
def var v-weekend as int.

find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

/* собрать список за даты больше/равно текущей */
do v-dt = v-dtb to v-dte:
  hide message no-pause.
  message " Формирование отчета за" v-dt.
  
  for each wrk. delete wrk. end.
  run pkrepgrdat (v-dt).

  create t-svod.
  t-svod.dt = v-dt.

  v-count = 0.
  v-count0 = 0.
  v-count1 = 0.
  v-count2 = 0.
  for each wrk:
    accumulate wrk.lon (count).

    if wrk.balans2 <= v-sum then v-count = v-count + 1.
    if wrk.balacc <= v-sum then v-count0 = v-count0 + 1.
    if wrk.baltim <= v-sum then v-count1 = v-count1 + 1.
    if wrk.baleven <= v-sum then v-count2 = v-count2 + 1.
  end.

  t-svod.countdt = accum count wrk.lon.
  t-svod.count = v-count.
  t-svod.count0 = v-count0.
  t-svod.count1 = v-count1.
  t-svod.count2 = v-count2.

  /* отметить выходные дни */
  find hol where hol.hol = t-svod.dt no-lock no-error.
  t-svod.bday = (not available hol) and
     (weekday(t-svod.dt) >= v-weekbeg and
     weekday(t-svod.dt) <= v-weekend).
end.
hide message no-pause.



/* 14-00 - время отсечки для определения, сколько было клиентов без денег на счете на день погашения */
def var v-tim as integer init 50400. 
find sysc where sysc.sysc = "pktim" no-lock no-error.
if avail sysc then v-tim = sysc.inval.

/* вывод отчета */
find first cmp no-lock no-error.
define stream m-out.
output stream m-out to svsrok.html.

{html-title.i &stream = "stream m-out"}

put stream m-out unformatted "<table border=0><tr><td><h3>" cmp.name "</h3></td></tr><br>" skip.

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.


put stream m-out unformatted "<tr><td align=""center""><h3>Сводка по кредитам, по которым наступил срок платежа<br>"
                 "на период с " string(v-dtb, "99/99/9999") " по " string(v-dte, "99/99/9999")
                 "<BR>учитывается сумма на текущем счете более " replace(string(v-sum, ">>>>>>9.99"), ".", ",")
                 "</h3></td></tr><BR>" skip
                 "<TR><TD align=""center""><h3>" caps(bookcod.name) format "x(60)" "</h3></TD></TR>" skip
                 "<TR><TD>&nbsp;</TD></TR>" skip(1).

put stream m-out unformatted 
  "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">"
                  "<td>Дата</td>"
                  "<td>Количество<br>заемщиков</td>"
                  "<td>Из них без<br>денег на счете<br>на сегодня</td>"
                  "<td>В % к общему<br>количеству</td>"
                  "<td>Из них без<br>денег на счете<br>на дату отчета<br>на начало дня</td>"
                  "<td>В % к общему<br>количеству</td>"
                  "<td>Из них без<br>денег на счете<br>на дату отчета<br>на " entry(1, string(v-tim, "hh:mm:ss"), ":") + ":" + entry(2, string(v-tim, "hh:mm:ss"), ":") "</td>"
                  "<td>В % к общему<br>количеству</td>"
                  "<td>Из них без<br>денег на счете<br>на дату отчета<br>на 20:00</td>"
                  "<td>В % к общему<br>количеству</td>"
                  "</tr>" skip.

for each t-svod:
    put stream m-out unformatted
             "<tr align=""right""" if t-svod.bday then "" else " bgcolor=""#AAFFEE""" ">"
               "<td align=""center"">" t-svod.dt "</td>"
               "<td>" string(t-svod.countdt, ">>>>>>>>>>>>>>>9") "</td>"
               "<td>" string(t-svod.count, ">>>>>>>>>>>>>>>9") "</td>"
               "<td>" replace(string(t-svod.count / t-svod.countdt * 100, ">>>>>>9.99"), ".", ",") "</td>"
               "<td>" string(t-svod.count0, ">>>>>>>>>>>>>>>9") "</td>"
               "<td>" replace(string(t-svod.count0 / t-svod.countdt * 100, ">>>>>>9.99"), ".", ",") "</td>"
               "<td>" string(t-svod.count1, ">>>>>>>>>>>>>>>9") "</td>"
               "<td>" replace(string(t-svod.count1 / t-svod.countdt * 100, ">>>>>>9.99"), ".", ",") "</td>"
               "<td>" string(t-svod.count2, ">>>>>>>>>>>>>>>9") "</td>"
               "<td>" replace(string(t-svod.count2 / t-svod.countdt * 100, ">>>>>>9.99"), ".", ",") "</td>"
             "</tr>" skip.
end.                       

put stream m-out unformatted "</table></td></tr></table>" skip.
{html-end.i "stream m-out"}

output stream m-out close.

unix silent cptwin svsrok.html excel. 




