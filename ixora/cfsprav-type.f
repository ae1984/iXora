/* cfsprav-type.f
 * MODULE
        Форма для выбора типа счета (депозит., текущ., все)
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
    t-type.id_type no-label  
    t-type.nm_type no-label format "x(20)"
with 5 down title " ТИП СЧЕТА:" overlay centered row 6 no-label frame f-type.

