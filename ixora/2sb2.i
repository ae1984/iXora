/* fsb2.i
 * MODULE
        Статистика
 * DESCRIPTION
        Банковские займы, выданные в тенге и иностранной валюте с указанием ставок вознаграждения по ним
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
 * BASES
        BANK COMM
 * AUTHOR

 * CHANGES
        10/09/09 aigul - добавила МСБ
        23/09/09 kapar - ТЗ1142
*/

put stream vcrpt unformatted
 "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR style=""font:bold;"" align=""center"">" skip

    "<td width=""17%"" rowspan=""3""> </td>" skip
    "<td width=""17%"" rowspan=""3""> Шифр<br>строки</td>" skip
    "<td width=""41%"" colspan=""6"">" skip
    "<p align=""center"">Юридическим лицам в валюте</td>" skip
    "<td width=""42%"" colspan=""6"">" skip
    "<p align=""center"">Физическим лицам в валюте</td>" skip
 " </tr>" skip
 " <tr style=""font:bold;"">" skip
    "<td width=""14%"" colspan=""2"" align=""center"">национальной</td>" skip
    "<td width=""14%"" colspan=""2"" align=""center"">свободно-<br>контролируемой</td>" skip
    "<td width=""13%"" colspan=""2"" align=""center"">других виды валют</td>" skip
    "<td width=""14%"" colspan=""2"" align=""center"">национальной</td>" skip
    "<td width=""14%"" colspan=""2"" align=""center"">свободно-<br>контролируемой</td>" skip
    "<td width=""13%"" colspan=""2"" align=""center"">других виды валют</td>" skip
  "</tr>" skip
  "<tr style=""font:bold;"">" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
    "<td width=""7%"" align=""center"">сумма</td>" skip
    "<td width=""7%"" align=""center"">средне<br>взвешенная<br>ставка<br>вознаг<br>раждения,<br>%</td>" skip
  "</tr>" skip.
