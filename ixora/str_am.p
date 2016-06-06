/* str_am.p
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
 * BASES
        BANK COMM
 * CHANGES
        28.03.2012 damir - перекомпиляция в связи с изменением st_if.i.
        31.08.2012 damir - перекомпиляция в связи с изменением st_chkcif.i.
*/

/* ================= account mode =========================================== */

define variable mode            as character initial "a".
define variable in_format       as character initial "1".
define variable out_file        as character initial "rpt.img".
define variable out_com         as character initial ?.

{st_if.i}

