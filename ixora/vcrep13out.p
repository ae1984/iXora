/* vcrep13out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 13 - отчет о платежах по контрактам, где есть рег/свид-ва
        Вывод временной таблицы в IE или Excel
 * RUN

 * CALLER
        vcrep13.p
 * SCRIPT

 * INHERIT

 * MENU
        15.4.x.1
 * AUTHOR
        04.11.2002 nadejda создан
 * BASES
        BANK COMM
 * CHANGES
        22.08.2003 nadejda - изменения в связи с новой формой отчета от 11.08.2003 по письму НБ РК - добавлены признаки резидентства и убраны сведения о контракте
        02.09.2003 nadejda - пока нет изменения АИС "Статистика", признаки резидентства для передачи в Oracle пишутся перед наименованием
        05.01.2004 nataly  - был изменен вывод признаков сектора экономики для отправителя денег и бенефециара
        06.02.2004 nadejda - убран признак резидентства из наименования клиента и бенефициара
        20.01.2006 u00600  - изменения в связи с новыми требованиями Нац.Банка
        24.04.2008 galina - приложение переименовано в ПРИЛОЖЕНИЕ 3
        29.04.2008 galina - выводим буквенный код валюты платежа
        04.05.2008 galina - дясятичный разделитель ","
        27.05.2008 galina - изменения для загружения в АИС "Статистика"
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
  field sum like vcdocs.sum
  field docs like vcdocs.docs
  field dnrslc like vcrslc.dnnum
  field name like cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as char
  field ctnum like vccontrs.ctnum
  field ctdate like vccontrs.ctdate
  field rnn as char format "999999999999"
  field strsum as char
  field locat as char
  field locatben as char
  field note as char
  index main is primary dndate sum docs.

def shared var v-god    as inte format "9999".
def shared var v-month  as inte format "99".
def shared var v-dtb    as date.
def shared var v-dte    as date.

def var v-name      as char no-undo.
def var v-title     as char no-undo.
def var i           as integer no-undo.
def var v-monthname as char init "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-txbbank   as char.
def var v-bnkbin    as char.
def var v-str       as char.

def stream vcrpt.
output stream vcrpt to value(p-filename).
/*disp value(p-filename).*/

{vcrecda.i}

find first cmp no-lock no-error.

{html-title.i
&stream = " stream vcrpt "
&size-add = "xx-"
&title = " Приложение 4 " }

if p-printall then do:
    put stream vcrpt unformatted
        "<B>" skip
        "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
        "ПРИЛОЖЕНИЕ 4<BR>"
        "к Правилам осуществления валютных операций в Республике Казахстан<BR>"
        "</I></FONT></P>" skip
        "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
        "Отчет о платежах и (или) переводах денег, <br> осуществленных по валютным договорам, на которые были выданы регистрационные
        свидетельства и <br> свидетельства об уведомлении <br> за&nbsp;" string(month(v-dte),"99") + "&nbsp;месяц&nbsp;" + string(year(v-dte),"9999")
        "&nbsp;года</FONT></P>"
        "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
        "<P align=left>Наименование <U><FONT color=""#FF0000""> уполномоченного </FONT></U> банка:&nbsp;" v-txbbank "</P>" skip.

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
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD rowspan=""2"">N&nbsp;п/п</TD>" skip
        "<TD rowspan=""2"">Номер<BR>регистраци<BR>онного свиде<BR>тельства/свиде<BR>тельства об уведомлении</TD>" skip
        "<TD colspan=""2"">Отправитель денег</TD>" skip
        "<TD colspan=""2"">Бенефициар</TD>" skip
        "<TD rowspan=""2"">КНП</TD>" skip
        "<TD rowspan=""2"">Дата<BR>платежа</TD>" skip
        "<TD rowspan=""2"">Валюта<BR>платежа</TD>" skip
        "<TD rowspan=""2"">Сумма<BR>платежа<BR>(в тысячах<BR>единиц валюты<BR>платежа)</TD>" skip
        "<TD rowspan=""2"">Примечание</TD>" skip.

    put stream vcrpt unformatted
        "</TR>" skip
        "<TR align=""center"" style=""font:bold"">" skip
        "<TD>признак<BR>резидент<BR>ства</TD>" skip
        "<TD>Наимено<BR>вание/ФИО </TD>" skip
        "<TD>признак<BR>резидент<BR>ства</TD>" skip
        "<TD>Наимено<BR>вание/ФИО</TD>" skip
        "</TR>" skip.
end.
else do:
    put stream vcrpt unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Номер регистрационного свидетельства/свидетельства об уведомлении</TD>" skip
        "<TD>признак резидентства отправителя</TD>" skip
        "<TD>Наименование отправителя денег/ФИО</TD>" skip
        "<TD>признак резидентства бенефициара</TD>" skip
        "<TD>Наименование бенефициара/ФИО</TD>" skip
        "<TD>КНП</TD>" skip
        "<TD>Дата платежа</TD>" skip
        "<TD>Валюта платежа</TD>" skip
        "<TD>Сумма платежа (тыс.)</TD>" skip
        "<TD>Примечание</TD>" skip
        "</TR>" skip.
end.

i = 0.

for each t-docs no-lock:
    i = i + 1.
    find first ncrc where ncrc.code = t-docs.codval no-lock no-error.

    put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD>" i "</TD>" skip
        "<TD>" t-docs.dnrslc "</TD>" skip
        "<TD align=""center"">"  t-docs.locat "</TD>"  skip
        "<TD>" t-docs.name "</TD>" skip
        "<TD align=""center"">"  t-docs.locatben "</TD>" skip
        "<TD>" t-docs.partner "</TD>" skip
        "<TD align=""center"">" t-docs.knp "</TD>" skip
        "<TD align=""center"">" string(t-docs.dndate, "99/99/99") "</TD>" skip
        "<TD align=""center"">" if p-printall then string(t-docs.codval, "999")
        else string(ncrc.stn, "zzz")
        "</TD>" skip
        "<TD align=""right"">"replace(t-docs.strsum,'.',',')"</TD>" skip
        "<TD>" t-docs.note "</TD>" skip.

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
