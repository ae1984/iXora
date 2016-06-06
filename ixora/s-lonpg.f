/* s-lonpg.f
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

/*---------------------------
  #3.Koment–ri
---------------------------*/
define variable ko as character format "x(10)" extent 5 init [
       "Осн.сумма",
       "Проценты",
       "Замечания",
       "Прочие",
       "Выход"].
define variable i as integer.

form
    ko
    with no-label 1 down row 15 overlay 1 columns column 1 frame ko.

define shared variable s-lon like lon.lon.
