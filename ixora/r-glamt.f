/* r-glamt.f
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

form ledger label "СЧЕТ" asdate label "ДАТА"
    with frame glamt no-box side-labels centered row 8.

define variable arrput as character extent 4 initial [
    "ОСТАТКИ НА СЧЕТУ# ",
    "  ЗА ",
    "ВАЛЮТА        СУММА                 СУММА (Ls)",
    "ВСЕГО"].
