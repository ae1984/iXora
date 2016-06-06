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
        24.04.2008 galina  - приложение переименовано в ПРИЛОЖЕНИЕ 3
        29.04.2008 galina  - выводим буквенный код валюты платежа
        05.05.2008 galina  - изменения в согласно Правил ОВК от 11.12.2006 на состояние 25.06.2007
        27.05.2008 galina  - изменения для загрузки в АИС "Статистика"
        02/11/2009 galina  - выводим платежи физ.лиц без открытия в эквиваленте более 10 тыс.долларов
                             и с открытием в эквиваленте 50 тыс.долларов
                             добавила ИИН
        12/11/2009 galina  - перекомпеляция
        22/12/2009 galina  - добавила ИИН в файл для Статистики
        27/05/2010 galina  - выводим кнп в файл для статистики
        02.06.2011 aigul   - вывод отчета исходящих и входящих
        26.04.2012 aigul   - исправила вывод данных в отчет
        27.04.2012 aigul   - исправила ИНН на ИИН
        15.09.2012 damir   - изменения по формату Т.З. №1385.
        07.11.2012 damir   - корректировка наименования столбца. Изменения, относящиеся к Т.З. №1385.

*/

{vc.i}

{global.i}
{funcvc.i}

def input parameter p-filename  as char.
def input parameter p-printbank as logi.
def input parameter p-bankname  as char.
def input parameter p-printall  as logi.
def input parameter p-bank      as char.

def shared temp-table wrk-ish
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field crgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

def shared temp-table wrk-vh
    field bank      as char
    field rmz       as char
    field fio       as char
    field rez1      as char
    field rnn       as char
    field bin       as char
    field tranz     as char
    field knp       as char
    field dt        as date
    field acc       as char
    field fcrc      as char
    field amt       as decimal
    field usd-amt   as decimal
    field st        as char
    field rez2      as char
    field secK      as char
    field secK1     as char
    field bn        as char
    field drgl      as char
    field c-rmz     as char
    field dgk       as inte
    field cgk       as inte
    field clecod    as inte.

def shared var v-god    as integer format "9999".
def shared var v-month  as integer format "99".
def shared var v-pay    as integer.
def shared var v-dtb    as date.
def shared var v-dte    as date.

def var v-sum       as deci no-undo.
def var v-bank      as char.
def var v-mainbk    as char no-undo.
def var v-title     as char no-undo.
def var i           as inte no-undo.
def var j           as inte no-undo.
def var v-monthname as char init "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-txbbank   as char.
def var v-bnkbin    as char.
def var v-str       as char.

def buffer b-wrk-ish for wrk-ish.
def buffer b-wrk-vh for wrk-vh.

{vcrecda.i}

for each wrk-ish:
    find first b-wrk-ish where substr(b-wrk-ish.rnn,1,12) = substr(wrk-ish.rnn,1,12)  and b-wrk-ish.dt = wrk-ish.dt
    and b-wrk-ish.amt = wrk-ish.amt and b-wrk-ish.bank = "TXB00" exclusive-lock no-error.
    if avail b-wrk-ish then delete b-wrk-ish.
end.
for each wrk-vh:
    find first b-wrk-vh where substr(b-wrk-vh.rnn,1,12) = substr(wrk-vh.rnn,1,12)  and b-wrk-vh.dt = wrk-vh.dt
    and b-wrk-vh.amt = wrk-vh.amt and b-wrk-vh.bank = "TXB00" exclusive-lock no-error.
    if avail b-wrk-vh then delete b-wrk-vh.
end.

for each wrk-ish where (substr(string(wrk-ish.dgk),1,4) = "2870" or wrk-ish.dgk =   100100)
and (substr(string(wrk-ish.cgk),1,4) = "2203" or substr(string(wrk-ish.cgk),1,4) = "2204"
or substr(string(wrk-ish.cgk),1,4) = "2205" or substr(string(wrk-ish.cgk),1,4) = "2206"
or substr(string(wrk-ish.cgk),1,4) = "2207" or substr(string(wrk-ish.cgk),1,4) = "2215"
or substr(string(wrk-ish.cgk),1,4) = "2217" or substr(string(wrk-ish.cgk),1,4) = "2219"):
    delete wrk-ish.
