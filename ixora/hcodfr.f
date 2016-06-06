/* hcodfr.f
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

/* hcodfr.f */

form
    codfr.code label "КОД"
    codfr.name[1]label "НАИМЕНОВАНИЕ"
    with overlay frame hcodfr  row 11 6 down  centered
          title "Выбирите код филиала и нажмите клавишу.<ENTER>" .

