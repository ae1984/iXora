/* rpvoz_r.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Расходы по вознаграждениям (Приложение №14 к Декларации)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        03.03.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        11.03.2011 ruslan прописал базы
        11.03.2011 подправил порядковый номер
        15/02/2012 dmitriy - закомментировал отображение ИИН-БИН после 01.01.2012
*/

{global.i}

def var v-dt1 as date.
def var v-dt2 as date.
def stream rep.
def var v-ofile as char no-undo.
def var the_end as date init 01/01/2012.
def var ii as int init 1.

def new shared temp-table t-data
    field bank as char
    field voz_sum as deci
    field nname as char
    field rrn as char
    field bin as char
    field geo as char
    field t-branch as char
    field priznak as char init "НЕТ"
    index idx is primary bank nname.

v-dt1 = 01/01/2010.
v-dt2 = 12/31/2010.

update v-dt1 label "С" validate(v-dt1 <> '', "Введите дату") with side-labels overlay centered row 13 frame fr.
update v-dt2 label "По" validate(v-dt2 <> '', "Введите дату") with frame fr.

{r-brfilial.i &proc = "rpvoz(input v-dt1, v-dt2)"}

v-ofile = "rep.htm".

output stream rep to value(v-ofile).

    put stream rep unformatted
    "<head>
     <META http-equiv=""content-type"" content=""text/html; charset=windows-1251"">
     </head>
     <table border =1>
     <th colspan=9>Расходы по вознаграждениям (Приложение №14 к Декларации)</th>
     <tr>
      <td nowrap valign=bottom> № пп </td>
      <td nowrap valign=bottom> Наименование филиала </td>
      <td nowrap colspan=2 valign=bottom> Получатель  вознаграждения </td>
      <td nowrap colspan=3 valign=bottom> Регистрационные данные </td>
      <td nowrap valign=bottom> Сумма выплаченного вознаграждения в тенге </td>
      <td nowrap valign=bottom> Признак связанности сторон </td>
     </tr>
     <tr>
      <td nowrap valign=bottom>  </td>
      <td valign=bottom>  </td>
      <td valign=bottom> Наименование резидента </td>
      <td valign=bottom> Наименование нерезидента </td>
      <td valign=bottom> РНН резидента (с 01.01. 2012г. ИИН/БИН) </td>
      <td valign=bottom> ИНН нерезидента </td>
      <td valign=bottom> Страна нерезидента </td>
      <td nowrap valign=bottom>   </td>
      <td width=96 valign=bottom>   </td>
     </tr>
     <tr>
      <td nowrap valign=bottom> 1 </td>
      <td nowrap valign=bottom> 2 </td>
      <td nowrap valign=bottom> 3 </td>
      <td nowrap valign=bottom> 4 </td>
      <td nowrap valign=bottom> 5 </td>
      <td nowrap valign=bottom> 6 </td>
      <td nowrap valign=bottom> 7 </td>
      <td nowrap valign=bottom> 8 </td>
      <td nowrap valign=bottom> 9 </td>
     </tr>
    </table>" skip.

for each t-data no-lock:
    put stream rep unformatted
    "<table border = 1>"
    "<tr>" skip
    "<td>" ii "</td>" skip
    "<td>" t-data.t-branch "</td>" skip.
    if t-data.geo = "021" then put stream rep unformatted "<td>" t-data.nname "</td> <td> </td>" skip.
    else put stream rep unformatted "<td>" "</td> <td>" t-data.nname "</td>" skip.
    /*if today >= the_end then put stream rep unformatted "<td>&nbsp;" t-data.bin "</td>" skip.
    else*/ put stream rep unformatted "<td>&nbsp;" t-data.rrn "</td>" skip.
    ii = ii + 1.
    put stream rep unformatted
    "<td> </td>" skip
    "<td> </td>" skip
    "<td>" replace(replace(string(t-data.voz_sum, "->>>,>>>,>>>,>>9.99"),","," "),".",",")"</td>" skip
    "<td>" t-data.priznak "</td>" skip
    "</tr></table>" skip.
end.

output stream rep close.

unix silent value("cptwin " + v-ofile + " excel").
unix silent value("rm -r " + v-ofile).
