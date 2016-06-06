/* depport1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        15.01.2013 evseev ТЗ-1626
 * BASES
        BANK
 * CHANGES
*/

{mainhead.i}

def var v-gl as char init "2203,2204,2205,2206,2207,2215,2217,2219,2223,2240,2707,2719,2721,2723,2237".

def var v-sectorname as char extent 19 init
    ["Физические лица",
    "Сельское хозяйство",
    "Горнодобывающая промышленность",
    "Продукты питания",
    "Производство",
    "Электроэнергетика",
    "Строительство",
    "Торговля",
    "Транспортировка",
    "Связь",
    "Финансовые услуги",
    "Недвижимость",
    "Гостиничный и ресторанный бизнес",
    "Профессиональные услуги",
    "Туризм",
    "Образование",
    "Медицинские услуги",
    "Некоммерческие организации",
    "Прочее"].

def var v-oked as char extent 19 init
    ["00,0,9991",
    "01,02,03",
    "05,06,07,08,09",
    "10,11,12",
    "13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33",
    "35",
    "41,42,43",
    "45,46,47",
    "49,50,51,52,53",
    "61",
    "64,65,66",
    "68,77",
    "55,56,92,93",
    "69,70,71,72,73,74,75",
    "79",
    "85",
    "86",
    "87,88",
    "36,37,38,39,58,59,60,62,63,78,80,81,82,84,90,91,94,95,96,97,98,99,9992"].

def var v-amt as deci extent 19 init [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].
def var v-allamt as deci init 0.
def var v-percent as deci extent 19 init [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].


def var v-tenge as logi.
def var v-print1  as logi.

/*Переменные****************************************************/
def new shared var v-gllist  as char.
def new shared var v-isdialog  as logi.
def new shared var v-print  as logi.
def new shared var v-headgl  as logi.
def new shared var v-okedall as char init "".

def new shared var vasof  as date.
def new shared var vasof2 like vasof.
def new shared var v-crc  like crc.crc.
def new shared var vglacc as char format "x(6)".
def new shared var v-withprc as logi.
def new shared var v-withzero as logi.
/***************************************************************/

/*Временные таблицы*********************************************/
def new shared temp-table t-gl /*временная таблица для сбора данных по счетам ГК*/
	field gl like gl.gl /*счет ГК*/
	field des like gl.des /*Название ГК*/
	index gl is primary unique gl.

def new shared temp-table t-glcrc
	field gl like gl.gl /*счет ГК*/
	field crc like crc.crc /*Валюта*/
	field amt as dec format "zzz,zzz,zzz,zzz.99-" /*сумма в валюте счета, зависит от валюты*/
	field amtkzt as dec format "zzz,zzz,zzz,zzz.99-" /*Сумма в валюте счета конвертированная в тенге*/
	index gl is primary gl.

def new shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
	field gl  like t-gl.gl  /*счет ГК*/
	field acc like aaa.aaa  /*субсчет ГК*/
	field cif as char format "x(20)"  /*Название клиента*/
    field rnn as char format "x(12)"  /*РНН*/
	field geo as char format "x(3)"  /*ГЕО код*/
	field crc like crc.crc  /*валюта субсчета*/
	field ecdivis like sub-cod.ccode /*сектор отраслей экономики клиента*/
	field secek like sub-cod.ccode /*сектор экономики клиента*/ /* 31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel. TZ690.*/
	field rdt like aaa.regdt /*дата открытия счета*/
	field duedt like arp.duedt /*дата закрытия счета*/

    field rdt1 as char /*пролонгация счета*/
    field duedt1 as char /*окончание действия счета*/

    field rate like aaa.rate /*процентная ставка по счету, если есть*/

    field opnamt like t-glcrc.amt /*сумма по договору*/

	field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
	field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/
	field kurs like crchis.rate[1] /*курс конвертации*/
    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field des as char
    field attrib as char /*признак bnkrel*/
    field uslov as char /*услоние обслуживания*/
    field osnov as char /*основание*/
    field clnsegm as char /* код сегментации */
    /*field krate like accr.rate ставка по счету на день загрузки отчета*/
	index gl is primary gl.
/***************************************************************/

v-gllist = v-gl.
v-isdialog = no.
vglacc = "".
v-withprc = yes.
v-withzero = no.
v-crc = 1.
v-headgl = no.

vasof2 = today.
vasof = today.

v-print = no.
v-tenge = yes.
update vasof label "Дата за" validate (vasof <> ? and vasof <= vasof2, "Неверная дата!") skip
           v-print label "Расшифровка" skip
           v-tenge label "В тенге/тыс. тенге"
           with row 9 centered no-box side-labels frame vasfff. /*вводим дату отчета*/

def var i as int.
do i = 1 to 19:
   if v-okedall <> "" then v-okedall = v-okedall + ",".
   v-okedall = v-okedall + v-oked[i].
end.

run r-salde0.


output to t-acc-delete.csv.
for each t-acc:
    if lookup(t-acc.ecdivis,v-okedall) = 0 then do:
       export delimiter ';' t-acc.
       delete t-acc.
    end.
end.

output to t-acc.csv.
for each t-acc.
  export delimiter ';' t-acc.
  v-allamt = v-allamt +  t-acc.lev2kzt + t-acc.amtkzt.
end.

do i = 1 to 19:
   for each t-acc:
      if lookup(t-acc.ecdivis,v-oked[i]) > 0 then v-amt[i] = v-amt[i] + t-acc.lev2kzt + t-acc.amtkzt.
   end.
   v-percent[i] = v-amt[i] * 100 / v-allamt.
end.

output to t-acc1.csv.
do i = 1 to 19:
  export delimiter ';' v-sectorname[i] replace(trim(string(v-amt[i],"->>>>>>>>>>>>>>>9.99")), ".", ",") replace(trim(string(v-percent[i],"->>>>>>>>>>>>>>>9.99999")), ".", ",") .
end.


output to value ("depport.htm").
{html-title.i}
put unformatted "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""50%"">" skip.

put unformatted
       "<tr><TD> </TD>
       <td> </td>"
       "<td>" vasof "</td>"
       "</tr>" skip.
put unformatted
       "<tr><TD> </TD>
       <td> Сумма</td>"
       "<td> %</td>"
       "</tr>" skip.

do i = 1 to 19:
   if v-tenge then
       put unformatted
           "<tr><TD>"  v-sectorname[i] "</TD>
           <td>" replace(trim(string(v-amt[i],"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
           "<td>" replace(trim(string(v-percent[i],"->>>>>>>>>>>>>>>9.99999")), ".", ",") "</td>"
           "</tr>" skip.
   else
       put unformatted
           "<tr><TD>"  v-sectorname[i] "</TD>
           <td>" replace(trim(string(v-amt[i] / 1000,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
           "<td>" replace(trim(string(v-percent[i],"->>>>>>>>>>>>>>>9.99999")), ".", ",") "</td>"
           "</tr>" skip.
end.

if v-tenge then
    put unformatted
           "<tr><TD>Итого</TD>
           <td> " replace(trim(string(v-allamt,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
           "<td> 100</td>"
           "</tr>" skip.
else
    put unformatted
           "<tr><TD>Итого</TD>
           <td> " replace(trim(string(v-allamt / 1000,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>"
           "<td> 100</td>"
           "</tr>" skip.

put unformatted "</table>" skip.

{html-end.i " "}
output close .
hide all.
unix silent cptwin value("depport.htm") excel.