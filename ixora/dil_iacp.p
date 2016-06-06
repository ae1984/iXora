/* dil_iacp.p
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{lgps.i new}

def input parameter dnum as char.

find first dealing_doc where DocNo = dnum exclusive-lock.
run connib.

run IBrej_ps(8, 0, "", "EXC" + DocNo).
if connected("ib") then disconnect "ib".
v-text = " Заявка No" + DocNo + " исполнена.".
run lgps.
