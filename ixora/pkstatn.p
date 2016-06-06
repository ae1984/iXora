/* pkstatn.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Проставление классификации по экспресс-кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        22/07/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def var ja as logical no-undo.
ja = no.
message " Принять классификацию ?" update ja.
if not ja then return.

{r-branch.i &proc = "pkstatn2"}

