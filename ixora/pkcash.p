/* pkcash.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Список задолжников для кассиров по БД и БК
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-16
 * AUTHOR
        05.11.2003 marinav
 * CHANGES
        13.12.2003 nadejda - вынесла формирование временной таблицы в pkcash.i для использования в pkletter.p
        01.02.2004 nadejda - добавлен контактный телефон
                             сумма на тек.счете
        10.02.2004 nadejda - добавлена дата открытия и дата окончания ссудного счета
        13.05.2004 tsoy    - Показываем синим цветом тех задолжников которые являются работниками наших клиентов
        14.06.2004 tsoy    - Изменил имя выходного файла
        18/06/2004 madiyar - Добавил возможность проверки конкретного клиента, вместо формирования полного списка
        18/08/2004 madiyar - Добавил колонку "статус"
        19/08/2004 madiyar - Забыл раскомментировать cptwin
        07/09/2004 madiyar - Добавил колонку "Примечание"
        08/09/2004 madiyar - Изменил оформление отчета
        14.09.2004 saltanat - Для клиентов с плат. карточками меняем фон в наименовании на желтый.
        20.09.2004 saltanat - включила дисконект базы Cards.
        30.09.2004 saltanat - включила проверку на статус карточки
        06/10/2004 madiyar - перекомпиляция
        03/02/2005 madiyar - по двум проблемным клиентам - выделяем строку красным цветом
        31/03/2005 madiyar - автоматическая смена статусов анкет по всем филиалам при запуске в головном до 10:30 утра
        13/06/2005 madiyar - три новые колонки (проц. ставка, ставка по штрафам, задолженность по комиссии)
        07/09/2005 madiyar - переделал с использованием таблицы londebt
        04/10/2005 madiyar - для ускорения переделал проверку клиент/не клиент
        01/11/2005 madiyar - Добавил внебаланс
        10/02/2006 madiyar - добавилась обработка результата "leg" - передан в Юридический департамент
        09/03/2006 Natalya D. - добавила поля по начисленным за балансом % и штрафам (bal4 & bal5)
        16/05/2006 madiyar - добавил статус "Z" - списанные за баланс
        03/08/2006 madiyar - добавил no-undo
        25/05/2007 madiyar - убрал лишнее (проверка по карточной базе, по рнн-у работодателя)
        24/02/2009 galina - добавила поля комиссионный долг в тенге, комиссионный долг в валюте кредита, валюта кредита
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

{mainhead.i}
{pk.i new}
{pk-sysc.i}

def var coun as int no-undo init 1.
def var v-jobrnn as char no-undo.

define variable datums as date no-undo format "99/99/9999" label "На".
define variable sumbil as decimal no-undo format "->,>>>,>>9.99".
def var tempgrp as int no-undo.
def var v-sel as char no-undo.
def var v-cif as char no-undo init ''.

datums = g-today.

define frame fr skip(1)
       v-cif label " Введите код клиента " skip
       with side-labels centered.

run sel2 (" Выбор: ", " 1. Информация по конкретному клиенту | 2. Полный список задолжников | 3. Выход ", output v-sel).
case v-sel:
  when '1' then update v-cif with frame fr.
  when '2' then do:
    v-cif = '*'.
    message " Формирование списка задолжников на сегодняшний день...".
  end.
  when '3' then return.
  otherwise return.
end case.

/* 31/03/2005 madiyar - автоматическая смена статусов анкет по всем филиалам при запуске в головном до 10:30 утра */

if s-ourbank = "txb00" and time < 37800 then do:
  def buffer b-pkanketa for pkanketa.
  for each pkanketa where pkanketa.sts = '10' or pkanketa.sts = '03' or pkanketa.sts = '04' no-lock:
    if pkanketa.sts = '03' and g-today - pkanketa.rdt >= 7 then do:
      find b-pkanketa where b-pkanketa.bank = pkanketa.bank and b-pkanketa.credtype = pkanketa.credtype and b-pkanketa.ln = pkanketa.ln and b-pkanketa.rdt = pkanketa.rdt exclusive-lock.
      b-pkanketa.sts = '00'.
      find current b-pkanketa no-lock.
    end.
    if pkanketa.sts <> '03' and g-today - pkanketa.rdt >= 14 then do: /* статусы 04 и 10 */
      find b-pkanketa where b-pkanketa.bank = pkanketa.bank and b-pkanketa.credtype = pkanketa.credtype and b-pkanketa.ln = pkanketa.ln and b-pkanketa.rdt = pkanketa.rdt exclusive-lock.
      b-pkanketa.sts = '15'.
      find current b-pkanketa no-lock.
    end.
  end.
end.

/* 31/03/2005 madiyar - end */

{pkcash.i &param = "londebt.cif matches v-cif"}


