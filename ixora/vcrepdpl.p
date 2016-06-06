/* vcrepdpl.p
 * MODULE
        Название Программного Модуля - Валютный контроль
 * DESCRIPTION
        Назначение программы, описание процедур и функций - Отчет по задолжникам на дату - отсутствуют ГТД (экспорт/импорт)
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
        14.12.2002 nadejda
 * BASES
        BANK COMM
 * CHANGES
	    24.05.2003 nadejda - убраны параметры -H -S из коннекта
        18.05.2004 nadejda - изменение описания таблицы t-dolgs для совместимости
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09/11/2010 madiyar - убрал -H,-S
        09/02/2011 damir - добавил cardnum - номер ЛКБК, carddt - дата ЛКБК.
        10/02/2011 damir - добавил ctterm - сроки репатриации

        16,02,2011 damir - передаем только тип 1 паспорт сделки в vcrepdpldat
        25,02,2011 damir - добавил field namefil as char
        28,02,2011 damir - &sumdolg = true.
        31.03.2011 damir - небольшие корректировки.
        25.12.2012 damir - Внедрено Т.З. 1306. Оптимизация кода.
*/

{mainhead.i}

{vcrepdplvar.i "new"}

find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then s-dtb = date(vcparams.valchar). else s-dtb = 01/01/2002.

s-dte = g-today.
s-closed = yes.

form
    s-dtb    label "с" format "99/99/9999" " " skip
    s-dte    label "по" format "99/99/9999" " " skip(1)
    s-closed label "Показывать закрытые контракты" skip
with centered side-label row 5 title "ЗАДОЛЖНИКИ ПО ПРЕДОСТАВЛЕНИЮ ГТД (ИМПОРТ)" frame f-dt.

update s-dtb s-dte s-closed with frame f-dt.

{r-brfilial.i &proc = "vcrepdpldat"}

run vcrepdplout.