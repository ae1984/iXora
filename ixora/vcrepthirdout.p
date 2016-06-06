/* vcrepthirdout.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок  для конракта типа 9
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        28.05.2008 galina
 * CHANGES
        16.07.2012 damir - добавил input parameter p-bank,funcvc.i.

        */

{vc.i}

{global.i}
{funcvc.i}

def input parameter p-filename  as char.
def input parameter p-printbank as logical.
def input parameter p-bankname  as char.
def input parameter p-printdep  as logical.
def input parameter p-depname   as char.
def input parameter p-printall  as logical.
def input parameter p-bank      as char.

def shared temp-table t-docs
  field psdate      as date
  field psnum       as char
  field name        like cif.name
  field okpo        as char format "999999999999"
  field rnn         as char format "999999999999"
  field clntype     as char
  field country     as char
  field region      as char
  field locat       as char
  field partner     like vcpartners.name
  field rnnben      as char format "999999999999"
  field okpoben     as char format "999999999999"
  field typeben     as char
  field countryben  as char
  field regionben   as char
  field locatben    as char
  field dnnum       as char
  field dndate      like vcdocs.dndate
  field docs        like vcdocs.docs
  field sum         like vcdocs.sum
  field strsum      as char
  field codval      as char
  field ctformrs    as char
  field inout       as char
  field note        as char
  field bin         as char
  field iin         as char
  field binben      as char
  field iinben      as char
  index main is primary dndate sum docs.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var v-name      as char no-undo.
def var v-title     as char no-undo.
def var i           as integer no-undo.
def var v-monthname as char init "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
def var v-txbbank   as char.
def var v-bnkbin    as char.

def stream vcrpt.
output stream vcrpt to value(p-filename).


find first cmp no-lock no-error.

if p-bank = "TXB00" or p-bank = "" then do:
    if p-bank = "" then p-bank = "TXB00".
    run RECNAME(p-bank,output v-txbbank,output v-bnkbin).
end.

if p-bank <> "TXB00" and p-bank <> "" then do:
    run RECNAME(p-bank,output v-txbbank,output v-bnkbin).
end.

{html-title.i &stream = " stream vcrpt " }

if p-printall then do:
    /*put stream vcrpt unformatted
        "<B>" skip
        "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
        "ПРИЛОЖЕНИЕ 4 (наш клиент - 3-е лицо)<BR>"
        "к Правилам осуществления валютных операций в Республике Казахстан<BR>"
        "</I></FONT></P>" skip
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
        "Отчет о движении средств клиентов</FONT></P>"
        "<FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans""><P align = ""left"">" skip
        "Наименование банка: <U>"  cmp.name "</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        "код ОКПО: <U>" substr (cmp.addr[3], 1, 8) "</U>" skip.*/

    put stream vcrpt unformatted
        "<P align=right><FONT size=2><I><B>Приложение 5 <BR> к Правилам осуществления <BR> экспортно-импортного валютного контроля
        <BR> в Республике Казахстан, <br> утвержденным постановлением Правления Национального Банка Республики Казахстан <br>
        от 24.02.2012 № 42</I></FONT></P>" skip
        "<P align=center><FONT size=2><B>Информация по исполнению обязательств по контрактам в разрезе учетных номеров
        контрактов <BR> за &nbsp;" string(v-month) + "&nbsp; месяц &nbsp;" + string(v-god) + "&nbsp; года</B></FONT></P>" skip
        "<P align=left><FONT size=2><B>БИН уполномоченного банка &nbsp;&nbsp;" v-bnkbin "</B></FONT></P>" skip.

    /*if p-printbank then put stream vcrpt unformatted
        "<BR>" + p-bankname skip.
    if p-printdep then put stream vcrpt unformatted
        ",&nbsp;" + p-depname.

    put stream vcrpt unformatted
        "</P><P align = ""center"">" skip
        "за " + entry(v-month, v-monthname) + " "
        string(v-god, "9999") + " года</P></FONT></B>" skip.*/
