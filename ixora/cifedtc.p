/* cifedtc.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       13/02/2011 dmitriy - перекомпиляция
*/

/* cifedtc.p
 * Модуль
     Клиентская база
 * Назначение
     Ввод и редактирование данных КОДИРОВАННЫХ клиента, открытие счетов
 * Применение
     только старшие менеджеры
 * Вызов
     главное меню
 * Меню
     1.4

 * Автор
     ...
 * Дата создания:
     ...
 * Изменения

*/

def temp-table wcif like cif.
{mainhead.i CFENTE}

{sixn.i
 &head = cif
 &post = cod
 &headkey = cif
 &option = CIF
 &numsys = auto
 &numprg = xxx
 &keytype = string
 &nmbrcode = CIF
 &postfind = "
 if cif.type NE ""X"" then do:
       message ""КЛИЕНТ НЕ КОДИРОВАННЫЙ!!!"".
       bell.
       undo, retry.
       end."
 &subprg = s-cifcod
 &postadd = "
 cif.regdt = g-today.
 cif.who = g-ofc.
 cif.whn = g-today.
 cif.tim = time.
 cif.ofc = g-ofc."
}


