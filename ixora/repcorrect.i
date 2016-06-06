/* repcorrect.i
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/


{html-title.i
 &stream = " stream vcrep "
 &size-add = "xx-"
 &title = " Приложение 1 "
}

if p-printall then do:
    put stream vcrep unformatted
        "<B>" skip
        "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
        "ПРИЛОЖЕНИЕ 4<BR>"
        "к Правилам осуществления экспортно-импортного валютного контроля в Республике Казахстан<BR>"
        "</I></FONT></P>" skip
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
        "Информация об исполнении обязательств по паспортам сделок</FONT></P>"
        "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
        "Наименование банка: <U>"  cmp.name "</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        "код ОКПО: <U>" substr (cmp.addr[3], 1, 8) "</U>" skip.

    if p-printbank then
    put stream vcrep unformatted
         "<BR>" + p-bankname skip.
    if p-printdep then
    put stream vcrep unformatted
         ",&nbsp;" + p-depname.

    put stream vcrep unformatted
        "</P><P align = ""center"">" skip
        "за " + entry(v-month, v-monthname) + " "
        string(v-god, "9999") + " года</P></FONT></B>" skip.
end.
else put stream vcrep unformatted "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

put stream vcrep unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
    "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
    "<TD rowspan=""3"">№</TD>" skip
    "<TD colspan=""2"">Реквизиты<br>действующего<br>паспорта сделки</TD>" skip
    "<TD colspan=""7"">Отправитель денег</TD>" skip
    "<TD colspan=""7"">Бенефициар</TD>" skip
    "<TD colspan=""7"">Информация о платеже и (или) переводе денег или ином исполнении обязательств</TD>" skip
    "<TD colspan=""2"">В случае переноса сумм на новый паспорт сделки</TD>" skip
    "<TD rowspan=""3"">Корректировка</TD>" skip.

put stream vcrep unformatted
    "</TR>" skip
    "<TR align=""center"" style=""font:bold"">" skip
    "<TD rowspan=""2"">№</TD>" skip
    "<TD rowspan=""2"">Дата</TD>" skip
    "<TD rowspan=""2"">Наименование<BR>или<BR>фамилия, имя, отчество</TD>" skip
    "<TD rowspan=""2"">Код<BR>ОКПО</TD>" skip
    "<TD rowspan=""2"">РНН</TD>" skip
    "<TD rowspan=""2"">Признак-<BR>юридическое<BR>лицо или<BR>физическое<BR>лицо</TD>" skip
    "<TD rowspan=""2"">Страна</TD>" skip
    "<TD rowspan=""2"">Код<BR>области</TD>" skip
    "<TD rowspan=""2"">Код<BR>резидент<BR>ства</TD>" skip
    "<TD rowspan=""2"">Наименование<BR>или<BR>фамилия, имя, отчество</TD>" skip
    "<TD rowspan=""2"">Код<BR>ОКПО</TD>" skip
    "<TD rowspan=""2"">РНН</TD>" skip
    "<TD rowspan=""2"">Признак-<BR>юридическое<BR>лицо или<BR>физическое<BR>лицо</TD>" skip
    "<TD rowspan=""2"">Страна</TD>" skip
    "<TD rowspan=""2"">Код<BR>области</TD>" skip
    "<TD rowspan=""2"">Код<BR>резидент<BR>ства</TD>" skip
    "<TD rowspan=""2"">Дата</TD>" skip
    "<TD rowspan=""2"">Сумма<BR>в тысячах единиц</TD>" skip
    "<TD rowspan=""2"">Валюта<BR>расчетов</TD>" skip
    "<TD rowspan=""2"">Код способа<BR>расчетов</TD>" skip
    "<TD rowspan=""2"">Признак-<BR>исходящий,<BR>входящий</TD>" skip
    "<TD colspan=""2"">Основание для зачета<BR>или уступки<BR>или иного<BR>исполнения</TD>" skip
    "<TD rowspan=""2"">Дата нового<BR>паспорта сделки</TD>" skip
    "<TD rowspan=""2"">Номер нового<BR>паспорта сделки</TD>" skip
    "</TR>" skip.

put stream vcrep unformatted
    "</TR>" skip
    "<TR align=""center"" style=""font:bold"">" skip
    "<TD>№</TD>" skip
    "<TD>Дата</TD>" skip
    "</TR>" skip.

i = 0.
for each t-docscorr no-lock:
    i = i + 1.
    put stream vcrep unformatted
        "<TR valign=""top"">" skip
        "<TD>" i                                     "</TD>" skip
        "<TD>" t-docscorr.psnum                      "</TD>" skip
        "<TD>" string(t-docscorr.psdate, "99/99/99") "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" t-docscorr.countryotp "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" t-docscorr.countryben "</TD>" skip
        "<TD></TD>"  skip
        "<TD></TD>"  skip.
    if t-docscorr.dndate <> ? then put stream vcrep unformatted "<TD>" string(t-docscorr.dndate, "99/99/99") "</TD>" skip.
    else put stream vcrep unformatted "<TD></TD>"  skip.
    if t-docscorr.sum <> 0 then put stream vcrep unformatted "<TD>" replace(string(t-docscorr.sum),".",",") "</TD>" skip.
    else put stream vcrep unformatted "<TD></TD>"  skip.
    put stream vcrep unformatted
        "<TD>" t-docscorr.pcrc   "</TD>" skip
        "<TD>" t-docscorr.kod14  "</TD>" skip
        "<TD>" t-docscorr.dntype "</TD>" skip
        "<TD>" t-docscorr.numdc  "</TD>"  skip.
    if t-docscorr.datedc <> ? then put stream vcrep unformatted "<TD>" string(t-docscorr.datedc, "99/99/99") "</TD>"  skip.
    else put stream vcrep unformatted "<TD></TD>"  skip.
    if t-docscorr.datenewps <> ? then put stream vcrep unformatted "<TD>" string(t-docscorr.datenewps, "99/99/99") "</TD>"  skip.
    else put stream vcrep unformatted "<TD></TD>"  skip.
    put stream vcrep unformatted
        "<TD>" t-docscorr.numnewps "</TD>"  skip
        "<TD>" t-docscorr.corr     "</TD>"  skip.
    put stream vcrep unformatted
        "</TR>" skip.
end.

put stream vcrep unformatted
    "</TABLE>" skip.

if p-printall then do:
    find sysc where sysc.sysc = "mainbk" no-lock no-error.
    if avail sysc then v-name = trim(sysc.chval).
    else do:
        message "Нет сведений о главном бухгалтере!". pause 3.
        v-name = "".
    end.

    find ofc where ofc.ofc = g-ofc no-lock no-error.

    put stream vcrep unformatted
    "<BR><BR>" skip
    "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
    "Главный бухгалтер " cmp.name " _________________________ " +
    v-name + "<BR><BR><BR>" skip
    "Исполнитель :  _________________________ "  + ofc.name + "<BR>" skip
    "тел.  " + string(ofc.tel[2], "999-999") + "<BR><BR>" skip
    string(g-today, "99/99/9999") + "<BR>" skip
    "</B></FONT></P>" skip.
end.

{html-end.i}

output stream vcrep close.


