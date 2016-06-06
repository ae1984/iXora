/* vcrep4out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок
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
        06.05.2008 galina
 * BASES
        BANK COMM
 * CHANGES
        17/11/2010 aigul - Изменение шапки, оглавления отчета и 14 графы
        22.12.2010 aigul - добавила в таблицу t-docs поле rdt
        10.04.2011 damir - новые переменные v-bin,v-iin,v-binben,v-iinben
                           bin,iin,binben,iinben во временную таблицу.
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        30.09.2011 damir - добавлены:
                           1) repcorrect.i, p-filename2.
        06.12.2011 damir - убрал chbin.i
        16.07.2012 damir - добавил funcvc.i, input parameter p-bank, vcrecda.i
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        */

{vc.i}
{global.i}
{funcvc.i}
{vcshared4.i}

def input parameter p-filename  as char.
def input parameter p-filename2 as char.
def input parameter p-printbank as logi.
def input parameter p-bankname  as char.
def input parameter p-printdep  as logi.
def input parameter p-depname   as char.
def input parameter p-printall  as logi.
def input parameter p-bank      as char.

def var v-name as char no-undo.
def var v-title as char no-undo.
def var i as integer no-undo.
def var v-monthname as char init "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-txbbank as char.
def var v-bnkbin as char.

def stream vcrpt.
output stream vcrpt to value(p-filename).




find first cmp no-lock no-error.

{vcrecda.i}

{ html-title.i &stream = " stream vcrpt " }

if p-printall then do:
    put stream vcrpt unformatted
        "<P align=right><FONT size=2><I><B>Приложение 4 <BR> к Правилам осуществления <BR> экспортно-импортного валютного контроля
        <BR> в Республике Казахстан, <br> утвержденным постановлением Правления Национального Банка Республики Казахстан <br>
        от 24.02.2012 № 42</I></FONT></P>" skip
        "<P align=center><FONT size=2><B>Информация по исполнению обязательств по контрактам в разрезе учетных номеров
        контрактов <BR> за &nbsp;" string(v-month) + "&nbsp; месяц &nbsp;" + string(v-god) + "&nbsp; года</B></FONT></P>" skip
        "<P align=left><FONT size=2><B>БИН уполномоченного банка &nbsp;&nbsp;" v-bnkbin "</B></FONT></P>" skip.
end.
else put stream vcrpt unformatted
    "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

put stream vcrpt unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

put stream vcrpt unformatted
    "<TR align=center style=""font:bold"">" skip
    "<TD rowspan=""2""><FONT size=2>№</FONT></TD>" skip
    "<TD colspan=""2""><FONT size=2>Реквизиты<br>учетного<br>номера контракта</FONT></TD>" skip
    "<TD colspan=""7""><FONT size=2>Отправитель</FONT></TD>" skip
    "<TD colspan=""7""><FONT size=2>Получатель</FONT></TD>" skip
    "<TD colspan=""5""><FONT size=2>Информация о платеже и (или) переводе денег или ином исполнении обязательств</FONT></TD>" skip
    "</TR>" skip.


put stream vcrpt unformatted
    "<TR align=""center"" style=""font:bold""><FONT size=2>" skip
    "<TD><FONT size=2>№</FONT></TD>" skip
    "<TD><FONT size=2>Дата</FONT></TD>" skip
    "<TD><FONT size=2>Наименование<BR>или<BR>фамилия, имя, отчество</FONT></TD>" skip
    "<TD><FONT size=2>БИН</FONT></TD>" skip
    "<TD><FONT size=2>ИИН</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR>юридическое<BR>лицо или<BR>физическое<BR>лицо</FONT></TD>" skip
    "<TD><FONT size=2>Страна</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>области</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>резидентства</FONT></TD>" skip
    "<TD><FONT size=2>Наименование<BR>или<BR>фамилия, имя, отчество</FONT></TD>" skip
    "<TD><FONT size=2>БИН</FONT></TD>" skip
    "<TD><FONT size=2>ИИН</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR> юридическое <BR> лицо или <BR> физическое <BR> лицо</FONT></TD>" skip
    "<TD><FONT size=2>Страна</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>области</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>резидент<BR>ства</FONT></TD>" skip
    "<TD><FONT size=2>Дата</FONT></TD>" skip
    "<TD><FONT size=2>Сумма <BR> в тысячах единиц</FONT></TD>" skip
    "<TD><FONT size=2>Валюта <BR> расчетов</FONT></TD>" skip
    "<TD><FONT size=2>Код <br> способа<BR>расчетов</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR>исходящий, входящий</FONT></TD>" skip
    "</TR>" skip.

