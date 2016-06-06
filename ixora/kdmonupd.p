/* kdmonupd.p
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Редактирование
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        kdmonnew
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01.03.05 marinav
 * CHANGES
*/


{global.i}
{kd.i}

define new shared variable s-newrec as logical.
s-newrec = true.
run kdmonnew.