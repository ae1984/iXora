/* cfsprav.f
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

/* cfsprav.f
   Форма вывода для списка документов

   25.03.2003 nadejda
*/

form 
    t-docs.choice no-label format "x"
    t-docs.name no-label format "x(76)"
with 12 down title " ОТМЕТЬТЕ НУЖНЫЕ СПРАВКИ " overlay centered row 6 no-label frame f-docs.
