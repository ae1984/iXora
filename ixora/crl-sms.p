/* crl-sms.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Статус SMS-информирования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16.2.2.10
 * AUTHOR
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        28.05.2013 damir - Внедрено Т.З. № 1819.
*/
{mainhead.i}

def new shared var v-dtb as date.
def new shared var v-dte as date.

def new shared temp-table t-wrk no-undo
    field cif as char
    field fio as char
    field iin as char
    field tell as char
    field state as char
    field pdate as date
    field ptime as inte
    field pwho as char
    field batchid as inte.

def stream rep.

def var v-file as char init "crl-sms.htm".

v-dtb = g-today.
v-dte = g-today.

update
    v-dtb label "        ПЕРИОД ОТЧЕТА С" skip
    v-dte label "                     ПО" skip
with side-label row 5 centered title " ВВЕДИТЕ " frame crl-sms.

{r-brfilial.i &proc = "crl-smstxb"}

output stream rep to value(v-file).
{html-title.i &stream = "stream rep"}

put stream rep unformatted
    "<P align=center style='font-size:14pt;font:bold'>Отчет по статусу SMS-информирования</P>" skip.

put stream rep unformatted
    "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

put stream rep unformatted
    "<TR align=center style='font-size:10pt;font:bold'>"
    "<TD>CIF-код клиента</TD>" skip
    "<TD>ФИО</TD>" skip
    "<TD>ИИН</TD>" skip
    "<TD>Номер мобильного тел.</TD>" skip
    "<TD>Статус</TD>" skip
    "<TD>Дата отправки</TD>" skip
    "<TD>Время отправки</TD>" skip
    "<TD>Логин отправителя</TD>" skip
    "<TD>ID<br>SMS-сообщения</TD>" skip
    "</TR>" skip.

for each t-wrk no-lock:
    put stream rep unformatted
        "<TR align=center style='font-size:10pt'>"
        "<TD>" t-wrk.cif "</TD>" skip
        "<TD>" t-wrk.fio "</TD>" skip
        "<TD>" t-wrk.iin "</TD>" skip
        "<TD>" t-wrk.tell "</TD>" skip
        "<TD>" t-wrk.state "</TD>" skip
        "<TD>" string(t-wrk.pdate,"99/99/9999") "</TD>" skip
        "<TD>" string(t-wrk.ptime,"HH:MM:SS") "</TD>" skip
        "<TD>" t-wrk.pwho "</TD>" skip
        "<TD>" string(t-wrk.batchid) "</TD>" skip
        "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(v-file) excel.



