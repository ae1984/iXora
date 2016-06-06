/* vccomexp.p
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание - Задолжники по коммерческим кредитам (ЭКСПОРТ)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 9.3.6.3
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        25.12.2012 damir - Внедрено Т.З. 1306.
*/

{mainhead.i}

{vccomexpvar.i "new"}

find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then s-dtb = date(vcparams.valchar). else s-dtb = 01/01/2002.

s-dte = g-today.
s-closed = yes.

form
    s-dtb    label "с" format "99/99/9999" " " skip
    s-dte    label "по" format "99/99/9999" " " skip(1)
    s-closed label "Показывать закрытые контракты" skip
with centered side-label row 5 title "Задолжники по коммерческим кредитам" frame f-dt.

update s-dtb s-dte s-closed with frame f-dt.


{r-brfilial.i &proc = "vccomexpdat"}

run vccomexpout.
