/* put-dol.f
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

define input parameter fls-1 as character.
define shared variable raksts as character format "x(78)".
define shared variable ident  as character format "x(78)".

define variable rinda    as character.
define variable rinda1   as character.
define variable ata      as character.
define variable r1       as character.
define variable r2       as character.
define variable r3       as character.
define variable r4       as character.
define variable r5       as character.
define variable r6       as character.
define variable r7       as character.
define variable v-r      as character.
define variable r        as character extent 32.
define variable r0       as character extent 32.
define variable p2       as character.
define variable i        as integer.
define variable i0       as integer.
define variable j        as integer.
define variable n        as integer.
define variable n0       as integer.

define variable m1 as character init "Ошибка в описании:".
define variable m2 as character init "в строке:".

define stream s1.
