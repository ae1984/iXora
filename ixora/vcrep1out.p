/* vcrep1out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 1 - отчет о платежах по контрактам, где нет рег/свид-ва
        Вывод временной таблицы в IE или Excel
 * RUN

 * CALLER
        vcrep1.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        28.04.2008 galina
 * CHANGES
        29.04.2008 galina - добавлено указание баз в описание
        04.05.2008 galina - дясятичный разделитель ","
                            вывод РНН не в числовом формате
        27.05.2008 galina - изменения для загрузки отчета в АИС "Статистика"
        04.07.2008 galina - добавлен пробел перед кодом операции
        02/11/2009 galina - изменения по суммам согласно ТЗ 577 от 29/10/2009
                            добавила БИН
        22/12/2009 galina - добавила БИН/ИИН в файл для Статистики
        02/11/2010 galina - добавила коды новые операции 16 и 17 добавила столбцы э/и и тип контракта
        24.07.2012 damir  - добавил p-bank,funcvc.i,vcrecda.i,изменение формата Приложения,выводимого в WORD.

        */

{vc.i}

{global.i}
{funcvc.i}

def input parameter p-filename  as char.
def input parameter p-printbank as logi.
def input parameter p-bankname  as char.
def input parameter p-printdep  as logi.
def input parameter p-depname   as char.
def input parameter p-printall  as logi.
def input parameter p-bank      as char.

def shared temp-table t-docs
  field dndate like vcdocs.dndate
  field docs like vcdocs.docs
  field opertype as char
  field sum like vcdocs.sum
  field name like cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as char
  field rnn as char format "999999999999"
  field secek as char
  field country as char
  field rnnben as char format "999999999999"
  field secekben as char
  field countryben as char
  field strsum as char
  field locat as char
  field locatben as char
  field note as char
  field bin as char
  field expimp as char
  field cttype as char
  index main is primary dndate sum docs.

def shared var v-god    as inte format "9999".
def shared var v-month  as inte format "99".
def shared var v-dtb    as date.
def shared var v-dte    as date.

def var v-name          as char no-undo.
def var v-title         as char no-undo.
def var i               as inte no-undo.
def var v-monthname     as char init "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-countrybenK   as char.
def var v-countryK      as char.
def var v-txbbank       as char.
def var v-bnkbin        as char.
def var v-str           as char.

def stream vcrpt.
output stream vcrpt to value(p-filename).

find first cmp no-lock no-error.

{vcrecda.i}

{html-title.i
&stream = " stream vcrpt "
&size-add = "xx-"
&title = " Приложение 2 "}

if p-printall then do:
    put stream vcrpt unformatted
        "<B>" skip
        "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
        "ПРИЛОЖЕНИЕ 2<BR>"
        "к Правилам осуществления валютных операций в Республике Казахстан<BR>"
        "</I></FONT></P>" skip
        "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
        "Отчет о платежах и и (или) переводах денег <br> по валютным операциям, проведенным по поручениям&nbsp;(в пользу)&nbsp;
        клиентов-резидентов <br> за&nbsp;" string(month(v-dte),"99") + "&nbsp;месяц&nbsp;" + string(year(v-dte),"9999")
        "&nbsp;года</FONT></P>" skip
        "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
        "<P align=left>Наименование уполномоченного банка:&nbsp;" v-txbbank "</P>" skip.

    /*if p-printbank then put stream vcrpt unformatted
        "<BR>" + p-bankname skip.
    if p-printdep then put stream vcrpt unformatted
        ",&nbsp;" + p-depname.

    put stream vcrpt unformatted
        "</P><P align = ""center"">" skip
        "за " + entry(v-month, v-monthname) + " "
        string(v-god, "9999") + " года</P></FONT></B>" skip.*/
end.
else put stream vcrpt unformatted
    "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

if p-printall then do:
    put stream vcrpt unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

    put stream vcrpt unformatted
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD rowspan=""2"">N&nbsp;п/п</TD>" skip
        "<TD rowspan=""2"">Код операции</TD>" skip
        "<TD colspan=""6"">Отправитель/Иностранный банк</TD>" skip
        "<TD colspan=""6"">Бенефициар/Иностранный банк</TD>" skip
        "<TD colspan=""4"">Платеж/перевод</TD>" skip
        "<TD rowspan=""2"">Примечание</TD>" skip
        "<TD rowspan=""2"">Э/И</TD>" skip
        "<TD rowspan=""2"">Тип контракта</TD>" skip.


    put stream vcrpt unformatted
        "</TR>" skip
        "<TR align=""center"" style=""font:bold"">" skip
        "<TD>признак<BR>резидент<BR>ства</TD>" skip
        "<TD>Сектор<BR>экономики</TD>" skip
        "<TD>Наимено<BR>вание/ФИО</TD>" skip
        "<TD>ОКПО/РНН<BR>резидента</TD>" skip
        "<TD>БИН/ИИН<BR>резидента</TD>" skip
        "<TD>Страна</TD>" skip
        "<TD>признак<BR>резидент<BR>ства</TD>" skip
        "<TD>Сектор<BR>экономики</TD>" skip
        "<TD>Наимено<BR>вание/ФИО</TD>" skip
        "<TD>ОКПО/РНН<BR>резидента</TD>" skip
        "<TD>БИН/ИИН<BR>резидента</TD>" skip
        "<TD>Страна</TD>" skip
        "<TD>Дата</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Сумма<BR>платежа<BR>(в тысячах<BR>единиц валюты<BR>платежа)</TD>" skip
        "<TD>КНП</TD>" skip
        "</TR>" skip.
