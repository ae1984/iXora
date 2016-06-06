/* cfsprav-lang.f
 * MODULE
        Форма выбора языка для справки
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
        26/09/2006 u00777
 * CHANGES
*/

form 
    t-lang.id_lang no-label  
    t-lang.nm_lang no-label format "x(20)"
with 5 down title " ВЫБЕРИТЕ ЯЗЫК:" overlay centered row 6 no-label frame f-lang.

