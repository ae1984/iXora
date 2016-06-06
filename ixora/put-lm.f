/* put-lm.f
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

define shared variable raksts as character format "x(78)".
define shared variable ident  as character format "x(78)".

define shared temp-table lonwrk
              field    indekss as character
              field    lon     as character
              field    lcnt    as character.

define temp-table wrk
       field nr          as integer
       field info        as character extent 16.

define variable ident1   as character.
define variable rinda    as character.
define variable rinda1   as character.
define variable r1       as character.
define variable r2       as character.
define variable r3       as character.
define variable r4       as character.
define variable r5       as character.
define variable p1       as character.
define variable p2       as character.
define variable rez      as character.
define variable i        as integer.
define variable j        as integer.
define variable k        as integer.
define variable l        as integer.
define variable n        as integer.
define variable kreisais as logical.

define variable m1 as character init "Ошибка в описании:".
define variable m2 as character init "в строке:".
