﻿/* pkspis.p
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
        22.12.2003 nadejda - сообщение типа "Ждите"
        05.02.2004 nadejda - изменены форматы выдачи
        06.04.2004 tsoy    - убрал валюту добавил РНН организации
        08.07.2004 tsoy    - убрал Срок кот. был два раза
        08.07.2004 tsoy    - добавил место работы
        14.09.2004 saltanat - добавила выделение желтым фоном клиентов с плат. картами
        20.09.2004 saltanat - включила дисконект базы Cards.
        30.09.2004 saltanat - включила проверку на статус карточки
        03/11/2004 madiyar - добавил поле gl в wrk
        03/03/2005 madiyar - добавил поле pen_prem (ставка по штрафам)
        14/10/2005 madiyar - добавил колонку "должность"
        29/09/2006 madiyar - добавил колонку "банк"
        03/04/2007 madiyar - добавил дату след. оплаты %%, убрал обращения к базе cards
        05.09.2008 galina - выводить консолидированный отчет только для ЦО
        22/04/2010 madiyar - рнн и название организации, должность - из анкеты
*/


{mainhead.i}

def new shared var d1 as date.
def var coun as int no-undo init 1.
def var cnt as decimal no-undo extent 8.
def var prc as decimal no-undo extent 4.
def var srk as decimal no-undo extent 14.
def var vsrk as decimal no-undo init 0.

prc[1] = 0. prc[2] = 0.

def new shared temp-table wrk no-undo
    field bank   as char
    field credtype as char
    field lon    like bank.lon.lon
    field grp   like  bank.lon.grp
    field name   like bank.cif.name
    field gua    like bank.lon.gua
    field amoun  like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field bal% like bank.lon.opnamt
    field balans7 like bank.lon.opnamt
    field bal%9 like bank.lon.opnamt
    field bal%10 like bank.lon.opnamt
    field balanst like bank.lon.opnamt
    field akkr like bank.lon.opnamt
    field garan like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field pen_prem as deci
    field dt1    like bank.lon.rdt
    field dt2    like bank.lon.rdt
    field dt3    like bank.lon.rdt
    field dt4    like bank.lon.rdt
    field grsum as deci
    field grsum% as deci
    field duedt  like bank.lon.rdt
    field rez    like bank.lonstat.prc
    field srez   like bank.lon.opnamt
    field zalog  like bank.lon.opnamt
    field srok   as deci
    field gl     like bank.gl.gl
    field orgrnn as char
    field orgname as char
    field orgposition as char
    index main is primary crc desc balans desc.

    /*для долларов*/
       cnt[1] = 0.   /*заявленная*/
       cnt[2] = 0.   /*реальная*/
       cnt[3] = 0.   /**/
   /*для тенге*/
       cnt[4] = 0.
       cnt[5] = 0.
       cnt[6] = 0.

d1 = today.
update d1 label " На дату" format "99/99/9999"
    skip with side-label row 5 centered frame dat .

define stream m-out.
output stream m-out to rpt.html.
put stream m-out "<html><head><title>METROCOMBANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

output stream m-out close.

message " Формирование кредитного портфеля на" d1 "..." .

{r-brfilial.i &proc = "pkspis2 (d1)"}

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.rdt < d1 no-lock no-error.

define stream m-out.
output stream m-out to rpt.html append.

{html-title.i &stream = "stream m-out" &size-add = "x-"}

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">"   skip.

put stream m-out  unformatted "<tr align=""left""><td><h3>Кредитный портфель на "
                 string(d1) "</h3></td></tr><br><br>"
                 skip(1).
 put stream m-out  unformatted "<br><br><tr></tr>" skip.


       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr bgcolor=""#C0C0C0"" align=""center"" style=""font:bold"">" skip
                  "<td>П/п</td>" skip
                  "<td>Вид кредита</td>" skip
                  "<td>Наименование заемщика</td>" skip
                  "<td>Одобренная сумма</td>" skip
                  "<td>Сумма остатка займа</td>" skip
                  "<td>Сумма процентов</td>" skip
                  "<td>Сумма просроч<BR>займа</td>" skip
                  "<td>Сумма просроч<BR>процентов</td>" skip
                  "<td>Предоплата процентов</td>" skip
                  "<td>Сумма на текущем счете</td>" skip
/*                  "<td>Валюта</td>" skip*/
                  "<td>% ставка</td>" skip
                  "<td>Ставка по штрафам</td>" skip
                  "<td>Дата выдачи займа</td>" skip
                  "<td>Дата последней <br> проплаты</td>" skip
                  "<td>Дата след.проплаты ОД по гр</td>" skip
                  "<td>Сумма след.проплаты ОД</td>" skip
                  "<td>Дата след.проплаты % по гр</td>" skip
                  "<td>Сумма след.проплаты %</td>" skip
                  "<td>Дата погашения займа</td>" skip
                  "<td>Обеспечение </td>" skip
                  "<td>Фонд покрытия<br> кред рисков %</td>" skip
                  "<td>Сумма фонда</td>" skip
                  "<td>Срок</td>" skip
                  "<td>РНН места работы</td>" skip
                  "<td>Место работы</td>" skip
                  "<td>Должность</td>" skip
                  "<td>Счет ГК</td></tr>" skip.