end.
for each wrk-vh where (substr(string(wrk-vh.dgk),1,4) = "2870" or wrk-vh.dgk =   100100)
and (substr(string(wrk-vh.cgk),1,4) = "2203" or substr(string(wrk-vh.cgk),1,4) = "2204"
or substr(string(wrk-vh.cgk),1,4) = "2205" or substr(string(wrk-vh.cgk),1,4) = "2206"
or substr(string(wrk-vh.cgk),1,4) = "2207" or substr(string(wrk-vh.cgk),1,4) = "2215"
or substr(string(wrk-vh.cgk),1,4) = "2217" or substr(string(wrk-vh.cgk),1,4) = "2219"):
    delete wrk-vh.
end.
for each wrk-ish where (substr(string(wrk-ish.cgk),1,4) = "2870" or wrk-ish.cgk =   100100)
and (substr(string(wrk-ish.dgk),1,4) = "2203" or substr(string(wrk-ish.dgk),1,4) = "2204"
or substr(string(wrk-ish.dgk),1,4) = "2205" or substr(string(wrk-ish.dgk),1,4) = "2206"
or substr(string(wrk-ish.dgk),1,4) = "2207" or substr(string(wrk-ish.dgk),1,4) = "2215"
or substr(string(wrk-ish.dgk),1,4) = "2217" or substr(string(wrk-ish.dgk),1,4) = "2219"):
    delete wrk-ish.
end.
for each wrk-vh where (substr(string(wrk-vh.cgk),1,4) = "2870" or wrk-vh.cgk =   100100)
and (substr(string(wrk-vh.dgk),1,4) = "2203" or substr(string(wrk-vh.dgk),1,4) = "2204"
or substr(string(wrk-vh.dgk),1,4) = "2205" or substr(string(wrk-vh.dgk),1,4) = "2206"
or substr(string(wrk-vh.dgk),1,4) = "2207" or substr(string(wrk-vh.dgk),1,4) = "2215"
or substr(string(wrk-vh.dgk),1,4) = "2217" or substr(string(wrk-vh.dgk),1,4) = "2219"):
    delete wrk-vh.
end.
for each wrk-ish where (wrk-ish.dgk = 603600 and wrk-ish.cgk = 653600):
    delete wrk-ish.
end.
for each wrk-vh where (wrk-vh.dgk = 603600 and wrk-vh.cgk = 653600):
    delete wrk-vh.
end.

for each wrk-ish:
    find first b-wrk-ish where b-wrk-ish.rmz = wrk-ish.c-rmz  and b-wrk-ish.rmz <> wrk-ish.rmz exclusive-lock no-error.
    if avail b-wrk-ish then delete b-wrk-ish.
end.
for each wrk-vh:
    find first b-wrk-vh where b-wrk-vh.rmz = wrk-vh.c-rmz  and b-wrk-vh.rmz <> wrk-vh.rmz exclusive-lock no-error.
    if avail b-wrk-vh then delete b-wrk-vh.
end.
for each wrk-ish where wrk-ish.dgk = 287032 and wrk-ish.cgk = 135100:
    find first b-wrk-ish where b-wrk-ish.dgk = 100100 and b-wrk-ish.cgk = 287032 and b-wrk-ish.dt = wrk-ish.dt
    and b-wrk-ish.amt = wrk-ish.amt and (b-wrk-ish.rnn = wrk-ish.rnn or b-wrk-ish.fio = wrk-ish.fio) exclusive-lock no-error.
    if avail b-wrk-ish then delete b-wrk-ish.
end.
for each wrk-vh where wrk-vh.dgk = 287032 and wrk-vh.cgk = 135100:
    find first b-wrk-vh where b-wrk-vh.dgk = 100100 and b-wrk-vh.cgk = 287032 and b-wrk-vh.dt = wrk-vh.dt
    and b-wrk-vh.amt = wrk-vh.amt and (b-wrk-vh.rnn = wrk-vh.rnn or b-wrk-vh.fio = wrk-vh.fio) exclusive-lock no-error.
    if avail b-wrk-vh then delete b-wrk-vh.
