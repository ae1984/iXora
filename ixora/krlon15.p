/* krlon15.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        28/01/04 nataly был добавлен признак отрасли
        30/05/2005 madiar - добавил поля "Выбрать до" и "Ответственный менеджер"
        28/12/2010 evseev - добавил поля Филиал, Номер соглашения, Тип лимита (возобновляемый или не возобновляемый), Одобренная сумма лимита,
                            Одобренная сумма лимита в тенге, а так же изменил ряд названий столбцов
        06/01/2011 evseev - дробные части прописывались через запятую, вместо точки.
        14/01/2011 evseev - дробные части прописывались через запятую, вместо точки. исправил ошибки в формате
                            Изменил наименование поля "Выбрать до" на "Период доступности".
        17/01/2011 evseev - добавил "'" в поле Номер соглашения
        14/02/2011 madiyar - подправил расчет
        31.10.2013 evseev - tz1744
*/


def shared var g-today as date.
def var crlf as char.
def var coun as int init 1.
define variable datums  as date format '99/99/9999' label 'На'.

datums = g-today.
update datums label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

crlf = chr(10) + chr(13).

def new shared temp-table  wrk
    field filial as char
    field lon    like bank.lon.lon
    field gua    as char
    field ecdivis  as  char
    field crc    like bank.lon.crc
    field cif    like bank.lon.cif
    field name   like bank.cif.name
    field lcnt   like bank.loncon.lcnt
    field typelimit as char
    field bal    like bank.lon.opnamt
    field opnamt like bank.lon.opnamt
    field duedt  like bank.lon.duedt
    field dt_do  as   date init ?
    field who    as   char
    field rdt  as   date .

def var v-am as decimal init 0.

run krlon1(input datums).

define stream m-out.
output stream m-out to rpt15.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.


put stream m-out "<tr align=""center""><td><h3>Суммы на внебал. по ссудным счетам клиентов за " string(datums)
                 "</h3></td></tr><br><br>" skip.

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Код клиента</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер <br> соглашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Тип лимита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Вид</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная <br> сумма лимита</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная <br> сумма лимита <br> в тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доступная сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Доступная сумма <br> в тенге</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата начала</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата окончания</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Отрасль экономики</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Период доступности</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный</td>"
                  "</tr>" skip.

v-am = 0.
for each wrk break by wrk.cif desc.

  find last crchis where crchis.crc = wrk.crc and crchis.regdt le datums no-lock no-error.

        put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>" /*Пп*/
               "<td align=""center"">" wrk.filial "</td>" /*Филиал*/
               "<td align=""left"">" wrk.cif "</td>" /*Код клиента*/
               "<td align=""left"">" wrk.name format "x(60)" "</td>" /*Наименование заемщика*/
               "<td align=""center"">" "`" wrk.lcnt "</td>" /*Номер соглашения*/
               "<td align=""center"">" wrk.typelimit "</td>" /*Тип лимита*/
               "<td align=""left"">" "`" wrk.lon "</td>" /*Ссудный счет*/
               "<td align=""left"">" wrk.gua "</td>" /*Вид*/
               "<td align=""left"">" crchis.code "</td>" /*Валюта*/
               "<td>" replace( string(wrk.opnamt),'.',',') format "x(17)" "</td>" /*Одобренная сумма лимита*/
               "<td>" replace( string(wrk.opnamt * crchis.rate[1]),'.',',') format "x(17)" "</td>" /*Одобренная сумма лимита в тенге*/
               "<td>" replace( string(wrk.bal),'.',',') format "x(17)" "</td>" /*доступная сумма*/
               "<td>" replace( string(wrk.bal * crchis.rate[1]),'.',',') format "x(17)" "</td>" /*доступная сумма в тенге*/
               "<td>" wrk.rdt "</td>" /*дата начала*/
               "<td>" wrk.duedt "</td>" /*дата окончания*/
               "<td>" wrk.ecdivis "</td>" /*отраслб экономики*/
               "<td>" wrk.dt_do format "99/99/9999" "</td>" /*выбрать до ->   Период доступности*/
               "<td>" wrk.who "</td>" /*Ответственный*/
               "</tr>" skip.
         v-am = v-am + wrk.bal * crchis.rate[1].
         coun = coun + 1.
end.
put stream m-out unformatted "<tr align=""left"">"
                 "<td></td> <td></td><td><b> ИТОГО </b></td> <td></td> <td></td> <td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
                 "<td align=""right""><b>" replace( string(v-am),'.',',') format "x(17)" "</b></td><br>" skip.

put stream m-out unformatted "</table>" skip.
output stream m-out close.

unix silent cptwin rpt15.html excel.exe.

