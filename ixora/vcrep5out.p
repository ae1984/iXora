/* vcrep5out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 5 - Информация по паспортам сделок и дополнительным листам к паспортам сделок (МТ111 для НБ)
        Вывод временной таблицы в IE
 * RUN

 * CALLER
        vcrep5.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        20.08.2008 galina
 * CHANGES
        22.08.2008 galina - рассположила подпись бухгалтера и исполнителя слева
        05.09.2008 galina - изменила формат ввывода суммы
                            добавила поле bankokpo во временную таблицу
        18/11/2008 galina - добавила поле repdate
                            не выводим сумму для закрытых ПС и ОКПО
        29/10/2009 galina - не выводим рег.свидетельства, лицензии, свидетельства об уведомлении
        08/10/2010 galina - добавила приммечание
        18/11/2010 aigul - переименование графы Ориентировочные сроки на Сроки репатриации
        19.04.2011 damir - новые переменные во временной
        28.04.2011 damir - поставлены ключи. процедура chbin.i
        08.09.2011 damir - Добавлены поля field - corrinfo, newval1, newval2, valplnew.новое поле - "Корректировка".
        30.09.2011 damir - добавил okpoprev в  temp-table t-ps.
        19.10.2011 damir - изменен формат вывода
        06.12.2011 damir - убрал chbin.i
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        29.06.2012 damir - oper_type,funcvc.i.
        16.07.2012 damir - переименовал в шапке на Приложение 5.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
        */

{vc.i}
{nbankBik.i}
{global.i}
{funcvc.i}
{vcshared5.i}

def input parameter p-filename  as char.
def input parameter p-printbank as logical.
def input parameter p-bankname  as char.
def input parameter p-printdep  as logical.
def input parameter p-depname   as char.
def input parameter p-printall  as logical.
def input parameter p-bank      as char.

def var v-bank as char.
def var v-info as char.
def var v-name as char no-undo.
def var v-title as char no-undo.
def var i as inte no-undo.
def var v-god as integer format "9999".
def var v-month as integer format "99".
def var v-day as integer format "99".
def var v-monthname as char init "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".
def var v-txbbank as char.
def var v-bnkbin as char.

def stream vcrpt.
output stream vcrpt to value(p-filename).

v-god = year(v-dt).
v-month  = month(v-dt).
v-day = day(v-dt).

{vcrecda.i}

v-bank = replace(p-bank,"TXB","0").

find first txb where txb.bank = p-bank no-lock no-error.
if avail txb then v-bank = txb.info.

find first cmp no-lock no-error.

{html-title.i &stream = "stream vcrpt"}

if p-printall then do:
    put stream vcrpt unformatted
        "<P align=right style='font-size:10pt;font:bold'>Приложение 5 <BR> к Правилам осуществления <BR> экспортно-импортного валютного контроля<BR>в Республике Казахстан,
        <br>утвержденным постановлением Правления Национального Банка Республики Казахстан<br>от 24.02.2012 № 42</P>" skip
        "<P align=center style='font-size:10pt;font:bold'>Информация по контрактам с учетным номером контракта <BR> за &nbsp;&nbsp;" string(v-day,"99") + "&nbsp;" +
        entry(v-month, v-monthname) + "&nbsp;" string(v-god, "9999") "</P>" skip
        "<P align=left style='font-size:10pt;font:bold'>БИН банка учетной регистрации контракта &nbsp;&nbsp;" v-bnkbin "</P>" skip.
end.

put stream vcrpt unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream vcrpt unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<td rowspan=3>N</td>" skip
    "<td colspan=4>Реквизиты учетной <br> регистрации контракта или <br> паспорта сделки</td>" skip
    "<td colspan=5>Информация по экспортеру или импортеру</td>" skip
    "<td colspan=5>Информация по контракту</td>" skip
    "<td colspan=2>Нерезидент</td>" skip
    "<td rowspan=3>Сроки репатриации</td>" skip
    "<td colspan=2>Снятие контракта с учетной регистрации</td>" skip
    "<td rowspan=3>Корректировка</td>" skip
    "</TR>" skip.

