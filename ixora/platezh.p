/* platezh.p
 * MODULE
        Электронная версия перевода
 * DESCRIPTION
        Электронная версия перевода
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27/05/08 marinav - добавление поля РНН
        28/05/08 marinav
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор


*/
{nbankBik.i}
def stream vcrpt.
output stream vcrpt to rpt.html.
def var v-crc as char.
def var v-sum as char.
def input parameter v-nomer as char. /* Номер выплаченного перевода */

find first translat where translat.nomer = v-nomer  no-lock no-error.
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

  put stream vcrpt unformatted "<p align=""right""><FONT size=""1""> Приложение 5 к Инструкции по осуществлению денежных <br> переводов
        по поручению  физических лиц без открытия <br> текущих счетов между <br> " + v-nbankru + " и ЗАО ""МЕТРОБАНК"" <br>
        введенной в действие протоколом Правления Банка <br> от ""__""________2005  года <br> N___Рег. N ____  </p>".
  put stream vcrpt unformatted "<p align=""center""><b><U> ПОДТВЕРЖДЕНИЕ ПЕРЕВОДА от  " + string(date) + "</U></b></p>" skip.

 find spr_bank where spr_bank.code = translat.rec-code no-lock no-error.

 find crc where crc.crc = translat.crc no-lock no-error.
 if avail crc then v-crc = crc.code.

run sumprop(translat.summa,translat.crc, output v-sum).

put stream vcrpt unformatted
   "<TABLE width=""75%"" border=""0"" cellspacing=""0"" cellpadding=""3"">" skip
   "<TR align=""left"">" skip
     "<TD width=""40%""><FONT size=""1""><B>Фамилия Отправителя: </B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.fam " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Имя Отправителя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.name " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Отчество Отправителя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.otch " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Документ, удостоверяющий личность Отправителя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.type-doc " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>серия, номер:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.series + " "  + translat.nom-doc " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>выдан (кем, когда):</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.vid-doc + " "  + string(translat.dt-doc) " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>адрес Отправителя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.addres " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>телефон Отправителя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.tel " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Фамилия Получателя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.rec-fam " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Имя Получателя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.rec-name " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Отчество Получателя:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.rec-otch " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Банк Получателя/Филиал:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" spr_bank.name " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма перевода</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.summa " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

  "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Код валюты</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" v-crc "</B></FONT></TD>"
     "<TD width=""40%"" > <table cellpadding=""2""><tr><B><td>Доллары США</b></td> <td> USD*</td></tr>
                                                   <tr><b><td>Евро       </b></td> <td> EUR</td></tr>
                                                   <tr><b><td>Рубли      </b></td> <td> RUR</td></tr> </table>  (проставляется только валюта перевода)  </TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма прописью:</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" v-sum  " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip

   "<TR align=""left"">" skip
     "<TD width=""40%"" ><FONT size=""1""><B>Сумма комиссии в валюте перевода</B></FONT></TD>" skip
     "<TD width=""40%"" ><FONT size=""1""><B>" translat.commis " </B></FONT></TD>" skip
     "<TD width=""40%"" ></TD></TR>" skip.

put stream vcrpt unformatted
  "</TABLE>" skip.

  put stream vcrpt unformatted "<p align=""left""><b><U> Уникальный Контрольный Номер перевода (УКН):  " translat.nomer  "</U></b> </p><br><br> " .
  put stream vcrpt unformatted "<p align=""left""><b>   Отправитель самостоятельно уведомляет Получателя о сумме и контрольном номере  перевода.<br>
     Невостребованная Получателем сумма перевода подлежит возврату в Банк Отправителя по истечению 30 (тридцати) календарных дней с даты
     приема Заявления на отправление перевода.
     Сумма оплаченной комиссии возврату не подлежит.<br>
     Я подтверждаю, что  cовершаемая операция не связана с осуществлением предпринимательской и  инвестиционной деятельности
   или приобретением прав на недвижимое имущество, с иными операциями, связанными с движением капитала,
   а также оплатой контрактов между юридическими лицами в качестве третьего лица. </b></p><br>"  .

  put stream vcrpt unformatted "<p align=""left"">Дата ____________________          Подпись ________________ </p><br><br> " .

  put stream vcrpt unformatted "<p align=""left""><b><U> *Подтверждение перевода не действыительно без приходного ордера и печати/подписи кассира </U></b></p><br><br> " .

  put stream vcrpt unformatted "<p align=""right"">    Печать кассира  _________    Подпись кассира   _______ </p><br><br> " .

{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin rpt.html  winword").
pause 0.
return.



