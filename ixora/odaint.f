/* odaint.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
	20.03.2006 u00121 - исправлен column-label из-за ошибки в работе shared library (SYSTEM ERROR: Memory violation. (49)), исправлено по рекемендации ProKb (KB-P25563: Error 49 running a 4GL procedure, stack trace shows umLitGetFmtStr)
*/

form
aaa.aaa column-label "ODA СЧЕТ "
b-aaa.aaa column-label "DDA СЧЕТ "
vmtdacc column-label "ОСТАТОК.!ЗА МЕСЯЦ"
vrate column-label "ПРОЦЕНТ.!СТАВКА"
s-int column-label "РАССЧИТ.!ПРОЦЕНТ.СУММА"
s-amt column-label "УДЕРЖАН.!ПРОЦЕНТ.СУММА"
s-jh column-label "ТРН #" format "zzzzzzzz"
header
"РАСЧЕТ ПРОЦЕНТОВ И УДЕРЖАНИЕ ЗА  " at 20
substring( string(g-today),4) skip(2)
with width 130.
