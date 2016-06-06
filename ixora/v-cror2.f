/* v-cror2.f
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

/* v-cror2.f  8.06.95 */
/*BURU*/


def var vtrx as log  label "Druk–t pёc Koda/Nos." format "Kods/Nos.".
def var ku2  as char format "x(7)"  init "laiks: ".
def var ku3  as char  init "VAL®TU CROSS-RATES   uz   ".
def var ku4  as char format "x(80)"
init "        SKAIDR… naud–     BEZSKAIDR… naud–".
def var ku5  as char format "x(20)" init  "  DOKUMENTA BEIGAS  ".
def var ku6  as char format "x(20)" init  " * - TIE№… KOTЁ№ANA ".
