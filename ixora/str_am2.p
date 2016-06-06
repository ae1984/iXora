/* str_am2.p
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
        07.03.2012 damir - перекомпиляция в связи с изменением st_if2.i
*/

/* ================= account mode =========================================== */

define variable mode 		as character initial "a".
define variable in_format 	as character initial "1".
define variable out_file 	as character initial "rpt.img".
define variable out_com         as character initial ?.

{st_if2.i}
