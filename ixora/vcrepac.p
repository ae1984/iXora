/* vcrepac.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по неакцептованным  документам и контрактам
 * RUN
        Реестр неакцептированных документов
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        15/06/04 saltanat
 * BASES
        BANK COMM
 * CHANGES
        05/09/06 u00600 - оптимизация
        11.10.2011 damir - исключил документы dntype = 28.
        21.10.2011 damir - оптимизация в соответствии с Т.З. № 1097.
        26.10.2011 damir - устранил мелкие ошибки.
        15.03.2012 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{vc.i}

{mainhead.i}
{get-dep.i}

def input parameter p-option as char.
def input parameter p-date   as date.
def input-output parameter vresult as logi.

def var v-dtb as date.
def var v-dte as date.

def new shared temp-table t-docsa
    field filial    as char
    field txb       as char
    field viddoc    as inte
    field depart    as inte
    field codcl     as char
    field clname    as char
    field cnum      as char
    field ctype     as char
    field conttype  as char
    field cdat      as date
    field dnum      as char
    field dtype     as char
    field documtype as char
    field ddat      as date
    field orig      as char
    field rdate     as date
    field rwho      as char.

def buffer b-t-docsa for t-docsa.

def var i as inte init 0.

def new shared var v-option as char.

v-option = trim(p-option).

{defperem.i}.

if p-option = "mail" then do:
    v-dtb = p-date.
    v-dte = p-date.
    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.
    def var vv-path as char no-undo.
    /*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
    if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then vv-path = '/data/b'.
    else vv-path = '/data/'.*/
    if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
    else vv-path = '/data/b'.
    for each comm.txb where comm.txb.consolid = true no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run vcrepacdat (input txb.bank, v-dtb, v-dte).
    end.
    if connected ("txb") then disconnect "txb".
end.
else do:
    form
       v-dtb label 'Начало периода' format '99/99/9999' skip
       v-dte label ' Конец периода' format '99/99/9999' skip
    with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.
    v-dtb = g-today.
    v-dte = g-today.
    update v-dtb v-dte with frame f-dt.

    {r-brfilial.i   &proc = " vcrepacdat (input txb.bank, v-dtb, v-dte) "}
end.

def stream vcrpt.
if p-option <> "mail" then output stream vcrpt to vcreestr.htm.
else output stream vcrpt to value(vfname).

find first t-docsa no-lock no-error.
if avail t-docsa then v-yesno = yes.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Реестр неакцептованных документов"
 &size-add = "xx-"
}

put stream vcrpt unformatted
    "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
    "<B>РЕЕСТР НЕАКЦЕПТОВАННЫХ ДОКУМЕНТОВ<BR>за период с " + string(v-dtb, "99/99/9999") +
    " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip
    "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
    "<B>Неакцептованные контракты</B></FONT></P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* Вывод в отчет неакцептованных контрактов */

put stream vcrpt unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>№</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Тип контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Дата контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Дата регистрации</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Регистрировал</B></FONT></TD>" skip
    "</TR>" skip.

for each t-docsa where t-docsa.viddoc = 1 no-lock break by t-docsa.txb:
    if first-of(t-docsa.txb) then do:
        i = 0.
        put stream vcrpt unformatted
            "<TR align=""center"">" skip
            "<TD colspan=""7""><FONT size=""2""><B>" t-docsa.filial "</B></FONT></TD>" skip
            "</TR>" skip.
        for each b-t-docsa where b-t-docsa.txb = t-docsa.txb and b-t-docsa.viddoc = 1 no-lock:
            i = i + 1.
            put stream vcrpt unformatted
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">" string(i) "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.codcl  "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.clname  "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.cnum  "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.conttype "</FONT></TD>" skip
                "<TD><FONT size=""2"">" string(b-t-docsa.cdat, "99/99/99")  "</FONT></TD>" skip
                "<TD><FONT size=""2"">" string(b-t-docsa.rdate, "99/99/99")  "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.rwho  "</FONT></TD>" skip
                "</TR>" skip.
        end.
    end.
end.

put stream vcrpt unformatted
    "</TABLE>" skip.

/* Вывод в отчет неакцептованных документов */

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Неакцептованные документы</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put stream vcrpt unformatted
    "<TR align=""center"">" skip
    "<TD><FONT size=""2""><B>№</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Код клиента</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Наименование клиента</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Номер контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Тип контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Дата контракта</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Номер документа</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Тип документа</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Дата документа</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Оригинал</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Дата регистрации</B></FONT></TD>" skip
    "<TD><FONT size=""2""><B>Регистрировал</B></FONT></TD>" skip
    "</TR>" skip.

for each t-docsa where t-docsa.viddoc = 2 no-lock break by t-docsa.txb:
    if first-of(t-docsa.txb) then do:
        i = 0.
        put stream vcrpt unformatted
           "<TR align=""center"">" skip
            "<TD colspan=""11""><FONT size=""2""><B>" t-docsa.filial "</B></FONT></TD>" skip
           "</TR>" skip.
        for each b-t-docsa where b-t-docsa.txb = t-docsa.txb and b-t-docsa.viddoc = 2 no-lock:
            i = i + 1.
            put stream vcrpt unformatted
                "<TR align=""center"">" skip
                "<TD><FONT size=""2"">" string(i) "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.codcl "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.clname "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.cnum "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.conttype "</FONT></TD>" skip
                "<TD><FONT size=""2"">" string(b-t-docsa.cdat, "99/99/99") "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.dnum "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.documtype "</FONT></TD>" skip
                "<TD><FONT size=""2"">" if b-t-docsa.ddat = ? then "" else string(b-t-docsa.ddat, "99/99/99") "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.orig "</FONT></TD>" skip
                "<TD><FONT size=""2"">" string(b-t-docsa.rdate, "99/99/99") "</FONT></TD>" skip
                "<TD><FONT size=""2"">" b-t-docsa.rwho "</FONT></TD>" skip
                "</TR>" skip.
        end.
    end.
end.

put stream vcrpt unformatted
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

if p-option <> "mail" then unix silent value("cptwin vcreestr.htm iexplore").

pause 0.

vresult = yes.

