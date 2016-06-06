/* r-klasif-nb.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Классификация кредитного портфеля для НБРК
 * RUN
        r-klasif-nb
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT

 * INHERIT
        r-klasif-nb2(input datums)
 * MENU
        3-4-16-2
 * BASES
        BANK COMM
 * AUTHOR
        23.06.2011 aigul
 * CHANGES
        04.07.2011 aigul - добавила комменты - описание переменных и алгоритма
        21.07.2011 kapar - вывод данных из excel
*/


def shared var g-today as date.
def var i as int no-undo.
define variable datums as date no-undo format '99/99/9999' label 'На'.
datums = g-today.
update datums label ' На дату' format '99/99/9999' skip
       with side-label row 5 centered frame dat.

def new shared temp-table wrk no-undo
    field num as inte /*нумерация*/
    field fcode as int /*код филиала*/
    field fil as char /*филиал*/
    field cif as char /*номер клиента*/
    field cname as char /*наименование клиента*/
    field org as char /*ТОО,ИП,ФЛ*/
    field lontype as char /*группа кредита - наименование*/
    field seco as char /*шифр экономики*/
    field rez as char  /*резид*/
    field inside as char /*нумерация*/
    field sign as char /*признак однородности*/
    field contr as char /*номер контракта*/
    field grp as  int /*группа кредита*/
    field issuedt as date /*дата регистр кредита*/
    field rpaydt as date /*дата погашения*/
    field perc-rate as decimal /*процентная ставка*/
    field crc as int /*валюта кредита*/
    field crccode as char /*валюта кредита - наименование*/
    field acc as char /*счет по НПС*/
    field lon as char /*номер кредита*/
    field od as decimal /*ОД*/
    field exp-od as decimal /*просрочен ОД*/
    field perc as decimal /*проценты*/
    field exp-perc as decimal /*просрочен проценты*/
    field sup-sum as decimal /*сумма обеспечения*/
    field sup-char as char /*описание обеспечения*/
    field rpayod as char /*условия погашения ОД*/
    field rpayperc as char /*условия погашения процентов*/
    field categ as char /*классификация - категория*/
    field provi-sum as decimal /*сумма провизий*/
    field fin as decimal /*фин сост*/
    field exp-pay as decimal /*просрочка платежей*/
    field sup-qual as decimal /*качесчтво обеспечен*/
    field shr as decimal /*доля нецелев использ*/
    field rate as decimal /*наличие рейтинга*/
    field totball as char /*итого баллов*/
    field rezid as char /*гео код*/
    field scode as char /*сектор экономики*/
    field val as char /*опред валюты*/
    field rel as char /*связ/не связ лицо*/
    field sup-sum-kzt as decimal.
def var v-cur  as deci no-undo init 1.
def var v-curd as deci no-undo.
def var v-cure as deci no-undo.
def var v-curr as deci no-undo.
if datums = g-today then do:
  find first crc where crc.crc = 2 no-lock no-error.
  if avail crc then v-curd = crc.rate[1].
  find first crc where crc.crc = 3 no-lock no-error.
  if avail crc then v-cure = crc.rate[1].
  find first crc where crc.crc = 4 no-lock no-error.
  if avail crc then v-curr = crc.rate[1].
end.

if datums < g-today then do:
  find last crchis where crchis.crc = 2 and crchis.rdt < datums no-lock no-error.
  if avail crchis then v-curd = crchis.rate[1].
  find last crchis where crchis.crc = 3 and crchis.rdt < datums no-lock no-error.
  if avail crchis then v-cure = crchis.rate[1].
  find last crchis where crchis.crc = 4 and crchis.rdt < datums no-lock no-error.
  if avail crchis then v-curr = crchis.rate[1].
end.

def new shared temp-table list
    field dt as date
    field fcode as int
    field fil as char
    field lon as char
    field fin as decimal
    field exp-pay as decimal
    field sup-qual as decimal
    field shr as decimal
    field rate as decimal
    field total as char
index ind is primary fcode lon.
def var LINE as char.
def var v-file as char.

v-file = '/data/temp/' + substr(string(datums),1,2) + substr(string(datums),4,2) + substr(string(datums),7,2) + ".csv".
if v-file <> "" then do:
    /*message v-file view-as alert-box.*/
    input from value(v-file).
    LOOP:
         REPEAT ON ENDKEY UNDO, LEAVE LOOP:
         IMPORT LINE.
         create list.
         list.dt = datums.
         list.fcode = int(entry(2,LINE,";")).
         list.lon = entry(3,LINE,";").
         list.fin = decimal(replace(entry(4,LINE,";"),",",".")).
         list.exp-pay = decimal(replace(entry(5,LINE,";"),",",".")).
         list.sup-qual = decimal(replace(entry(6,LINE,";"),",",".")).
         list.shr = decimal(replace(entry(7,LINE,";"),",",".")).
         list.rate = decimal(replace(entry(8,LINE,";"),",",".")).
         list.total = entry(9,LINE,";").
    END.
