/* vcrepdus.p
 * MODULE
        Описание - Валютный контроль
 * DESCRIPTION
        Отчет по задолжникам на дату - отсутствуют акты выполненных работ - экспорт/импорт
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
        31.03.2003 nadejda
 * BASES
        BANK COMM
 * CHANGES
        31.07.2003 nadejda - добавлено поле sumdolg для совместимости
        06.11.2003 nadejda - добавила выбор количества дней просрочки для просмотра
        18.05.2004 nadejda - изменение описания таблицы t-dolgs для совместимости
        09/02/2011 damir - добавил cardnum - номер ЛКБК, carddt - дата ЛКБК.
        10/02/2011 damir - добавил ctterm - сроки репатриации
        23.02.2011 damir - убрал процедуру vcrepdusout вывод в этой процедуре.
        24,02,2011 damir - добавил разбранчевку стр.107.
                           внес изменения в вызываемую процедуру vcrepdusdat.
        25,02,2011 damir - добавил field namefil as char
        31.03.2011 damir - небольшие корректировки.
        25.12.2012 damir - Внедрено Т.З. 1306. Оптимизация кода.
*/

{mainhead.i}

{vcrepdusvar.i "new"}

find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then s-dtb = date(vcparams.valchar). else s-dtb = 01/01/2002.

s-dte = g-today.
s-closed = yes.

form
    s-dtb    label "с" format "99/99/9999" " " skip
    s-dte    label "по" format "99/99/9999" " " skip(1)
    s-closed label "Показывать закрытые контракты" skip
with centered side-label row 5 title "ЗАДОЛЖНИКИ ПО ПРЕДОСТАВЛЕНИЮ АКТОВ" frame f-dt.

update s-dtb s-dte s-closed with frame f-dt.

{r-brfilial.i &proc = "vcrepdusdat"}

run vcrepdusout.