end.
else do:
    put stream vcrpt unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Код операции</TD>" skip
        "<TD>признак резидентства<BR>ства</TD>" skip
        "<TD>Сектор экономики</TD>" skip
        "<TD>Наименование/ФИО</TD>" skip
        "<TD>ОКПО/РНН резидента</TD>" skip
        "<TD>БИН/ИИН резидента</TD>" skip
        "<TD>Страна</TD>" skip
        "<TD>признак резидентства</TD>" skip
        "<TD>Сектор экономики</TD>" skip
        "<TD>Наименование/ФИО" skip
        "<TD>ОКПО/РНН резидента</TD>" skip
        "<TD>БИН/ИИН резидента</TD>" skip
        "<TD>Страна</TD>" skip
        "<TD>Дата</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Сумма платежа (в тысячах единиц валюты платежа)</TD>" skip
        "<TD>КНП</TD>" skip
        "<TD>Примечание</TD>" skip
        "</TR>" skip.
end.

i = 0.

for each t-docs no-lock:
    i = i + 1.
    find first code-st where code-st.code = t-docs.country no-lock no-error.
    if avail code-st then v-countryK = code-st.cod-ch.

    find first code-st where code-st.code = t-docs.countryben no-lock no-error.
    if avail code-st then v-countrybenK = code-st.cod-ch.

    find first ncrc where ncrc.code = t-docs.codval no-lock no-error.

    put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD>" i "</TD>" skip
        "<TD align=""center""> &nbsp;" t-docs.opertype "</TD>" skip
        "<TD align=""center"">"  t-docs.locat "</TD>"  skip
        "<TD align=""center"">"  t-docs.secek "</TD>"  skip
        "<TD>" t-docs.name "</TD>" skip
        "<TD> &nbsp;"  t-docs.rnn "</TD>"  skip.
    /*if p-printall then do:*/
    if t-docs.rnn <> '' then put stream vcrpt unformatted "<TD>&nbsp;"  t-docs.bin "</TD>"  skip.
    else  put stream vcrpt unformatted "<TD></TD>"  skip.
    /*end.    */
    put stream vcrpt unformatted
        "<TD>" if p-printall then t-docs.country
        else v-countryK
        "</TD>"  skip
        "<TD align=""center"">"  t-docs.locatben "</TD>" skip
        "<TD align=""center"">"  t-docs.secekben "</TD>"  skip
        "<TD>" t-docs.partner "</TD>" skip
        "<TD> &nbsp;"  t-docs.rnnben "</TD>"  skip.
    /*if p-printall then do:*/
    if t-docs.rnnben <> '' then put stream vcrpt unformatted "<TD>&nbsp;"  t-docs.bin "</TD>"  skip.
    else  put stream vcrpt unformatted "<TD></TD>"  skip.
    /*end.   */
    put stream vcrpt unformatted "<TD>"  if p-printall then t-docs.countryben
    else v-countrybenK
        "</TD>"  skip
        "<TD align=""center"">" string(t-docs.dndate, "99/99/99") "</TD>" skip
        "<TD align=""center"">" if p-printall then string(t-docs.codval, "999")
        else string(ncrc.stn, "zzz")
        "</TD>" skip
        "<TD align=""right"">"replace(t-docs.strsum,'.',',')"</TD>" skip
        "<TD align=""center"">" t-docs.knp "</TD>" skip
        "<TD>" t-docs.note "</TD>" skip.

    if p-printall then put stream vcrpt  unformatted
        "<TD align=""center"">" t-docs.expimp "</TD>" skip
        "<TD>" t-docs.cttype "</TD>" skip.

    put stream vcrpt unformatted
        "</TR>" skip.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

if month(g-today) = 1       then v-str = "января".
else if month(g-today) = 2  then v-str = "февраля".
else if month(g-today) = 3  then v-str = "марта".
else if month(g-today) = 4  then v-str = "апреля".
else if month(g-today) = 5  then v-str = "мая".
else if month(g-today) = 6  then v-str = "июня".
else if month(g-today) = 7  then v-str = "июля".
else if month(g-today) = 8  then v-str = "августа".
else if month(g-today) = 9  then v-str = "сентября".
else if month(g-today) = 10 then v-str = "октября".
else if month(g-today) = 11 then v-str = "ноября".
else if month(g-today) = 12 then v-str = "декабря".

if p-printall then do:
    find sysc where sysc.sysc = "mainbk" no-lock no-error.
    if avail sysc then v-name = trim(sysc.chval).
    else do:
        message "Нет сведений о главном бухгалтере!". pause 3.
        v-name = "".
    end.

    find ofc where ofc.ofc = g-ofc no-lock no-error.

    put stream vcrpt unformatted
        "<BR><BR>" skip
        "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
        "Руководитель/Главный бухгалтер___________________" + v-name + "<BR><BR><BR>" skip
        "Исполнитель :___________________" + ofc.name + "&nbsp;&nbsp;телефон&nbsp;&nbsp;" + string(ofc.tel[2],"999-999") + "<BR><BR>" skip
        '<' + string(day(g-today),"99") + '>&nbsp;' + v-str + "&nbsp;" + string(year(g-today), "9999") + "&nbsp; года<BR>" skip
        "</B></FONT></P>" skip.
end.

{html-end.i}


output stream vcrpt close.

if p-printall then
    unix silent value("cptwin " + p-filename + " iexplore").
else
    unix silent value("cptwin " + p-filename + " excel").

pause 0.