i = 0.
for each t-docs no-lock:
    i = i + 1.
    put stream vcrpt unformatted
        "<TR valign=""top"">" skip
        "<TD><FONT size=2>" i "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.psnum "</FONT></TD>" skip
        "<TD><FONT size=2>" string(t-docs.psdate, "99/99/99") "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.name "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.bin "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.iin "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.clntype "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.country "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.region "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.locat "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.partner "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.binben "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.iinben "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.typeben "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.countryben "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.regionben "</FONT></TD>"  skip
        "<TD><FONT size=2>" t-docs.locatben "</FONT></TD>"  skip
        "<TD><FONT size=2>" string(t-docs.dndate, "99/99/99") "</FONT></TD>" skip
        "<TD><FONT size=2>"replace(t-docs.strsum,'.',',')"</FONT></TD>" skip
        "<TD><FONT size=2>" string(t-docs.codval, "999") "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.ctformrs "</FONT></TD>" skip
        "<TD><FONT size=2>" t-docs.inout "</FONT></TD>" skip
        "</TR>" skip.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

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
        "Главный бухгалтер " cmp.name " _________________________ " +
        v-name + "<BR><BR><BR>" skip
        "Исполнитель :  _________________________ "  + ofc.name + "<BR>" skip
        "тел.  " + string(ofc.tel[2], "999-999") + "<BR><BR>" skip
        string(g-today, "99/99/9999") + "<BR>" skip
        "</B></FONT></P>" skip.
end.

{html-end.i}

output stream vcrpt close.

/*----------------------------------------------------------------*/
def stream vcrep.
output stream vcrep to value(p-filename2).
{html-title.i &stream = "stream vcrep"}

if p-printall then do:
    put stream vcrep unformatted
        "<P align=right style='font-size:14pt;font:bold'><I>ПРИЛОЖЕНИЕ 4<BR>к Правилам осуществления экспортно-импортного валютного контроля в Республике Казахстан<BR></I></P>" skip
        "<P align=center style='font-size:10pt'>Информация об исполнении обязательств по паспортам сделок</P>"
        "<P align=left style='font-size:10pt'>Наименование банка:<U>" trim(cmp.name) "</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;код ОКПО:<U>" substr(cmp.addr[3],1,8) "</U></P>" skip.

    if p-printbank then put stream vcrep unformatted "<BR>" + p-bankname skip.
    if p-printdep then put stream vcrep unformatted ",&nbsp;" + p-depname.

    put stream vcrep unformatted
        "<P align=center style='font-size:10pt'>за " + entry(v-month,v-monthname) + " " string(v-god, "9999") + " года</P>" skip.
end.
else put stream vcrep unformatted "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.

put stream vcrep unformatted
    "<TABLE width=100% border=1 cellspacing=0 cellpadding=0>" skip.

put stream vcrep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD rowspan=3>№</TD>" skip
    "<TD colspan=2>Реквизиты<br>действующего<br>паспорта сделки</TD>" skip
    "<TD colspan=7>Отправитель денег</TD>" skip
    "<TD colspan=7>Бенефициар</TD>" skip
    "<TD colspan=7>Информация о платеже и (или) переводе денег или ином исполнении обязательств</TD>" skip
    "<TD colspan=2>В случае переноса сумм на новый паспорт сделки</TD>" skip
    "<TD rowspan=3>Корректировка</TD>" skip
    "</TR>" skip.

