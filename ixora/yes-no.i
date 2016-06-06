/* yes-no.i
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
        04/10/04 sasco Добавил обработку F4 (когда choice = ?)
        22/06/06 u00568 Evgeniy - сделал функцию которая требует сделать выбор
        11/09/2006 u00568 Evgeniy -  добавил ещё одну  функцию yes-no-question
*/

function yes-no returns logical ( ctitle as char, cmess as char).
    IF cTitle <> '' THEN cTitle = '[ ' + cTitle + ' ]'.
    MESSAGE cMess VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE cTitle UPDATE choice AS LOGICAL.
    if choice = ? then choice = no.
    RETURN choice.
end.


/*в случае F4  выдаёт требует сделать выбор*/
function only_yes_or_no returns logical ( ctitle as char, cmess as char).
   def var choice as logical init ? no-undo.
   do while choice = ? :
     MESSAGE cMess
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE cTitle UPDATE choice.
     if choice = ? then
       message "Вам придется сделать выбор! <да> или <нет>" view-as alert-box title "!!!".
   end.
RETURN choice.
end.


/*в случае F4  выдаёт ?*/
function yes-no-question returns logical ( ctitle as char, cmess as char).
IF cTitle <> '' THEN cTitle = '[ ' + cTitle + ' ]'.
    MESSAGE cMess VIEW-AS ALERT-BOX MESSAGE BUTTONS YES-NO TITLE cTitle UPDATE choice AS LOGICAL.
RETURN choice.
end.
