/* help-sklad2.f
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

define frame hcurr
    wcho.des format "x(35)" no-label
    wcho.amt no-label
    wcho.cost no-label
    wcho.dpr no-label
    with title "Доступные товары и материалы. Выберите из списка" 
    side-labels centered row 2 overlay 18 down.

