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
*/
put stream vcrpt unformatted
 "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip

    "<td width=""17%"" rowspan=""3""> Шифр строки</td>" skip
    "<td width=""41%"" colspan=""12"">" skip
    "<p align=""center"">Юридическим лицам в валюте</td>" skip
    "<td width=""42%"" colspan=""12"">" skip
    "<p align=""center"">Физическим лицам в валюте</td>" skip
 " </tr>" skip
 " <tr>" skip
    "<td width=""14%"" colspan=""4"" align=""center"">национальной</td>" skip
    "<td width=""14%"" colspan=""4"" align=""center"">СКВ</td>" skip
    "<td width=""13%"" colspan=""4"" align=""center"">ОКВ</td>" skip
    "<td width=""14%"" colspan=""4"" align=""center"">национальной</td>" skip
    "<td width=""14%"" colspan=""4"" align=""center"">СКВ</td>" skip
    "<td width=""13%"" colspan=""4"" align=""center"">ОКВ</td>" skip
  "</tr>" skip
  "<tr>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
    "<td width=""7%"" align=""center"">Сумма</td>" skip
    "<td width=""7%"" align=""center"">%%</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ Сумма</td>" skip
    "<td width=""7%"" align=""center"">в.т.ч МСБ %%</td>" skip
  "</tr>" skip.
