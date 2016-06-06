/* rep1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по депозитам физических лиц
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.3.1.15.13
 * BASES
        BANK COMM
 * AUTHOR
        23/01/2006 dpuchkov
 * CHANGES
*/




{global.i}
def new shared var vn-dt as date.
def new shared var vn-dtbeg as date.



update vn-dtbeg label "C "  vn-dt label "по"  with side-labels centered row 9.
display "Ждите идет формирование отчетов..."  with row 10 frame ww centered.
 {r-branch.i &proc = "bigdepnext"}


