/* v-crcard.p
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

/* v-crcard.p */
{global.i}
def shared var vcrdt like crcard.crcard.
def var a1 like crcard.crcard.
def var a2 like crcard.crdt.
def var vrem as char format "x(30)".

{v-crcard.f}

find crcard where crcard.crcard = vcrdt no-error.

find crdtstn where crdtstn.crdtstn = crcard.crdtstn no-error.
vrem = crdtstn.des.
disp crcard.crcard crcard.crdt  crcard.lname
     crcard.mname  crcard.fname crcard.relation
     crcard.expdt vrem with frame crcdac.
