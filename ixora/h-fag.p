/* h-fag.p
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

/* h-fag.p
*/
{global.i}
{itemlist.i
       &file = "fagn"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = "true"
       &flddisp = "fagn.fag FORMAT ""x(5)"" LABEL ""Груп.""
                   fagn.naim FORMAT ""x(25)"" LABEL ""Название "" 
                   fagn.gl FORMAT 'zzzzz9' column-LABEL 'Счет '
                 '  '  fagn.cont FORMAT ""x(1)"" column-LABEL ""Налог.!катег.""
                   fagn.noy FORMAT 'zz9' column-LABEL ""Срок(г)!износа""
                   fagn.pednr format 'zzzzz9' column-Label 'След!номер' " 
       &chkey = "fag"
       &chtype = "string"
       &index  = "fag"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }

