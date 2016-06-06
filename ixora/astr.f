/* astr.f
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
  ast.ast format "x(8)"   column-label "Nr.Карточки"  
  ast.gl format "zzzzz9"  column-label "Счет"  
  ast.fag format "xxx"    column-label "Груп."
  ast.addr[1] format "x(5)"  column-label "Ответ .!лицо "                 
  ast.attn format "x(5)"  column-label "Место!расп." 
  ast.noy format "zz9"  column-label "Срок!изн." 
  ast.ldd  column-label "Дата!расчета!амортиз"
  ast.name format "x(15)" column-label "Название  "
  WITH FRAME astr row 4 centered 
   title "ОТВЕТСТВ.ЛИЦ И МЕСТА РАСПОЛОЖ.РЕДАКТИРОВАНИЕ" scroll 1 12 down overlay.