end.

/*
for each wrk-ish:
    find first b-wrk-ish where b-wrk-ish.c-rmz = wrk-ish.c-rmz and b-wrk-ish.rmz <> wrk-ish.rmz exclusive-lock no-error.
    if avail b-wrk-ish  then delete wrk-ish.
end.
for each wrk-vh:
    find first b-wrk-vh where b-wrk-vh.c-rmz = wrk-vh.c-rmz and b-wrk-vh.rmz <> wrk-vh.rmz exclusive-lock no-error.
    if avail b-wrk-vh  then delete wrk-vh.
end.
*/

def stream vcrpt.
output stream vcrpt to value(p-filename).

find first cmp no-lock no-error.

{html-title.i
&stream = " stream vcrpt "
&size-add = "xx-"
&title = " Приложение 2 "
}

if p-printall then do:
    put stream vcrpt unformatted
       "<B>" skip
       "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
       "ПРИЛОЖЕНИЕ 3 <BR> к Правилам осуществления валютных операций в Республике Казахстан<BR></I></FONT></P>" skip
       "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
       "Отчет о платежах и (или) переводах денег, осуществленных физическими лицами по валютным операциям <br>
       за&nbsp;" string(month(v-dte),"99") + "&nbsp;месяц&nbsp;" + string(year(v-dte),"9999") "&nbsp;года</FONT></P>"
       "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
       "<P align=left>Наименование уполномоченного банка:&nbsp;" v-txbbank "</P>" skip.
end.
else put stream vcrpt unformatted
    "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

if p-printall and (v-pay = 1 or v-pay = 3) then do:
    put stream vcrpt unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD rowspan=""2"">N&nbsp;п/п</TD>" skip
        "<TD rowspan=""2"">N&nbsp;ГК и платежа</TD>" skip
        "<TD rowspan=""2"">Ф.И.О.<BR>отправителя<BR>(получателя) денег</TD>" skip
        "<TD rowspan=""2"">Признак<br>резидентства<br>отправителя<br>(получателя) денег</TD>" skip
        "<TD rowspan=""2"">РНН</TD>" skip
        "<TD rowspan=""2"">ИИН</TD>" skip
        "<TD rowspan=""2"">Признак<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">КНП</TD>" skip
        "<TD rowspan=""2"">Дата проведения<BR>платежа/перевода</TD>" skip
        "<TD rowspan=""2"">Код банка <br> или <br> код филиала <br> банка</TD>" skip
        "<TD rowspan=""2"">Валюта<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">Сумма,<BR>тысяч<BR>единиц<BR>валюты<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">Сумма,<BR>тысяч<BR>долларов<BR>США</TD>" skip
        "<TD rowspan=""2"">Страна<BR>получения<BR>(отправления)<BR>денег</TD>" skip
        "<TD colspan=""3"">Имеющаяся информация о получателе (отправителе) денег</TD>" skip.
    put stream vcrpt unformatted
        "</TR>" skip
        "<TR align=""center"" style=""font:bold"">" skip
        "<TD>резидентство</TD>" skip
        "<TD>сектор<BR>экономики</TD>" skip
        "<TD>ФИО физического лица<br>либо наименование<br>юридического лица</TD>" skip
        "</TR>" skip.
end.
if not p-printall then do:
    put stream vcrpt unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>Ф.И.О. отправителя (получателя) денег</TD>" skip
        "<TD>Признак резидентства отправителя (получателя) денег</TD>" skip
        "<TD>РНН физического лица</TD>" skip
        "<TD>ИИН физического лица</TD>" skip
        "<TD>Признак платежа/перевода</TD>" skip
        "<TD>Назначение платежа/перевода</TD>" skip
        "<TD>Дата проведения платежа/перевода</TD>" skip
        "<TD>Код банка <br> или <br> код филиала <br> банка</TD>" skip
        "<TD>Валюта платежа/перевода</TD>" skip
        "<TD>Сумма, тысяч единиц валюты платежа/перевода</TD>" skip
        "<TD>Сумма, тысяч долларов США</TD>" skip
        "<TD>Страна получения (отправления) денег</TD>" skip
        "<TD>резидентство</TD>" skip
        "<TD>сектор экономики</TD>" skip
        "<TD>Наименование/фамилия, имя, отчество</TD>" skip
        "</TR>" skip.
end.

i = 0.
if (v-pay = 1 or v-pay = 3) then do:
    for each wrk-ish break by wrk-ish.bank:
        if (wrk-ish.st = 'KZ') then next.
        if wrk-ish.secK1 <> "9" then next.
        /*if (wrk-ish.st = "" or wrk-ish.st = 'msc') then do:
            if wrk-ish.rez1 = '1' and wrk-ish.rez2 = '1' then next.
        end.*/
        if connected ("txb") then disconnect "txb".
        find comm.txb where comm.txb.consolid and comm.txb.bank = wrk-ish.bank no-lock no-error.
        if avail comm.txb then do:
          connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
          run vcbin(wrk-ish.bank, output v-bank).
        end.
        i = i + 1.
        if p-printall then do:
            if first-of(wrk-ish.bank) then do:
                put stream vcrpt  unformatted
                "<TR valign=""top"">" skip
                "<td>" v-bank "</td>" skip
                "<td>" "</td>"  skip
                "<td>" "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "</tr>" skip.
            end.
        end.
        put stream vcrpt  unformatted
        "<TR valign=""top"">" skip
        "<td>" i "</td>" skip.
        if p-printall then put stream vcrpt  unformatted "<td>" wrk-ish.dgk "-" wrk-ish.cgk "<br>" wrk-ish.crgl "</td>"  skip.
        put stream vcrpt  unformatted
        "<td>" wrk-ish.fio "</td>"  skip
        "<td>" wrk-ish.rez1 "</td>"  skip
        "<td> &nbsp;" wrk-ish.rnn "</td>"  skip
        "<td>&nbsp;" wrk-ish.bin "</td>"  skip.
        if p-printall then put stream vcrpt  unformatted "<td>" wrk-ish.tranz "</td>"  skip.
        else put stream vcrpt  unformatted "<td>" 1 "</td>"  skip.
        put stream vcrpt  unformatted
        "<td>" wrk-ish.knp "</td>"  skip
        "<td>" wrk-ish.dt "</td>"  skip
        "<td>" string(wrk-ish.clecod) "</td>"  skip
        "<td>" wrk-ish.fcrc "</td>"  skip
        "<td>" replace(trim(string(wrk-ish.amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(wrk-ish.usd-amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" wrk-ish.st "</td>" skip
        "<td>" wrk-ish.rez2 "</td>" skip
        "<td>" wrk-ish.secK "</td>" skip
        "<td>" wrk-ish.bn "</td>" skip
        "</tr>" skip.
	end.
end.

if p-printall then put stream vcrpt unformatted
    "</table>".

if p-printall and (v-pay = 2 or v-pay = 3) then do:
    put stream vcrpt unformatted
        "<br><br>"
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
        "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
        "<TD rowspan=""2"">N&nbsp;п/п</TD>" skip
        "<TD rowspan=""2"">N&nbsp;ГК и платежа</TD>" skip
        "<TD rowspan=""2"">Ф.И.О.<BR>отправителя<BR>(получателя) денег</TD>" skip
        "<TD rowspan=""2"">Признак<br>резидентства<br>отправителя<br>(получателя) денег</TD>" skip
        "<TD rowspan=""2"">РНН</TD>" skip
        "<TD rowspan=""2"">ИИН</TD>" skip
        "<TD rowspan=""2"">Признак<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">КНП</TD>" skip
        "<TD rowspan=""2"">Дата проведения<BR>платежа/перевода</TD>" skip
        "<TD rowspan=""2"">Код банка <br> или <br> код филиала <br> банка</TD>" skip
        "<TD rowspan=""2"">Валюта<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">Сумма,<BR>тысяч<BR>единиц<BR>валюты<BR>платежа/<BR>перевода</TD>" skip
        "<TD rowspan=""2"">Сумма,<BR>тысяч<BR>долларов<BR>США</TD>" skip
        "<TD rowspan=""2"">Страна<BR>получения<BR>(отправления)<BR>денег</TD>" skip
        "<TD colspan=""3"">Имеющаяся информация о получателе (отправителе) денег</TD>" skip.
    put stream vcrpt unformatted
        "</TR>" skip
        "<TR align=""center"" style=""font:bold"">" skip
        "<TD>резидентство</TD>" skip
        "<TD>сектор<BR>экономики</TD>" skip
        "<TD>ФИО физического лица<br>либо наименование<br>юридического лица</TD>" skip
        "</TR>" skip.
end.
if p-printall then j = 0.
else j = i.
if (v-pay = 2 or v-pay = 3) then do:
    for each wrk-vh break by wrk-vh.bank:
        if (wrk-vh.st = 'KZ') then next.
        if wrk-vh.secK1 <> "9" then next.
        if connected ("txb") then disconnect "txb".
        find comm.txb where comm.txb.consolid and comm.txb.bank = wrk-vh.bank no-lock no-error.
        if avail comm.txb then do:
          connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
          run vcbin(wrk-vh.bank, output v-bank).
        end.
        if p-printall then do:
            if first-of(wrk-vh.bank) then do:
                put stream vcrpt  unformatted
                "<TR valign=""top"">" skip
                "<td>" v-bank "</td>" skip
                "<td>" "</td>"  skip
                "<td>" "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>"  skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "<td>"  "</td>" skip
                "</tr>" skip.
            end.
        end.
        j = j + 1.
        put stream vcrpt  unformatted
        "<TR valign=""top"">" skip
        "<td>" j "</td>" skip.
        if p-printall then put stream vcrpt  unformatted "<td>" wrk-vh.dgk "-" wrk-vh.cgk "<br>" wrk-vh.drgl "</td>"  skip.
        put stream vcrpt  unformatted
        "<td>" wrk-vh.fio "</td>"  skip
        "<td>" wrk-vh.rez1 "</td>"  skip
        "<td> &nbsp;" wrk-vh.rnn "</td>"  skip
        "<td>&nbsp;" wrk-vh.bin "</td>"  skip.
        if p-printall then put stream vcrpt  unformatted "<td>" wrk-vh.tranz "</td>"  skip.
        else put stream vcrpt  unformatted "<td>" 2 "</td>"  skip.
        put stream vcrpt  unformatted
        "<td>" wrk-vh.knp "</td>"  skip
        "<td>" wrk-vh.dt "</td>"  skip
        "<td>" string(wrk-vh.clecod) "</td>"  skip
        "<td>" wrk-vh.fcrc "</td>"  skip
        "<td>" replace(trim(string(wrk-vh.amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" replace(trim(string(wrk-vh.usd-amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>" skip
        "<td>" wrk-vh.st "</td>" skip
        "<td>" wrk-vh.rez2 "</td>" skip
        "<td>" wrk-vh.secK "</td>" skip
        "<td>" wrk-vh.bn "</td>" skip
        "</tr>" skip.
	end.
end.

put stream vcrpt unformatted "</TABLE>" skip.

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
    if avail sysc then v-mainbk = trim(sysc.chval).
    else do:
    message "Нет сведений о главном бухгалтере!". pause 3.
    v-mainbk = "".
    end.
    find ofc where ofc.ofc = g-ofc no-lock no-error.

    put stream vcrpt unformatted
        "<BR><BR>" skip
        "<P><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><B>" +
        "Руководитель/Главный бухгалтер___________________" + v-mainbk + "<BR><BR><BR>" skip
        "Исполнитель :___________________" + ofc.name + "&nbsp;&nbsp;телефон&nbsp;&nbsp;" + string(ofc.tel[2],"999-999") + "<BR><BR>" skip
        '<' + string(day(g-today),"99") + '>&nbsp;' + v-str + "&nbsp;" + string(year(g-today), "9999") + "&nbsp; года<BR>" skip
        "</B></FONT></P>" skip.
end.

{html-end.i}

output stream vcrpt close.

if p-printall then unix silent value("cptwin " + p-filename + " iexplore").
else unix silent value("cptwin " + p-filename + " excel").
pause 0.