end.
/*else put stream vcrpt unformatted
    "01." + string(v-month, "99") + "." + string(v-god, "9999") skip.*/

put stream vcrpt unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip.

put stream vcrpt unformatted
    "<TR align=center style=""font:bold"">" skip
    "<TD rowspan=""2""><FONT size=2>№</TD>" skip
    "<TD colspan=""2""><FONT size=2>Реквизиты <br> учетного <br> номера контракта</TD>" skip
    "<TD colspan=""7""><FONT size=2>Отправитель</TD>" skip
    "<TD colspan=""7""><FONT size=2>Получатель</TD>" skip
    "<TD colspan=""7""><FONT size=2>Информация о платеже и (или) переводе денег или ином исполнении обязательств</TD>" skip
    /*"<TD colspan=""2"">В случае переноса сумм на новый паспорт сделки</TD>" skip.*/
    "</FONT></TR>" skip.

put stream vcrpt unformatted
    "<TR align=""center"" style=""font:bold""><FONT size=2>" skip
    "<TD><FONT size=2>№</TD>" skip
    "<TD><FONT size=2>Дата</FONT></TD>" skip
    "<TD><FONT size=2>Наименование<BR>или<BR>фамилия, имя, отчество</TD>" skip
    "<TD><FONT size=2>БИН</FONT></TD>" skip
    "<TD><FONT size=2>ИИН</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR>юридическое<BR>лицо или<BR>инивидуальный<BR>предприниматель</FONT></TD>" skip
    "<TD><FONT size=2>Страна</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>области</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>резидент<BR>ства</FONT></TD>" skip
    "<TD><FONT size=2>Наименование<BR>или<BR>фамилия, имя, отчество</FONT></TD>" skip
    "<TD><FONT size=2>БИН</FONT></TD>" skip
    "<TD><FONT size=2>ИИН</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR>юридическое<BR>лицо или<BR>инивидуальный<BR>предприниматель</FONT></TD>" skip
    "<TD><FONT size=2>Страна</TD>" skip
    "<TD><FONT size=2>Код<BR>области</FONT></TD>" skip
    "<TD><FONT size=2>Код<BR>резидент<BR>ства</FONT></TD>" skip
    "<TD><FONT size=2>Дата</FONT></TD>" skip
    "<TD><FONT size=2>Сумма<BR>в тысячах единиц</FONT></TD>" skip
    "<TD><FONT size=2>Валюта<BR>расчетов</FONT></TD>" skip
    "<TD><FONT size=2>Код способа<BR>расчетов</FONT></TD>" skip
    "<TD><FONT size=2>Признак-<BR>исходящий,<BR>входящий</FONT></TD>" skip
    /*"<TD colspan=""2"">Основание для зачета<BR>или уступки<BR>или иного<BR>исполнения</TD>" skip
    "<TD rowspan=""2"">Дата нового<BR>паспорта сделки</TD>" skip
    "<TD rowspan=""2"">Номер нового<BR>паспорта сделки</TD>" skip*/
    "</FONT></TR>" skip.

/*put stream vcrpt unformatted
    "</TR>" skip
    "<TR align=""center"" style=""font:bold"">" skip
    "<TD>№</TD>" skip
    "<TD>Дата</TD>" skip
    "</TR>" skip.*/

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
        "<TD><FONT size=2>" t-docs.inout "</FONT></TD>" skip.
        /*"<TD>&nbsp;" "</TD>"  skip
        "<TD>&nbsp;" "</TD>"  skip
        "<TD>&nbsp;" "</TD>"  skip
        "<TD>&nbsp;" "</TD>"  skip.*/
    put stream vcrpt unformatted
        "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

/*if p-printall then do:
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
end.*/

{html-end.i}


output stream vcrpt close.

if p-printall then
  unix silent value("cptwin " + p-filename + " iexplore").
else
  unix silent value("cptwin " + p-filename + " excel").

pause 0.