put stream vcrpt unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<td colspan=2>Реквизиты <br> паспорта <br> сделки</td>" skip
    "<td colspan=2>Учетный <br> номер <br> контракта</td>" skip
    "<td rowspan=2>Наименование или фамилия, имя, отчество</td>" skip
    "<td rowspan=2>БИН</td>" skip
    "<td rowspan=2>ИИН</td>" skip
    "<td rowspan=2>Признак юридическое лицо <br> или индивидуальный предприниматель</td>" skip
    "<td rowspan=2>Код области</td>" skip
    "<td rowspan=2>Признак – экспорт или импорт</td>" skip
    "<td rowspan=2>Номер</td>" skip
    "<td rowspan=2>Дата</td>" skip
    "<td rowspan=2>Сумма контракта в тысячах единиц</td>" skip
    "<td rowspan=2>Валюта контракта</td>" skip
    "<td rowspan=2>Наименование или фамилия, имя, отчество</td>" skip
    "<td rowspan=2>Страна</td>" skip
    "<td rowspan=2>Дата</td>" skip
    "<td rowspan=2>Основание</td>" skip
    "</TR>" skip.

put stream vcrpt unformatted
    "<TR style='font-size:10pt;font:bold'>" skip
    "<td>№</td>"
    "<td>Дата</td>"
    "<td>№</td>"
    "<td>Дата</td>"
    "</TR>" skip.
for each t-ps:
    i = i + 1.
    put stream vcrpt  unformatted
        "<TR align=center style='font-size:10pt'>"
        "<td>" string(i) "</td>" skip.
    if t-ps.psdate < 07/01/2012 then do:
        put stream vcrpt  unformatted
            "<td>" t-ps.psnum "</td>" skip
            "<td>" string(t-ps.psdate,'99/99/9999') "</td>" skip
            "<td></td>" skip
            "<td></td>" skip.
    end.
    else do:
        put stream vcrpt  unformatted
            "<td></td>" skip
            "<td></td>" skip
            "<td>" t-ps.psnum "</td>" skip
            "<td>" string(t-ps.psdate,'99/99/9999') "</td>" skip.
    end.
    put stream vcrpt  unformatted
        "<td>" t-ps.cifname "</td>" skip.
    put stream vcrpt  unformatted
        "<td>" t-ps.bin "</td>" skip
        "<td>" t-ps.iin "</td>" skip.
    put stream vcrpt  unformatted
        "<td>" replace(string(t-ps.cif_type),"0","") "</td>" skip
        "<td>" t-ps.cif_region "</td>" skip
        "<td>" replace(string(t-ps.ctexpimp),'0','') "</td>" skip
        "<td>" t-ps.ctnum "</td>" skip
        "<td>" if t-ps.ctdate <> ? then string(t-ps.ctdate,'99/99/9999') else "" "</td>" skip.
    if t-ps.ctsum > 0 then put stream vcrpt  unformatted
        "<td>" replace(trim(string(t-ps.ctsum, '>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
    else put stream vcrpt  unformatted
        "<td></td>" skip.
    put stream vcrpt  unformatted
        "<td>" t-ps.ctncrc "</td>" skip
        "<td>" t-ps.partner_name "</td>" skip
        "<td>" t-ps.partner_country "</td>" skip
        "<td>" string(t-ps.ctterm,"999.99") "</td> " skip
        "<td>" if t-ps.ctclosedt <> ? then string(t-ps.ctclosedt,'99/99/9999') else "" "</td>" skip
        "<td>" t-ps.ctclosereas "</td>" skip
        "<td>" t-ps.corrinfo "</td>" skip
        "</tr>" skip.
end.
put stream vcrpt unformatted
    "</TABLE>".

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
        "<P align=left style='font-size:10pt;font:bold'>Главный бухгалтер " v-info " " v-bank " _________________________ " + v-name + "<BR><BR><BR>" skip
        "Исполнитель :  _________________________ "  + ofc.name + "<BR>" skip
        "тел.  " + string(ofc.tel[2], "999-999") + "<BR><BR>" + string(g-today, "99/99/9999") + "<BR></P>" skip.
end.

{html-end.i "stream vcrpt"}
output stream vcrpt close.

if p-printall then /*unix silent value("cptwin " + p-filename + " iexplore").
else*/ unix silent value("cptwin " + p-filename + " excel").

pause 0.

unix silent rm -f  value(p-filename).

