/* swmt950.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        формирование выписки по лоро счетам формата МТ950
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
 * BASES
        BANK COMM
 * AUTHOR

 * CHANGES
            18/04/2012 Luiza

*/

/* ================= account mode =========================================== */

define variable mode 		as character initial "a".
define variable in_format 	as character initial "1".
define variable out_file 	as character initial "swmt950.img".
define variable out_com     as character initial ?.

{swmt950.i}