for each wrk break by wrk.crc desc by wrk.balans desc.
   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.

   /*
   v-rnn = ''. v-joborg = ''. v-position = ''.
   find first lon where lon.lon = wrk.lon no-lock no-error.
   if avail lon then do:
       find cif where cif.cif = lon.cif no-lock no-error.
       if avail cif then do:
            if cif.item <> "" then do:
              v-rnn = entry(1, cif.item, "|").
            end.

            v-joborg = cif.ref[8].
            v-position = cif.sufix.

       end.
   end.
   */

   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">" wrk.credtype "</td>"
               "<td align=""left""" /* if card_color(cif.jss) then " bgcolor = ""#FFC972"" " else "" */ ">" wrk.name "</td>"
               "<td>" replace(trim(string(wrk.amoun, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balans, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal%, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balans7, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal%9, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal%10, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balanst, ">>>>>>>>>>>9.99")),".",",") "</td>" skip
/*               "<td>" bank.crc.code "</td>"*/
               "<td>" replace(trim(string(wrk.prem, ">9.99")),".",",") "%</td>"
               "<td>" replace(trim(string(wrk.pen_prem, ">9.99")),".",",") "%</td>"
               "<td>" wrk.dt1 "</td>"
               "<td>" wrk.dt2 "</td>"
               "<td>" wrk.dt3 "</td>"
               "<td>" replace(trim(string(wrk.grsum, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt4 "</td>"
               "<td>" replace(trim(string(wrk.grsum%, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.duedt "</td>"
               "<td>" replace(trim(string(wrk.zalog, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.rez, ">>9.99")),".",",") "%</td>"
               "<td>" replace(trim(string(wrk.srez, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.srok, "->>>9")),".",",") "</td>"
               "<td>&nbsp;" wrk.orgrnn "</td>"
               "<td>" wrk.orgname "</td>" skip
               "<td>" wrk.orgposition "</td>" skip
               "<td>" wrk.gl  "</td>" skip
               "</tr>" skip.


    if wrk.crc = 2 then do:
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       cnt[7] = cnt[7] + wrk.balans7 * wrk.prem.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       prc[4] = prc[4] + wrk.balans * wrk.srok.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if wrk.crc = 1 then do:
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       cnt[8] = cnt[8] + wrk.balans7.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       prc[3] = prc[3] + wrk.balans / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if last-of (wrk.crc) then do:
        put stream m-out unformatted "<tr align=""rigth"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td></td><td></td>"
               "<td><b> " replace(trim(string(cnt[3], "->>>>>>>>>>>9.99")),".",",") "</b></td>"
               "<td></td><td><b>" replace(trim(string(cnt[8], "->>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td><b> " replace(trim(string(cnt[6], ">>>>>>>>>>>9.99")),".",",") "</b></td><td></td><td></td><td></td><td></td>"
               "</tr>" skip.
        cnt[3] = 0. cnt[6] = 0.
    end.

    coun = coun + 1.

end.
put stream m-out unformatted "<tr></tr><tr></tr><tr></tr></table>" skip.

/*
output stream m-out close.



define stream m-out.
output stream m-out to rpt.html append.
*/

put stream m-out unformatted
                 "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""><br><tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО В ДОЛЛАРАХ США </b></td> "
                 "<td align=""right""><b> " replace(trim(string(cnt[1], ">>>>>>>>>>>9.99")),".",",") "</b></td> "
                 "<td align=""right""><b> " replace(trim(string(cnt[2], ">>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b> " replace(trim(string(prc[1] / cnt[2], ">9.99")),".",",") "%</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</td></tr>" skip.

put stream m-out
                 "<br><tr align=""left"">"
                 "<td></td><td></td><td><b> ИТОГО В ТЕНГЕ </b></td>"
                 "<td align=""right""><b> " replace(trim(string(cnt[4], ">>>>>>>>>>>9.99")),".",",") "</b></td> "
                 "<td align=""right""><b>" replace(trim(string(cnt[5], ">>>>>>>>>>>9.99")),".",",") "</b></td>"
                 "<td align=""right""><b> " replace(trim(string(prc[2] / cnt[5], ">9.99")),".",",") "%</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</table></td></tr>" skip.

{html-end.i "stream m-out"}
output stream m-out close.

unix silent cptwin rpt.html excel.

pause 0.

