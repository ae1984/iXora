/* help-push.f
 * MODULE
        PUSH-отчеты
 * DESCRIPTION
        Формы для различных выборов (помощь по F2)
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
        25/07/05 sasco
 * CHANGES
*/

define frame hid 
    b-pushrep.id at 6 no-label
    b-pushrep.des no-label
    with title "Перечень PUSH отчетов, F4 - отмена"
    side-labels centered row 2 overlay 10 down.

