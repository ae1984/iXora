/* pknlvar.i
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
        21/02/2008 madiyar - s-menu extent 13
*/

def {1} shared var v-kolmenu as integer init 13.
define {1} shared variable s-main as character.
define {1} shared variable s-opt as character.
define {1} shared variable s-sign as character format "x" extent 2.
define {1} shared variable s-menu as character format "x(7)" extent 13.
define {1} shared variable s-page as integer.
define {1} shared variable s-noedt as logical.
define {1} shared variable s-nodel as logical.
{2}
