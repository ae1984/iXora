/* vcpartnn.p
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

/* vcedpartnn.p Валютный контроль 
   Новая запись в таблице инопартнеров

   18.10.2002 nadejda создан
*/

{vc.i}


def var v-num as integer.
def shared var s-partner like vcpartners.partner.
def shared var s-newpartner as logical.

v-num = next-value(vc-partner).

create vcpartners.
vcpartners.partner = "VC" + string(v-num, '999999').

s-partner = vcpartners.partner.
s-newpartner = true.

