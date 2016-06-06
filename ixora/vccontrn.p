/* vccontrn.p
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

/* vccontrn.p Валютный контроль
   Новая запись в таблице контрактов 
   
   18.10.2002 nadejda создан
*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-newcontract as logical.

create vccontrs.
vccontrs.contract = next-value(vc-contract).

s-contract = vccontrs.contract.
s-newcontract = true.


