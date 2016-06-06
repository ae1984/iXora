/* vcrepfinout.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Задолжники по финансовым займам
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
*/
{vcrepfinvar.i}

def var v-file as char init "vcrepfinout.htm".

output to value(v-file).

{html-title.i &title = "Задолжники по финансовым займам"}

function famount returns char (input amt as deci).
    return replace(replace(string(amt,"->>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99"),","," "),".",",").
end function.

put unformatted
    "<P align=center style='font-size:12pt;font:bold'>Задолжники по финансовым займам<br>на дату " string(v-dt,"99/99/9999") "</P>" skip.

put unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding='0'>" skip.

put unformatted
    "<TR align=center style='font-size:10pt;font:bold'>" skip
    "<TD>Заимодатель</TD>" skip
    "<TD>Заемщик</TD>" skip
    "<TD>№ контракта</TD>" skip
    "<TD>Дата контракта</TD>" skip
    "<TD>Сумма задолженности</TD>" skip
    "<TD>Срок задолженности</TD>" skip
    "</TR>" skip.

for each t-dolgs no-lock:
    put unformatted
        "<TR align=center style='font-size:10pt;font:bold'>" skip
        "<TD>" t-dolgs.lender "</TD>" skip
        "<TD>" t-dolgs.borrower "</TD>" skip
        "<TD>" t-dolgs.ctnum "</TD>" skip
        "<TD>" string(t-dolgs.ctdate,"99/99/9999") "</TD>" skip
        "<TD>" famount(t-dolgs.sumdolg) "</TD>" skip
        "<TD>" t-dolgs.ctterm "</TD>" skip
        "</TR>" skip.
end.

put unformatted
    "</TABLE>" skip.

{html-end.i}
output close.

unix silent cptwin value(v-file).
