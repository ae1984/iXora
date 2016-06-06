/* str_iz.p
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

/* ================= account mode =========================================== */

define variable mode                 as character initial "i".
define variable in_format         as character initial "dft".
define variable out_file         as character initial "rpt.img".
define variable out_com         as character initial ?.

{st_if.i}
