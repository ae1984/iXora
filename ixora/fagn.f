/* fagn.f
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

/* 11/04/96 FORM LIKE file fagn */

FORM
fagn.fag FORMAT "x(3)" COLUMN-LABEL "!Гру!ппа"
fagn.naim FORMAT "x(25)"COLUMN-LABEL "!Название!"
fagn.gl FORMAT "zzzzz9" COLUMN-LABEL "Счет!гл.!книги" space(2)
fagn.ser FORMAT "x(7)" COLUMN-LABEL "Код!линейн.!износа"
fagn.noy FORMAT "zz9" COLUMN-LABEL "Срок!износа!(года )" space(3)
fagn.cont FORMAT "x(1)"COLUMN-LABEL "Катег.!налог.!аморт."
fagn.ref FORMAT "x(5)" COLUMN-LABEL "Нал.и!став-!ка(%)"
fagn.pkop format "x(1)" column-label "!!!"
/*help "1 - Nemateri–lie ieguldЁjumi, 2 -Pamatlidzekli 3 -Nepabeigto celt.obl.izm."
*/
 WITH FRAME fagn row 4 centered title 
 "ВВОД И РЕДАКТИРОВАНИЕ ГРУПП ОСНОВНЫХ СРЕДСТВ" scroll 1 12 down overlay.

