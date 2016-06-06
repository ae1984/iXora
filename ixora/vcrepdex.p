/* vcrepdex.p
 * MODULE
        Название Модуля - Валютный контроль
 * DESCRIPTION
        Описание - Задолжники - консигнация (экспорт) на дату
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
        13.11.2002 nadejda
 * BASES
        BANK COMM
 * CHANGES
	    24.05.2003 nadejda - убраны параметры -H -S из коннекта
	    31.07.2003 nadejda - добавлено поле sumdolg для совместимости
        18.05.2004 nadejda - добавлены поля РНН и ОКПО клиента
        04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        09/11/2010 madiyar - убрал -H,-S
        09/02/2011 damir - добавил cardnum - номер ЛКБК, carddt - дата ЛКБК.
        10/02/2011 damir - добавил ctterm - сроки репатриации
        16.02.2011 damir - vcrepdexdat передается только тип 1 паспорт сделки.
        17.02.2011 damir - Добавлено field srokrep as decimal
        23.02.2011 damir - произвожу разбранчевку r-brfilial.i &proc = " vcrepdexdat (input txb.bank, 0, v-dtb, v-dte, v-closed, '1') "
        25,02,2011 damir - добавил field namefil as char
        31.03.2011 damir - небольшие корректировки.
        25.12.2012 damir - Внедрено Т.З. 1306. Оптимизация кода.
*/
{mainhead.i}

{vcrepdexvar.i "new"}

find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then s-dtb = date(vcparams.valchar). else s-dtb = 01/01/2002.
s-dte = g-today.

form
    skip(1)
    s-dtb    label "         Контракты после " format "99/99/9999" " " skip
    s-dte    label " Отчетная дата (не вкл.) " format "99/99/9999" " " skip(1)
    s-closed label " Показывать закрытые контракты " skip(1)
with centered side-label row 5 title "Задолжники по консигнации" frame f-dt.

update s-dtb s-dte s-closed with frame f-dt.

{r-brfilial.i &proc = "vcrepdexdat"}

run vcrepdexout.








