/* prisv.p
 * MODULE
        Особые отношения
 * DESCRIPTION
        Формирование отчёта по базе
 * BASES
        BANK COMM
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        30/04/2008 alex
 * CHANGES
        07/05/2008 alex - добавил COMM
        02/01/2013 madiyar - в поле prisv.rnn теперь ИИН/БИН
*/

def stream v-out.
output stream v-out to prisv.html.

put stream v-out unformatted
    "<html><title>Отчет по базе</title><META http-equiv=Content-Type content=""text/html; charset=windows-1251""><body>" skip
    "<table border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
    "<tr align= center valign= top style= font:bold; font-size:xx-small bgcolor= #C0C0C0>" skip
    "<td>ИИН/БИН</td>" skip
    "<td>Наименование/ФИО</td>" skip
    "<td>Признак</td>"
    "<td>Описание признака</td></tr>" skip.

   for each prisv no-lock.
        put stream v-out unformatted
            "<tr align= center valign= top>" skip
            "<td>&nbsp;" + prisv.rnn + "</td>" skip
            "<td>" + prisv.name + "</td>" skip
            "<td align= center>" + prisv.specrel + "</td>" skip.

        find first codfr where codfr.codfr = "affil" and codfr.code = prisv.specrel no-lock no-error.
        if avail codfr then put stream v-out unformatted "<td align= justify>" + codfr.name[1] + "</td></tr>" skip.
        else put stream v-out unformatted "<td align= justify></td></tr>" skip.
    end.

    put stream v-out unformatted
    "</table></body></html>"skip.
output stream v-out close.
unix silent cptwin prisv.html excel.