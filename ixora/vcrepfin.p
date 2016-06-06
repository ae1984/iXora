/* vcrepfin.p
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
{mainhead.i}
{vcrepfinvar.i "new"}

form
    v-dt format "99/99/9999" label "Дата отчета"
with centered row 5 side-labels title "ВВЕДИТЕ" frame vcrepfin.

set v-dt with frame vcrepfin.

{r-brfilial.i &proc = "vcrepfindat"}

run vcrepfinout.