end.

{r-brfilial.i &proc = "r-klasif-nb2(input datums)"}

find first wrk no-lock no-error.
if not avail wrk then return.

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

put stream m-out unformatted "<html><head><title>METROCOMBANK</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.


put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<tr><td><h3>Классификация (расшифровка) ссудного портфеля для НБ РК на " string(datums) "</h3></td></tr><br><br>" skip(1).

put stream m-out unformatted "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
    "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>П/п</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Филиал</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Наименование заемщика</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Организ. правовая форма</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Вид кредита по программе банка</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Сектор эк-ки</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Резидентство</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Инсайдер(связанный с банком особ. отнош.)</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Признак однородности</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Номер кредитного договора</td>"
    /*"<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Группа кредита</td>"*/
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Дата</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>% ставка</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Валюта выдачи</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Счет по НПС</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>№ ссудного счета </td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Основной долг</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Просроченный основной долг</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Начисленные вознаграждения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Просроченные вознаграждения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=3>Обеспечение</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Условия погашения по срокам</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=2>Классификация</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" colspan=5>Баллы</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"" rowspan=2>Итого баллов</td></tr>" skip.

put stream m-out unformatted "<tr style=""font:bold"">"
    "<td bgcolor=""#C0C0C0"" align=""center"">выдачи</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">погашения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В валюте займа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В тенге</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В валюте займа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В тенге</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В валюте займа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В тенге</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В валюте займа</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">В тенге</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Сумма в валюте</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Сумма в тенге</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Характеристика</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Основного долга</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Вознаграждения</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Категория</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">Сумма провизий</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">1 - фин. состояние</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">2 - проср. платежей</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">3 - кач. обесп.</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">4 - доля нецелевого исп.</td>"
    "<td bgcolor=""#C0C0C0"" align=""center"">5 - наличие рейтинга</td></tr>" skip.
    i = 0.
for each wrk no-lock break by wrk.fil:
    find crc where crc.crc = wrk.crc no-lock no-error.

      v-cur = 1.
      if wrk.crc = 2 then v-cur = v-curd.
      if wrk.crc = 3 then v-cur = v-cure.
      if wrk.crc = 4 then v-cur = v-curr.

    i = i + 1.
    put stream m-out unformatted "<tr align=""right"">"
    "<td align=""center""> " i "</td>"
    "<td align=""center""> " wrk.fil "</td>"
    "<td align=""center""> " wrk.cname "</td>"
    "<td align=""center""> " wrk.org "</td>"
    "<td align=""center""> " wrk.lontype "</td>"
    "<td align=""center""> " wrk.seco "</td>"
    "<td align=""center""> " wrk.rez "</td>"
    "<td align=""center""> " wrk.inside "</td>"
    "<td align=""center""> " wrk.sign "</td>"
    "<td align=""center""> '" wrk.contr "</td>"
    /*"<td align=""center""> " wrk.grp "</td>"*/
    "<td align=""center""> " wrk.issuedt "</td>"
    "<td align=""center""> " wrk.rpaydt "</td>"
    "<td align=""center""> '" wrk.perc-rate "</td>"
    "<td align=""center""> " wrk.crccode "</td>"
    "<td align=""center""> " wrk.acc "</td>"
    "<td align=""center""> " wrk.lon "</td>"
    "<td align=""center""> " replace(trim(string(wrk.od,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.od * v-cur,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.exp-od,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.exp-od * v-cur,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.perc,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.perc * v-cur,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.exp-perc,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.exp-perc * v-cur,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.sup-sum,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.sup-sum-kzt,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " wrk.sup-char "</td>"
    "<td align=""center""> " wrk.rpayod "</td>"
    "<td align=""center""> " wrk.rpayperc "</td>"
    "<td align=""center""> " wrk.categ "</td>"
    "<td align=""center""> " replace(trim(string(wrk.provi-sum,">>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.fin,"->>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.exp-pay,"->>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.sup-qual,"->>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.shr,"->>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " replace(trim(string(wrk.rate,"->>>>>>>>>>>>>>>>>9.99")),'.',',') "</td>"
    "<td align=""center""> " wrk.totball "</td></tr>" skip.
end.
put stream m-out unformatted "</table>" skip.
output stream m-out close.
unix silent cptwin rpt.html excel.exe.
