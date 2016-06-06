/* m_sprav.p
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
        08/05/2012 dmitriy - Ширина поля "Номер счета" = 20 символов
*/

/***  m_level.p  ***/


define variable subledger as character.
define variable account   as character format "x(20)".

define frame f_subl
    subledger label "Тип счета"
    account   label "Номер счета"
    with centered row 1 side-labels.


on help of subledger in frame f_subl do:
    run help-subled.
end.

repeat on endkey undo, return:
    update subledger account with frame f_subl.
    run subcod (input account, input subledger).
end.
