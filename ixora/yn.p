/* yn.p
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
    yn.p
    ИТЯ...
    Пропер С.В.
*/
DEFINE INPUT  PARAMETER cTitle  AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-1 AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-2 AS CHARACTER.
DEFINE INPUT  PARAMETER cMess-3 AS CHARACTER.
DEFINE OUTPUT PARAMETER lYes    AS LOG INIT no.

/*
def var ctitle as char init 'asd'.
def var cmess-1 as cha init ''.
def var cmess-2 as cha init 'asdasdasd'.
def var cmess-3 as cha init ''.
def var lyes as log init no.
*/

IF cTitle <> '' THEN cTitle = '[ ' + cTitle + ' ]'.
REPEAT:
    MESSAGE 
    ' ' cMess-1 SKIP
    ' ' cMess-2 SKIP
    ' ' cMess-3 SKIP
    VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO
    TITLE cTitle UPDATE choice AS LOGICAL.
    CASE choice:
         WHEN TRUE  THEN lYes = yes.
         WHEN FALSE THEN lYes = no.
         OTHERWISE DO:
            lYes = no.
            NEXT.
         END.
    END CASE.
    LEAVE.
END.
    
RETURN.
/***/


