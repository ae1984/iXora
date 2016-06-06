/* pk-sub-cod.i
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

/* 
Example:
{1} = "lon"
{1} = "lonsrok"
{2} = s-lon
{3} = "03"
*/

find sub-cod where sub-cod.sub = {1} and sub-cod.d-cod = {2} and sub-cod.acc = {3} no-error .
if avail sub-cod and sub-cod.ccode = 'msc' then sub-cod.ccode = {4} .
