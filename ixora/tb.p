/* tb.p
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
*/

/*
    12.04.2000
    tb.p
    ИТЯ...
    Пропер С.В.
*/
               
DEFINE INPUT  PARAMETER cTitle  AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-1 AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-2 AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-3 AS CHARACTER.

    IF cTitle <> '' THEN cTitle = '[ ' + cTitle + ' ]'.
    MESSAGE 
    ' ' cMess-1 SKIP
    ' ' cMess-2 SKIP
    ' ' cMess-3 SKIP
    VIEW-AS ALERT-BOX 
    TITLE cTitle.

RETURN.  
/***/


