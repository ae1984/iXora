/* bookref.f
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

form
    bookref.bookcod     label "КОД СПРАВ"
    bookref.bookname    label "НАИМЕНОВАНИЕ СПРАВОЧНИКА" format "x(46)"
    bookref.regdt       label "ДАТА РЕГИСТР"
    bookref.regwho      label "ОФИЦЕР"
with 13 down title "ОБЩИЕ СПРАВОЧНИКИ" overlay centered row 3 frame bookref.