for each wrk:
  if wrk.bal13 + wrk.bal14 + wrk.bal30 > 0 then wrk.sts = "Z".
  else do:
    find last lnsch where lnsch.lnn = wrk.lon and lnsch.stdat < datums and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then do:

       find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = wrk.lon and pkdebtdat.rdt >= (datums - wrk.dt1) and pkdebtdat.rdt <= datums use-index lonrdt no-lock no-error.
       if avail pkdebtdat then do:
             wrk.sts = "K".

            find last pkdebtdat where pkdebtdat.bank = s-ourbank
                                      and pkdebtdat.lon = wrk.lon
                                      and pkdebtdat.rdt >= (datums - wrk.dt1)
                                      and pkdebtdat.rdt <= datums
                                      and (pkdebtdat.result = "part" or pkdebtdat.result = "secu" or pkdebtdat.result = "leg") use-index lonrdt no-lock no-error.
              if avail pkdebtdat then do:
                    if pkdebtdat.result = "part" then wrk.sts = "K,P".
                    else if pkdebtdat.result = "secu" then wrk.sts = "K,S".
                    else if pkdebtdat.result = "leg" then wrk.sts = "K,L".
              end.
       end.
       else wrk.sts = "N".
    end.
  end.
end.

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rptpkcash.html.

{html-title.i &title = "TEXAKABANK" &stream = "stream m-out" &size-add = "x-"}

put stream m-out unformatted
  "<TABLE border=""0"" cellpadding=""10"" cellspacing=""0""><TR><TD align=""left"">" cmp.name "</TD></TR>" skip.


put stream m-out unformatted
  "<TR><TD align=""center""><h3>Задолженность по ссудным счетам клиентов за " string(datums)
                 "<BR><BR></h3></TD></TR>" skip.

put stream m-out unformatted
  "<TR><TD><table border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold; font-size:xx-small; bgcolor:#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Валюта кредита</td>"
                  "<td>Задол-ть в<BR>валюте кредита <br>(без штрафов и комиссий в тенге)</td>"
                  "<td>Пеня</td>"
                  "<td>Внебаланс<BR>(штрафы)</td>"
                  "<td>Начисленные штрафы<BR>за балансом</td>"
                  "<td>Задол-ть по ком.<BR>за вед. счета в тенге</td>"
                  "<td>Задол-ть по ком.<BR>за вед. счета в валюте кредита</td>"
                  "<td>%<BR>ставка</td>"
                  "<td>Cтавка по<BR>штрафам</td>"
                  "<td>Ежемес<BR>платеж</td>"
                  "<td>Дней<BR>просрочки</td>"
                  "<td>Просрочка<BR>%</td>"
                  "<td>Просрочка<BR>ОД</td>"
                  "<td>Внебаланс<BR>(ОД)</td>"
                  "<td>Внебаланс<BR>(%)</td>"
                  "<td>Начисленные % <BR>за балансом</td>"
                  "<td>День расчета<br>(ежемес.взноса)</td>"
                  "<td>Вид<BR>кредита</td>"
                  "<td>Статус</td>" skip
                  "<td>Примечание</td></tr>" skip.
sumbil = 0.

for each wrk where wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.bal13 + wrk.com_acc + wrk.bal14 + wrk.bal30 > 0.
        put stream m-out unformatted
           "<tr align=""right"" " if wrk.cif = "T42501" or wrk.cif = "T42496" then "style=""COLOR: red;""" else "" ">"
               "<td align=""center"">" coun "</td>"
               "<td align=""left"">" wrk.name "</td>"
               "<td align=""left"">" wrk.crc "</td>"
               "<td style=""font:bold"">" replace(trim(string(wrk.bal2 + wrk.bal3 + wrk.com_acc + wrk.bal13 + wrk.bal14, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(wrk.bal1, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(wrk.bal30, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(wrk.bal5, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td style=""font:bold"">" replace(trim(string(wrk.com_acckzt, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.com_acc, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td >" replace(trim(string(wrk.prem, "->9.99")),".",",") "</td>"
               "<td >" replace(trim(string(wrk.pen_prc, "->9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.balmon, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" wrk.dt1 format "->>>9" "</td>"
               "<td>" replace(trim(string(wrk.bal2, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal3, "->>>>>>>>>>>9.99")),".",",") "</td>"


               "<td>" replace(trim(string(wrk.bal13, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal14, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td>" replace(trim(string(wrk.bal4, "->>>>>>>>>>>9.99")),".",",") "</td>"
               "<td align=""center"">" wrk.day "</td>"
               "<td align=""left"">" wrk.stype format "x(30)" "</td>"
               "<td align=""left"">" wrk.sts "</td>"
               "<td align=""left"">" wrk.note "</td>"
               "</tr>" skip.
         coun = coun + 1.
end.

put stream m-out unformatted "</table></TD></TR></TABLE>" skip.

{html-end.i "stream m-out"}

output stream m-out close.

unix silent cptwin rptpkcash.html excel.
pause 0.