put stream vcrep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD rowspan=2>№</TD>" skip
    "<TD rowspan=2>Дата</TD>" skip
    "<TD rowspan=2>Наименование<BR>или<BR>фамилия, имя, отчество</TD>" skip
    "<TD rowspan=2>Код<BR>ОКПО</TD>" skip
    "<TD rowspan=2>РНН</TD>" skip
    "<TD rowspan=2>Признак-<BR>юридическое<BR>лицо или<BR>физическое<BR>лицо</TD>" skip
    "<TD rowspan=2>Страна</TD>" skip
    "<TD rowspan=2>Код<BR>области</TD>" skip
    "<TD rowspan=2>Код<BR>резидент<BR>ства</TD>" skip
    "<TD rowspan=2>Наименование<BR>или<BR>фамилия, имя, отчество</TD>" skip
    "<TD rowspan=2>Код<BR>ОКПО</TD>" skip
    "<TD rowspan=2>РНН</TD>" skip
    "<TD rowspan=2>Признак-<BR>юридическое<BR>лицо или<BR>физическое<BR>лицо</TD>" skip
    "<TD rowspan=2>Страна</TD>" skip
    "<TD rowspan=2>Код<BR>области</TD>" skip
    "<TD rowspan=2>Код<BR>резидент<BR>ства</TD>" skip
    "<TD rowspan=2>Дата</TD>" skip
    "<TD rowspan=2>Сумма<BR>в тысячах единиц</TD>" skip
    "<TD rowspan=2>Валюта<BR>расчетов</TD>" skip
    "<TD rowspan=2>Код способа<BR>расчетов</TD>" skip
    "<TD rowspan=2>Признак-<BR>исходящий,<BR>входящий</TD>" skip
    "<TD colspan=2>Основание для зачета<BR>или уступки<BR>или иного<BR>исполнения</TD>" skip
    "<TD rowspan=2>Дата нового<BR>паспорта сделки</TD>" skip
    "<TD rowspan=2>Номер нового<BR>паспорта сделки</TD>" skip
    "</TR>" skip.

put stream vcrep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD>№</TD>" skip
    "<TD>Дата</TD>" skip
    "</TR>" skip.

i = 0.
for each t-dc no-lock:
    i = i + 1.
    put stream vcrep unformatted
        "<TR align=center style='font-size:10pt'>" skip
        "<TD>" string(i) "</TD>" skip
        "<TD>" t-dc.psnum "</TD>" skip
        "<TD>" string(t-dc.psdate,"99/99/99") "</TD>" skip
        "<TD>" t-dc.NAME "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" t-dc.COUNTRY "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" t-dc.BNAME "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD>" t-dc.BCOUNTRY "</TD>" skip
        "<TD></TD>"  skip
        "<TD></TD>"  skip
        "<TD>" t-dc.PAYDATE "</TD>" skip
        "<TD>" if deci(t-dc.SUMM) <> 0 then replace(t-dc.SUMM,".",",") else "" "</TD>" skip
        "<TD>" t-dc.CURR "</TD>" skip
        "<TD>" t-dc.CODECALC "</TD>" skip
        "<TD>" t-dc.INOUT "</TD>" skip
        "<TD></TD>"  skip
        "<TD></TD>"  skip
        "<TD></TD>"  skip
        "<TD></TD>"  skip
        "<TD>" t-dc.corr "</TD>" skip
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
{html-end.i "stream vcrep"}
output stream vcrep close.
/*------------------------------------------------------------------*/

if p-printall then unix silent value("cptwin " + p-filename + " excel").
else unix silent value("cptwin " + p-filename + " excel").

if p-printall then unix silent value("cptwin " + p-filename2 + " excel").

