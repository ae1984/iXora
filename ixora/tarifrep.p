/* tarifrep.p
 * MODULE
        Название модуля - Справочник услуг
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
        Пункт меню - 1.3.8.5
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def var v-file as char init "tarif.htm".

def stream rep.
output stream rep to value(v-file).

def temp-table t-rep
    field num as inte
    index idx is primary num ascending.

def var v-num  as char.
def var j      as inte.
def var v-temp as char.

{html-title.i
 &stream = " stream rep "
 &title = "Отчет по тарификатору"
 &size-add = "xx-"
}

put stream rep unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

put stream rep unformatted
    "<TR align=center>" skip
    "<TD><FONT size=3><B>№</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Код комиссии</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Счет бал.</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Наименование услуги</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Валюта</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Сумма</B></FONT></TD>" skip
    "<TD><FONT size=3><B>%</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Минимальная</B></FONT></TD>" skip
    "<TD><FONT size=3><B>Максимальная</B></FONT></TD>" skip
    "</TR>" skip.

def buffer b-tarif for tarif.

for each b-tarif no-lock break by b-tarif.num:
    if first-of(b-tarif.num) then do:
        create t-rep.
        assign
        t-rep.num = integer(b-tarif.num).
    end.
end.

for each t-rep no-lock use-index idx:
    find first tarif where tarif.num = string(t-rep.num) no-lock no-error.
    if avail tarif then do:
        put stream rep unformatted
            "<TR align=center>" skip
            "<TD><FONT size=3><B>" tarif.num    "</B></FONT></TD>" skip
            "<TD><FONT size=3><B>" tarif.pakalp "</B></FONT></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "<TD></TD>" skip
            "</TR>" skip.
        for each tarif2 where trim(tarif2.num) = trim(tarif.num) and tarif2.stat = 'r' no-lock use-index num:
            put stream rep unformatted
            "<TR align=center>" skip
            "<TD><FONT size=2>" trim(tarif.num) + "." + string(integer(tarif2.kod)) + "." "</FONT></TD>" skip.
            put stream rep unformatted
                "<TD><FONT size=2>" trim(tarif2.num + tarif2.kod) ".</FONT></TD>" skip.
            put stream rep unformatted
                "<TD><FONT size=2>" trim(string(tarif2.kont)) "</FONT></TD>" skip
                "<TD><FONT size=2>" trim(tarif2.pakalp)    "</FONT></TD>" skip
                "<TD><FONT size=2>" string(tarif2.crc, "99") "</FONT></TD>" skip
                "<TD><FONT size=2>" string(tarif2.ost, ">>>>>>>>>>>>>>>>>>>9.99") ".</FONT></TD>" skip
                "<TD><FONT size=2>" string(tarif2.proc, ">>>9.99") ".</FONT></TD>" skip
                "<TD><FONT size=2>" string(tarif2.min1, ">>>>>>>>>>>>>>>>>>>9.99") ".</FONT></TD>" skip
                "<TD><FONT size=2>" string(tarif2.max1, ">>>>>>>>>>>>>>>>>>>9.99") ".</FONT></TD>" skip
                "</TR>" skip.
        end.
    end.
end.

{html-end.i " stream rep " }

put stream rep unformatted
    "</TABLE>" skip.

output stream rep close.

unix silent cptwin value(v-file) excel.