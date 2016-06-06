/* LCmenuvar.i
 * MODULE
        Trade Finance
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
        09/09/2010 galina - скопировала из menuvar.i с изменениями
 * BASES
        BANK COMM
 * CHANGES
    21/01/2011 id00810 - s-menu extent 13
*/

/* menuvar.i Janet */
define {1} shared variable s-main as character.
define {1} shared variable s-opt as character.
define {1} shared variable s-sign as character format "x" extent 2.
define {1} shared variable s-menu as character format "x(7)" extent 13.
define {1} shared variable s-page as integer.
define {1} shared variable s-hideone as logical.
define {1} shared variable s-hidetwo as logical.
{2}
